-- Headless tests for GuildPlaybook/Monday.lua.
--
--   lua GuildPlaybook/tools/monday_test.lua
--
-- Monday.lua only ever reaches the outside world through WoW globals, so the
-- harness stubs those and drives the module through its own event handler
-- rather than reaching into its internals. Every test gets a freshly loaded
-- copy of the module, because the boards live in file-locals.
--
-- tools/ is excluded from the release zip; this never ships to the client.

local MODULE = "GuildPlaybook/Monday.lua"

-- ------------------------------------------------------------------
-- Assertions
-- ------------------------------------------------------------------

local passed, failed = 0, 0

local function check(ok, label, detail)
    if ok then
        passed = passed + 1
    else
        failed = failed + 1
        io.write("FAIL: ", label, detail and ("\n      " .. tostring(detail)) or "", "\n")
    end
end

local function eq(got, want, label)
    check(got == want, label, ("got %s, want %s"):format(tostring(got), tostring(want)))
end

-- ------------------------------------------------------------------
-- Environment
-- ------------------------------------------------------------------

local REALM = "Caelestrasz"

-- 2026-09-08 is a Tuesday; the Monday it points at is 2026-09-14.
local DEFAULT_CAL = { year = 2026, month = 9, monthDay = 8, weekday = 3, hour = 12, minute = 0 }
local TARGET = "2026-09-14"
local MON = "M" .. TARGET       -- the Monday board's wire key
local OPEN = "open"             -- the open board's wire key
-- Dashes are pattern quantifiers, so the key needs escaping wherever it is
-- matched rather than compared.
local MON_PAT = MON:gsub("%-", "%%-")

local function newEnv(opts)
    opts = opts or {}
    local env = {
        now = opts.now or 1757332800,
        cal = opts.cal or DEFAULT_CAL,
        player = opts.player or "Vizzo",
        specRole = opts.specRole or "DAMAGER",
        key = opts.key,
        secretKey = opts.secretKey or false,
        challenge = false,
        sent = {},
        printed = {},
        timers = {},
        tickers = {},
    }

    _G.GuildPlaybookDB = opts.db or {}

    _G.time = os.time
    _G.date = os.date
    _G.GetServerTime = function() return env.now end

    _G.print = function(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
        env.printed[#env.printed + 1] = table.concat(parts, " ")
    end

    _G.UnitName = function() return env.player end
    _G.GetNormalizedRealmName = function() return REALM end
    _G.IsInGuild = function() return opts.noGuild ~= true end
    _G.IsInInstance = function() return false end
    _G.GetSpecialization = function() return 1 end
    _G.GetSpecializationRole = function() return env.specRole end
    -- The numeric spec id, which is a *different* thing from the 1-4 index
    -- GetSpecialization returns. nil by default, modelling a client that will
    -- not say: every existing test therefore goes on sending the wire's "not
    -- told" value, and only the tests that opt in exercise a real id.
    env.specID = opts.specID
    _G.GetSpecializationInfo = function(index)
        if index ~= 1 then return nil end
        return env.specID
    end
    _G.GetNumGuildMembers = function() return 0 end
    _G.GetGuildRosterInfo = function() return nil end

    env.chat = {}
    env.invited = {}
    env.party = {}
    env.raid = {}
    -- The deprecated global shim. Anything landing here rather than on
    -- C_ChatInfo means the module reached for the wrong one.
    _G.SendChatMessage = function(text, chattype)
        env.chat[#env.chat + 1] = { text = text, chattype = chattype, via = "global" }
    end
    _G.UnitInParty = function(unit) return env.party[unit] == true end
    _G.UnitInRaid = function(unit) return env.raid[unit] == true end
    _G.C_PartyInfo = {
        InviteUnit = function(name) env.invited[#env.invited + 1] = name end,
    }

    -- UnitFullName takes a *unit*, and only resolves players the client has
    -- loaded - your party, your target, someone in your zone. A guildie
    -- questing elsewhere is not one of those. This models that faithfully,
    -- because it is the whole reason the boards cannot reuse Core's MDT sender
    -- key: a generous stub here would hide the bug rather than catch it.
    _G.UnitFullName = function(unit)
        -- Your own name is a valid unit token, which is what Core's commtest
        -- loopback rests on. Anyone else's is not, unless they are grouped.
        if unit == "player" or unit == env.player then return env.player, REALM end
        return nil
    end
    -- "short" drops any realm; "none" drops only our own, which is the form
    -- Core's MDT sender key depends on.
    _G.Ambiguate = function(name, mode)
        name = tostring(name or "")
        if mode == "short" then return (name:gsub("%-.*$", "")) end
        return (name:gsub("%-" .. REALM .. "$", ""))
    end

    -- A secret value is modelled as a table nobody is allowed to inspect.
    local SECRET = setmetatable({}, { __tostring = function() return "<secret>" end })
    _G.issecretvalue = function(v) return v == SECRET end

    _G.C_DateAndTime = {
        GetCurrentCalendarTime = function() return env.cal end,
    }
    _G.C_ChallengeMode = {
        IsChallengeModeActive = function() return env.challenge end,
        GetMapUIInfo = function(mapID) return env.mapName or ("Map" .. tostring(mapID)) end,
    }
    _G.C_MythicPlus = {
        GetOwnedKeystoneChallengeMapID = function()
            if env.secretKey then return SECRET end
            return env.key and env.key.mapID or nil
        end,
        GetOwnedKeystoneLevel = function()
            if env.secretKey then return SECRET end
            return env.key and env.key.level or nil
        end,
    }
    _G.C_ChatInfo = {
        RegisterAddonMessagePrefix = function() return 0 end,
        SendAddonMessage = function() end,
        SendChatMessage = function(text, chattype)
            env.chat[#env.chat + 1] = { text = text, chattype = chattype, via = "C_ChatInfo" }
        end,
    }
    _G.C_Timer = {
        After = function(delay, fn)
            env.timers[#env.timers + 1] = { at = env.now + (delay or 0), fn = fn }
        end,
        NewTicker = function(interval, fn)
            local ticker = {
                at = env.now + interval,
                interval = interval,
                fn = fn,
                cancelled = false,
            }
            function ticker:Cancel() self.cancelled = true end
            env.tickers[#env.tickers + 1] = ticker
            return ticker
        end,
    }
    _G.ChatThrottleLib = {
        SendAddonMessage = function(_, prio, prefix, text, chattype, target)
            env.sent[#env.sent + 1] = {
                prio = prio, prefix = prefix, text = text,
                chattype = chattype, target = target,
            }
        end,
    }

    _G.CreateFrame = function()
        local frame = { events = {} }
        function frame:RegisterEvent(e) self.events[e] = true end
        function frame:UnregisterEvent(e) self.events[e] = nil end
        function frame:SetScript(which, fn) if which == "OnEvent" then env.onEvent = fn end end
        return frame
    end

    local ns = {}
    function ns.safecall(fn, ...)
        if not fn then return end
        local ok, err = pcall(fn, ...)
        if not ok then
            env.printed[#env.printed + 1] = "ERROR " .. tostring(err)
            env.error = tostring(err)
        end
    end
    -- A faithful port of Core.lua's ns.MdtSenderKey, so a test can assert what
    -- it does and does not resolve. Monday.lua must not be using it.
    function ns.MdtSenderKey(sender)
        local name, realm = UnitFullName(Ambiguate(sender or "", "none"))
        if not name then return nil end
        if not realm or #realm < 3 then
            local _, playerRealm = UnitFullName("player")
            realm = playerRealm
        end
        if not realm or realm == "" then return nil end
        return name .. "-" .. realm
    end
    ns.MONDAY_BRACKETS = {
        { id = "low", label = "Low", min = 2, max = 6 },
        { id = "mid", label = "Mid", min = 6, max = 10 },
        { id = "high", label = "High", min = 10, max = 15 },
        { id = "any", label = "Any" },
    }

    assert(loadfile(MODULE))("GuildPlaybook", ns)
    env.ns = ns
    env.M = ns.Monday

    function env.fire(event, ...)
        assert(env.onEvent, "module registered no OnEvent handler")
        env.onEvent(nil, event, ...)
    end

    function env.recv(text, sender, channel)
        env.fire("CHAT_MSG_ADDON", "GPMM2", text, channel or "GUILD", sender)
    end

    -- Runs every timer and ticker whose deadline has passed, advancing first.
    function env.tick(seconds)
        env.now = env.now + (seconds or 0)
        local due, keep = {}, {}
        for _, t in ipairs(env.timers) do
            if t.at <= env.now then due[#due + 1] = t else keep[#keep + 1] = t end
        end
        env.timers = keep
        table.sort(due, function(a, b) return a.at < b.at end)
        for _, t in ipairs(due) do t.fn() end

        for _, tk in ipairs(env.tickers) do
            local guard = 0
            while not tk.cancelled and tk.interval > 0 and tk.at <= env.now and guard < 1000 do
                tk.at = tk.at + tk.interval
                guard = guard + 1
                tk.fn(tk)
            end
        end
    end

    function env.liveTickers()
        local n = 0
        for _, tk in ipairs(env.tickers) do
            if not tk.cancelled then n = n + 1 end
        end
        return n
    end

    function env.clearSent() env.sent = {} end

    -- Last outbound message with the given command letter, optionally scoped
    -- to one board's wire key.
    function env.last(cmd, wire)
        for i = #env.sent, 1, -1 do
            local m = env.sent[i]
            if m.text:sub(1, 1) == cmd
                and (not wire or m.text:match("^%S+%s+(%S+)") == wire) then
                return m
            end
        end
    end

    function env.count(cmd, wire)
        local n = 0
        for _, m in ipairs(env.sent) do
            if m.text:sub(1, 1) == cmd
                and (not wire or m.text:match("^%S+%s+(%S+)") == wire) then
                n = n + 1
            end
        end
        return n
    end

    function env.board(ev) return env.M._boards[ev] end

    function env.load()
        env.fire("ADDON_LOADED", "GuildPlaybook")
        return env
    end

    return env
end

-- ------------------------------------------------------------------
-- 1. Target Monday
-- ------------------------------------------------------------------

do
    local cases = {
        { { year = 2026, month = 9, monthDay = 8,  weekday = 3 }, "2026-09-14", "Tuesday looks a week ahead" },
        { { year = 2026, month = 9, monthDay = 14, weekday = 2 }, "2026-09-14", "Monday means today" },
        { { year = 2026, month = 9, monthDay = 13, weekday = 1 }, "2026-09-14", "Sunday means tomorrow" },
        { { year = 2026, month = 9, monthDay = 12, weekday = 7 }, "2026-09-14", "Saturday means in two days" },
        { { year = 2026, month = 12, monthDay = 30, weekday = 4 }, "2027-01-04", "target rolls over the year" },
    }
    for _, c in ipairs(cases) do
        local env = newEnv({ cal = c[1] }).load()
        eq(env.M.TargetDate(), c[2], "TargetDate: " .. c[3])
    end

    local env = newEnv().load()
    eq(env.M.TargetLabel(), "Mon 14 Sep", "TargetLabel is locale-independent")
end

-- ------------------------------------------------------------------
-- 2. Events and wire keys
-- ------------------------------------------------------------------

do
    local env = newEnv().load()

    eq(#env.M.EVENTS, 2, "there are two boards")
    eq(env.M.EVENTS[1], "monday", "monday is the first")
    eq(env.M.EVENTS[2], "open", "open is the second")
    eq(env.M.EventTitle("monday"), "Mythic Monday", "the monday board has a title")
    eq(env.M.EventTitle("open"), "Open groups", "so does the open board")
    eq(env.M.EventTitle("nope"), nil, "and an unknown id has none")

    -- Event id -> wire key.
    eq(env.M.WireKey("monday"), MON, "the monday wire key carries its date")
    eq(env.M.WireKey("open"), OPEN, "the open wire key is a literal")
    eq(env.M.WireKey("nope"), nil, "an unknown event has no wire key")

    -- Wire key -> event id.
    eq(env.M.EventFromWire(MON), "monday", "the monday key maps back")
    eq(env.M.EventFromWire(OPEN), "open", "the open key maps back")
    eq(env.M.EventFromWire("M2026-09-07"), nil, "last week's monday key is stale")
    eq(env.M.EventFromWire("M2026-09-21"), nil, "next week's is not ours either")
    eq(env.M.EventFromWire("raid"), nil, "an invented key is unknown")
    eq(env.M.EventFromWire(nil), nil, "and a missing key is not a board")

    -- Those two rejections must show up as dropped messages, not stored ones.
    env.recv("E M2026-09-07 100 T join mid 111 8 -", "Anna-" .. REALM)
    env.recv("E raid 100 T join mid 111 8 -", "Anna-" .. REALM)
    eq(#env.M.Pool("monday"), 0, "a stale wire key is dropped")
    eq(#env.M.Pool("open"), 0, "and so is an unknown one")

    -- Invalid event ids are reported, never thrown - the UI is the caller.
    local ok, why = env.M.SignUp("nope", { intent = "join" })
    eq(ok, false, "SignUp on an unknown board fails")
    eq(why, "badevent", "and says why")
    eq(env.M.Me("nope"), nil, "Me on an unknown board is nil")
    eq(#env.M.Groups("nope"), 0, "Groups on an unknown board is empty")
    eq(#env.M.Pool("nope"), 0, "Pool on an unknown board is empty")
    eq(select(2, env.M.Withdraw("nope")), "badevent", "so is Withdraw")
    eq(select(2, env.M.Join("nope", "Anna")), "badevent", "and Join")
    eq(select(2, env.M.Leave("nope")), "badevent", "and Leave")
    eq(select(2, env.M.Disband("nope")), "badevent", "and Disband")
    eq(select(2, env.M.Refresh("nope")), "badevent", "and Refresh")
    eq(env.error, nil, "and none of it raised an error")
end

-- ------------------------------------------------------------------
-- 3. Entry merge and expiry
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.recv("E " .. MON .. " 100 T join mid 111 8 -", "Anna-" .. REALM)
    eq(env.board("monday").entries["Anna-" .. REALM].level, 8, "E is stored")

    -- An older broadcast arriving late must not overwrite a newer one.
    env.recv("E " .. MON .. " 50 D join low 222 3 -", "Anna-" .. REALM)
    eq(env.board("monday").entries["Anna-" .. REALM].level, 8, "E merge keeps the max ts")
    eq(env.board("monday").entries["Anna-" .. REALM].role, "T", "E merge does not half-apply")

    env.recv("E " .. MON .. " 200 H join high 333 12 -", "Anna-" .. REALM)
    eq(env.board("monday").entries["Anna-" .. REALM].level, 12, "a newer E wins")

    -- Our own GUILD sends echo back to us; applying them would be re-entrant.
    env.recv("E " .. MON .. " 5 D join any - - -", "Vizzo-" .. REALM)
    eq(env.board("monday").entries["Vizzo-" .. REALM], nil, "own echo is ignored")

    env.recv("X " .. MON, "Anna-" .. REALM)
    eq(env.board("monday").entries["Anna-" .. REALM], nil, "X removes the entry")
end

-- ------------------------------------------------------------------
-- 4. Signing up to lead
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    local ok = env.M.SignUp("monday", { intent = "lead" })
    check(ok == true, "SignUp lead succeeds with a key")

    local e = env.last("E")
    check(e ~= nil, "SignUp lead emits E")
    -- The trailing 0 is the spec field with nothing in it: this env's
    -- GetSpecializationInfo says nothing, which is exactly what a client too
    -- old to have the getter does.
    check(e and e.text:match("^E " .. MON_PAT .. " %d+ D lead %- 501 12 Vizzo%-" .. REALM .. " 0$") ~= nil,
        "E has the documented field order", e and e.text)
    eq(e and e.chattype, "GUILD", "E goes to GUILD")
    eq(e and e.prefix, "GPMM2", "E uses the bumped GPMM2 prefix")

    local g = env.last("G")
    check(g ~= nil, "SignUp lead emits G")
    check(g and g.text:match("^G " .. MON_PAT .. " %d+ 501 12 Vizzo%-" .. REALM .. ":D 0 %-$") ~= nil,
        "G lists the leader as its own member", g and g.text)

    local groups = env.M.Groups("monday")
    eq(#groups, 1, "the leader sees their own group")
    eq(groups[1].isMine, true, "own group is flagged")
    eq(groups[1].isFull, false, "a one-person group is not full")
    eq(groups[1].missing.T, true, "a tank is still missing")
    eq(groups[1].missing.D, 2, "two dps slots are left")
    eq(#env.M.Pool("monday"), 0, "a signed-up leader is not in the pool")
    eq(#env.M.Groups("open"), 0, "and the other board is untouched")
    eq(_G.GuildPlaybookDB.monday.boards.monday.key, MON,
        "the board is persisted under its wire key")

    -- Leading needs a key; without one it must fail rather than broadcast a
    -- group nobody can run.
    local env2 = newEnv().load()
    env2.fire("PLAYER_ENTERING_WORLD", false, false)
    local ok2, why2 = env2.M.SignUp("monday", { intent = "lead" })
    eq(ok2, false, "SignUp lead without a key fails")
    eq(why2, "nokey", "and says why")
end

-- ------------------------------------------------------------------
-- 5. Join requests, from the leader's side
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("monday", { intent = "lead" })

    env.recv("E " .. MON .. " 100 T join any - - -", "Anna-" .. REALM)
    env.clearSent()
    env.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")

    local g = env.last("G")
    check(g ~= nil, "an accepted J emits a new G")
    check(g and g.text:find("Anna%-" .. REALM .. ":T") ~= nil,
        "the accepted joiner is in the roster", g and g.text)
    eq(env.count("N"), 0, "an accepted J sends no denial")
    eq(env.board("monday").entries["Anna-" .. REALM].leader, "Vizzo-" .. REALM,
        "the joiner's cached entry now points at the leader")
    eq(#env.M.Pool("monday"), 0, "an accepted joiner leaves the pool")

    -- Bob is a second tank. The slot is gone.
    env.recv("E " .. MON .. " 100 T join any - - -", "Bob-" .. REALM)
    env.clearSent()
    env.recv("J " .. MON, "Bob-" .. REALM, "WHISPER")

    local n = env.last("N")
    check(n ~= nil, "a J with no free slot is denied")
    eq(n and n.text, "N " .. MON .. " full", "the denial names the board and reason")
    eq(n and n.chattype, "WHISPER", "the denial is whispered")
    eq(n and n.target, "Bob-" .. REALM, "the denial goes to the joiner")
    eq(env.count("G"), 0, "a denied J does not rewrite the roster")
    eq(#env.M.Pool("monday"), 1, "the denied joiner stays in the pool")

    env.clearSent()
    env.recv("L " .. MON, "Anna-" .. REALM, "WHISPER")
    local g2 = env.last("G")
    check(g2 ~= nil, "a leave rewrites the roster")
    check(g2 and g2.text:find("Anna") == nil, "the leaver is gone from it", g2 and g2.text)
    eq(env.board("monday").entries["Anna-" .. REALM].leader, nil, "and back in the pool")

    -- Someone with no group at all gets told so.
    local solo = newEnv().load()
    solo.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")
    eq(solo.last("N") and solo.last("N").text, "N " .. MON .. " nogroup",
        "a J to a non-leader is denied with nogroup")
end

-- ------------------------------------------------------------------
-- 6. Join requests, from the joiner's side
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.recv("G " .. MON .. " 100 501 12 Anna-" .. REALM .. ":T", "Anna-" .. REALM)
    env.M.SignUp("monday", { intent = "join", bracket = "mid" })
    env.clearSent()

    local ok = env.M.Join("monday", "Anna-" .. REALM)
    eq(ok, true, "Join a known group is accepted locally")
    local j = env.last("J")
    check(j ~= nil, "Join whispers a J")
    eq(j and j.chattype, "WHISPER", "the J is whispered")
    eq(j and j.target, "Anna-" .. REALM, "the J goes to the leader")
    eq(env.M.Me("monday").leader, nil, "membership is not assumed before the leader answers")

    env.clearSent()
    env.recv("G " .. MON .. " 200 501 12 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)
    eq(env.M.Me("monday").leader, "Anna-" .. REALM, "a G listing us sets our leader")
    check(env.last("E") ~= nil, "and we re-broadcast our entry")
    eq(#env.M.Pool("monday"), 0, "we are no longer in the pool")

    env.recv("G " .. MON .. " 300 501 12 Anna-" .. REALM .. ":T", "Anna-" .. REALM)
    eq(env.M.Me("monday").leader, nil, "a G that drops us clears our leader")

    env.recv("G " .. MON .. " 250 501 12 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)
    eq(env.M.Me("monday").leader, nil, "an out-of-order G is dropped")

    env.M.Join("monday", "Anna-" .. REALM)
    env.recv("N " .. MON .. " full", "Anna-" .. REALM, "WHISPER")
    local sawDenial = false
    for _, line in ipairs(env.printed) do
        if line:find("full", 1, true) then sawDenial = true end
    end
    check(sawDenial, "an N prints the reason to chat")
end

-- ------------------------------------------------------------------
-- 7. Disband, withdraw, leave
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("monday", { intent = "join", bracket = "any" })
    env.recv("G " .. MON .. " 100 501 12 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)
    eq(env.M.Me("monday").leader, "Anna-" .. REALM, "we are in Anna's group")
    env.recv("D " .. MON, "Anna-" .. REALM)
    eq(env.M.Me("monday").leader, nil, "a disband clears our leader")
    eq(#env.M.Groups("monday"), 0, "and removes the group")
    eq(#env.M.Pool("monday"), 1, "and puts us back in the pool")

    local lead = newEnv({ key = { mapID = 501, level = 12 } }).load()
    lead.fire("PLAYER_ENTERING_WORLD", false, false)
    lead.M.SignUp("monday", { intent = "lead" })
    lead.recv("E " .. MON .. " 100 T join any - - -", "Anna-" .. REALM)
    lead.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")
    lead.clearSent()
    eq(lead.M.Withdraw("monday"), true, "Withdraw succeeds")
    check(lead.last("D") ~= nil, "Withdraw while leading emits D")
    check(lead.last("X") ~= nil, "Withdraw emits X")
    eq(lead.M.Me("monday"), nil, "the own entry is gone")
    eq(#lead.M.Groups("monday"), 0, "the group is gone")
    eq(lead.board("monday").entries["Anna-" .. REALM].leader, nil,
        "the member is back in the pool")

    local swap = newEnv({ key = { mapID = 501, level = 12 } }).load()
    swap.fire("PLAYER_ENTERING_WORLD", false, false)
    swap.M.SignUp("monday", { intent = "lead" })
    swap.clearSent()
    swap.M.SignUp("monday", { intent = "join", bracket = "low" })
    check(swap.last("D") ~= nil, "lead -> join emits D")
    eq(#swap.M.Groups("monday"), 0, "and drops the group")
    eq(swap.M.Me("monday").bracket, "low", "and keeps the new bracket")

    local mem = newEnv().load()
    mem.fire("PLAYER_ENTERING_WORLD", false, false)
    mem.M.SignUp("monday", { intent = "join", bracket = "any" })
    mem.recv("G " .. MON .. " 100 501 12 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)
    mem.clearSent()
    eq(mem.M.Leave("monday"), true, "Leave succeeds")
    local l = mem.last("L")
    check(l ~= nil, "Leave whispers an L")
    eq(l and l.target, "Anna-" .. REALM, "the L goes to the leader")
    eq(mem.M.Me("monday").leader, nil, "and clears our leader locally")
end

-- ------------------------------------------------------------------
-- 8. Challenge mode: outbound queued, inbound ignored
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    env.challenge = true
    eq(env.M.SignUp("monday", { intent = "lead" }), true, "SignUp works inside a key")
    eq(#env.sent, 0, "but nothing is sent from inside a key")

    env.recv("E " .. MON .. " 100 T join any - - -", "Anna-" .. REALM)
    eq(env.board("monday").entries["Anna-" .. REALM], nil, "inbound is ignored inside a key")

    env.challenge = false
    env.fire("CHALLENGE_MODE_COMPLETED")
    check(env.last("E") ~= nil, "the queued E is flushed on completion")
    check(env.last("G") ~= nil, "the queued G is flushed on completion")

    env.key = { mapID = 502, level = 13 }
    env.clearSent()
    env.tick(3)
    eq(env.M.MyKey().level, 13, "the new key is picked up after the run")
    check(env.last("E") ~= nil, "and broadcast")

    -- A queued message for a board that expired mid-run is dropped on flush.
    local stale = newEnv({ key = { mapID = 501, level = 12 } }).load()
    stale.fire("PLAYER_ENTERING_WORLD", false, false)
    stale.challenge = true
    stale.M.SignUp("monday", { intent = "join", bracket = "any" })
    stale.clearSent()
    stale.cal = { year = 2026, month = 9, monthDay = 15, weekday = 3 }
    stale.challenge = false
    stale.fire("CHALLENGE_MODE_COMPLETED")
    eq(stale.count("E", MON), 0, "a queued message for last week's board is dropped")
end

-- ------------------------------------------------------------------
-- 9. Keystone reads
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(env.M.MyKey().mapID, 501, "a plain keystone is read")
    eq(env.M.MyKey().name, "Map501", "and named")

    local secret = newEnv({ key = { mapID = 501, level = 12 }, secretKey = true }).load()
    secret.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(secret.M.MyKey(), nil, "a secret keystone value reads as no key")
    eq(secret.error, nil, "and raises no error")

    -- The key belongs to the character, so a change reaches every board.
    local env2 = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env2.fire("PLAYER_ENTERING_WORLD", false, false)
    env2.M.SignUp("monday", { intent = "lead" })
    env2.M.SignUp("open", { intent = "join", bracket = "any" })
    env2.clearSent()
    env2.key = { mapID = 777, level = 20 }
    env2.fire("BAG_UPDATE_DELAYED")
    eq(#env2.sent, 0, "BAG_UPDATE_DELAYED is debounced")
    env2.tick(2)
    eq(env2.M.MyKey().level, 20, "the new key is read after the debounce")
    local g = env2.last("G", MON)
    check(g and g.text:find(" 777 20 ") ~= nil,
        "the monday group is rebroadcast with the new key", g and g.text)
    local eo = env2.last("E", OPEN)
    check(eo and eo.text:find(" 777 20 ") ~= nil,
        "and so is the open entry", eo and eo.text)
end

-- ------------------------------------------------------------------
-- 10. Roles, brackets, pool ordering
-- ------------------------------------------------------------------

do
    local env = newEnv({ specRole = "TANK" }).load()
    eq(env.M.MyRole(), "T", "a tank spec maps to T")

    local healer = newEnv({ specRole = "HEALER" }).load()
    eq(healer.M.MyRole(), "H", "a healer spec maps to H")

    eq(#env.M.Brackets(), 4, "the brackets come from the data file")

    local pool = newEnv().load()
    pool.recv("E " .. MON .. " 100 D join high - - -", "Zoe-" .. REALM)
    pool.recv("E " .. MON .. " 100 T join low - - -", "Bob-" .. REALM)
    pool.recv("E " .. MON .. " 100 D join low - - -", "Ann-" .. REALM)
    local p = pool.M.Pool("monday")
    eq(p[1].name, "Bob-" .. REALM, "the pool sorts by bracket, then role")
    eq(p[2].name, "Ann-" .. REALM, "dps follow the tank inside a bracket")
    eq(p[3].name, "Zoe-" .. REALM, "and higher brackets come last")
    eq(p[1].online, nil, "with no guild roster to ask, online is unknown - not a guessed false")
end

-- ------------------------------------------------------------------
-- 11. Requests and the login summary
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("monday", { intent = "lead" })
    env.clearSent()

    env.recv("R " .. MON, "Anna-" .. REALM)
    eq(#env.sent, 0, "the reply to an R is jittered, not immediate")
    env.tick(2)
    check(env.last("E") ~= nil, "the R reply carries our entry")
    check(env.last("G") ~= nil, "and our roster")
    eq(env.count("E"), 1, "and nothing else - no relaying of cached peers")

    -- An R for the other board must not be answered from this one.
    env.clearSent()
    env.recv("R " .. OPEN, "Anna-" .. REALM)
    env.tick(2)
    eq(#env.sent, 0, "an R for a board we are not on gets no reply")

    env.clearSent()
    env.recv("R " .. MON, "Vizzo-" .. REALM)
    env.tick(2)
    eq(#env.sent, 0, "our own R echo is ignored")

    -- Refresh throttles per board.
    env.clearSent()
    eq(env.M.Refresh("monday", true), true, "a forced Refresh sends")
    eq(env.M.Refresh("monday"), false, "a second Refresh inside the window is refused")
    eq(select(2, env.M.Refresh("monday")), "throttled", "and says why")
    eq(env.M.Refresh("open"), true, "the other board has its own throttle")

    -- Summary, empty.
    local sum = newEnv().load()
    sum.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(sum.M.Summary(),
        "Mythic Monday (Mon 14 Sep): 0 groups, 0 in pool. Right now: 0 groups, 0 in pool. You: not signed up. /gp monday",
        "the summary covers both boards when empty")

    -- Summary, both boards populated, monday status wins.
    local sum2 = newEnv({ key = { mapID = 501, level = 12 } }).load()
    sum2.fire("PLAYER_ENTERING_WORLD", false, false)
    sum2.M.SignUp("monday", { intent = "lead" })
    sum2.M.SignUp("open", { intent = "join", bracket = "mid" })
    sum2.recv("E " .. OPEN .. " 100 T join any - - -", "Anna-" .. REALM)
    sum2.recv("G " .. OPEN .. " 100 501 9 Bob-" .. REALM .. ":T", "Bob-" .. REALM)
    eq(sum2.M.Summary(),
        "Mythic Monday (Mon 14 Sep): 1 group, 0 in pool. Right now: 1 group, 2 in pool. You: leading +12 Map501, 1/5. /gp monday",
        "a monday sign-up wins the You: line")

    -- Summary, open only: the board is named so it cannot be misread.
    local sum3 = newEnv().load()
    sum3.fire("PLAYER_ENTERING_WORLD", false, false)
    sum3.M.SignUp("open", { intent = "join", bracket = "low" })
    eq(sum3.M.Summary(),
        "Mythic Monday (Mon 14 Sep): 0 groups, 0 in pool. Right now: 0 groups, 1 in pool. You: in the pool, D, low (right now). /gp monday",
        "an open-only sign-up names the board")

    -- The login path asks both boards and prints the summary five seconds on.
    local login = newEnv().load()
    login.fire("PLAYER_ENTERING_WORLD", true, false)
    check(login.last("R", MON) ~= nil, "login broadcasts an R for monday")
    check(login.last("R", OPEN) ~= nil, "and one for the open board")
    eq(login.count("R"), 2, "two requests, one per board")
    local before = #login.printed
    login.tick(5)
    check(#login.printed > before, "and prints the summary afterwards")
    check(login.printed[#login.printed]:find("Right now:", 1, true) ~= nil,
        "which covers both boards", login.printed[#login.printed])
end

-- ------------------------------------------------------------------
-- 12. Guildless clients stay out of the way
-- ------------------------------------------------------------------

do
    local env = newEnv({ noGuild = true }).load()
    env.fire("PLAYER_ENTERING_WORLD", true, false)
    eq(env.M.Me("monday"), nil, "Me is nil without a guild")
    local ok, why = env.M.SignUp("monday", { intent = "join" })
    eq(ok, false, "SignUp is refused without a guild")
    eq(why, "noguild", "and says why")
    eq(#env.M.Groups("open"), 0, "Groups is empty without a guild")
    eq(#env.M.Pool("open"), 0, "Pool is empty without a guild")
    eq(#env.sent, 0, "and nothing is broadcast")
end

-- ------------------------------------------------------------------
-- 13. The monday board expires when its date passes
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.M.SignUp("monday", { intent = "join", bracket = "any" })
    env.M.SignUp("open", { intent = "join", bracket = "any" })
    check(env.M.Me("monday") ~= nil, "signed up for this Monday")

    env.cal = { year = 2026, month = 9, monthDay = 15, weekday = 3 }
    eq(env.M.TargetDate(), "2026-09-21", "the target moved to the next Monday")
    eq(env.M.Me("monday"), nil, "the old monday board cleared itself")
    eq(#env.M.Groups("monday"), 0, "including its groups")
    check(env.M.Me("open") ~= nil, "but the open board is unaffected by the date")

    -- A saved monday board for last week is not loaded back in.
    local staleDb = { monday = { boards = {
        monday = {
            key = "M2026-09-07",
            me = { role = "D", intent = "join", bracket = "any", ts = 1 },
            entries = { ["Anna-" .. REALM] = { role = "T", ts = 1 } },
            groups = {},
        },
    } } }
    local stale = newEnv({ db = staleDb }).load()
    eq(stale.M.Me("monday"), nil, "a saved board from last week is discarded")
    eq(#stale.M.Pool("monday"), 0, "along with its entries")

    -- This week's saved board survives a reload.
    local freshDb = { monday = { boards = {
        monday = {
            key = MON,
            me = { role = "D", intent = "join", bracket = "mid", ts = 1 },
            entries = { ["Vizzo-" .. REALM] = { role = "D", intent = "join", bracket = "mid", ts = 1 } },
            groups = {},
        },
    } } }
    local fresh = newEnv({ db = freshDb }).load()
    fresh.fire("PLAYER_ENTERING_WORLD", false, true)
    eq(fresh.M.Me("monday") and fresh.M.Me("monday").bracket, "mid",
        "this week's saved board is restored")
    -- The own entry and the entries table must be the same object again, or a
    -- later edit to one silently fails to show up in the other.
    fresh.M.Me("monday").bracket = "high"
    eq(fresh.board("monday").entries["Vizzo-" .. REALM].bracket, "high",
        "the own entry is re-linked into the entries table after a load")

    -- v1.3.0's flat table was never released, so it is thrown away, not migrated.
    local oldDb = { monday = {
        mon = TARGET,
        me = { role = "D", intent = "join", bracket = "mid", ts = 1 },
        entries = { ["Anna-" .. REALM] = { role = "T", ts = 1, seen = 1 } },
        groups = {},
    } }
    local old = newEnv({ db = oldDb }).load()
    eq(old.error, nil, "an old flat saved board loads without error")
    eq(old.M.Me("monday"), nil, "and is discarded rather than migrated")
    eq(#old.M.Pool("monday"), 0, "along with its entries")
    check(_G.GuildPlaybookDB.monday.boards ~= nil, "it is replaced by the new shape")
    eq(_G.GuildPlaybookDB.monday.mon, nil, "with the old field gone")
end

-- ------------------------------------------------------------------
-- 14. The open board ages records out
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.recv("E " .. OPEN .. " 100 T join any - - -", "Anna-" .. REALM)
    env.recv("G " .. OPEN .. " 100 501 9 Bob-" .. REALM .. ":T", "Bob-" .. REALM)
    eq(#env.M.Pool("open"), 1, "a fresh open entry is listed")
    eq(#env.M.Groups("open"), 1, "and a fresh open group")

    -- Fourteen minutes on, still here.
    env.now = env.now + 14 * 60
    eq(#env.M.Pool("open"), 1, "still listed inside the window")
    eq(#env.M.Groups("open"), 1, "and so is the group")

    -- Sixteen: assumed logged out. The leader takes the group with them,
    -- because nobody else may edit that roster.
    env.now = env.now + 2 * 60
    eq(#env.M.Pool("open"), 0, "an unseen open entry is hidden")
    eq(#env.M.Groups("open"), 0, "and an unseen leader hides the whole group")

    -- The monday board has no such expiry.
    local mon = newEnv().load()
    mon.fire("PLAYER_ENTERING_WORLD", false, false)
    mon.recv("E " .. MON .. " 100 T join any - - -", "Anna-" .. REALM)
    mon.now = mon.now + 60 * 60
    eq(#mon.M.Pool("monday"), 1, "a monday entry does not age out")

    -- Stale records are pruned, not merely hidden, when the board is loaded.
    local pruneDb = { monday = { boards = {
        open = {
            key = OPEN,
            me = nil,
            entries = {
                ["Anna-" .. REALM] = { role = "T", intent = "join", ts = 1, seen = 1 },
                ["Bob-" .. REALM] = { role = "H", intent = "join", ts = 1, seen = 1757332800 },
            },
            groups = {
                ["Cid-" .. REALM] = { ts = 1, seen = 1, members = {} },
            },
        },
    } } }
    local pruned = newEnv({ db = pruneDb }).load()
    eq(pruned.board("open").entries["Anna-" .. REALM], nil,
        "a stale open entry is pruned on load")
    check(pruned.board("open").entries["Bob-" .. REALM] ~= nil,
        "a fresh one survives the load")
    eq(pruned.board("open").groups["Cid-" .. REALM], nil,
        "a stale open group is pruned on load")
end

-- ------------------------------------------------------------------
-- 15. The open board's heartbeat
-- ------------------------------------------------------------------

do
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(env.liveTickers(), 0, "no heartbeat before signing up")

    env.M.SignUp("open", { intent = "join", bracket = "any" })
    eq(env.liveTickers(), 1, "signing up on the open board starts a heartbeat")
    env.clearSent()

    env.tick(5 * 60)
    check(env.last("E", OPEN) ~= nil, "the heartbeat re-sends our entry")
    eq(env.count("E", MON), 0, "and only for the open board")

    -- It keeps proving presence, which is what stops peers ageing us out.
    env.clearSent()
    env.tick(5 * 60)
    check(env.last("E", OPEN) ~= nil, "and again on the next beat")

    -- Nothing leaves the client inside a key, heartbeat included.
    env.challenge = true
    env.clearSent()
    env.tick(5 * 60)
    eq(#env.sent, 0, "the beat is skipped inside a key, not queued")
    env.challenge = false

    -- Withdrawing stops it.
    env.M.Withdraw("open")
    eq(env.liveTickers(), 0, "withdrawing stops the heartbeat")
    env.clearSent()
    env.tick(5 * 60)
    eq(#env.sent, 0, "and nothing is sent afterwards")

    -- Signing up on the monday board alone starts no heartbeat.
    local mon = newEnv({ key = { mapID = 501, level = 12 } }).load()
    mon.fire("PLAYER_ENTERING_WORLD", false, false)
    mon.M.SignUp("monday", { intent = "lead" })
    eq(mon.liveTickers(), 0, "the monday board needs no heartbeat")

    -- A relog re-announces the saved open entry rather than waiting a beat.
    local relogDb = { monday = { boards = {
        open = {
            key = OPEN,
            me = { role = "D", intent = "join", bracket = "any", ts = 1, seen = 1757332800 },
            entries = {},
            groups = {},
        },
    } } }
    local relog = newEnv({ db = relogDb }).load()
    relog.fire("PLAYER_ENTERING_WORLD", true, false)
    check(relog.last("E", OPEN) ~= nil, "a relog re-broadcasts the saved open entry")
    eq(relog.liveTickers(), 1, "and restarts the heartbeat")
end

-- ------------------------------------------------------------------
-- 16. The two boards are independent
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)

    eq(env.M.SignUp("monday", { intent = "lead" }), true, "lead on the monday board")
    env.recv("G " .. OPEN .. " 100 601 8 Anna-" .. REALM .. ":T", "Anna-" .. REALM)
    eq(env.M.SignUp("open", { intent = "join", bracket = "any" }), true,
        "and join the pool on the open board")
    eq(env.M.Join("open", "Anna-" .. REALM), true, "then join a group there")
    env.recv("G " .. OPEN .. " 200 601 8 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)

    eq(env.M.Me("monday").intent, "lead", "the monday entry still leads")
    eq(env.M.Me("monday").leader, "Vizzo-" .. REALM, "its own group")
    eq(env.M.Me("open").leader, "Anna-" .. REALM, "while the open entry follows Anna")
    eq(#env.M.Groups("monday"), 1, "one group on monday")
    eq(#env.M.Groups("open"), 1, "one on open")

    -- Leaving one board leaves the other alone.
    eq(env.M.Leave("open"), true, "leave the open group")
    eq(env.M.Me("open").leader, nil, "which clears the open leader")
    eq(env.M.Me("monday").leader, "Vizzo-" .. REALM, "and leaves monday untouched")

    -- Both boards persist side by side.
    local db = _G.GuildPlaybookDB.monday.boards
    eq(db.monday.key, MON, "the monday board is saved under its dated key")
    eq(db.open.key, OPEN, "and the open board under its literal one")
    check(db.monday.me ~= nil, "with our monday entry")
    check(db.open.me ~= nil, "and our open entry")

    -- Withdrawing from monday does not touch the open board.
    eq(env.M.Withdraw("monday"), true, "withdraw from monday")
    eq(env.M.Me("monday"), nil, "the monday entry is gone")
    check(env.M.Me("open") ~= nil, "the open entry survives")

    -- Callbacks say which board changed.
    local seen = {}
    env.M.RegisterCallback(function(ev) seen[#seen + 1] = ev end)
    env.M.SignUp("open", { intent = "join", bracket = "high" })
    eq(seen[#seen], "open", "the callback names the board that changed")
    env.M.SignUp("monday", { intent = "join", bracket = "low" })
    eq(seen[#seen], "monday", "and again for the other one")
end

-- ------------------------------------------------------------------
-- 17. Sender keys: the boards are guild-wide, not party-wide
-- ------------------------------------------------------------------

do
    local env = newEnv().load()

    env.recv("E " .. MON .. " 100 T join mid 111 8 -", "Anna-OtherRealm")
    check(env.board("monday").entries["Anna-OtherRealm"] ~= nil,
        "a cross-realm guildie's message is accepted")

    env.recv("E " .. MON .. " 100 H join low 222 4 -", "Bob")
    check(env.board("monday").entries["Bob-" .. REALM] ~= nil,
        "a bare same-realm sender gets our realm appended")

    -- The reason this needs its own normaliser: Core's MDT one is unit-based
    -- and resolves neither of the senders above.
    eq(env.ns.MdtSenderKey("Bob"), nil,
        "Core's MDT sender key cannot resolve an unloaded guildie")
    eq(env.ns.MdtSenderKey("Anna-OtherRealm"), nil, "nor a cross-realm one")
    eq(env.ns.MdtSenderKey("Vizzo"), "Vizzo-" .. REALM,
        "it only works for players the client has loaded")

    eq(#env.M.Pool("monday"), 2, "both guildies land in the pool")

    env.recv("E " .. MON .. " 100 D join any - - -", "")
    eq(#env.M.Pool("monday"), 2, "an empty sender is dropped")
end

-- ------------------------------------------------------------------
-- 18. A roster that cannot fit in one addon message
-- ------------------------------------------------------------------

do
    local huge = string.rep("Q", 300)
    local env = newEnv({ player = huge, key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    eq(env.M.SignUp("monday", { intent = "lead" }), true,
        "SignUp lead survives an unsendable name")
    local g = env.last("G")
    check(g ~= nil, "the group is still broadcast")
    -- Roster and spec list both emptied, and emptied together: a roster cut
    -- shorter than its positional spec list would mis-icon every member.
    check(g and g.text:sub(-4) == " - -",
        "with an empty roster rather than an endless trim", g and g.text)
    check(g and #g.text <= 255, "and inside the addon-message limit", g and #g.text)

    local warned = false
    for _, line in ipairs(env.printed) do
        if line:find("too long to broadcast", 1, true) then warned = true end
    end
    check(warned, "and the truncation is reported, not silent")

    local long = newEnv({ player = "Vizzo", key = { mapID = 501, level = 12 } }).load()
    long.fire("PLAYER_ENTERING_WORLD", false, false)
    long.M.SignUp("monday", { intent = "lead" })
    for i = 1, 3 do
        local name = string.rep("N", 70) .. i .. "-" .. REALM
        long.recv("E " .. MON .. " 100 D join any - - -", name)
        long.recv("J " .. MON, name, "WHISPER")
    end
    local g2 = long.last("G")
    check(g2 and #g2.text <= 255, "an overlong roster is trimmed to fit", g2 and #g2.text)
    check(g2 and g2.text:find("Vizzo%-" .. REALM .. ":D") ~= nil,
        "and keeps the leader, who is serialised first", g2 and g2.text)
end

-- ------------------------------------------------------------------
-- 19. Ghost members on the open board
-- ------------------------------------------------------------------

do
    -- Our own roster: a member who logs off without withdrawing must not go on
    -- holding their slot, or every later applicant is told the group is full.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "lead" })       -- Vizzo leads as D

    for _, who in ipairs({ "Anna", "Bob" }) do
        env.recv("E " .. OPEN .. " 100 D join any - - -", who .. "-" .. REALM)
        env.recv("J " .. OPEN, who .. "-" .. REALM, "WHISPER")
    end
    env.clearSent()
    env.recv("J " .. OPEN, "Cid-" .. REALM, "WHISPER")
    eq(env.last("N") and env.last("N").text, "N " .. OPEN .. " full",
        "three dps fills the group")

    -- Step the clock one beat at a time, so exactly one heartbeat fires at the
    -- end and the roster it broadcasts is the one under test. Jumping the
    -- clock instead would fire several beats and let a prune that runs *after*
    -- the broadcast look correct on the following beat.
    env.tick(5 * 60)
    env.tick(5 * 60)
    env.tick(5 * 60)        -- Anna is at fifteen minutes exactly: still here

    env.now = env.now + 60  -- and now past the window
    env.recv("E " .. OPEN .. " 200 D join any - - -", "Bob-" .. REALM)
    env.clearSent()
    env.tick(5 * 60)        -- exactly one more beat

    local roster = env.board("open").groups["Vizzo-" .. REALM].members
    eq(roster["Anna-" .. REALM], nil, "the ghost is pruned from our own roster")
    check(roster["Bob-" .. REALM] ~= nil, "the member still announcing stays")
    local g = env.last("G", OPEN)
    check(g ~= nil, "the corrected roster is re-broadcast")
    check(g and g.text:find("Anna") == nil, "without the ghost", g and g.text)
    check(g and g.text:find("Bob") ~= nil, "and with the live member", g and g.text)

    -- The freed slot is really free.
    env.clearSent()
    env.recv("E " .. OPEN .. " 300 D join any - - -", "Cid-" .. REALM)
    env.recv("J " .. OPEN, "Cid-" .. REALM, "WHISPER")
    eq(env.count("N"), 0, "a new dps is no longer told the group is full")
    local g2 = env.last("G", OPEN)
    check(g2 and g2.text:find("Cid") ~= nil, "and takes the freed slot", g2 and g2.text)

    -- A member we accepted but never heard an E from is not mistaken for a
    -- ghost on the very next prune.
    local fresh = newEnv({ key = { mapID = 501, level = 12 } }).load()
    fresh.fire("PLAYER_ENTERING_WORLD", false, false)
    fresh.M.SignUp("open", { intent = "lead" })
    fresh.recv("J " .. OPEN, "Dot-" .. REALM, "WHISPER")
    fresh.tick(5 * 60)
    check(fresh.board("open").groups["Vizzo-" .. REALM].members["Dot-" .. REALM] ~= nil,
        "an unheard joiner survives the next prune")

    -- Zoning corrects the roster too, without waiting for the next beat. The
    -- clock is moved by hand here so no heartbeat fires and the only thing
    -- that can do the pruning is the world-entering path.
    local zone = newEnv({ key = { mapID = 501, level = 12 } }).load()
    zone.fire("PLAYER_ENTERING_WORLD", false, false)
    zone.M.SignUp("open", { intent = "lead" })
    zone.recv("E " .. OPEN .. " 100 T join any - - -", "Anna-" .. REALM)
    zone.recv("J " .. OPEN, "Anna-" .. REALM, "WHISPER")
    zone.now = zone.now + 16 * 60
    zone.clearSent()
    zone.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(zone.board("open").groups["Vizzo-" .. REALM].members["Anna-" .. REALM], nil,
        "zoning prunes the ghost from our roster")
    local zg = zone.last("G", OPEN)
    check(zg ~= nil, "and re-broadcasts the roster")
    check(zg and zg.text:find("Anna") == nil, "without the ghost", zg and zg.text)
end

do
    -- Someone else's roster is theirs to correct. We hide what has gone quiet,
    -- but we do not rewrite their group.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.recv("E " .. OPEN .. " 100 D join any - - -", "Ann-" .. REALM)
    env.recv("G " .. OPEN .. " 100 601 8 Bob-" .. REALM .. ":T,Ann-" .. REALM .. ":D",
        "Bob-" .. REALM)
    eq(#env.M.Groups("open")[1].members, 2, "both members show while fresh")
    eq(env.M.Groups("open")[1].missing.D, 2, "with two dps slots left")

    -- Ann goes quiet; Bob keeps announcing, so the group itself stays.
    env.now = env.now + 16 * 60
    env.recv("G " .. OPEN .. " 200 601 8 Bob-" .. REALM .. ":T,Ann-" .. REALM .. ":D",
        "Bob-" .. REALM)

    local groups = env.M.Groups("open")
    eq(#groups, 1, "a live leader keeps the group listed")
    eq(#groups[1].members, 1, "the quiet member is hidden from the view")
    eq(groups[1].members[1].name, "Bob-" .. REALM, "leaving the leader")
    eq(groups[1].missing.D, 3, "and their slot reads as free")
    eq(groups[1].isFull, false, "fullness is counted from what is shown")
    check(env.board("open").groups["Bob-" .. REALM].members["Ann-" .. REALM] ~= nil,
        "but the cached roster is left for its leader to fix")
end

do
    -- A cached group that is full on paper but holds one ghost. Fullness has
    -- to follow the rows we actually draw, or the page shows a free slot and
    -- refuses to let anyone take it.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local live = { "Cid:H", "Dee:D", "Eve:D" }
    for _, who in ipairs({ "Cid", "Dee", "Eve", "Fay" }) do
        env.recv("E " .. OPEN .. " 100 D join any - - -", who .. "-" .. REALM)
    end
    local roster = "Bob-" .. REALM .. ":T,Cid-" .. REALM .. ":H,Dee-" .. REALM
        .. ":D,Eve-" .. REALM .. ":D,Fay-" .. REALM .. ":D"
    env.recv("G " .. OPEN .. " 100 601 8 " .. roster, "Bob-" .. REALM)

    local before = env.M.Groups("open")[1]
    eq(#before.members, 5, "all five show while everyone is fresh")
    eq(before.isFull, true, "and the group reads as full")

    -- Everyone but Fay keeps announcing.
    env.now = env.now + 16 * 60
    for _, pair in ipairs(live) do
        local who = pair:match("^(%a+)")
        env.recv("E " .. OPEN .. " 200 D join any - - -", who .. "-" .. REALM)
    end
    env.recv("G " .. OPEN .. " 200 601 8 " .. roster, "Bob-" .. REALM)

    local after = env.M.Groups("open")[1]
    eq(#after.members, 4, "the ghost drops out of the view")
    eq(after.isFull, false, "so the group is no longer full")
    eq(after.missing.D, 1, "with one dps slot open")
    eq(after.missing.T, false, "the tank slot is still taken")
    eq(after.missing.H, false, "and so is the healer slot")
end

do
    -- None of this applies to the Monday board, which has no presence rule.
    local mon = newEnv({ key = { mapID = 501, level = 12 } }).load()
    mon.fire("PLAYER_ENTERING_WORLD", false, false)
    mon.M.SignUp("monday", { intent = "lead" })
    mon.recv("E " .. MON .. " 100 T join any - - -", "Anna-" .. REALM)
    mon.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")

    mon.now = mon.now + 60 * 60
    mon.fire("PLAYER_ENTERING_WORLD", false, false)
    mon.tick(0)
    check(mon.board("monday").groups["Vizzo-" .. REALM].members["Anna-" .. REALM] ~= nil,
        "a quiet member keeps their Monday slot")
    eq(#mon.M.Groups("monday")[1].members, 2, "and is still shown")

    -- A cached Monday group whose members we never heard an E from stays whole.
    local cache = newEnv().load()
    cache.fire("PLAYER_ENTERING_WORLD", false, false)
    cache.recv("G " .. MON .. " 100 601 8 Bob-" .. REALM .. ":T,Ann-" .. REALM .. ":D",
        "Bob-" .. REALM)
    cache.now = cache.now + 60 * 60
    eq(#cache.M.Groups("monday")[1].members, 2,
        "an unheard Monday member is not hidden as a ghost")
end

-- ------------------------------------------------------------------
-- 20. Guild chat lines
-- ------------------------------------------------------------------

local function leaderEnv()
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    return env
end

do
    -- Leading, with slots to fill. Vizzo is a dps, so a tank, a healer and two
    -- more dps are wanted.
    local env = leaderEnv()
    env.M.SignUp("open", { intent = "lead" })
    eq(env.M.ChatLine("open"),
        "LFM +12 Map501 - need Tank, Healer, 2 DPS. Sign up: /gp now",
        "a leader advertises the slots they still need")

    env.M.SignUp("monday", { intent = "lead" })
    eq(env.M.ChatLine("monday"),
        "LFM +12 Map501 - need Tank, Healer, 2 DPS for Mythic Monday (Mon 14 Sep). Sign up: /gp monday",
        "the Monday board names the night and its own slash command")

    -- Fill it up. "LFM ... (full)" would ask for nobody, so the line changes.
    for _, who in ipairs({ "Anna:T", "Bob:H", "Cid:D", "Dee:D" }) do
        local name, role = who:match("^(%a+):(%a)$")
        env.recv("E " .. OPEN .. " 100 " .. role .. " join any - - -", name .. "-" .. REALM)
        env.recv("J " .. OPEN, name .. "-" .. REALM, "WHISPER")
    end
    -- A full group has nothing to advertise, so there is no line to post.
    local line, why = env.M.ChatLine("open")
    eq(line, nil, "a full group produces no chat line")
    eq(why, "full", "with fullness as the reason")
    eq(select(2, env.M.PostToGuild("open")), "full",
        "so posting it is refused rather than spamming a non-advertisement")
    eq(#env.chat, 0, "and nothing was said")

    eq(env.M.ChatLine("monday"),
        "LFM +12 Map501 - need Tank, Healer, 2 DPS for Mythic Monday (Mon 14 Sep). Sign up: /gp monday",
        "and the other board is unaffected")
end

do
    -- A member who has gone quiet must free their slot in the advertisement
    -- too, or the leader keeps posting a line that hides a vacancy. The clock
    -- is moved by hand so no prune runs: only the counting rule is under test.
    local env = leaderEnv()
    env.M.SignUp("open", { intent = "lead" })
    for _, who in ipairs({ "Anna:T", "Bob:D" }) do
        local name, role = who:match("^(%a+):(%a)$")
        env.recv("E " .. OPEN .. " 100 " .. role .. " join any - - -", name .. "-" .. REALM)
        env.recv("J " .. OPEN, name .. "-" .. REALM, "WHISPER")
    end
    eq(env.M.ChatLine("open"),
        "LFM +12 Map501 - need Healer, 1 DPS. Sign up: /gp now",
        "a full tank slot is not advertised")

    local before = env.M.MissingSlots("open", "Vizzo-" .. REALM)
    eq(before.T, false, "MissingSlots agrees the tank slot is taken")
    eq(before.D, 1, "with one dps slot left")

    -- Anna goes quiet; Bob keeps announcing.
    env.now = env.now + 16 * 60
    env.recv("E " .. OPEN .. " 200 D join any - - -", "Bob-" .. REALM)
    check(env.board("open").groups["Vizzo-" .. REALM].members["Anna-" .. REALM] ~= nil,
        "the ghost is still on the roster, unpruned")

    eq(env.M.ChatLine("open"),
        "LFM +12 Map501 - need Tank, Healer, 1 DPS. Sign up: /gp now",
        "but the ghost's slot is advertised as free again")
    local after = env.M.MissingSlots("open", "Vizzo-" .. REALM)
    eq(after.T, true, "and MissingSlots reports the tank slot as open")
    eq(env.M.MissingSlots("open", "Nobody-" .. REALM), nil,
        "an unknown leader has no slots")
end

do
    -- In the pool, with and without a key, and on every bracket shape.
    local env = leaderEnv()
    env.M.SignUp("open", { intent = "join", bracket = "mid" })
    eq(env.M.ChatLine("open"),
        "LF key group - DPS, Mid 6-10, have +12 Map501. Sign up: /gp now",
        "a pool entry lists role, bracket and key")

    env.M.SignUp("monday", { intent = "join", bracket = "mid" })
    eq(env.M.ChatLine("monday"),
        "LF key group - DPS, Mid 6-10, have +12 Map501 for Mythic Monday (Mon 14 Sep). Sign up: /gp monday",
        "the Monday pool line names the night")

    env.M.SignUp("open", { intent = "join", bracket = "any" })
    eq(env.M.ChatLine("open"),
        "LF key group - DPS, any level, have +12 Map501. Sign up: /gp now",
        "the any bracket reads as any level")

    local nokey = newEnv().load()
    nokey.fire("PLAYER_ENTERING_WORLD", false, false)
    nokey.M.SignUp("open", { intent = "join", bracket = "high" })
    eq(nokey.M.ChatLine("open"),
        "LF key group - DPS, High 10-15. Sign up: /gp now",
        "no key means no have clause")

    local tank = newEnv({ specRole = "TANK" }).load()
    tank.fire("PLAYER_ENTERING_WORLD", false, false)
    tank.M.SignUp("open", { intent = "join", bracket = "low" })
    eq(tank.M.ChatLine("open"),
        "LF key group - Tank, Low 2-6. Sign up: /gp now",
        "the role is spelled out in words")
end

do
    -- In somebody else's group.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "join", bracket = "any" })
    env.recv("G " .. OPEN .. " 100 601 8 Anna-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Anna-" .. REALM)
    eq(env.M.Me("open").leader, "Anna-" .. REALM, "we are in Anna's group")
    eq(env.M.ChatLine("open"),
        "LFM +8 Map601 (Anna's group) - need Healer, 2 DPS. Sign up: /gp now",
        "a member advertises whose group it is, and its key")

    -- A member of a group that is already full has nothing to advertise either.
    local full = newEnv().load()
    full.fire("PLAYER_ENTERING_WORLD", false, false)
    full.M.SignUp("open", { intent = "join", bracket = "any" })
    -- They have to be on the board in their own right: on the open board a
    -- member nobody has heard from is an absence, not a filled slot.
    for _, who in ipairs({ "Cid:H", "Dee:D", "Eve:D" }) do
        local name, role = who:match("^(%a+):(%a)$")
        full.recv("E " .. OPEN .. " 100 " .. role .. " join any - - -", name .. "-" .. REALM)
    end
    full.recv("G " .. OPEN .. " 100 601 8 Anna-" .. REALM .. ":T,Cid-" .. REALM
        .. ":H,Vizzo-" .. REALM .. ":D,Dee-" .. REALM .. ":D,Eve-" .. REALM .. ":D",
        "Anna-" .. REALM)
    eq(full.M.Me("open").leader, "Anna-" .. REALM, "we are in a full group")
    eq(full.M.ChatLine("open"), nil, "which produces no chat line")
    eq(select(2, full.M.ChatLine("open")), "full", "with fullness as the reason")

    -- Not signed up at all.
    local idle = newEnv().load()
    idle.fire("PLAYER_ENTERING_WORLD", false, false)
    local line, why = idle.M.ChatLine("open")
    eq(line, nil, "no sign-up means no chat line")
    eq(why, "notsignedup", "and a reason")
    eq(select(2, idle.M.ChatLine("nope")), "badevent", "an unknown board is refused")
    eq(idle.error, nil, "without raising an error")
end

do
    -- Worst-case names must not produce an oversized chat message.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "join", bracket = "any" })
    local giant = string.rep("W", 300) .. "-" .. REALM
    env.recv("G " .. OPEN .. " 100 601 8 " .. giant .. ":T,Vizzo-" .. REALM .. ":D", giant)
    local line = env.M.ChatLine("open")
    check(#line <= 255, "an absurd leader name still fits the chat limit", #line)
    check(line:find("WWWW") == nil, "because whose group it is gets dropped first", line)
    eq(line, "LFM +8 Map601 - need Healer, 2 DPS. Sign up: /gp now",
        "leaving a line that still says something useful")

    -- When even that is not enough, the line is cut rather than sent oversized.
    local wide = newEnv({ key = { mapID = 501, level = 12 } }).load()
    wide.mapName = string.rep("K", 400)
    wide.fire("PLAYER_ENTERING_WORLD", false, false)
    wide.M.SignUp("open", { intent = "lead" })
    local cut = wide.M.ChatLine("open")
    eq(#cut, 255, "an absurd dungeon name is clamped to the limit")

    -- Clamping must not slice a multi-byte character in half.
    local utf8env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    utf8env.mapName = string.rep("ä", 200)     -- two bytes each
    utf8env.fire("PLAYER_ENTERING_WORLD", false, false)
    utf8env.M.SignUp("open", { intent = "lead" })
    local sliced = utf8env.M.ChatLine("open")
    check(#sliced <= 255, "a multi-byte name is clamped", #sliced)
    local trailing = 0
    for i = #sliced, 1, -1 do
        local byte = sliced:byte(i)
        if byte >= 0x80 and byte < 0xC0 then trailing = trailing + 1 else break end
    end
    local lead = sliced:byte(#sliced - trailing)
    check(lead == nil or lead < 0x80 or trailing == 1,
        "and never ends mid-character", ("lead=%s trailing=%d"):format(tostring(lead), trailing))
end

-- ------------------------------------------------------------------
-- 21. Posting to guild chat
-- ------------------------------------------------------------------

do
    local env = leaderEnv()
    eq(select(2, env.M.PostToGuild("open")), "notsignedup",
        "there is nothing to post before signing up")
    eq(#env.chat, 0, "and nothing was said")

    env.M.SignUp("open", { intent = "lead" })
    eq(env.M.PostToGuild("open"), true, "a signed-up leader can post")
    eq(#env.chat, 1, "one message went out")
    eq(env.chat[1].chattype, "GUILD", "to guild chat")
    eq(env.chat[1].text, env.M.ChatLine("open"), "carrying exactly the chat line")
    eq(env.chat[1].via, "C_ChatInfo",
        "through the current chat API, not the global deprecated in 11.2")

    eq(env.M.PostToGuild("open"), false, "a second post inside the window is refused")
    eq(select(2, env.M.PostToGuild("open")), "throttled", "and says why")
    eq(#env.chat, 1, "with nothing more said")

    -- The boards throttle separately.
    env.M.SignUp("monday", { intent = "lead" })
    eq(env.M.PostToGuild("monday"), true, "the other board has its own throttle")
    eq(#env.chat, 2, "so a second message went out")

    -- The window opens again.
    env.now = env.now + 61
    eq(env.M.PostToGuild("open"), true, "and reopens after a minute")

    eq(select(2, env.M.PostToGuild("nope")), "badevent", "an unknown board is refused")
end

do
    -- Chat is under lockdown inside a key, and a refusal must not burn the
    -- throttle window - otherwise one attempt in a dungeon mutes the button
    -- for a minute after you leave.
    local env = leaderEnv()
    env.M.SignUp("open", { intent = "lead" })
    env.challenge = true
    local ok, why = env.M.PostToGuild("open")
    eq(ok, false, "posting inside a key is refused")
    eq(why, "inkey", "with the lockdown as the reason")
    eq(#env.chat, 0, "and nothing was said")

    env.challenge = false
    eq(env.M.PostToGuild("open"), true, "posting works once the key is over")
    eq(#env.chat, 1, "and the refusal did not consume the window")

    local guildless = newEnv({ noGuild = true }).load()
    guildless.fire("PLAYER_ENTERING_WORLD", false, false)
    eq(select(2, guildless.M.PostToGuild("open")), "noguild",
        "there is no guild chat without a guild")

    -- On a client old enough to lack the namespaced call, the shim still works.
    local old = leaderEnv()
    old.M.SignUp("open", { intent = "lead" })
    _G.C_ChatInfo.SendChatMessage = nil
    eq(old.M.PostToGuild("open"), true, "posting still works without C_ChatInfo")
    eq(old.chat[1].via, "global", "by falling back to the deprecated global")
end

-- ------------------------------------------------------------------
-- 22. Party invites
-- ------------------------------------------------------------------

do
    local env = leaderEnv()
    env.M.SignUp("open", { intent = "lead" })

    eq(select(2, env.M.Invite("Vizzo-" .. REALM)), "self", "you cannot invite yourself")
    eq(#env.invited, 0, "and nothing was sent")

    env.recv("E " .. OPEN .. " 100 T join any - - -", "Anna-" .. REALM)
    env.party["Anna-" .. REALM] = true
    eq(select(2, env.M.Invite("Anna-" .. REALM)), "inparty", "nor someone already grouped")

    env.raid["Rai-" .. REALM] = true
    eq(select(2, env.M.Invite("Rai-" .. REALM)), "inparty", "raid counts as grouped")

    -- The unit APIs index a same-realm group member under their bare name, so
    -- checking only "Name-Realm" would miss them and re-invite someone who is
    -- already standing next to you.
    env.party["Zed"] = true
    eq(select(2, env.M.Invite("Zed-" .. REALM)), "inparty",
        "a same-realm party member is found under their short name")
    env.raid["Rex"] = true
    eq(select(2, env.M.Invite("Rex-" .. REALM)), "inparty",
        "and so is a same-realm raid member")
    eq(#env.invited, 0, "none of which produced an invite")

    -- Known, and recently heard from.
    env.recv("E " .. OPEN .. " 100 H join any - - -", "Bob-" .. REALM)
    eq(env.M.Invite("Bob-" .. REALM), true, "a live guildie is invited")
    eq(env.invited[#env.invited], "Bob-" .. REALM, "by name")

    -- Known, but silent for a quarter of an hour.
    env.now = env.now + 16 * 60
    local ok, why = env.M.Invite("Bob-" .. REALM)
    eq(ok, false, "someone who has gone quiet is not invited")
    eq(why, "offline", "because they have almost certainly logged out")

    -- Never heard of: worth a try rather than a refusal.
    eq(env.M.Invite("Stranger-" .. REALM), true, "an unknown name is tried anyway")
    eq(env.invited[#env.invited], "Stranger-" .. REALM, "and the invite goes out")
end

do
    -- InviteAll only makes sense for the leader of the group.
    local env = leaderEnv()
    local n, skipped = env.M.InviteAll("open")
    eq(n, 0, "a non-leader invites nobody")
    eq(#skipped, 1, "and is told once")
    eq(skipped[1].name, "Vizzo-" .. REALM, "naming themselves")
    eq(skipped[1].reason, "notleader", "with the reason")
    eq(select(2, env.M.InviteAll("nope"))[1].reason, "notleader",
        "an unknown board is the same refusal")

    env.M.SignUp("open", { intent = "lead" })
    for _, who in ipairs({ "Anna:T", "Bob:H", "Cid:D" }) do
        local name, role = who:match("^(%a+):(%a)$")
        env.recv("E " .. OPEN .. " 100 " .. role .. " join any - - -", name .. "-" .. REALM)
        env.recv("J " .. OPEN, name .. "-" .. REALM, "WHISPER")
    end

    -- Anna is already in the party; Bob has gone quiet; Cid is still here.
    env.party["Anna-" .. REALM] = true
    env.now = env.now + 16 * 60
    env.recv("E " .. OPEN .. " 200 D join any - - -", "Cid-" .. REALM)
    env.invited = {}

    local invited, skips = env.M.InviteAll("open")
    eq(invited, 1, "only the member who needs an invite gets one")
    eq(#env.invited, 1, "so one invite went out")
    eq(env.invited[1], "Cid-" .. REALM, "to the right person")
    eq(#skips, 2, "the other two are reported")
    eq(skips[1].name, "Anna-" .. REALM, "sorted by name")
    eq(skips[1].reason, "inparty", "Anna is already grouped")
    eq(skips[2].name, "Bob-" .. REALM, "then Bob")
    eq(skips[2].reason, "offline", "who has gone quiet")
    for _, s in ipairs(skips) do
        check(s.name ~= "Vizzo-" .. REALM, "the leader never invites themselves")
    end
end

-- ------------------------------------------------------------------
-- 23. Guild roster class cache
-- ------------------------------------------------------------------
-- Backs UI.lua's class-coloured names. GetNumGuildMembers/GetGuildRosterInfo
-- are already stubbed to an empty roster by newEnv (see above); these tests
-- override them the same way test 21 overrides C_ChatInfo.SendChatMessage,
-- to model a roster actually arriving.

do
    local env = newEnv().load()

    eq(env.M.ClassOf("Anna-" .. REALM), nil, "unknown before the roster has been read")

    local classOf = { ["Anna-" .. REALM] = "WARRIOR", ["Bob-" .. REALM] = "PRIEST" }
    local names = { "Anna-" .. REALM, "Bob-" .. REALM }
    _G.GetNumGuildMembers = function() return #names end
    _G.GetGuildRosterInfo = function(i)
        local name = names[i]
        -- name, rank, rankIndex, level, class, zone, note, officernote,
        -- online, status, classFileName - GetGuildRosterInfo's real shape;
        -- classFileName is the 11th return, not the 9th (online).
        return name, "Member", 1, 80, "Warrior", "Zone", "", "", true, 0, classOf[name]
    end

    env.fire("GUILD_ROSTER_UPDATE")
    eq(env.M.ClassOf("Anna-" .. REALM), "WARRIOR", "GUILD_ROSTER_UPDATE populates the cache")
    eq(env.M.ClassOf("Bob-" .. REALM), "PRIEST", "for every member the roster carries")
    eq(env.M.ClassOf("Stranger-" .. REALM), nil, "a name the roster never listed stays unknown")
    eq(env.error, nil, "and none of it raised an error")
end

do
    -- The once-at-login pass: C_GuildInfo is deliberately not stubbed by
    -- newEnv, so this also proves the roster request is optional, not
    -- assumed to exist, on a client old enough to lack it.
    local env = newEnv()
    _G.GetNumGuildMembers = function() return 1 end
    _G.GetGuildRosterInfo = function()
        return "Cid-" .. REALM, "Member", 1, 80, "Priest", "Zone", "", "", true, 0, "PRIEST"
    end
    env.load()
    env.fire("PLAYER_ENTERING_WORLD", true, false)
    eq(env.M.ClassOf("Cid-" .. REALM), "PRIEST", "the login pass primes the cache immediately")
    eq(env.error, nil, "even with no C_GuildInfo on this client")
end

-- ------------------------------------------------------------------
-- 24. Specialization ids on the wire
-- ------------------------------------------------------------------
-- Two trailing fields, E's tenth and G's seventh, both added after the
-- protocol shipped and both therefore optional in both directions: a message
-- without them must read as "not told" rather than as a parse failure, and a
-- message with them must not disturb anything a client reading only the older
-- fields would see. 63/65/66 are Fire/Frost/Arcane Mage; 250 is Blood Death
-- Knight. Real ids, so a reader can tell at a glance that the field carries a
-- spec id and not the 1-4 index.

do
    -- (a)+(b) E, with and without the field.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)

    env.recv("E " .. MON .. " 100 D join mid 111 8 - 63", "Anna-" .. REALM)
    local anna = env.board("monday").entries["Anna-" .. REALM]
    eq(anna and anna.spec, 63, "a tenth field on E is kept as the entry's spec")
    eq(anna and anna.role, "D", "and the fields before it are untouched")
    eq(anna and anna.bracket, "mid", "every one of them")
    eq(anna and anna.level, 8, "including the key")

    env.recv("E " .. MON .. " 100 T join low 222 4 -", "Bob-" .. REALM)
    local bob = env.board("monday").entries["Bob-" .. REALM]
    eq(bob and bob.spec, nil, "an E from a client too old to send it has no spec")
    eq(bob and bob.role, "T", "and is otherwise read exactly as before")
    eq(bob and bob.bracket, "low", "in every field")

    -- "0" is what this client itself writes for "not told", so it has to read
    -- back as nil rather than as a spec whose id happens to be zero.
    env.recv("E " .. MON .. " 100 H join high - - - 0", "Cid-" .. REALM)
    local cid = env.board("monday").entries["Cid-" .. REALM]
    eq(cid and cid.spec, nil, "a zero in the field means the same as no field")
    eq(cid and cid.role, "H", "without costing the entry anything else")

    -- The pool is what the UI actually renders from, so the spec has to
    -- survive the trip through it.
    local seen = {}
    for _, e in ipairs(env.M.Pool("monday")) do seen[e.name] = e end
    eq(seen["Anna-" .. REALM] and seen["Anna-" .. REALM].spec, 63,
        "and the pool hands the spec on to the UI")
    eq(seen["Bob-" .. REALM] and seen["Bob-" .. REALM].spec, nil,
        "leaving it nil for the entry that never carried one")
end

do
    -- (c)+(d)+(e) G's positional spec list.
    local function membersOf(env, leader)
        for _, g in ipairs(env.M.Groups("monday")) do
            if g.leader == leader then
                local by = {}
                for _, m in ipairs(g.members) do by[m.name] = m end
                return by
            end
        end
        return {}
    end

    local roster = "Ann-" .. REALM .. ":T,Bob-" .. REALM .. ":H,Cid-" .. REALM .. ":D"

    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.recv("G " .. MON .. " 100 501 12 " .. roster .. " 250,65,66", "Ann-" .. REALM)
    local g = env.board("monday").groups["Ann-" .. REALM]
    eq(g and g.specs and g.specs["Ann-" .. REALM], 250, "G's spec list is read positionally")
    eq(g and g.specs and g.specs["Bob-" .. REALM], 65, "second member, second id")
    eq(g and g.specs and g.specs["Cid-" .. REALM], 66, "third member, third id")
    local m = membersOf(env, "Ann-" .. REALM)
    eq(m["Bob-" .. REALM] and m["Bob-" .. REALM].spec, 65,
        "and Groups hands each member's spec to the UI")
    eq(m["Cid-" .. REALM] and m["Cid-" .. REALM].role, "D",
        "with the roles still where they were")

    -- A member's own E outranks the roster's copy: they respec long after
    -- they joined, and only their E will say so.
    env.recv("E " .. MON .. " 200 H join any - - - 64", "Bob-" .. REALM)
    local m2 = membersOf(env, "Ann-" .. REALM)
    eq(m2["Bob-" .. REALM] and m2["Bob-" .. REALM].spec, 64,
        "a later E outranks the roster's copy of the same member's spec")

    local old = newEnv().load()
    old.fire("PLAYER_ENTERING_WORLD", false, false)
    old.recv("G " .. MON .. " 100 501 12 " .. roster, "Ann-" .. REALM)
    local og = old.board("monday").groups["Ann-" .. REALM]
    eq(og and og.members and og.members["Ann-" .. REALM], "T",
        "a G with no spec list still lists every member")
    eq(og and og.members and og.members["Cid-" .. REALM], "D", "with their roles intact")
    eq(og and og.specs and next(og.specs), nil, "and simply knows no specs")
    eq(#(old.M.Groups("monday")[1] or {}).members, 3, "all three still reach the UI")

    local short = newEnv().load()
    short.fire("PLAYER_ENTERING_WORLD", false, false)
    short.recv("G " .. MON .. " 100 501 12 " .. roster .. " 250,65", "Ann-" .. REALM)
    local sg = short.board("monday").groups["Ann-" .. REALM]
    eq(sg and sg.specs and sg.specs["Ann-" .. REALM], 250, "a short spec list fills what it covers")
    eq(sg and sg.specs and sg.specs["Bob-" .. REALM], 65, "as far as it goes")
    eq(sg and sg.specs and sg.specs["Cid-" .. REALM], nil, "and leaves the rest unknown")
    eq(sg and sg.members and sg.members["Cid-" .. REALM], "D",
        "without dropping the member it could not describe")

    -- A zero in the middle is the placeholder for a member whose spec the
    -- leader does not know; it must not shift the ones after it.
    local gap = newEnv().load()
    gap.fire("PLAYER_ENTERING_WORLD", false, false)
    gap.recv("G " .. MON .. " 100 501 12 " .. roster .. " 250,0,66", "Ann-" .. REALM)
    local gg = gap.board("monday").groups["Ann-" .. REALM]
    eq(gg and gg.specs and gg.specs["Bob-" .. REALM], nil, "a zero in the list is a known gap")
    eq(gg and gg.specs and gg.specs["Cid-" .. REALM], 66, "that does not shift what follows it")
end

do
    -- (f) Our own spec, captured at sign-up and published.
    local env = newEnv({ specID = 250, specRole = "TANK",
                         key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    eq(env.M.MySpec(), 250, "MySpec reports the id, not the 1-4 index")
    eq(env.M.SignUp("monday", { intent = "lead" }), true, "SignUp lead succeeds")
    eq(env.board("monday").me.spec, 250, "and stamps our spec on our own entry")

    local e = env.last("E")
    check(e and e.text:match(" 250$") ~= nil, "the E we send carries it last", e and e.text)
    local g = env.last("G")
    check(g and g.text:match(" Vizzo%-" .. REALM .. ":T 250 %-$") ~= nil,
        "and our G lists it against our own name", g and g.text)

    -- A joiner we have heard from contributes their spec to our roster.
    env.recv("E " .. MON .. " 100 D join any - - - 63", "Anna-" .. REALM)
    env.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")
    local g2 = env.last("G")
    check(g2 and g2.text:match(" 250,63 %-$") ~= nil,
        "an accepted joiner's spec joins the list in roster order", g2 and g2.text)

    -- One we have not keeps its slot as a zero rather than vanishing.
    env.recv("J " .. MON, "Zed-" .. REALM, "WHISPER")
    local g3 = env.last("G")
    check(g3 and g3.text:match(" 250,63,0 %-$") ~= nil,
        "an unheard joiner holds its slot as a zero", g3 and g3.text)

    -- Respeccing within the same role used to be nothing to announce; now it
    -- is, because the spec itself rides the wire.
    env.clearSent()
    env.specID = 251
    env.fire("PLAYER_SPECIALIZATION_CHANGED")
    eq(env.board("monday").me.spec, 251, "a same-role respec updates our entry")
    local e2 = env.last("E")
    check(e2 and e2.text:match(" 251$") ~= nil, "and is broadcast", e2 and e2.text)
    local g4 = env.last("G")
    check(g4 and g4.text:match(" 251,63,0 %-$") ~= nil,
        "including in the roster we lead", g4 and g4.text)

    -- PLAYER_SPECIALIZATION_CHANGED also fires during login, before talent
    -- data is ready, and MySpec is nil until it is. Treating that as a change
    -- would wipe the spec restored from SavedVariables and publish 0 for the
    -- rest of the session.
    env.clearSent()
    local roleBefore = env.board("monday").me.role
    local realGetSpec = _G.GetSpecialization
    _G.GetSpecialization = function() return nil end
    env.fire("PLAYER_SPECIALIZATION_CHANGED")
    eq(env.M.MySpec(), nil, "MySpec says nothing before talent data is ready")
    eq(env.board("monday").me.spec, 251, "and a silent client does not clear a known spec")
    eq(env.board("monday").groups["Vizzo-" .. REALM].specs["Vizzo-" .. REALM], 251,
        "nor the roster's copy of it")
    -- The role shares the race: MyRole would fall through to "D" here, and
    -- that must not count as a role change either, so nothing is sent.
    eq(env.board("monday").me.role, roleBefore, "and a silent client does not change the role")
    eq(env.last("E", MON), nil, "so a silent client sends no E at all")
    _G.GetSpecialization = realGetSpec
end

do
    -- The same hazard by its real route: a relog restores the spec from
    -- SavedVariables, and the login re-broadcast must carry it even though
    -- nothing this session has called SignUp.
    local db = {}
    local first = newEnv({ db = db, specID = 250, specRole = "TANK",
                           key = { mapID = 501, level = 12 } }).load()
    first.fire("PLAYER_ENTERING_WORLD", false, false)
    first.M.SignUp("open", { intent = "join", bracket = "any" })

    local relog = newEnv({ db = db, specRole = "DAMAGER" }).load()
    _G.GetSpecialization = function() return nil end
    relog.fire("PLAYER_ENTERING_WORLD", true, false)
    local e = relog.last("E", OPEN)
    check(e and e.text:match(" 250$") ~= nil,
        "a relog re-broadcasts the saved spec, not a zero", e and e.text)
    check(e and e.text:match("^E %S+ %S+ T ") ~= nil,
        "and the saved tank role, not MyRole's D default", e and e.text)
    eq(relog.board("open").me.role, "T", "the saved role survives the login event")

    -- And once talents do load, the real value replaces the saved one.
    local later = newEnv({ db = db, specID = 63, specRole = "DAMAGER" }).load()
    later.fire("PLAYER_ENTERING_WORLD", true, false)
    local e2 = later.last("E", OPEN)
    check(e2 and e2.text:match(" 63$") ~= nil,
        "and a live spec outranks the saved one", e2 and e2.text)
end

do
    -- The roster walk is shared and throttled: one pass fills both the online
    -- set and the class cache. GUILD_ROSTER_UPDATE forces a fresh walk rather
    -- than waiting out ROSTER_CACHE - online status is the whole point of the
    -- event - but the repaint that triggers it is itself throttled to once
    -- per five seconds, so a burst costs one extra walk, not one per event.
    local env = newEnv()
    local walks = 0
    local roster = { { "Anna-" .. REALM, "WARRIOR", true },
                     { "Bob-" .. REALM, "PRIEST", false } }
    _G.GetNumGuildMembers = function() return #roster end
    _G.GetGuildRosterInfo = function(i)
        local row = roster[i]
        if not row then return nil end
        if i == 1 then walks = walks + 1 end
        return row[1], "Member", 1, 80, "Class", "Zone", "", "", row[3], 0, row[2]
    end
    env.load()
    env.fire("PLAYER_ENTERING_WORLD", true, false)
    local after = walks
    check(after > 0, "the login pass walks the roster once")
    eq(env.M.ClassOf("Anna-" .. REALM), "WARRIOR", "filling the class cache")

    for _ = 1, 20 do env.fire("GUILD_ROSTER_UPDATE") end
    eq(walks, after + 1, "a burst of roster events costs one fresh walk, not one per event")
    local afterBurst = walks

    -- Past the five-second repaint throttle the next event walks again.
    roster[1] = { "Cid-" .. REALM, "MAGE", true }
    env.now = env.now + 6
    env.fire("GUILD_ROSTER_UPDATE")
    check(walks > afterBurst, "past the throttle window it walks again")
    eq(env.M.ClassOf("Cid-" .. REALM), "MAGE", "picking up the new member")
    eq(env.M.ClassOf("Anna-" .. REALM), nil, "and evicting the one who left")
    eq(env.error, nil, "with no errors along the way")
end

do
    -- (g) Both fields ride SavedVariables, which stores the board tables
    -- whole rather than copying named fields out of them.
    local db = {}
    local env = newEnv({ db = db, specID = 250, specRole = "TANK",
                         key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("monday", { intent = "lead" })
    env.recv("E " .. MON .. " 100 D join any - - - 63", "Anna-" .. REALM)
    env.recv("J " .. MON, "Anna-" .. REALM, "WHISPER")

    local saved = db.monday and db.monday.boards and db.monday.boards.monday
    eq(saved and saved.me and saved.me.spec, 250, "our own spec is saved")
    eq(saved and saved.entries["Anna-" .. REALM].spec, 63, "and so is a peer's")
    eq(saved and saved.groups["Vizzo-" .. REALM].specs["Anna-" .. REALM], 63,
        "and the roster sidecar with it")

    local relog = newEnv({ db = db, specID = 250, specRole = "TANK" }).load()
    eq(relog.board("monday").me.spec, 250, "a relog reads our own spec back")
    eq(relog.board("monday").entries["Anna-" .. REALM].spec, 63, "and the peer's")
    eq(relog.board("monday").groups["Vizzo-" .. REALM].specs["Anna-" .. REALM], 63,
        "and the sidecar")

    -- A board saved before either field existed has no `spec` anywhere and no
    -- `specs` table at all, and must load without either being missed.
    local oldDb = { monday = { boards = {
        monday = {
            key = MON,
            me = { role = "T", intent = "lead", leader = "Vizzo-" .. REALM, ts = 1 },
            entries = {
                ["Vizzo-" .. REALM] = { role = "T", intent = "lead",
                                        leader = "Vizzo-" .. REALM, ts = 1 },
                ["Anna-" .. REALM] = { role = "D", intent = "join", ts = 1 },
            },
            groups = {
                ["Vizzo-" .. REALM] = {
                    ts = 1, seen = 1757332800,
                    members = { ["Vizzo-" .. REALM] = "T", ["Anna-" .. REALM] = "D" },
                },
            },
        },
        open = { key = OPEN, entries = {}, groups = {} },
    } } }
    local legacy = newEnv({ db = oldDb, specRole = "TANK" }).load()
    eq(legacy.error, nil, "a pre-spec saved board loads without error")
    local lg = legacy.M.Groups("monday")[1]
    eq(lg and #lg.members, 2, "with its roster whole")
    local bySpec = {}
    for _, mem in ipairs(lg and lg.members or {}) do bySpec[mem.name] = mem.spec end
    eq(bySpec["Anna-" .. REALM], nil, "and every spec simply unknown")
    legacy.clearSent()
    legacy.fire("PLAYER_ENTERING_WORLD", true, false)
    local lgSent = legacy.last("G", MON)
    check(lgSent and lgSent.text:match(" 0,0 %-$") ~= nil,
        "rebroadcast with a placeholder per member", lgSent and lgSent.text)
end

-- ------------------------------------------------------------------
-- 25. Scheduling wire: the `when` field on G
-- ------------------------------------------------------------------

do
    -- Leading with a `when` stamps both the group and our own entry, and
    -- broadcasts it as G's trailing token.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    local when = env.now + 3600
    eq(env.M.SignUp("open", { intent = "lead", when = when }), true,
        "SignUp lead accepts a when")
    eq(env.board("open").groups["Vizzo-" .. REALM].when, when, "and stamps it on the group")
    eq(env.board("open").me.when, when, "and on our own entry")

    local g = env.last("G", OPEN)
    check(g and g.text:match(" " .. when .. "$") ~= nil,
        "and broadcasts it as the trailing token", g and g.text)
end

do
    -- The Monday board has nothing to schedule: its key IS the date, so a
    -- `when` opt is simply ignored there.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    eq(env.M.SignUp("monday", { intent = "lead", when = env.now + 3600 }), true,
        "SignUp lead on monday ignores a when")
    eq(env.board("monday").groups["Vizzo-" .. REALM].when, nil,
        "the monday board never carries one")
    local g = env.last("G", MON)
    check(g and g.text:match(" %-$") ~= nil, "and its G ends with the nil token", g and g.text)
end

do
    -- G's 8th field, read by fixed index like the two before it: an epoch
    -- parses, and a dash, a zero, unparseable text, or the field simply not
    -- being there at all all mean the same nil - "not told".
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)

    local when = env.now + 7200
    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":D 0 " .. when, "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM].when, when, "an epoch in field 8 is read")

    -- If a later G omits the field, the cached value is replaced by nil, same
    -- as every other field a leader stops sending.
    env.recv("G " .. OPEN .. " 101 501 12 Bob-" .. REALM .. ":D 0", "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM].when, nil,
        "a client too old to send field 8 is read the same as nil")

    env.recv("G " .. OPEN .. " 102 501 12 Bob-" .. REALM .. ":D 0 " .. when, "Bob-" .. REALM)
    env.recv("G " .. OPEN .. " 103 501 12 Bob-" .. REALM .. ":D 0 -", "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM].when, nil, "a dash means nil")

    env.recv("G " .. OPEN .. " 104 501 12 Bob-" .. REALM .. ":D 0 " .. when, "Bob-" .. REALM)
    env.recv("G " .. OPEN .. " 105 501 12 Bob-" .. REALM .. ":D 0 0", "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM].when, nil, "so does a zero")

    env.recv("G " .. OPEN .. " 106 501 12 Bob-" .. REALM .. ":D 0 " .. when, "Bob-" .. REALM)
    env.recv("G " .. OPEN .. " 107 501 12 Bob-" .. REALM .. ":D 0 garbage", "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM].when, nil, "and unparseable text")
end

do
    -- The trailing `when` token is reserved before pairs/specs are trimmed,
    -- so even a roster cut down to nothing keeps its schedule.
    local huge = string.rep("Q", 300)
    local env = newEnv({ player = huge, key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.clearSent()

    local when = env.now + 3600
    eq(env.M.SignUp("open", { intent = "lead", when = when }), true,
        "SignUp lead survives an unsendable name, when and all")
    local g = env.last("G", OPEN)
    check(g and #g.text <= 255, "inside the addon-message limit", g and #g.text)
    check(g and g.text:match(" %- %- " .. when .. "$") ~= nil,
        "with an empty roster but the schedule intact", g and g.text)
end

do
    -- A full five-man roster of long Name-Realm strings, scheduled: the G
    -- still fits inside 255 bytes, and a peer who only hears this one message
    -- still reads the schedule back correctly.
    local env = newEnv({ specRole = "TANK", key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local when = env.now + 5400
    env.M.SignUp("open", { intent = "lead", when = when })

    for i, role in ipairs({ "H", "D", "D", "D" }) do
        local name = string.rep("X", 40) .. i .. "-" .. REALM
        env.recv("E " .. OPEN .. " " .. (100 + i) .. " " .. role .. " join any - - -", name)
        env.recv("J " .. OPEN, name, "WHISPER")
    end

    local g = env.last("G", OPEN)
    check(g and #g.text <= 255, "a full scheduled roster stays inside the limit", g and #g.text)
    check(g and g.text:match(" " .. when .. "$") ~= nil, "and the schedule rides along", g and g.text)

    local peer = newEnv({ player = "Peer" }).load()
    peer.fire("PLAYER_ENTERING_WORLD", false, false)
    peer.recv(g.text, "Vizzo-" .. REALM)
    eq(peer.board("open").groups["Vizzo-" .. REALM].when, when,
        "the schedule round-trips through the wire")
end

-- ------------------------------------------------------------------
-- 26. Scheduling lifetime: grace vs the ordinary heartbeat rule
-- ------------------------------------------------------------------

do
    -- A scheduled group outlives the ordinary 15-minute silence rule; only
    -- the grace window past its own `when` can prune it.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local when = env.now + 3600
    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":D 0 " .. when, "Bob-" .. REALM)

    env.tick(16 * 60)
    eq(#env.M.Groups("open"), 1, "a scheduled group outlives the 15-minute heartbeat rule")

    env.tick((when - env.now) + 60)
    eq(#env.M.Groups("open"), 1, "and stays visible just after its start time, inside grace")

    env.tick(2 * 60 * 60)
    eq(#env.M.Groups("open"), 0, "but is pruned once the grace window runs out")
end

do
    -- An unscheduled group is unaffected: the grace rule only ever applies
    -- once `when` is actually set.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":D 0 -", "Bob-" .. REALM)
    env.tick(15 * 60 + 1)
    eq(#env.M.Groups("open"), 0, "an unscheduled group is still pruned after 15 minutes of silence")
end

do
    -- Pool entries (non-lead sign-ups) are untouched by the scheduling rule:
    -- a silent member still ages out on the ordinary clock even while their
    -- leader's own group is scheduled hours in the future.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local when = env.now + 6 * 60 * 60
    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":D,Ann-" .. REALM .. ":D 0,0 " .. when,
        "Bob-" .. REALM)
    env.recv("E " .. OPEN .. " 100 D join any - - -", "Ann-" .. REALM)

    env.tick(15 * 60 + 1)
    local groups = env.M.Groups("open")
    eq(#groups, 1, "the scheduled group is still there")
    eq(#groups[1].members, 1, "but a silent member is hidden same as ever")
end

-- ------------------------------------------------------------------
-- 27. M.SetWhen
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)

    eq(env.M.SetWhen("open", env.now + 3600), false, "a no-op before signing up to lead")

    env.M.SignUp("open", { intent = "lead" })
    env.clearSent()
    local when = env.now + 3600
    eq(env.M.SetWhen("open", when), true, "the leader may schedule the group")
    eq(env.board("open").me.when, when, "on our own entry")
    eq(env.board("open").groups["Vizzo-" .. REALM].when, when, "and the group record")
    local g = env.last("G", OPEN)
    check(g and g.text:match(" " .. when .. "$") ~= nil,
        "and re-broadcasts the group with it", g and g.text)

    eq(env.M.SetWhen("open", nil), true, "and clears it back to right-now")
    eq(env.board("open").groups["Vizzo-" .. REALM].when, nil, "on the group")
    eq(env.board("open").me.when, nil, "and on our own entry")

    local joiner = newEnv({ player = "Ann" }).load()
    joiner.fire("PLAYER_ENTERING_WORLD", false, false)
    joiner.M.SignUp("open", { intent = "join", bracket = "any" })
    eq(joiner.M.SetWhen("open", joiner.now + 60), false, "a non-leader cannot schedule")

    local lead = newEnv({ key = { mapID = 501, level = 12 } }).load()
    lead.fire("PLAYER_ENTERING_WORLD", false, false)
    lead.M.SignUp("monday", { intent = "lead" })
    eq(lead.M.SetWhen("monday", lead.now + 60), false, "the Monday board has nothing to schedule")
end

-- ------------------------------------------------------------------
-- 28. FormatWhen, BuildWhen, DefaultWhen, IsScheduled
-- ------------------------------------------------------------------

do
    -- Day/time parts, checked against the same date() the module itself uses
    -- so the test holds regardless of the host's timezone.
    local env = newEnv().load()
    local now = env.now

    eq(env.M.FormatWhen(nil, now), "", "no when, nothing to show")

    local abbr = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

    local today = env.M.BuildWhen(0, 20, 0, now)
    local todayT = os.date("*t", today)
    eq(env.M.FormatWhen(today, now):match("^(%a+ %d%d:%d%d)"),
        string.format("Today %02d:%02d", todayT.hour, todayT.min),
        "later the same local day is Today")

    local tomorrow = env.M.BuildWhen(1, 9, 30, now)
    local tomT = os.date("*t", tomorrow)
    eq(env.M.FormatWhen(tomorrow, now):match("^(%a+ %d%d:%d%d)"),
        string.format("Tomorrow %02d:%02d", tomT.hour, tomT.min),
        "the next local day is Tomorrow")

    local within = env.M.BuildWhen(4, 18, 0, now)
    local withinT = os.date("*t", within)
    eq(env.M.FormatWhen(within, now):match("^(.-%d%d:%d%d)"),
        string.format("%s %02d:%02d", abbr[withinT.wday], withinT.hour, withinT.min),
        "four days out is a bare weekday")

    local far = env.M.BuildWhen(10, 12, 0, now)
    local farT = os.date("*t", far)
    eq(env.M.FormatWhen(far, now):match("^(.-%d%d:%d%d)"),
        string.format("%s %d %s %02d:%02d", abbr[farT.wday], farT.day, months[farT.month],
            farT.hour, farT.min),
        "past a week out gets the full date")
end

do
    -- The relative suffix: pure epoch arithmetic, so it holds regardless of
    -- timezone.
    local env = newEnv().load()
    local now = env.now

    local soon = now + 2 * 3600 + 15 * 60
    check(env.M.FormatWhen(soon, now):find("(in 2h 15m)", 1, true) ~= nil,
        "a couple hours out gets a relative suffix", env.M.FormatWhen(soon, now))

    local far = now + 3 * 86400 + 4 * 3600
    check(env.M.FormatWhen(far, now):find("(in 3d 4h)", 1, true) ~= nil,
        "days out rounds to days and hours", env.M.FormatWhen(far, now))

    local started = now - 12 * 60
    check(env.M.FormatWhen(started, now):find("(started 12m ago)", 1, true) ~= nil,
        "just started counts up instead of down", env.M.FormatWhen(started, now))

    local longGone = now - (2 * 60 * 60 + 5 * 60)
    check(env.M.FormatWhen(longGone, now):find("(", 1, true) == nil,
        "past the grace window the relative suffix drops entirely",
        env.M.FormatWhen(longGone, now))
end

do
    -- BuildWhen round-trips against date("*t"): the requested clock time, and
    -- the requested day expressed as local-midnight arithmetic so it holds
    -- across a DST boundary too.
    local env = newEnv().load()
    local now = env.now
    local w = env.M.BuildWhen(2, 14, 45, now)
    local wt = os.date("*t", w)
    local nowT = os.date("*t", now)
    eq(wt.hour, 14, "BuildWhen lands on the requested hour")
    eq(wt.min, 45, "and minute")
    local expectedDay = os.time({ year = nowT.year, month = nowT.month, day = nowT.day + 2,
        hour = 0, min = 0, sec = 0 })
    local gotDay = os.time({ year = wt.year, month = wt.month, day = wt.day,
        hour = 0, min = 0, sec = 0 })
    eq(gotDay, expectedDay, "and the requested day, two days ahead of now")
end

do
    -- DefaultWhen: the next full hour, at least half an hour out.
    local env = newEnv().load()
    local now = env.now
    local w = env.M.DefaultWhen(now)
    check(w >= now + 1800, "at least half an hour out", w - now)
    check(w < now + 1800 + 3600, "and no more than an hour past that", w - now)
    local wt = os.date("*t", w)
    eq(wt.min, 0, "landing on the top of the hour")
    eq(wt.sec, 0, "exactly")
end

do
    local env = newEnv().load()
    eq(env.M.IsScheduled(nil), false, "no group at all is not scheduled")
    eq(env.M.IsScheduled({ when = nil }), false, "a group without when is not scheduled")
    eq(env.M.IsScheduled({ when = env.now + 60 }), true, "a group with when is scheduled")
end

-- ------------------------------------------------------------------
-- 29. M.Groups sort order with `when`
-- ------------------------------------------------------------------

do
    local env = newEnv({ key = { mapID = 501, level = 5 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "lead", when = env.now + 7200 })

    env.recv("G " .. OPEN .. " 100 502 20 Ann-" .. REALM .. ":T", "Ann-" .. REALM)
    env.recv("G " .. OPEN .. " 100 503 15 Bob-" .. REALM .. ":T", "Bob-" .. REALM)
    env.recv("G " .. OPEN .. " 100 504 8 Deb-" .. REALM .. ":T - " .. (env.now + 3600),
        "Deb-" .. REALM)

    local order = {}
    for _, g in ipairs(env.M.Groups("open")) do order[#order + 1] = g.leader end
    eq(order[1], "Vizzo-" .. REALM, "our own group leads regardless of its own schedule")
    eq(order[2], "Ann-" .. REALM, "unscheduled groups (when=0) sort first among the rest")
    eq(order[3], "Bob-" .. REALM, "tied on when, the higher level goes first")
    eq(order[4], "Deb-" .. REALM, "a scheduled group sorts after every unscheduled one")
end

-- ------------------------------------------------------------------
-- 30. A leader's own E or X drops their cached group
-- ------------------------------------------------------------------

do
    -- Bob's own E now says "join" - his client thinks he left the group, with
    -- no D ever having arrived to say so. His cached group goes with it.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "join", bracket = "any" })

    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Bob-" .. REALM)
    eq(env.board("open").me.leader, "Bob-" .. REALM, "the G accepts our join")
    check(env.board("open").groups["Bob-" .. REALM] ~= nil, "and caches Bob's group")

    env.recv("E " .. OPEN .. " 200 D join any - - -", "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM], nil,
        "Bob's cached group is dropped along with his own E")
    eq(env.board("open").me.leader, nil, "and we are freed back to the pool")
end

do
    -- Bob withdraws outright, with no preceding D either.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "join", bracket = "any" })

    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":T,Vizzo-" .. REALM .. ":D",
        "Bob-" .. REALM)
    eq(env.board("open").me.leader, "Bob-" .. REALM, "we are in Bob's group")

    env.recv("X " .. OPEN, "Bob-" .. REALM)
    eq(env.board("open").groups["Bob-" .. REALM], nil,
        "his cached group goes with his withdraw")
    eq(env.board("open").me.leader, nil, "and we are freed back to the pool")
    eq(#env.M.Groups("open"), 0, "no group remains for anyone to see")
end

-- ------------------------------------------------------------------
-- 31. Online presence
-- ------------------------------------------------------------------

do
    -- Tri-state: unknown before any scan, then explicitly true/false once the
    -- roster has actually said so - never guessed at.
    local env = newEnv().load()
    eq(env.M.IsOnline("Nobody-" .. REALM), nil, "unscanned/unknown is nil, not false")

    local roster = { { "Anna-" .. REALM, "WARRIOR", true },
                     { "Bob-" .. REALM, "PRIEST", false } }
    _G.GetNumGuildMembers = function() return #roster end
    _G.GetGuildRosterInfo = function(i)
        local row = roster[i]
        if not row then return nil end
        return row[1], "Member", 1, 80, "Class", "Zone", "", "", row[3], 0, row[2]
    end
    env.fire("GUILD_ROSTER_UPDATE")

    eq(env.M.IsOnline("Anna-" .. REALM), true, "online comes back true")
    eq(env.M.IsOnline("Bob-" .. REALM), false, "offline comes back false, not hidden")
    eq(env.M.IsOnline("Cid-" .. REALM), nil, "someone not on the roster is still unknown")
end

do
    -- GUILD_ROSTER_UPDATE invalidates the cached scan and repaints both
    -- boards, throttled to once per five seconds.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local seen = {}
    env.M.RegisterCallback(function(ev) seen[#seen + 1] = ev end)

    local roster = { { "Anna-" .. REALM, "WARRIOR", true } }
    _G.GetNumGuildMembers = function() return #roster end
    _G.GetGuildRosterInfo = function(i)
        local row = roster[i]
        if not row then return nil end
        return row[1], "Member", 1, 80, "Class", "Zone", "", "", row[3], 0, row[2]
    end

    env.fire("GUILD_ROSTER_UPDATE")
    local firedOnce = #seen
    check(firedOnce >= 2, "the first event repaints both boards", firedOnce)

    for _ = 1, 10 do env.fire("GUILD_ROSTER_UPDATE") end
    eq(#seen, firedOnce, "a burst inside the throttle repaints nothing further")

    env.now = env.now + 6
    env.fire("GUILD_ROSTER_UPDATE")
    check(#seen > firedOnce, "past the throttle window it repaints again")
end

do
    -- RequestRoster nudges C_GuildInfo.GuildRoster, guarded for a client
    -- without it and for one where the call itself throws.
    local env = newEnv().load()
    local called = 0
    _G.C_GuildInfo = { GuildRoster = function() called = called + 1 end }
    env.M.RequestRoster()
    eq(called, 1, "RequestRoster asks the client for a fresh roster")

    _G.C_GuildInfo = nil
    local ok1 = pcall(env.M.RequestRoster)
    check(ok1, "and does nothing, quietly, without the API")

    _G.C_GuildInfo = { GuildRoster = function() error("boom") end }
    local ok2 = pcall(env.M.RequestRoster)
    check(ok2, "or if the call itself throws")
end

do
    -- Groups() and Pool() both surface it, tri-state, per member/entry.
    local env = newEnv().load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local roster = { { "Bob-" .. REALM, "WARRIOR", true },
                     { "Ann-" .. REALM, "PRIEST", false } }
    _G.GetNumGuildMembers = function() return #roster end
    _G.GetGuildRosterInfo = function(i)
        local row = roster[i]
        if not row then return nil end
        return row[1], "Member", 1, 80, "Class", "Zone", "", "", row[3], 0, row[2]
    end
    env.fire("GUILD_ROSTER_UPDATE")

    -- Ann needs a heard E or M.Groups hides her as an unheard ghost, same as
    -- ever - nothing to do with online status. Zed stays unaffiliated, off
    -- the guild roster entirely, to check Pool's nil case.
    env.recv("E " .. OPEN .. " 100 D join any - - -", "Ann-" .. REALM)
    env.recv("E " .. OPEN .. " 100 D join any - - -", "Zed-" .. REALM)
    env.recv("G " .. OPEN .. " 100 501 12 Bob-" .. REALM .. ":T,Ann-" .. REALM .. ":D",
        "Bob-" .. REALM)

    local members = env.M.Groups("open")[1].members
    local byName = {}
    for _, m in ipairs(members) do byName[m.name] = m.online end
    eq(byName["Bob-" .. REALM], true, "the leader's own online state shows in Groups")
    eq(byName["Ann-" .. REALM], false, "and a member's")

    local pool = env.M.Pool("open")
    eq(pool[1] and pool[1].name, "Zed-" .. REALM, "Zed is the only one left in the pool")
    eq(pool[1] and pool[1].online, nil, "and Pool for someone off the roster entirely")
end

-- ------------------------------------------------------------------
-- 32. An own scheduled group past grace self-disbands
-- ------------------------------------------------------------------

do
    -- Past `when` + the grace window, logging back in disbands it exactly as
    -- a manual Disband would: a D goes out, and we land back in the pool
    -- rather than vanishing outright.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local when = env.now + 3600
    env.M.SignUp("open", { intent = "lead", when = when })
    env.clearSent()

    env.now = when + 2 * 60 * 60 + 60
    env.fire("PLAYER_ENTERING_WORLD", true, false)

    check(env.last("D", OPEN) ~= nil, "a D is broadcast for the overdue group")
    eq(env.board("open").me.leader, nil, "we are no longer leading")
    eq(env.board("open").me.intent, "join", "and are left looking, not withdrawn")
    eq(#env.M.Groups("open"), 0, "the group is gone from the view")
end

do
    -- Still inside the two-hour grace window: untouched.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    local when = env.now + 3600
    env.M.SignUp("open", { intent = "lead", when = when })
    env.clearSent()

    env.now = when + 60 * 60
    env.fire("PLAYER_ENTERING_WORLD", true, false)

    check(env.last("D", OPEN) == nil, "no D for a group still inside its grace window")
    eq(env.board("open").me.leader, "Vizzo-" .. REALM, "still leading")
    eq(#env.M.Groups("open"), 1, "and still shown")
end

do
    -- An unscheduled own group: no `when`, so grace never applies, no matter
    -- how long ago it was left running.
    local env = newEnv({ key = { mapID = 501, level = 12 } }).load()
    env.fire("PLAYER_ENTERING_WORLD", false, false)
    env.M.SignUp("open", { intent = "lead" })
    env.clearSent()

    env.now = env.now + 5 * 60 * 60
    env.fire("PLAYER_ENTERING_WORLD", true, false)

    check(env.last("D", OPEN) == nil, "no D for an unscheduled group")
    eq(env.board("open").me.leader, "Vizzo-" .. REALM, "still leading")
    eq(#env.M.Groups("open"), 1, "and still shown")
end

-- ------------------------------------------------------------------

if failed > 0 then
    io.write(("\n%d passed, %d FAILED\n"):format(passed, failed))
    os.exit(1)
end
io.write(("OK %d tests\n"):format(passed))
