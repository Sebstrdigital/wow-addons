local ADDON, ns = ...

-- ------------------------------------------------------------------
-- Sign-up boards
-- ------------------------------------------------------------------
-- Two guild sign-up boards with identical mechanics and different scope:
--
--   "monday"  the next Mythic Monday, scoped to one date
--   "open"    "I am online and want to run keys right now"
--
-- They are fully independent - you can hold a slot in a Monday group and an
-- open group at the same time - so everything below is keyed by event id. The
-- module keeps the Monday.lua / ns.Monday name from v1.3.0 to limit churn.
--
-- There is no server. Two rules keep the guild's clients converging:
--
--   * Each client is the only writer of its own entry. Peers cache what they
--     hear and merge by timestamp, highest wins.
--   * Groups are leader-authoritative. Only the leader's client edits its
--     roster; join and leave are whispered *requests* the leader answers.
--
-- A request is therefore answered with our own state only, never with our
-- cache of everyone else's - otherwise thirty people logging in at raid time
-- would each rebroadcast thirty entries.
--
-- Protocol (prefix GPMM2, space-separated fields, "-" means nil). Every
-- message carries the board's *wire key* as its second field: "M2026-09-14"
-- for a Monday board, the literal "open" for the open board. A wire key that
-- does not map to a live board - last week's Monday, a future version's
-- invention - is dropped rather than guessed at.
--
--   R ev                                          request  (GUILD)
--   E ev ts role intent bracket mapID level leader own entry (GUILD)
--   X ev                                          withdraw (GUILD)
--   G ev ts mapID level name:R,name:R,...         roster   (GUILD, leader)
--   D ev                                          disband  (GUILD, leader)
--   J ev                                          join req (WHISPER to leader)
--   L ev                                          leave    (WHISPER to leader)
--   N ev reason                                   denied   (WHISPER to joiner)
--
-- Bump the prefix to GPMM3 on any breaking change to those fields.

ns.Monday = ns.Monday or {}
local M = ns.Monday

local PREFIX = "GPMM2"
local MAX_BYTES = 255           -- hard addon-message payload limit
local REFRESH_THROTTLE = 60     -- seconds between outbound R broadcasts, per board
local ROSTER_CACHE = 20         -- seconds an online/offline roster scan is reused
local REPLY_JITTER = 2          -- seconds; spreads replies to a broadcast R
local KEY_DEBOUNCE = 2          -- seconds after the last BAG_UPDATE_DELAYED
local OPEN_STALE = 15 * 60      -- an open-board record older than this is gone
local OPEN_HEARTBEAT = 5 * 60   -- how often we prove we are still here
local POST_THROTTLE = 60        -- seconds between guild-chat posts, per board
local MAX_CHAT = 255            -- SendChatMessage's payload limit
local SLOTS = { T = 1, H = 1, D = 3 }
local ROLE_ORDER = { T = 1, H = 2, D = 3 }
local ROLE_WORD = { T = "Tank", H = "Healer", D = "DPS" }
local BRACKET_ORDER = { low = 1, mid = 2, high = 3, any = 4 }

local EVENTS = { "monday", "open" }
local EVENT_TITLE = { monday = "Mythic Monday", open = "Open groups" }
M.EVENTS = EVENTS

local WEEKDAY_ABBR = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local MONTH_ABBR = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local function Say(line)
    print("|cff69ccf0Guild boards:|r " .. line)
end

local function Warn(line)
    print("|cffff4040Guild boards:|r " .. line)
end

function M.EventTitle(ev)
    return EVENT_TITLE[ev]
end

local function IsEvent(ev)
    return EVENT_TITLE[ev] ~= nil
end

-- ------------------------------------------------------------------
-- State
-- ------------------------------------------------------------------

-- boards[ev] = { key, me, entries, groups }
--
-- board.entries[myName] is deliberately the *same table* as board.me, so a
-- change to our own sign-up cannot drift out of sync with what the aggregate
-- views show. SavedVariables round-trips them as two tables, so EnsureSelf
-- re-links them after a load.
local boards = {}

local callbacks = {}
local outQueue = {}             -- sends deferred while inside a challenge mode
local pendingJoin = {}          -- ev -> leader we have an unanswered J out to
local lastRefresh = {}          -- ev -> when we last broadcast an R
local lastPost = {}             -- ev -> when we last posted to guild chat
local myKey = nil               -- { mapID, level, name } or nil
local keyTimer = nil            -- debounce guard for BAG_UPDATE_DELAYED
local heartbeat = nil           -- C_Timer ticker for the open board
local rosterOnline, rosterAt = nil, 0
local summaryPrinted = false

-- ------------------------------------------------------------------
-- Small helpers
-- ------------------------------------------------------------------

local function Now()
    -- Server epoch, so timestamps from different clients are comparable.
    if GetServerTime then return GetServerTime() end
    return time()
end

local function Split(s, sep)
    local out = {}
    for piece in string.gmatch(s or "", "([^" .. sep .. "]+)") do
        out[#out + 1] = piece
    end
    return out
end

-- "-" is the wire's nil. Real names never collapse to a bare dash, because
-- they always carry a realm suffix.
local function Unwire(v)
    if v == nil or v == "-" then return nil end
    return v
end

local function Wire(v)
    if v == nil or v == "" then return "-" end
    return tostring(v)
end

local function MyName()
    if not UnitName or not GetNormalizedRealmName then return nil end
    local name = UnitName("player")
    local realm = GetNormalizedRealmName()
    if not name or not realm or realm == "" then return nil end
    return name .. "-" .. realm
end

-- The board's own sender normaliser, deliberately not ns.MdtSenderKey.
--
-- That one round-trips through UnitFullName, which takes a *unit* and only
-- resolves players the client has loaded - your party, your target, someone in
-- your zone. MDT gets away with it because its comms are party-scoped. Ours
-- are guild-scoped, and a guildie questing three zones away is exactly who we
-- need to hear from, so anything unit-based would silently drop most of the
-- board. CHAT_MSG_ADDON already hands us the realm, so no lookup is needed.
local function SenderKey(raw)
    if not raw or raw == "" then return nil end
    if raw:find("-", 1, true) then return raw end
    -- A sender with no realm suffix can only be from our own realm.
    if not GetNormalizedRealmName then return nil end
    local realm = GetNormalizedRealmName()
    if not realm or realm == "" then return nil end
    return raw .. "-" .. realm
end

local function InChallenge()
    return not not (C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive
        and C_ChallengeMode.IsChallengeModeActive())
end

-- Secret Values: inside an active key some getters hand back an opaque value
-- that errors on use. Test before touching, never after.
local function IsSecret(v)
    return v ~= nil and issecretvalue ~= nil and issecretvalue(v) == true
end

local function KeyName(mapID)
    if not mapID then return nil end
    if not C_ChallengeMode or not C_ChallengeMode.GetMapUIInfo then return nil end
    local name = C_ChallengeMode.GetMapUIInfo(mapID)
    if IsSecret(name) then return nil end
    return name
end

function M.RegisterCallback(fn)
    if type(fn) ~= "function" then return end
    callbacks[#callbacks + 1] = fn
end

-- Callbacks are told *which* board changed, so a UI showing one page can
-- ignore traffic on the other.
local function Fire(ev)
    for i = 1, #callbacks do
        ns.safecall(callbacks[i], ev)
    end
end

-- ------------------------------------------------------------------
-- Target Monday and wire keys
-- ------------------------------------------------------------------
-- The Monday board is scoped to one date and clears itself when that date
-- passes: its wire key carries the date, and a message or saved table with any
-- other key is dropped rather than merged. The open board never expires as a
-- whole - its individual records age out instead.

local function TargetEpoch()
    local wday, y, mo, d
    local cal = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime
        and C_DateAndTime.GetCurrentCalendarTime()
    if cal and cal.weekday and cal.year and cal.month and cal.monthDay then
        -- Calendar time is server time, which is what the guild agrees on.
        wday, y, mo, d = cal.weekday, cal.year, cal.month, cal.monthDay
    else
        -- Only reachable if the calendar API is missing; local time still
        -- lands on the right Monday for everyone in the same region.
        local t = date("*t")
        wday, y, mo, d = t.wday, t.year, t.month, t.day
    end
    -- weekday/wday are both 1 = Sunday .. 7 = Saturday, so Monday is 2.
    -- Today counts as "next Monday" when today *is* Monday.
    local daysAhead = (2 - wday) % 7
    -- Noon, so a daylight-saving jump cannot push the result onto the day before.
    local base = time({ year = y, month = mo, day = d, hour = 12, min = 0, sec = 0 })
    return base + daysAhead * 86400
end

function M.TargetDate()
    local t = date("*t", TargetEpoch())
    return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end

-- "Mon 14 Sep". Built from our own tables rather than date("%a %d %b") so the
-- string does not change shape with the client's locale.
function M.TargetLabel()
    local t = date("*t", TargetEpoch())
    return string.format("%s %d %s", WEEKDAY_ABBR[t.wday] or "?", t.day,
        MONTH_ABBR[t.month] or "?")
end

local function WireKey(ev)
    if ev == "monday" then return "M" .. M.TargetDate() end
    if ev == "open" then return "open" end
    return nil
end
M.WireKey = WireKey

-- Wire key -> event id. Returns nil for last week's Monday, for a key a newer
-- version invented, and for anything malformed. Callers drop the message.
local function EventFromWire(key)
    if not key then return nil end
    if key == "open" then return "open" end
    if key == WireKey("monday") then return "monday" end
    return nil
end
M.EventFromWire = EventFromWire

-- ------------------------------------------------------------------
-- Boards
-- ------------------------------------------------------------------

local function FreshBoard(ev)
    return { key = WireKey(ev), me = nil, entries = {}, groups = {} }
end

local function Persist()
    GuildPlaybookDB = GuildPlaybookDB or {}
    local out = {}
    for _, ev in ipairs(EVENTS) do
        local b = boards[ev]
        if b then
            out[ev] = { key = b.key, me = b.me, entries = b.entries, groups = b.groups }
        end
    end
    GuildPlaybookDB.monday = { boards = out }
end

-- An open-board record we have not heard from in a quarter of an hour is
-- assumed logged out. Our own record is exempt: we plainly are here, and the
-- heartbeat that would refresh it may not have ticked yet.
local function IsStale(ev, seen, name, me)
    if ev ~= "open" then return false end
    if name and me and name == me then return false end
    return not seen or (Now() - seen) > OPEN_STALE
end

-- Returns changed, rosterChanged. The second flag means our *own* roster lost
-- a member, which peers have to be told about; PruneOpen cannot send anything
-- itself because it is defined above the senders.
local function PruneOpen()
    local b = boards.open
    if not b then return false, false end
    local me = MyName()
    local changed, rosterChanged = false, false
    for name, e in pairs(b.entries) do
        if IsStale("open", e.seen, name, me) then
            b.entries[name] = nil
            changed = true
        end
    end
    for leader, g in pairs(b.groups) do
        if IsStale("open", g.seen, leader, me) then
            b.groups[leader] = nil
            changed = true
        end
    end

    -- Our own roster is ours alone to correct, so a member who logged off
    -- without withdrawing would hold their slot for ever: they drop out of the
    -- pool after fifteen minutes but stay on the roster, and HasFreeSlot goes
    -- on counting them, so every later applicant is told the group is full.
    local own = me and b.groups[me]
    if own and own.members then
        for name in pairs(own.members) do
            local e = b.entries[name]
            -- No entry left means the loop above just pruned it. Accepting a
            -- join always files one, so a member without an entry is stale too.
            if name ~= me and (not e or IsStale("open", e.seen, name, me)) then
                own.members[name] = nil
                changed, rosterChanged = true, true
            end
        end
        if rosterChanged then own.ts = Now() end
    end
    return changed, rosterChanged
end

-- Called before anything reads or writes a board. Handles the Tuesday
-- rollover for a client that never logged out.
local function EnsureCurrent(ev)
    local b = boards[ev]
    local want = WireKey(ev)
    if not b or b.key ~= want then
        boards[ev] = FreshBoard(ev)
        pendingJoin[ev] = nil
        Persist()
        return true
    end
    return false
end

-- Re-links board.me and board.entries[me] after a SavedVariables load, which
-- is the one place they arrive as separate tables.
local function EnsureSelf(ev)
    local me = MyName()
    local b = boards[ev]
    if not me or not b or not b.me then return me end
    if b.entries[me] ~= b.me then
        b.me.seen = Now()
        b.entries[me] = b.me
    end
    return me
end

local function LoadSaved()
    GuildPlaybookDB = GuildPlaybookDB or {}
    local saved = GuildPlaybookDB.monday
    -- v1.3.0 stored one flat board here and was never released, so there is
    -- nothing to migrate: anything without `boards` is thrown away.
    local savedBoards = nil
    if type(saved) == "table" and type(saved.boards) == "table" then
        savedBoards = saved.boards
    end
    for _, ev in ipairs(EVENTS) do
        local want = WireKey(ev)
        local s = savedBoards and savedBoards[ev]
        if type(s) == "table" and s.key == want then
            boards[ev] = {
                key = want,
                me = type(s.me) == "table" and s.me or nil,
                entries = type(s.entries) == "table" and s.entries or {},
                groups = type(s.groups) == "table" and s.groups or {},
            }
        else
            boards[ev] = FreshBoard(ev)
        end
    end
    PruneOpen()
    Persist()
end

-- ------------------------------------------------------------------
-- Sending
-- ------------------------------------------------------------------

local function Dispatch(text, chattype, target)
    if ChatThrottleLib then
        ChatThrottleLib:SendAddonMessage("NORMAL", PREFIX, text, chattype, target)
    elseif C_ChatInfo and C_ChatInfo.SendAddonMessage then
        -- No throttle library means the 10-burst cap is ours to lose. Better
        -- a dropped message than no board at all.
        C_ChatInfo.SendAddonMessage(PREFIX, text, chattype, target)
    else
        Warn("no way to send addon messages - the boards cannot sync.")
    end
end

local function Send(text, chattype, target)
    if not IsInGuild or not IsInGuild() then return end
    if #text > MAX_BYTES then
        Warn(("dropped an oversized %s message (%d bytes)."):format(
            text:sub(1, 1), #text))
        return
    end
    if InChallenge() then
        -- Secret Values forbid comms inside an active key. Hold, do not drop.
        outQueue[#outQueue + 1] = { text, chattype, target }
        return
    end
    Dispatch(text, chattype, target)
end

local function FlushQueue()
    if InChallenge() then return end
    if #outQueue == 0 then return end
    local queued = outQueue
    outQueue = {}
    for i = 1, #queued do
        local m = queued[i]
        -- A run that straddled midnight into Tuesday leaves messages for a
        -- board that no longer exists; every receiver would drop them anyway.
        if EventFromWire(m[1]:match("^%S+%s+(%S+)")) then
            Dispatch(m[1], m[2], m[3])
        end
    end
end

local function IsLeading(ev)
    local me = MyName()
    local b = boards[ev]
    return me ~= nil and b ~= nil and b.groups[me] ~= nil
end

local function SendEntry(ev)
    local b = boards[ev]
    local e = b and b.me
    if not e then return end
    Send(table.concat({
        "E", b.key, tostring(e.ts or Now()), Wire(e.role),
        Wire(e.intent), Wire(e.bracket), Wire(e.mapID), Wire(e.level),
        Wire(e.leader),
    }, " "), "GUILD")
end

local function SerializeMembers(g, leader)
    -- Leader first, then alphabetical, so two clients rendering the same
    -- roster from the same message agree on the order.
    local names = {}
    for name in pairs(g.members or {}) do
        if name ~= leader then names[#names + 1] = name end
    end
    table.sort(names)
    if g.members and g.members[leader] then table.insert(names, 1, leader) end
    local parts = {}
    for i = 1, #names do
        parts[i] = names[i] .. ":" .. tostring(g.members[names[i]])
    end
    return table.concat(parts, ",")
end

local function SendGroup(ev)
    local me = MyName()
    local b = boards[ev]
    local g = me and b and b.groups[me]
    if not g then return end
    local head = table.concat({
        "G", b.key, tostring(g.ts or Now()), Wire(g.mapID), Wire(g.level),
    }, " ")
    local body = SerializeMembers(g, me)
    -- Five members of plausible name length fit inside 255 with room to spare;
    -- this only bites on pathological realm names, and losing the tail of the
    -- roster silently would look like members randomly vanishing.
    if #head + 1 + #body > MAX_BYTES then
        Warn("your group roster is too long to broadcast - some members were left out.")
        -- Drop trailing members while there is still a comma to cut at. The
        -- comma test is what bounds this: without it, a single member too long
        -- to fit leaves gsub matching nothing and the loop spinning forever.
        while body:find(",", 1, true) and #head + 1 + #body > MAX_BYTES do
            body = body:gsub(",[^,]*$", "")
        end
        if #head + 1 + #body > MAX_BYTES then
            -- Not even one member fits. Send the group with an empty roster
            -- rather than nothing, so peers still see it exists.
            body = ""
        end
    end
    Send(head .. " " .. (body ~= "" and body or "-"), "GUILD")
end

local function SendWithdraw(ev)
    Send("X " .. WireKey(ev), "GUILD")
end

local function SendDisband(ev)
    Send("D " .. WireKey(ev), "GUILD")
end

local function SendJoinRequest(ev, leader)
    Send("J " .. WireKey(ev), "WHISPER", leader)
end

local function SendLeaveRequest(ev, leader)
    Send("L " .. WireKey(ev), "WHISPER", leader)
end

local function SendDeny(ev, target, reason)
    Send("N " .. WireKey(ev) .. " " .. reason, "WHISPER", target)
end

-- Prune the open board and tell the guild if our own roster changed. Every
-- caller that is allowed to talk to the guild goes through this; LoadSaved
-- calls PruneOpen directly, because nothing may be sent that early.
local function PruneOpenAndSync()
    local changed, rosterChanged = PruneOpen()
    if not changed then return false end
    Persist()
    if rosterChanged then SendGroup("open") end
    Fire("open")
    return true
end

-- ------------------------------------------------------------------
-- Open-board heartbeat
-- ------------------------------------------------------------------
-- The open board has no date to expire on, so presence is proved rather than
-- assumed: while signed up we re-announce every five minutes, and everyone
-- else drops records they have not heard from in fifteen.

local function StopHeartbeat()
    if not heartbeat then return end
    if heartbeat.Cancel then heartbeat:Cancel() end
    heartbeat = nil
end

local function StartHeartbeat()
    if heartbeat then return end
    if not C_Timer or not C_Timer.NewTicker then return end
    heartbeat = C_Timer.NewTicker(OPEN_HEARTBEAT, function()
        ns.safecall(function()
            local b = boards.open
            if not b or not b.me then
                StopHeartbeat()
                return
            end
            -- Skip the beat rather than queue it: a heartbeat delivered after
            -- the dungeon says nothing useful about when we were last here.
            if InChallenge() then return end
            b.me.ts = Now()
            b.me.seen = Now()
            -- Prune before broadcasting, or the roster we send this beat still
            -- carries the ghost and only self-corrects on the next one.
            local changed = PruneOpen()
            SendEntry("open")
            if IsLeading("open") then SendGroup("open") end
            if changed then Persist() end
            Fire("open")
        end)
    end)
end

-- ------------------------------------------------------------------
-- Own keystone
-- ------------------------------------------------------------------

local function ReadKeystone()
    -- Never read inside an active key: that is exactly where the getters are
    -- allowed to hand back secret values.
    if InChallenge() then return false end
    if not C_MythicPlus or not C_MythicPlus.GetOwnedKeystoneChallengeMapID then
        return false
    end
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local level = C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel()
    if IsSecret(mapID) or IsSecret(level) then
        mapID, level = nil, nil
    end
    if mapID == 0 or (level ~= nil and level == 0) then
        mapID, level = nil, nil
    end

    local prevMap = myKey and myKey.mapID
    local prevLevel = myKey and myKey.level
    if mapID and level then
        myKey = { mapID = mapID, level = level, name = KeyName(mapID) }
    else
        myKey = nil
    end
    if prevMap == (myKey and myKey.mapID) and prevLevel == (myKey and myKey.level) then
        return false
    end

    -- The key belongs to the character, not to one board, so every board we
    -- are signed up on has to hear about it.
    local me = MyName()
    local touched = false
    for _, ev in ipairs(EVENTS) do
        local b = boards[ev]
        if b and b.me then
            b.me.mapID = myKey and myKey.mapID
            b.me.level = myKey and myKey.level
            b.me.ts = Now()
            local g = me and b.groups[me]
            if g then
                g.mapID = b.me.mapID
                g.level = b.me.level
                g.ts = Now()
            end
            SendEntry(ev)
            if g then SendGroup(ev) end
            touched = true
        end
    end
    if touched then Persist() end
    -- Both pages show your own key whether or not you are signed up there, so
    -- both redraw regardless of which boards actually changed.
    for _, ev in ipairs(EVENTS) do
        Fire(ev)
    end
    return true
end

function M.MyKey()
    return myKey
end

function M.MyRole()
    -- Deliberately the spec role, not ns.role: ns.role follows the group's
    -- assigned role and can be overridden with /gp tank for reading tactics,
    -- neither of which should decide which slot you take.
    local spec = GetSpecialization and GetSpecialization()
    local role = spec and GetSpecializationRole and GetSpecializationRole(spec)
    if role == "TANK" then return "T" end
    if role == "HEALER" then return "H" end
    return "D"
end

-- ------------------------------------------------------------------
-- Group bookkeeping (leader side)
-- ------------------------------------------------------------------

local function CountRoles(g)
    local counts = { T = 0, H = 0, D = 0 }
    for _, role in pairs(g.members or {}) do
        if counts[role] then counts[role] = counts[role] + 1 end
    end
    return counts
end

local function HasFreeSlot(g, role)
    local counts = CountRoles(g)
    return (counts[role] or 0) < (SLOTS[role] or 0)
end

local function FullFromCounts(counts)
    return counts.T >= SLOTS.T and counts.H >= SLOTS.H and counts.D >= SLOTS.D
end

local function GroupIsFull(g)
    return FullFromCounts(CountRoles(g))
end

-- Clears the `leader` field on every cached entry pointing at a group that no
-- longer holds them, so the pool view picks them back up.
local function ClearLeader(ev, leader, keep)
    local b = boards[ev]
    if not b then return end
    for name, e in pairs(b.entries) do
        if e.leader == leader and not (keep and keep[name]) then
            e.leader = nil
        end
    end
end

local function DisbandOwnGroup(ev)
    local me = MyName()
    local b = boards[ev]
    if not me or not b or not b.groups[me] then return false end
    b.groups[me] = nil
    ClearLeader(ev, me, nil)
    if b.me then
        b.me.leader = nil
        b.me.ts = Now()
    end
    SendDisband(ev)
    return true
end

-- ------------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------------

local function NoGuild()
    return not (IsInGuild and IsInGuild())
end

-- Every board-specific entry point runs this first. An unknown event id is a
-- caller bug, but the UI is the caller and a thrown error there takes the
-- whole panel down, so it is reported as a value instead.
local function Ready(ev)
    if not IsEvent(ev) then return false, "badevent" end
    if NoGuild() then return false, "noguild" end
    EnsureCurrent(ev)
    return true
end

function M.Me(ev)
    if not Ready(ev) then return nil end
    EnsureSelf(ev)
    return boards[ev].me
end

function M.SignUp(ev, opts)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    opts = opts or {}
    local intent = opts.intent == "lead" and "lead" or "join"
    local bracket = opts.bracket
    if not BRACKET_ORDER[bracket] then bracket = "any" end

    local me = MyName()
    if not me then return false, "noname" end
    local b = boards[ev]

    ReadKeystone()
    if intent == "lead" and not myKey then return false, "nokey" end

    -- Leaving one arrangement for another has to be announced, or the old
    -- group keeps showing a member who is no longer there.
    if intent == "join" and IsLeading(ev) then
        DisbandOwnGroup(ev)
    elseif intent == "lead" and b.me and b.me.leader and b.me.leader ~= me then
        SendLeaveRequest(ev, b.me.leader)
        local old = b.groups[b.me.leader]
        if old and old.members then old.members[me] = nil end
        b.me.leader = nil
    end

    local entry = b.me or {}
    entry.role = M.MyRole()
    entry.intent = intent
    -- A leader has no bracket: they are the group, not a preference. Written
    -- long-hand because `cond and nil or x` collapses to x in Lua.
    if intent == "lead" then
        entry.bracket = nil
    else
        entry.bracket = bracket
    end
    entry.mapID = myKey and myKey.mapID
    entry.level = myKey and myKey.level
    entry.ts = Now()
    entry.seen = Now()
    if intent == "lead" then
        entry.leader = me
    end
    b.me = entry
    b.entries[me] = entry

    if intent == "lead" then
        local g = b.groups[me] or { members = {} }
        g.members = g.members or {}
        g.members[me] = entry.role
        g.mapID = entry.mapID
        g.level = entry.level
        g.ts = Now()
        g.seen = Now()
        b.groups[me] = g
    end

    Persist()
    SendEntry(ev)
    if intent == "lead" then SendGroup(ev) end
    if ev == "open" then StartHeartbeat() end
    Fire(ev)
    return true
end

function M.Withdraw(ev)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    if not me or not b.me then return false, "notsignedup" end

    if IsLeading(ev) then
        DisbandOwnGroup(ev)
    elseif b.me.leader then
        SendLeaveRequest(ev, b.me.leader)
        local g = b.groups[b.me.leader]
        if g and g.members then g.members[me] = nil end
    end

    b.me = nil
    b.entries[me] = nil
    pendingJoin[ev] = nil
    Persist()
    SendWithdraw(ev)
    -- Nothing left to prove presence for.
    if ev == "open" then StopHeartbeat() end
    Fire(ev)
    return true
end

function M.Join(ev, leaderName)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    local me = EnsureSelf(ev)
    if not me then return false, "noname" end
    if not leaderName or leaderName == me then return false, "nogroup" end

    local b = boards[ev]
    local g = b.groups[leaderName]
    if not g then return false, "nogroup" end

    -- Signing up implicitly: the group rows offer Join without forcing a trip
    -- through the sign-up block first.
    if not b.me then
        local signed, reason = M.SignUp(ev, { intent = "join", bracket = "any" })
        if not signed then return false, reason end
        me = EnsureSelf(ev)
    elseif IsLeading(ev) then
        DisbandOwnGroup(ev)
    end

    if not HasFreeSlot(g, b.me.role) then return false, "full" end

    if b.me.leader and b.me.leader ~= leaderName then
        SendLeaveRequest(ev, b.me.leader)
        local old = b.groups[b.me.leader]
        if old and old.members then old.members[me] = nil end
        b.me.leader = nil
    end

    -- Acceptance is not assumed. The leader answers with a G that lists us,
    -- or an N; until then this is only a pending request.
    pendingJoin[ev] = leaderName
    b.me.intent = "join"
    b.me.ts = Now()
    Persist()
    SendEntry(ev)
    SendJoinRequest(ev, leaderName)
    Fire(ev)
    return true
end

function M.Leave(ev)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    if not me or not b.me then return false, "notsignedup" end
    local leader = b.me.leader
    if not leader or leader == me then return false, "nogroup" end

    SendLeaveRequest(ev, leader)
    local g = b.groups[leader]
    if g and g.members then g.members[me] = nil end
    b.me.leader = nil
    b.me.ts = Now()
    pendingJoin[ev] = nil
    Persist()
    SendEntry(ev)
    Fire(ev)
    return true
end

function M.Disband(ev)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    EnsureSelf(ev)
    if not IsLeading(ev) then return false, "nogroup" end
    local b = boards[ev]
    DisbandOwnGroup(ev)
    if b.me then
        -- Disbanding is not withdrawing: stay on the board, now looking.
        b.me.intent = "join"
        b.me.bracket = b.me.bracket or "any"
        b.me.ts = Now()
    end
    Persist()
    SendEntry(ev)
    Fire(ev)
    return true
end

function M.Refresh(ev, force)
    local ok, why = Ready(ev)
    if not ok then return false, why end
    local now = Now()
    -- Throttled per board, so refreshing one page cannot mute the other.
    if not force and now - (lastRefresh[ev] or 0) < REFRESH_THROTTLE then
        return false, "throttled"
    end
    lastRefresh[ev] = now
    Send("R " .. WireKey(ev), "GUILD")
    return true
end

function M.Brackets()
    return ns.MONDAY_BRACKETS or {}
end

-- ------------------------------------------------------------------
-- Views
-- ------------------------------------------------------------------

local function OnlineSet()
    local now = Now()
    if rosterOnline and now - rosterAt < ROSTER_CACHE then return rosterOnline end
    local set = {}
    if GetNumGuildMembers and GetGuildRosterInfo then
        local total = GetNumGuildMembers() or 0
        for i = 1, total do
            local fullName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
            if fullName and online then set[fullName] = true end
        end
    end
    rosterOnline, rosterAt = set, now
    return set
end

function M.Groups(ev)
    if not Ready(ev) then return {} end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    local out = {}
    for leader, g in pairs(b.groups) do
        -- A leader we have not heard from takes the whole group with them:
        -- nobody else may edit that roster, so it can only go stale.
        if not IsStale(ev, g.seen, leader, me) then
            local members = {}
            local counts = { T = 0, H = 0, D = 0 }
            for name, role in pairs(g.members or {}) do
                -- A member of someone else's group who has gone quiet is
                -- hidden but never deleted: that roster belongs to its leader,
                -- who runs this same prune and will correct it. Our own group
                -- has already been pruned, so nothing is hidden there.
                -- IsStale short-circuits to false on the Monday board, so a
                -- missing entry hides nobody there.
                local e = b.entries[name]
                local ghost = (name ~= leader) and IsStale(ev, e and e.seen, name, me)
                if not ghost then
                    members[#members + 1] = { name = name, role = role }
                    if counts[role] then counts[role] = counts[role] + 1 end
                end
            end
            table.sort(members, function(a, c)
                local ra, rc = ROLE_ORDER[a.role] or 9, ROLE_ORDER[c.role] or 9
                if ra ~= rc then return ra < rc end
                return a.name < c.name
            end)
            out[#out + 1] = {
                leader = leader,
                mapID = g.mapID,
                level = g.level,
                keyName = KeyName(g.mapID),
                members = members,
                isMine = (leader == me),
                -- Counted from what is actually shown, so the row cannot say
                -- "full" while displaying an empty slot.
                isFull = FullFromCounts(counts),
                missing = {
                    T = counts.T < SLOTS.T,
                    H = counts.H < SLOTS.H,
                    D = SLOTS.D - counts.D,
                },
                seen = g.seen,
            }
        end
    end
    table.sort(out, function(a, c)
        if a.isMine ~= c.isMine then return a.isMine end
        if (a.level or 0) ~= (c.level or 0) then return (a.level or 0) > (c.level or 0) end
        return a.leader < c.leader
    end)
    return out
end

function M.Pool(ev)
    if not Ready(ev) then return {} end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    local online = OnlineSet()
    local out = {}
    for name, e in pairs(b.entries) do
        if not e.leader and not IsStale(ev, e.seen, name, me) then
            out[#out + 1] = {
                name = name,
                role = e.role,
                bracket = e.bracket,
                mapID = e.mapID,
                level = e.level,
                keyName = KeyName(e.mapID),
                online = online[name] == true,
                seen = e.seen,
            }
        end
    end
    table.sort(out, function(a, c)
        local ba = BRACKET_ORDER[a.bracket] or 5
        local bc = BRACKET_ORDER[c.bracket] or 5
        if ba ~= bc then return ba < bc end
        local ra, rc = ROLE_ORDER[a.role] or 9, ROLE_ORDER[c.role] or 9
        if ra ~= rc then return ra < rc end
        return a.name < c.name
    end)
    return out
end

-- One line describing our own standing on a board, or nil if not signed up.
local function YouLine(ev)
    local b = boards[ev]
    local e = b and b.me
    if not e then return nil end
    local me = MyName()
    if e.leader == me and me then
        local g = b.groups[me]
        local filled = 0
        for _ in pairs(g and g.members or {}) do filled = filled + 1 end
        local key = e.level and ("+" .. e.level .. " " .. (KeyName(e.mapID) or "?")) or "no key"
        return ("leading %s, %d/5."):format(key, filled)
    elseif e.leader then
        return ("in %s's group."):format(e.leader)
    end
    return ("in the pool, %s, %s."):format(tostring(e.role), tostring(e.bracket or "any"))
end

function M.Summary()
    local label = M.TargetLabel()
    if NoGuild() then
        return ("Guild boards (%s): you are not in a guild."):format(label)
    end
    local mondayGroups = M.Groups("monday")
    local mondayPool = M.Pool("monday")
    local openGroups = M.Groups("open")
    local openPool = M.Pool("open")

    -- Monday is the headline board, so its status wins when we are on both.
    local you = YouLine("monday")
    if not you then
        local openYou = YouLine("open")
        -- Naming the board matters here: "leading +12 Kings' Rest" reads as a
        -- Monday group otherwise, and the two are entirely separate.
        if openYou then you = openYou:gsub("%.$", " (right now).") end
    end

    return ("Mythic Monday (%s): %d group%s, %d in pool. Right now: %d group%s, %d in pool. You: %s /gp monday")
        :format(label,
            #mondayGroups, #mondayGroups == 1 and "" or "s", #mondayPool,
            #openGroups, #openGroups == 1 and "" or "s", #openPool,
            you or "not signed up.")
end

-- ------------------------------------------------------------------
-- Guild chat and party invites
-- ------------------------------------------------------------------
-- Everything a leader would otherwise type by hand. Note the plain "-" rather
-- than an em dash: the repo already swapped an arrow for ">" because the WoW
-- chat font has no glyph for it, and a missing glyph in guild chat is worse
-- than a duller separator.

local function ShortName(full)
    if not full then return "?" end
    return (full:gsub("%-.*$", ""))
end

local function KeyPhrase(mapID, level)
    if not mapID or not level then return nil end
    local name = KeyName(mapID)
    if not name then return "+" .. tostring(level) end
    return ("+%s %s"):format(tostring(level), name)
end

local function BracketPhrase(id)
    for _, br in ipairs(ns.MONDAY_BRACKETS or {}) do
        if br.id == id then
            if br.min and br.max then
                return ("%s %d-%d"):format(br.label or br.id, br.min, br.max)
            end
            return "any level"
        end
    end
    return "any level"
end

local function NeedPhrase(missing)
    if not missing then return nil end
    local parts = {}
    if missing.T then parts[#parts + 1] = "Tank" end
    if missing.H then parts[#parts + 1] = "Healer" end
    if (missing.D or 0) > 0 then parts[#parts + 1] = missing.D .. " DPS" end
    if #parts == 0 then return nil end
    return table.concat(parts, ", ")
end

-- Trim to the chat limit without slicing a multi-byte character in half, which
-- would put a broken glyph in guild chat.
local function Clamp(s, limit)
    if #s <= limit then return s end
    local cut = limit
    while cut > 0 do
        local b = s:byte(cut + 1)
        if not b or b < 0x80 or b >= 0xC0 then break end
        cut = cut - 1
    end
    return s:sub(1, cut)
end

local function EventClause(ev)
    if ev == "monday" then
        return (" for %s (%s)"):format(EVENT_TITLE.monday, M.TargetLabel())
    end
    return ""
end

local function SlashFor(ev)
    return ev == "monday" and "/gp monday" or "/gp now"
end

-- What a group still needs, counted the way Groups() counts it so the chat
-- line and the page can never disagree about a free slot.
function M.MissingSlots(ev, leader)
    if not Ready(ev) then return nil end
    local b = boards[ev]
    local g = leader and b.groups[leader]
    if not g then return nil end
    local me = MyName()
    local counts = { T = 0, H = 0, D = 0 }
    for name, role in pairs(g.members or {}) do
        local e = b.entries[name]
        local ghost = (name ~= leader) and IsStale(ev, e and e.seen, name, me)
        if not ghost and counts[role] then counts[role] = counts[role] + 1 end
    end
    return { T = counts.T < SLOTS.T, H = counts.H < SLOTS.H, D = SLOTS.D - counts.D }
end

function M.ChatLine(ev)
    local ok, why = Ready(ev)
    if not ok then return nil, why end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    local e = b.me
    if not e then return nil, "notsignedup" end

    local clause, slash = EventClause(ev), SlashFor(ev)
    local g = e.leader and b.groups[e.leader]

    local build
    if g then
        local key = KeyPhrase(g.mapID, g.level) or "a key"
        local need = NeedPhrase(M.MissingSlots(ev, e.leader))
        -- A full group has nothing to advertise. Refusing here rather than
        -- returning a "we are full" line lets the UI disable the post button
        -- instead of offering to spam guild chat with a non-advertisement.
        if not need then return nil, "full" end
        build = function(whose)
            return ("LFM %s%s - need %s%s. Sign up: %s"):format(key, whose, need, clause, slash)
        end
    else
        local parts = { ROLE_WORD[e.role] or "DPS", BracketPhrase(e.bracket) }
        local key = KeyPhrase(e.mapID, e.level)
        if key then parts[#parts + 1] = "have " .. key end
        local body = table.concat(parts, ", ")
        build = function()
            return ("LF key group - %s%s. Sign up: %s"):format(body, clause, slash)
        end
    end

    local whose = ""
    if g and e.leader ~= me then
        whose = (" (%s's group)"):format(ShortName(e.leader))
    end
    local line = build(whose)
    -- Whose group it is costs the most characters and matters the least, so it
    -- is the first thing dropped when a name pushes the line over the limit.
    if #line > MAX_CHAT and whose ~= "" then line = build("") end
    return Clamp(line, MAX_CHAT)
end

function M.PostToGuild(ev)
    if not IsEvent(ev) then return false, "badevent" end
    if NoGuild() then return false, "noguild" end
    -- Secret Values put chat under lockdown inside an active key.
    if InChallenge() then return false, "inkey" end
    local text, why = M.ChatLine(ev)
    if not text then return false, why or "notsignedup" end
    local now = Now()
    -- Checked last, so a refusal above never burns the window.
    if now - (lastPost[ev] or 0) < POST_THROTTLE then return false, "throttled" end
    lastPost[ev] = now
    -- SendChatMessage was deprecated in 11.2 and now survives only as a shim in
    -- Blizzard_DeprecatedChatInfo, so prefer the namespaced call where it is.
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(text, "GUILD")
    else
        SendChatMessage(text, "GUILD")
    end
    return true
end

-- UnitInParty and UnitInRaid take a *unit*, and a same-realm group member is
-- indexed under their bare name - "Bob-OurRealm" simply misses. Try both forms.
local function InGroupWith(name)
    local forms = { name }
    if Ambiguate then
        local short = Ambiguate(name, "short")
        if short and short ~= "" and short ~= name then
            forms[#forms + 1] = short
        end
    end
    for i = 1, #forms do
        local unit = forms[i]
        if (UnitInParty and UnitInParty(unit)) or (UnitInRaid and UnitInRaid(unit)) then
            return true
        end
    end
    return false
end

function M.Invite(name)
    if not name or name == "" then return false, "offline" end
    if name == MyName() then return false, "self" end
    if InGroupWith(name) then return false, "inparty" end
    -- Someone we know of but have not heard from in a quarter of an hour has
    -- almost certainly logged out; inviting them only prints an error. A name
    -- we have never seen gets the benefit of the doubt.
    local seen
    for _, id in ipairs(EVENTS) do
        local b = boards[id]
        local e = b and b.entries[name]
        if e and e.seen and (not seen or e.seen > seen) then seen = e.seen end
    end
    if seen and (Now() - seen) > OPEN_STALE then return false, "offline" end
    if C_PartyInfo and C_PartyInfo.InviteUnit then
        C_PartyInfo.InviteUnit(name)
    end
    return true
end

-- Returns how many invites went out, and an array of { name, reason } for the
-- ones that did not.
function M.InviteAll(ev)
    local me = MyName()
    if not Ready(ev) or not IsLeading(ev) then
        return 0, { { name = me or "?", reason = "notleader" } }
    end
    local g = boards[ev].groups[me]
    local names = {}
    for name in pairs(g.members or {}) do
        if name ~= me then names[#names + 1] = name end
    end
    -- Sorted so the skipped list a caller shows is stable between calls.
    table.sort(names)

    local invited, skipped = 0, {}
    for _, name in ipairs(names) do
        local ok, reason = M.Invite(name)
        if ok then
            invited = invited + 1
        else
            skipped[#skipped + 1] = { name = name, reason = reason }
        end
    end
    return invited, skipped
end

local function DumpBoard(ev)
    local b = boards[ev]
    if not b then
        Say(("  %s: not loaded"):format(ev))
        return
    end
    Say(("%s (%s), key=%s"):format(M.EventTitle(ev) or ev, ev, tostring(b.key)))
    if b.me then
        local e = b.me
        Say(("  entry: %s intent=%s bracket=%s leader=%s ts=%s"):format(
            tostring(e.role), tostring(e.intent), tostring(e.bracket),
            tostring(e.leader), tostring(e.ts)))
    else
        Say("  entry: none")
    end
    for name, e in pairs(b.entries) do
        Say(("  entry %s: %s %s %s key=%s+%s leader=%s ts=%s seen=%s"):format(
            name, tostring(e.role), tostring(e.intent), tostring(e.bracket),
            tostring(e.mapID), tostring(e.level), tostring(e.leader),
            tostring(e.ts), tostring(e.seen)))
    end
    for leader, g in pairs(b.groups) do
        Say(("  group %s: +%s %s members=%s ts=%s seen=%s"):format(
            leader, tostring(g.level), tostring(KeyName(g.mapID)),
            SerializeMembers(g, leader), tostring(g.ts), tostring(g.seen)))
    end
end

-- With no argument, dumps every board - which is what /gp monday dump wants.
function M.Dump(ev)
    local me = MyName()
    Say(("me=%s role=%s key=%s queued=%d heartbeat=%s"):format(
        tostring(me), M.MyRole(),
        myKey and ("+" .. myKey.level .. " " .. tostring(myKey.name)) or "none",
        #outQueue, heartbeat and "on" or "off"))
    if ev then
        DumpBoard(ev)
        return
    end
    for _, id in ipairs(EVENTS) do
        DumpBoard(id)
    end
end

-- ------------------------------------------------------------------
-- Receiving
-- ------------------------------------------------------------------

local handlers = {}

-- R: someone wants a board. Answer with our own state only - never with our
-- cache of other people's - or a guild login rush turns into N^2 traffic.
function handlers.R(ev, sender, fields, isSelf)
    if isSelf then return end
    local b = boards[ev]
    if not b or (not b.me and not IsLeading(ev)) then return end
    local delay = math.random() * REPLY_JITTER
    C_Timer.After(delay, function()
        ns.safecall(function()
            if EnsureCurrent(ev) then return end
            SendEntry(ev)
            if IsLeading(ev) then SendGroup(ev) end
        end)
    end)
end

-- E: a peer's own entry. Merge by timestamp, highest wins.
function handlers.E(ev, sender, fields, isSelf)
    if isSelf then return end     -- GUILD echoes our own sends back to us
    local ts = tonumber(fields[3])
    if not ts then return end
    local b = boards[ev]
    local existing = b.entries[sender]
    if existing and (existing.ts or 0) >= ts then
        -- Still proof of life, which is all the open board's expiry needs.
        existing.seen = Now()
        return
    end
    b.entries[sender] = {
        role = Unwire(fields[4]),
        intent = Unwire(fields[5]),
        bracket = Unwire(fields[6]),
        mapID = tonumber(Unwire(fields[7]) or ""),
        level = tonumber(Unwire(fields[8]) or ""),
        leader = Unwire(fields[9]),
        ts = ts,
        seen = Now(),
    }
    Persist()
    Fire(ev)
end

function handlers.X(ev, sender, fields, isSelf)
    if isSelf then return end
    local b = boards[ev]
    local hadEntry = b.entries[sender] ~= nil
    b.entries[sender] = nil
    -- If they were in our group the roster is ours to correct and rebroadcast,
    -- and that holds even if we never heard their E - a J from an unknown
    -- player still puts them on our roster.
    local me = MyName()
    local g = me and b.groups[me]
    local wasMember = g and g.members and g.members[sender] ~= nil
    if wasMember then
        g.members[sender] = nil
        g.ts = Now()
        SendGroup(ev)
    end
    if not hadEntry and not wasMember then return end
    Persist()
    Fire(ev)
end

-- G: a leader's roster. The only message that may write board.groups[leader].
function handlers.G(ev, sender, fields, isSelf)
    if isSelf then return end
    local ts = tonumber(fields[3])
    if not ts then return end
    local b = boards[ev]
    local existing = b.groups[sender]
    if existing and (existing.ts or 0) > ts then return end

    local members = {}
    local raw = Unwire(fields[6])
    if raw then
        for _, pair in ipairs(Split(raw, ",")) do
            local name, role = pair:match("^(.+):([THD])$")
            if name then members[name] = role end
        end
    end
    b.groups[sender] = {
        mapID = tonumber(Unwire(fields[4]) or ""),
        level = tonumber(Unwire(fields[5]) or ""),
        ts = ts,
        seen = Now(),
        members = members,
    }

    -- This is how a joiner learns their J was accepted. It has to run before
    -- the bulk fix-up below, because board.entries[me] *is* board.me - the
    -- loop would set our own leader first and hide the transition.
    local me = EnsureSelf(ev)
    if me and b.me then
        if members[me] and b.me.leader ~= sender then
            b.me.leader = sender
            b.me.ts = Now()
            pendingJoin[ev] = nil
            Persist()
            SendEntry(ev)
            Say(("you are in %s's group (%s)."):format(sender, M.EventTitle(ev)))
        elseif not members[me] and b.me.leader == sender then
            b.me.leader = nil
            b.me.ts = Now()
            Persist()
            SendEntry(ev)
        end
    end

    -- Everyone listed belongs to this leader; everyone who used to and is no
    -- longer listed is back in the pool.
    for name in pairs(members) do
        local e = b.entries[name]
        if e then e.leader = sender end
    end
    ClearLeader(ev, sender, members)

    Persist()
    Fire(ev)
end

function handlers.D(ev, sender, fields, isSelf)
    if isSelf then return end
    local b = boards[ev]
    if not b.groups[sender] then return end
    b.groups[sender] = nil
    ClearLeader(ev, sender, nil)
    local me = EnsureSelf(ev)
    if me and b.me and b.me.leader == sender then
        b.me.leader = nil
        b.me.ts = Now()
        SendEntry(ev)
        Say(("%s disbanded the group (%s)."):format(sender, M.EventTitle(ev)))
    end
    Persist()
    Fire(ev)
end

-- J: a whispered join request. We are the leader; we answer, nobody else does.
function handlers.J(ev, sender, fields, isSelf)
    if isSelf then return end
    local me = MyName()
    local b = boards[ev]
    local g = me and b.groups[me]
    if not g then
        SendDeny(ev, sender, "nogroup")
        return
    end
    if g.members and g.members[sender] then
        SendGroup(ev)   -- idempotent ack; their G may simply have been missed
        return
    end
    -- The request carries no role, by design: the role a player takes is their
    -- own entry's business. An unheard entry defaults to D, the wide slot.
    local entry = b.entries[sender]
    local role = entry and entry.role or "D"
    if not SLOTS[role] then role = "D" end
    if not HasFreeSlot(g, role) then
        SendDeny(ev, sender, "full")
        return
    end
    g.members[sender] = role
    g.ts = Now()
    if entry then
        entry.leader = me
    else
        -- We have never heard their E, but they just whispered us, so they are
        -- plainly online. Without a record the open board's prune would read
        -- them as a ghost and drop them again within minutes. ts 0 means their
        -- real entry supersedes this the moment it arrives.
        b.entries[sender] = {
            role = role, intent = "join", leader = me, ts = 0, seen = Now(),
        }
    end
    Persist()
    SendGroup(ev)
    Fire(ev)
end

function handlers.L(ev, sender, fields, isSelf)
    if isSelf then return end
    local me = MyName()
    local b = boards[ev]
    local g = me and b.groups[me]
    if not g or not g.members or not g.members[sender] then return end
    g.members[sender] = nil
    g.ts = Now()
    local entry = b.entries[sender]
    if entry and entry.leader == me then entry.leader = nil end
    Persist()
    SendGroup(ev)
    Fire(ev)
end

function handlers.N(ev, sender, fields, isSelf)
    if isSelf then return end
    if pendingJoin[ev] ~= sender then return end
    pendingJoin[ev] = nil
    local reason = fields[3]
    if reason == "full" then
        Say(("%s's group is full (%s)."):format(sender, M.EventTitle(ev)))
    else
        Say(("%s has no group to join (%s)."):format(sender, M.EventTitle(ev)))
    end
    Fire(ev)
end

local function OnMessage(prefix, text, channel, rawSender)
    if prefix ~= PREFIX then return end
    -- Inbound is ignored inside a key for the same reason outbound is queued:
    -- nothing in there may touch comms or keystone state.
    if InChallenge() then return end
    if not text then return end

    local cmd = text:match("^(%S+)")
    local handler = cmd and handlers[cmd]
    if not handler then return end

    local fields = Split(text, " ")
    -- Last week's Monday, or a key some future version invented: drop it
    -- rather than file it under a board that does not exist.
    local ev = EventFromWire(fields[2])
    if not ev then return end

    local sender = SenderKey(rawSender)
    if not sender then return end

    EnsureCurrent(ev)
    handler(ev, sender, fields, sender == MyName())
end

-- ------------------------------------------------------------------
-- Events
-- ------------------------------------------------------------------

local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("CHAT_MSG_ADDON")
ef:RegisterEvent("BAG_UPDATE_DELAYED")
ef:RegisterEvent("CHALLENGE_MODE_COMPLETED")
ef:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

ef:SetScript("OnEvent", function(_, event, ...)
    local a1, a2, a3, a4 = ...
    if event == "ADDON_LOADED" then
        if a1 ~= ADDON then return end
        ns.safecall(function()
            LoadSaved()
            if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
                local code = C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
                -- 0 = ok, 1 = already registered; anything higher is fatal and
                -- would otherwise look like a silently dead board.
                if type(code) == "number" and code > 1 then
                    Warn(("could not register the %s prefix (code %d) - the boards will not sync.")
                        :format(PREFIX, code))
                end
            end
        end)

    elseif event == "CHAT_MSG_ADDON" then
        ns.safecall(OnMessage, a1, a2, a3, a4)

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isLogin = a1
        ns.safecall(function()
            for _, ev in ipairs(EVENTS) do
                EnsureCurrent(ev)
                EnsureSelf(ev)
            end
            FlushQueue()
            -- After the queue, so a correction we make here goes out now
            -- rather than sitting behind messages from before the dungeon.
            PruneOpenAndSync()
            if not IsInInstance or not IsInInstance() then ReadKeystone() end
            if not IsInGuild or not IsInGuild() then return end
            -- A relog should keep us on the open board, so the saved entry is
            -- re-announced rather than waiting for the first heartbeat.
            if boards.open and boards.open.me then StartHeartbeat() end
            if isLogin and not summaryPrinted then
                summaryPrinted = true
                for _, ev in ipairs(EVENTS) do
                    M.Refresh(ev, true)
                    SendEntry(ev)
                    if IsLeading(ev) then SendGroup(ev) end
                end
                -- Five seconds is enough for the replies to a login R to land,
                -- so the summary counts a board rather than an empty table.
                C_Timer.After(5, function()
                    ns.safecall(function() Say(M.Summary()) end)
                end)
            end
        end)

    elseif event == "BAG_UPDATE_DELAYED" then
        -- Looting a key fires a burst of these; only the last one matters.
        if keyTimer then return end
        keyTimer = true
        C_Timer.After(KEY_DEBOUNCE, function()
            keyTimer = nil
            ns.safecall(ReadKeystone)
        end)

    elseif event == "CHALLENGE_MODE_COMPLETED" then
        ns.safecall(function()
            FlushQueue()
            -- The new key does not exist the instant the timer stops.
            C_Timer.After(3, function() ns.safecall(ReadKeystone) end)
        end)

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        ns.safecall(function()
            local role = M.MyRole()
            local me = MyName()
            local changed = false
            for _, ev in ipairs(EVENTS) do
                local b = boards[ev]
                if b and b.me and b.me.role ~= role then
                    b.me.role = role
                    b.me.ts = Now()
                    local g = me and b.groups[me]
                    if g and g.members and g.members[me] then
                        g.members[me] = role
                        g.ts = Now()
                    end
                    SendEntry(ev)
                    if g then SendGroup(ev) end
                    Fire(ev)
                    changed = true
                end
            end
            if changed then Persist() end
        end)
    end
end)

-- Exposed for the headless tests in tools/monday_test.lua, which drive the
-- module through its own event handler rather than reaching into its state.
M._frame = ef
M._boards = boards
