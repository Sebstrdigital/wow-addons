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
--   E ev ts role intent bracket mapID level leader spec own entry (GUILD)
--   X ev                                          withdraw (GUILD)
--   G ev ts mapID level name:R,name:R,... s,s,... when roster   (GUILD, leader)
--   D ev                                          disband  (GUILD, leader)
--   J ev                                          join req (WHISPER to leader)
--   L ev                                          leave    (WHISPER to leader)
--   N ev reason                                   denied   (WHISPER to joiner)
--
-- The two `spec` fields are trailing additions, both carrying numeric
-- specialization ids (GetSpecializationInfo's first return), and both
-- optional by construction rather than by promise: E's peers read fields 3..9
-- by fixed index and G's read 3..8, so a client that predates these fields
-- simply never looks at them, and one that postdates a sender who omits them
-- reads nil. "0" and a missing field mean the same thing - not told. G's list
-- is positional against the member list in the field before it, one entry per
-- member in the same order.
--
-- G's field 8 is one more trailing addition beyond its spec list: `when`, the
-- open board's leader-set start time as a decimal server epoch, or "-" for
-- "right now". Same fixed-index, no-arity-check rule as the rest, so an older
-- client simply never looks at it. Only the open board ever sets it - the
-- Monday board's key IS the date, so it has nothing to schedule - and it
-- never rides E: groups are leader-authoritative, so only a G may say when
-- one starts.
--
-- Bump the prefix to GPMM3 on any breaking change to those fields.

ns.Monday = ns.Monday or {}
local M = ns.Monday

local PREFIX = "GPMM2"
local MAX_BYTES = 255           -- hard addon-message payload limit
local REFRESH_THROTTLE = 60     -- seconds between outbound R broadcasts, per board
local ROSTER_CACHE = 20         -- seconds an online/offline roster scan is reused
local ROSTER_FIRE_THROTTLE = 5  -- seconds between GUILD_ROSTER_UPDATE-driven repaints
local REPLY_JITTER = 2          -- seconds; spreads replies to a broadcast R
local KEY_DEBOUNCE = 2          -- seconds after the last BAG_UPDATE_DELAYED
local OPEN_STALE = 15 * 60      -- an open-board record older than this is gone
local OPEN_HEARTBEAT = 5 * 60   -- how often we prove we are still here
local OPEN_SCHEDULED_GRACE = 2 * 60 * 60  -- grace past `when` before a scheduled group is pruned
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
local onlineCache = {}          -- fullName -> true/false; absent = never scanned
local lastRosterFire = 0        -- Now() of the last throttled GUILD_ROSTER_UPDATE repaint
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

-- A specialization id off the wire. Unlike the other fields this one has a
-- second spelling for nil: "0" is what a sender writes when it has a slot to
-- fill but nothing to put in it (G's list is positional, so it cannot just
-- leave a gap), and a missing field is what every client older than these two
-- trailing fields sends. Both mean "not told".
local function SpecFromWire(v)
    local n = tonumber(Unwire(v) or "")
    if not n or n <= 0 then return nil end
    return n
end

-- A schedule epoch off the wire, or nil for "not told" / "right now". "0" is
-- a second spelling of nil here too - nobody's clock is truly epoch zero -
-- and a missing field means the same, so one rule covers both.
local function WhenFromWire(v)
    local n = tonumber(Unwire(v) or "")
    if not n or n <= 0 then return nil end
    return n
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

-- ------------------------------------------------------------------
-- Scheduling ("when" on an open-board group)
-- ------------------------------------------------------------------
-- A leader-set start time, nil unless someone picks one - nil still means
-- "right now", today's behaviour, unchanged.

-- "2h 15m" / "3d 4h" / "12m" - the coarsest two units that say something,
-- because "2h 15m 3s" answers a question nobody asked and "0d 2h" makes the
-- reader do the subtraction FormatWhen exists to avoid.
local function FormatDuration(seconds)
    seconds = math.max(0, math.floor(seconds))
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then
        return string.format("%dd %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    end
    return string.format("%dm", minutes)
end

-- A calendar-time table's own local midnight, so day-boundary arithmetic
-- never has to reason about hours or DST directly - `time` does that.
local function LocalMidnight(t)
    return time({ year = t.year, month = t.month, day = t.day,
        hour = 0, min = 0, sec = 0 })
end

-- `when == nil` -> "" (nothing to show; "right now" already says it on the
-- page header). Otherwise a day part - "Today", "Tomorrow", a bare weekday
-- inside a week, else a full date - plus the clock time, plus a relative
-- suffix while it still means something: how long until a future start, or
-- how long since a past one that has not yet run out its grace.
function M.FormatWhen(when, now)
    if not when then return "" end
    now = now or Now()

    local whenT = date("*t", when)
    local dayDiff = math.floor(
        (LocalMidnight(whenT) - LocalMidnight(date("*t", now))) / 86400 + 0.5)

    local dayPart
    if dayDiff == 0 then
        dayPart = "Today"
    elseif dayDiff == 1 then
        dayPart = "Tomorrow"
    elseif dayDiff >= 2 and dayDiff <= 6 then
        dayPart = WEEKDAY_ABBR[whenT.wday] or "?"
    else
        dayPart = string.format("%s %d %s", WEEKDAY_ABBR[whenT.wday] or "?",
            whenT.day, MONTH_ABBR[whenT.month] or "?")
    end

    local result = string.format("%s %02d:%02d", dayPart, whenT.hour, whenT.min)

    local delta = when - now
    if delta > 0 then
        result = result .. " (in " .. FormatDuration(delta) .. ")"
    elseif -delta <= OPEN_SCHEDULED_GRACE then
        result = result .. " (started " .. FormatDuration(-delta) .. " ago)"
    end
    return result
end

-- `dayOffset` days from today (0 = today), local calendar, at `hour:minute`.
-- Built with `time{}` on the calendar fields rather than arithmetic on `now`,
-- so a span that crosses a DST boundary still lands on the wall-clock time
-- asked for - the C library's job, not ours.
function M.BuildWhen(dayOffset, hour, minute, now)
    local t = date("*t", now or Now())
    return time({ year = t.year, month = t.month, day = t.day + (dayOffset or 0),
        hour = hour or 0, min = minute or 0, sec = 0 })
end

-- What the UI seeds its steppers with: the next full hour that is still at
-- least half an hour away, so "Scheduled" never defaults to a time already
-- half gone.
function M.DefaultWhen(now)
    now = now or Now()
    local t = date("*t", now + 1800)
    local hour = t.hour
    if t.min > 0 or t.sec > 0 then hour = hour + 1 end
    return time({ year = t.year, month = t.month, day = t.day, hour = hour, min = 0, sec = 0 })
end

function M.IsScheduled(g)
    return g ~= nil and g.when ~= nil
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

-- A scheduled group's leader may be offline for hours before the run - the
-- 15-minute heartbeat rule would hide it long before anyone could plan around
-- it - so a group carrying `when` lives and dies by that time instead: still
-- visible however long the leader has been offline, gone once the grace
-- window past the start time has run out. Our own group is exempt from this
-- exactly as it is from OPEN_STALE, for the same reason: nothing here may
-- prune the group out from under the leader looking at it.
local function IsGroupStale(ev, g, leader, me)
    if ev ~= "open" then return false end
    if leader and me and leader == me then return false end
    if g and g.when then
        return Now() > g.when + OPEN_SCHEDULED_GRACE
    end
    return IsStale(ev, g and g.seen, leader, me)
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
        if IsGroupStale("open", g, leader, me) then
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
        Wire(e.leader), tostring(e.spec or 0),
    }, " "), "GUILD")
end

-- The spec to publish for one member of a group we lead. A member's own E is
-- the authority - they respec, they tell us, and that arrives long after they
-- joined - so the roster's own sidecar is only the fallback for someone whose
-- E we have never heard (the J handler's unknown joiner, or a roster restored
-- from SavedVariables before anyone has spoken).
local function SpecFor(g, entries, name)
    local e = entries and entries[name]
    if e and e.spec then return e.spec end
    return (g.specs and g.specs[name]) or nil
end

-- Returns the roster body and the parallel spec list, in one pass so the two
-- cannot drift out of order. `entries` is optional; without it the spec list
-- falls back to the group's sidecar alone.
local function SerializeMembers(g, leader, entries)
    -- Leader first, then alphabetical, so two clients rendering the same
    -- roster from the same message agree on the order.
    local names = {}
    for name in pairs(g.members or {}) do
        if name ~= leader then names[#names + 1] = name end
    end
    table.sort(names)
    if g.members and g.members[leader] then table.insert(names, 1, leader) end
    local parts, specs = {}, {}
    for i = 1, #names do
        parts[i] = names[i] .. ":" .. tostring(g.members[names[i]])
        specs[i] = tostring(SpecFor(g, entries, names[i]) or 0)
    end
    return table.concat(parts, ","), table.concat(specs, ",")
end

local function SendGroup(ev)
    local me = MyName()
    local b = boards[ev]
    local g = me and b and b.groups[me]
    if not g then return end
    local head = table.concat({
        "G", b.key, tostring(g.ts or Now()), Wire(g.mapID), Wire(g.level),
    }, " ")
    -- Measured and reserved before the roster is, so trimming below only ever
    -- eats into pairs/specs - the trailing `when` token is never what a full
    -- roster pushes out.
    local whenToken = Wire(g.when and math.floor(g.when) or nil)
    local body, specBody = SerializeMembers(g, me, b.entries)
    -- The spec list is positional against the roster, so it is measured with
    -- it and trimmed with it - a body cut shorter than its spec list would
    -- hand every receiver the wrong icons rather than none.
    local function Overflows()
        return #head + 1 + #body + 1 + #specBody + 1 + #whenToken > MAX_BYTES
    end
    -- Five members of plausible name length fit inside 255 with room to spare;
    -- this only bites on pathological realm names, and losing the tail of the
    -- roster silently would look like members randomly vanishing.
    if Overflows() then
        Warn("your group roster is too long to broadcast - some members were left out.")
        -- Drop trailing members while there is still a comma to cut at. The
        -- comma test is what bounds this: without it, a single member too long
        -- to fit leaves gsub matching nothing and the loop spinning forever.
        while body:find(",", 1, true) and Overflows() do
            body = (body:gsub(",[^,]*$", ""))
            specBody = (specBody:gsub(",[^,]*$", ""))
        end
        if Overflows() then
            -- Not even one member fits. Send the group with an empty roster
            -- rather than nothing, so peers still see it exists.
            body, specBody = "", ""
        end
    end
    Send(head .. " " .. (body ~= "" and body or "-")
              .. " " .. (specBody ~= "" and specBody or "-")
              .. " " .. whenToken, "GUILD")
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

-- Forward-declared: real body assigned below, once DisbandOwnGroup exists to
-- do the actual work. Clears an own scheduled group that has sat past its
-- grace window - checked at login and on every heartbeat, the only two
-- moments that may change state on our own initiative - so a leader who
-- never comes back online for their own run does not leave a stale group
-- standing, or need to remember to withdraw by hand. Deliberately not called
-- from M.Groups: a getter that Fires a callback can re-enter the very render
-- that called it.
local PruneOwnSchedule

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
            PruneOwnSchedule("open")
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

-- The specialization's own id (GetSpecializationInfo's first return), not the
-- 1-4 index GetSpecialization hands back: the index is meaningless without the
-- class, and the wire carries no class. nil whenever the client will not say -
-- a character who has not picked a spec, a client without the getter, or a
-- Secret Value inside an active key, tested for before it is touched the same
-- way KeyName tests the map name.
function M.MySpec()
    if not GetSpecialization or not GetSpecializationInfo then return nil end
    local index = GetSpecialization()
    if not index or IsSecret(index) then return nil end
    local id = GetSpecializationInfo(index)
    if IsSecret(id) then return nil end
    id = tonumber(id)
    if not id or id <= 0 then return nil end
    return id
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

-- Only the open board's own group can be scheduled, so only it is ever
-- checked. An unscheduled own group is untouched, same as ever - this is
-- purely about a `when` nobody showed up for. A key in progress holds off
-- entirely, same reasoning as the heartbeat's own skip: whatever the club
-- decided two hours ago, disbanding out from under a live run would be worse
-- than a stale one.
PruneOwnSchedule = function(ev)
    if ev ~= "open" or InChallenge() then return false end
    local b = boards[ev]
    local me = b and MyName()
    if not me or not b or not b.me then return false end
    local g = b.groups[me]
    if not g or not g.when or Now() <= g.when + OPEN_SCHEDULED_GRACE then
        return false
    end

    -- Exactly M.Disband's own path: drop the group, then stay on the board as
    -- a looking pool entry rather than vanish outright.
    DisbandOwnGroup(ev)
    b.me.intent = "join"
    b.me.bracket = b.me.bracket or "any"
    b.me.ts = Now()
    Persist()
    SendEntry(ev)
    Fire(ev)
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
    entry.spec = M.MySpec()
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
    -- `when` is an open-board, leader-only concept: the Monday board's key IS
    -- the date, so it has nothing to schedule, and a joiner has no group to
    -- carry the field. Set here at creation; M.SetWhen edits it afterwards.
    if ev == "open" and intent == "lead" then
        local w = tonumber(opts.when)
        if not w or w <= 0 then w = nil end
        entry.when = w
    end
    b.me = entry
    b.entries[me] = entry

    if intent == "lead" then
        local g = b.groups[me] or { members = {} }
        g.members = g.members or {}
        g.members[me] = entry.role
        -- A sidecar rather than a third part of the member pair: the pair
        -- pattern in handlers.G below anchors on "name:role", so anything
        -- extra inside it makes an older client drop the member entirely.
        g.specs = g.specs or {}
        g.specs[me] = entry.spec
        g.mapID = entry.mapID
        g.level = entry.level
        if ev == "open" then g.when = entry.when end
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

-- Leader-only: (re)schedules the open board's own group. `when` is a server
-- epoch, or nil for "right now". A no-op for anyone not currently leading the
-- open board - the Monday board has nothing to schedule, and a non-leader has
-- no group to carry the field.
function M.SetWhen(ev, when)
    if ev ~= "open" then return false, "badevent" end
    local ok, why = Ready(ev)
    if not ok then return false, why end
    local me = EnsureSelf(ev)
    if not me or not IsLeading(ev) then return false, "nogroup" end

    local w = tonumber(when)
    if not w or w <= 0 then w = nil end

    local b = boards[ev]
    b.me.when = w
    local g = b.groups[me]
    g.when = w
    g.ts = Now()
    Persist()
    SendGroup(ev)
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

-- classCache[fullName] = classFileName ("WARRIOR", ...), fullName in
-- GetGuildRosterInfo's own form. Board entries are always keyed "Name-Realm"
-- (MyName/SenderKey above both guarantee it), and the online scan below
-- already matches board names against the roster's fullName with no
-- Ambiguate step - proof the two already agree on shape - so this reuses
-- that same key rather than inventing a second one.
local classCache = {}

-- One pass fills both the online set and the class cache, because both come
-- off the same GetGuildRosterInfo row and walking the roster is the expensive
-- part. GUILD_ROSTER_UPDATE arrives in bursts - every login, logout and rank
-- change anywhere in the guild fires one - so the 20-second guard that
-- already kept the online scan off the hot path now covers the class cache
-- too, instead of the cache paying O(roster) per event.
--
-- Both tables are rebuilt rather than merged into, so someone who left the
-- guild stops being coloured as a guildie instead of lingering forever.
local function ScanRoster()
    local now = Now()
    if rosterOnline and now - rosterAt < ROSTER_CACHE then return rosterOnline end
    local set, classes, online = {}, {}, {}
    if GetNumGuildMembers and GetGuildRosterInfo then
        local total = GetNumGuildMembers() or 0
        for i = 1, total do
            local fullName, _, _, _, _, _, _, _, isOnline, _, classFileName =
                GetGuildRosterInfo(i)
            if fullName then
                if isOnline then set[fullName] = true end
                online[fullName] = isOnline == true
                if classFileName then classes[fullName] = classFileName end
            end
        end
    end
    rosterOnline, rosterAt = set, now
    classCache = classes
    onlineCache = online
    return set
end

local function OnlineSet()
    return ScanRoster()
end

-- nil until the roster has told us, or for anyone it never will (addon
-- message senders outside the guild, roster still loading). Callers fall
-- back to the name colour they always had.
function M.ClassOf(name)
    return name and classCache[name] or nil
end

-- true/false once the roster has said so, nil for anyone not in it (or not
-- scanned yet) - never guessed at, so a caller can tell "not shown" apart
-- from "shown offline".
function M.IsOnline(fullName)
    if not fullName then return nil end
    ScanRoster()
    local v = onlineCache[fullName]
    if v == nil then return nil end
    return v
end

-- Nudges the client into a fresh guild-roster fetch; GUILD_ROSTER_UPDATE
-- picks up the result. The server throttles this to about once per 10s on
-- its own, so nothing here adds a second throttle on top of it.
function M.RequestRoster()
    if not C_GuildInfo or not C_GuildInfo.GuildRoster then return end
    pcall(C_GuildInfo.GuildRoster)
end

function M.Groups(ev)
    if not Ready(ev) then return {} end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    local out = {}
    for leader, g in pairs(b.groups) do
        -- A leader we have not heard from takes the whole group with them:
        -- nobody else may edit that roster, so it can only go stale.
        if not IsGroupStale(ev, g, leader, me) then
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
                    members[#members + 1] = {
                        name = name,
                        role = role,
                        -- Same precedence SpecFor publishes with: the
                        -- member's own entry first, the roster's sidecar
                        -- only for someone we have never heard from.
                        spec = (e and e.spec) or (g.specs and g.specs[name]) or nil,
                        online = M.IsOnline(name),
                    }
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
                when = g.when,
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
        local wa, wc = a.when or 0, c.when or 0
        if wa ~= wc then return wa < wc end
        if (a.level or 0) ~= (c.level or 0) then return (a.level or 0) > (c.level or 0) end
        return a.leader < c.leader
    end)
    return out
end

function M.Pool(ev)
    if not Ready(ev) then return {} end
    local me = EnsureSelf(ev)
    local b = boards[ev]
    OnlineSet()
    local out = {}
    for name, e in pairs(b.entries) do
        if not e.leader and not IsStale(ev, e.seen, name, me) then
            out[#out + 1] = {
                name = name,
                role = e.role,
                spec = e.spec,
                bracket = e.bracket,
                mapID = e.mapID,
                level = e.level,
                keyName = KeyName(e.mapID),
                online = M.IsOnline(name),
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
        Say(("  entry %s: %s spec=%s %s %s key=%s+%s leader=%s ts=%s seen=%s"):format(
            name, tostring(e.role), tostring(e.spec), tostring(e.intent),
            tostring(e.bracket),
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
    local intent = Unwire(fields[5])
    b.entries[sender] = {
        role = Unwire(fields[4]),
        intent = intent,
        bracket = Unwire(fields[6]),
        mapID = tonumber(Unwire(fields[7]) or ""),
        level = tonumber(Unwire(fields[8]) or ""),
        leader = Unwire(fields[9]),
        spec = SpecFromWire(fields[10]),
        ts = ts,
        seen = Now(),
    }
    -- A leader who now says "join" rather than "lead" - a client we never saw
    -- disband, only heard from again afterwards - takes their cached group
    -- with them, same as an explicit D. ClearLeader runs on b.entries before
    -- EnsureSelf has necessarily re-linked ours to b.me, so our own leader
    -- pointer is fixed up separately below, exactly as handlers.D does.
    if intent ~= "lead" and b.groups[sender] then
        b.groups[sender] = nil
        ClearLeader(ev, sender, nil)
        local me = EnsureSelf(ev)
        if me and b.me and b.me.leader == sender then
            b.me.leader = nil
            b.me.ts = Now()
            SendEntry(ev)
        end
    end
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
        if g.specs then g.specs[sender] = nil end
        g.ts = Now()
        SendGroup(ev)
    end
    -- A leader who withdraws takes their cached group with them, same as an
    -- explicit D - nobody else may edit that roster, and leaving it behind
    -- would show a group whose own leader denies ever having led it.
    local hadGroup = b.groups[sender] ~= nil
    if hadGroup then
        b.groups[sender] = nil
        ClearLeader(ev, sender, nil)
        local myName = EnsureSelf(ev)
        if myName and b.me and b.me.leader == sender then
            b.me.leader = nil
            b.me.ts = Now()
            SendEntry(ev)
        end
    end
    if not hadEntry and not wasMember and not hadGroup then return end
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

    local members, specs = {}, {}
    local raw = Unwire(fields[6])
    if raw then
        -- The spec list is positional against the member list, so both are
        -- walked by the same index. A sender too old to send one leaves
        -- specList nil and every member simply unknown; a short list runs out
        -- and the rest are unknown too. Indexing by the *pair* position, not
        -- by how many pairs were accepted, keeps a malformed pair in the
        -- middle from shifting everything after it.
        local pairList = Split(raw, ",")
        local rawSpecs = Unwire(fields[7])
        local specList = rawSpecs and Split(rawSpecs, ",") or nil
        for i = 1, #pairList do
            local name, role = pairList[i]:match("^(.+):([THD])$")
            if name then
                members[name] = role
                local s = specList and SpecFromWire(specList[i])
                if s then specs[name] = s end
            end
        end
    end
    b.groups[sender] = {
        mapID = tonumber(Unwire(fields[4]) or ""),
        level = tonumber(Unwire(fields[5]) or ""),
        ts = ts,
        seen = Now(),
        members = members,
        specs = specs,
        -- Field 8, absent from anyone who predates it - WhenFromWire reads
        -- nil the same as "-" or "0", so an older sender's G is unaffected.
        when = WhenFromWire(fields[8]),
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
    -- Whatever their entry told us, if it told us anything. A joiner we have
    -- never heard from gets no spec until their E arrives, at which point
    -- SpecFor prefers it over this anyway.
    g.specs = g.specs or {}
    g.specs[sender] = entry and entry.spec or nil
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
    if g.specs then g.specs[sender] = nil end
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
ef:RegisterEvent("GUILD_ROSTER_UPDATE")

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
            -- A leader who logs back in days after their own scheduled run
            -- must not re-broadcast it as if it were still on: past grace, it
            -- is disbanded here rather than left for them to notice and
            -- withdraw by hand.
            PruneOwnSchedule("open")
            if not IsInInstance or not IsInInstance() then ReadKeystone() end
            if not IsInGuild or not IsInGuild() then return end
            -- A relog should keep us on the open board, so the saved entry is
            -- re-announced rather than waiting for the first heartbeat.
            if boards.open and boards.open.me then StartHeartbeat() end
            if isLogin and not summaryPrinted then
                summaryPrinted = true
                -- Nudge the client into fetching the roster if nothing else
                -- has yet; the scan below picks up whatever a guild frame
                -- opened earlier this session left lying around, and
                -- GUILD_ROSTER_UPDATE refreshes it for real once the request
                -- lands.
                if C_GuildInfo and C_GuildInfo.GuildRoster then
                    C_GuildInfo.GuildRoster()
                end
                ScanRoster()
                -- The entry about to go out came off SavedVariables, so its
                -- spec is last session's. Talent data is usually ready by
                -- now; when it is not, MySpec says nothing and the saved
                -- value stands rather than being replaced by nothing.
                local mySpec = M.MySpec()
                local myName = MyName()
                for _, ev in ipairs(EVENTS) do
                    local b = boards[ev]
                    if b and b.me and mySpec then
                        b.me.spec = mySpec
                        local g = myName and b.groups[myName]
                        if g and g.members and g.members[myName] then
                            g.specs = g.specs or {}
                            g.specs[myName] = mySpec
                        end
                    end
                    M.Refresh(ev, true)
                    SendEntry(ev)
                    if IsLeading(ev) then SendGroup(ev) end
                end
                Persist()
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
            -- The role has the same login race as the spec below: with talent
            -- data not yet loaded, GetSpecialization() is nil and MyRole falls
            -- through to its "D" default, which would flip a saved tank to DPS
            -- and broadcast it. A live index the client will not give is
            -- treated as "no opinion" for the role too.
            local liveIndex = GetSpecialization and GetSpecialization()
            local role = nil
            if liveIndex and not IsSecret(liveIndex) then role = M.MyRole() end
            local spec = M.MySpec()
            local me = MyName()
            local changed = false
            for _, ev in ipairs(EVENTS) do
                local b = boards[ev]
                -- This event also fires during login, before talent data is
                -- ready, and MySpec is nil until it is. Treating that nil as
                -- a change would wipe the spec restored from SavedVariables
                -- and publish 0 for the rest of the session, so "the client
                -- will not say" keeps what we already knew rather than
                -- overwriting it.
                local newSpec = (b and b.me and (spec or b.me.spec)) or spec
                local newRole = (b and b.me and (role or b.me.role)) or role
                -- Spec is checked as well as role, because the common respec
                -- keeps the role: Fire to Frost is still D, and before the
                -- spec rode the wire that was correctly nothing to announce.
                if b and b.me and (b.me.role ~= newRole or b.me.spec ~= newSpec) then
                    b.me.role = newRole
                    b.me.spec = newSpec
                    b.me.ts = Now()
                    local g = me and b.groups[me]
                    if g and g.members and g.members[me] then
                        g.members[me] = newRole
                        g.specs = g.specs or {}
                        g.specs[me] = newSpec
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

    elseif event == "GUILD_ROSTER_UPDATE" then
        -- This fires in bursts - every login, logout and rank change anywhere
        -- in the guild - so the repaint (not the scan itself; ScanRoster has
        -- its own 20-second guard) is throttled to once per five seconds, and
        -- only a repaint that actually runs invalidates the cached scan, so a
        -- burst that lands inside the throttle still costs one roster walk.
        ns.safecall(function()
            local now = Now()
            if now - lastRosterFire < ROSTER_FIRE_THROTTLE then return end
            lastRosterFire = now
            rosterAt = 0
            ScanRoster()
            for _, ev in ipairs(EVENTS) do Fire(ev) end
        end)
    end
end)

-- Exposed for the headless tests in tools/monday_test.lua, which drive the
-- module through its own event handler rather than reaching into its state.
M._frame = ef
M._boards = boards
