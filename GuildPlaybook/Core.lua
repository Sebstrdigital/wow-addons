local ADDON, ns = ...

-- ------------------------------------------------------------------
-- Data registry (Data/*.lua files call ns.RegisterDungeon)
-- ------------------------------------------------------------------

ns.dungeons = {}        -- slug -> dungeon table
ns.byInstanceID = {}    -- instanceID -> dungeon
ns.byName = {}          -- dungeon name -> dungeon
ns.byEncounterID = {}   -- encounterID -> { dungeon = d, boss = b }

function ns.RegisterDungeon(d)
    ns.dungeons[d.slug] = d
    if d.instanceID then ns.byInstanceID[d.instanceID] = d end
    if d.dungeon then ns.byName[d.dungeon] = d end
    for _, list in ipairs({ d.bosses or {}, d.minibosses or {} }) do
        for _, boss in ipairs(list) do
            if boss.encounterID then
                ns.byEncounterID[boss.encounterID] = { dungeon = d, boss = boss }
            end
        end
    end
end

-- Call an optional UI function, surfacing errors in chat instead of
-- failing silently (scriptErrors is off for most players).
function ns.safecall(fn, ...)
    if not fn then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        print("|cffff4040Guild Playbook error:|r " .. tostring(err))
    end
end

-- How MDT turns an addon-message sender into its preset-cache key, copied from
-- its OnCommReceived (MDT's Modules/Transmission.lua): a sender on our own realm
-- arrives with no realm attached, so the player's realm is filled back in. The
-- one-click import in UI.lua has to agree with this exactly - the chat link it
-- fires looks the preset up under this key - and /gp commtest reports it.
function ns.MdtSenderKey(sender)
    -- Raw CHAT_MSG_ADDON senders keep the realm attached ("Vizzo-Caelestrasz"),
    -- a form UnitFullName cannot resolve. MDT never sees that form: AceComm
    -- ambiguates the sender first, stripping the suffix for same-realm senders.
    -- Replicate that step, then re-derive the way MDT does.
    local name, realm = UnitFullName(Ambiguate(sender or "", "none"))
    if not name then return nil end
    if not realm or #realm < 3 then
        local _, playerRealm = UnitFullName("player")
        realm = playerRealm
    end
    if not realm or realm == "" then return nil end
    return name .. "-" .. realm
end

-- ------------------------------------------------------------------
-- State
-- ------------------------------------------------------------------

ns.role = "DPS"             -- effective role shown in the UI
ns.roleOverride = nil       -- set via /gp tank|healer|dps|all
ns.currentDungeon = nil
ns.captureIDs = false       -- /gp ids

local function DetectRole()
    if ns.roleOverride then return ns.roleOverride end
    local assigned = UnitGroupRolesAssigned("player")
    if assigned == "TANK" then return "TANK" end
    if assigned == "HEALER" then return "HEALER" end
    if assigned == "DAMAGER" then return "DPS" end
    -- Fall back to spec role when not in a group
    local spec = GetSpecialization and GetSpecialization()
    if spec then
        local specRole = GetSpecializationRole(spec)
        if specRole == "TANK" then return "TANK" end
        if specRole == "HEALER" then return "HEALER" end
    end
    return "DPS"
end

function ns.UpdateRole()
    local role = DetectRole()
    if role ~= ns.role then
        ns.role = role
        ns.safecall(ns.UI_Refresh)
    end
end

local function EnterDungeon(d)
    if ns.currentDungeon ~= d then
        ns.currentDungeon = d
        ns.safecall(ns.UI_SetDungeon, d)
        if d then
            print("|cff69ccf0Guild Playbook:|r loaded playbook for " .. d.dungeon .. ". /gp to toggle.")
            if (GuildPlaybookDB and GuildPlaybookDB.autoOpen) ~= false then
                ns.safecall(ns.UI_Show)
            end
        end
    end
end

local function CheckZone()
    if not IsInInstance() then
        EnterDungeon(nil)
        return
    end
    local name, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
    if instanceType ~= "party" then
        EnterDungeon(nil)
        return
    end
    if ns.captureIDs then
        print(("|cff69ccf0GP ids:|r instance %q instanceID=%s"):format(name or "?", tostring(instanceID)))
    end
    EnterDungeon(ns.byInstanceID[instanceID] or ns.byName[name])
end

-- ------------------------------------------------------------------
-- Guild identity
-- ------------------------------------------------------------------
-- The addon is published on CurseForge, so most of it has to work for anyone.
-- The guild tab is the exception: it carries the Discord invite and anything
-- else meant for the roster, and a stranger should never see that the invite
-- exists. Membership is what gates the tab.

ns.GUILD_NAME = "Stand as One"
ns.DISCORD_URL = "https://discord.gg/EbwYS9u8t"

local GUILD_NAME_FOLDED = ns.GUILD_NAME:lower()

-- Matched on the folded name alone, deliberately: casing is the guild master's
-- to change, and GetGuildInfo's realm return is the *guild's* home realm, which
-- on a connected realm is not the character's - pinning to a realm would lock
-- out exactly the transfers and connected-realm alts we want covered. A
-- same-named guild elsewhere matching too costs us nothing.
function ns.IsGuildMember()
    if not IsInGuild() then return false end
    -- GetGuildInfo("player") returns nil for a guilded character while the
    -- roster is still loading, which is precisely the state at PLAYER_LOGIN.
    -- Hence the events below rather than one check at startup.
    local name = GetGuildInfo("player")
    return type(name) == "string" and name:lower() == GUILD_NAME_FOLDED
end

ns.isGuildMember = false

-- A flip adds or removes a whole tab, so it has to redraw. Unchanged is the
-- overwhelmingly common case - GUILD_ROSTER_UPDATE fires on every roster
-- change and every guild-panel open - and costs nothing.
function ns.UpdateGuildMembership()
    local now = ns.IsGuildMember()
    if now ~= ns.isGuildMember then
        ns.isGuildMember = now
        ns.safecall(ns.UI_GuildMembershipChanged)
    end
end

-- ------------------------------------------------------------------
-- Events
-- ------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:RegisterEvent("ENCOUNTER_START")
f:RegisterEvent("ENCOUNTER_END")
-- Guild name is unavailable at login and arrives on one of these two.
f:RegisterEvent("PLAYER_GUILD_UPDATE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")

f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        GuildPlaybookDB = GuildPlaybookDB or {}
        GuildPlaybookDB.point = GuildPlaybookDB.point or { "CENTER", 250, 0 }
        if GuildPlaybookDB.autoOpen == nil then GuildPlaybookDB.autoOpen = true end
        local n = 0
        for _ in pairs(ns.dungeons) do n = n + 1 end
        print(("|cff69ccf0Guild Playbook|r v%s loaded — %d dungeon(s), UI %s. /gp to toggle.")
            :format(C_AddOns.GetAddOnMetadata(ADDON, "Version") or "?", n, ns.uiLoaded and "ok" or "|cffff4040FAILED|r"))
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        ns.UpdateRole()
        ns.UpdateGuildMembership()
        CheckZone()
    elseif event == "PLAYER_GUILD_UPDATE" or event == "GUILD_ROSTER_UPDATE" then
        ns.UpdateGuildMembership()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        ns.UpdateRole()
    elseif event == "ENCOUNTER_START" then
        local encounterID, encounterName = arg1, arg2
        if ns.captureIDs then
            print(("|cff69ccf0GP ids:|r ENCOUNTER_START %s encounterID=%s"):format(tostring(encounterName), tostring(encounterID)))
        end
        local hit = ns.byEncounterID[encounterID]
        if hit and hit.dungeon == ns.currentDungeon then
            ns.safecall(ns.UI_SelectBoss, hit.dungeon, hit.boss)
        end
    elseif event == "ENCOUNTER_END" then
        if ns.currentDungeon then
            ns.safecall(ns.UI_SelectDefault)
        end
    end
end)

-- ------------------------------------------------------------------
-- Self-whisper loopback check (/gp commtest)
-- ------------------------------------------------------------------
-- The one-click MDT import in UI.lua rests on two assumptions: an addon
-- message whispered to yourself comes back, and UnitFullName resolves the
-- sender it arrives with. MDT keys its preset cache on the second one, so a
-- failure there is silent and looks like the import "just not working". This
-- checks both without MDT in the picture.

local COMMTEST_PREFIX = "GPlaybookPing"   -- 13 chars; the cap is 16
local commTestFrame
local commTestSentAt

local function CommTestReport(line)
    print("|cff69ccf0GP commtest:|r " .. line)
end

local function StartCommTest()
    if commTestSentAt then
        CommTestReport("a test is already running.")
        return
    end
    local name, realm = UnitFullName("player")
    if not name or not realm or realm == "" then
        CommTestReport("cannot resolve your own name - aborted.")
        return
    end
    local target = name .. "-" .. realm
    -- What the import's chat link will encode, built the way MDT's send path
    -- does. The point of the test is whether the received sender derives to it.
    local expected = (UnitFullName(name) or name) .. "-" .. realm

    if not commTestFrame then
        commTestFrame = CreateFrame("Frame")
        commTestFrame:SetScript("OnEvent", function(_, _, prefix, _, distribution, sender)
            if prefix ~= COMMTEST_PREFIX or not commTestSentAt then return end
            local elapsed = (GetTimePreciseSec() - commTestSentAt) * 1000
            commTestSentAt = nil
            commTestFrame:UnregisterEvent("CHAT_MSG_ADDON")
            CommTestReport(("loopback OK (%.0fms, %s)"):format(elapsed, tostring(distribution)))
            -- The half that fails silently: MDT files the preset under this key,
            -- and our link looks it up under `expected`. A same-realm sender
            -- arrives without a realm, so this is where a mismatch shows up.
            local key = ns.MdtSenderKey(sender)
            if not key then
                CommTestReport(("|cffff4040sender %q does not resolve via UnitFullName|r - MDT import would fail.")
                    :format(tostring(sender)))
            elseif key == expected then
                CommTestReport(("sender %q -> cache key %s (matches the import link)"):format(tostring(sender), key))
            else
                CommTestReport(("|cffff4040cache key mismatch|r: sender %q -> %s, but the import link encodes %s.")
                    :format(tostring(sender), key, expected))
            end
        end)
    end

    -- 0=success, 1=already registered, 2=invalid, 3=too many prefixes (cap 64).
    -- Without this a full prefix table would look identical to a dead loopback.
    local registered = C_ChatInfo.RegisterAddonMessagePrefix(COMMTEST_PREFIX)
    if type(registered) == "number" and registered > 1 then
        CommTestReport(("|cffff4040prefix registration failed (code %d)|r - not a loopback failure.")
            :format(registered))
        return
    end
    commTestFrame:RegisterEvent("CHAT_MSG_ADDON")
    commTestSentAt = GetTimePreciseSec()
    C_ChatInfo.SendAddonMessage(COMMTEST_PREFIX, "ping", "WHISPER", target)
    CommTestReport("whispered a ping to " .. target .. " - waiting 5s.")

    C_Timer.After(5, function()
        if not commTestSentAt then return end
        commTestSentAt = nil
        commTestFrame:UnregisterEvent("CHAT_MSG_ADDON")
        CommTestReport("|cffff4040NO loopback after 5s|r - one-click MDT import will fall back to the copy-box.")
    end)
end

-- ------------------------------------------------------------------
-- Slash command + addon compartment
-- ------------------------------------------------------------------

local function Usage()
    print("|cff69ccf0Guild Playbook|r — /gp [command]")
    print("  /gp             toggle the playbook panel")
    print("  /gp tank|healer|dps   force a role view")
    print("  /gp auto        follow your assigned role again")
    print("  /gp ids         toggle ID capture mode (prints instance/encounter IDs)")
    print("  /gp autoopen    toggle auto-open when you enter a covered dungeon")
    print("  /gp list        list loaded dungeons")
    print("  /gp minimap     show/hide the minimap button")
    print("  /gp commtest    check the self-whisper the MDT import relies on")
end

SLASH_GUILDPLAYBOOK1, SLASH_GUILDPLAYBOOK2 = "/gp", "/guildplaybook"
SlashCmdList.GUILDPLAYBOOK = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" then
        if ns.UI_Toggle then
            local ok, err = pcall(ns.UI_Toggle)
            if not ok then
                print("|cffff4040Guild Playbook error:|r " .. tostring(err))
            end
        else
            print("|cff69ccf0Guild Playbook:|r UI failed to load — run /gp debug and report the output.")
        end
    elseif msg == "debug" then
        local n = 0
        for _ in pairs(ns.dungeons) do n = n + 1 end
        print("|cff69ccf0GP debug:|r uiLoaded=" .. tostring(ns.uiLoaded)
            .. " frame=" .. tostring(GuildPlaybookFrame ~= nil)
            .. " dungeons=" .. n
            .. " role=" .. tostring(ns.role)
            .. " currentDungeon=" .. tostring(ns.currentDungeon and ns.currentDungeon.dungeon))
    elseif msg == "tank" or msg == "healer" or msg == "dps" then
        ns.roleOverride = msg:upper()
        ns.role = ns.roleOverride
        ns.safecall(ns.UI_Refresh)
        print("|cff69ccf0Guild Playbook:|r showing " .. msg:upper() .. " view (/gp auto to reset).")
    elseif msg == "auto" then
        ns.roleOverride = nil
        ns.UpdateRole()
        ns.safecall(ns.UI_Refresh)
        print("|cff69ccf0Guild Playbook:|r following assigned role (" .. ns.role .. ").")
    elseif msg == "ids" then
        ns.captureIDs = not ns.captureIDs
        print("|cff69ccf0Guild Playbook:|r ID capture " .. (ns.captureIDs and "ON — enter the dungeon and pull bosses; IDs print to chat." or "off."))
        if ns.captureIDs then CheckZone() end
    elseif msg == "autoopen" then
        GuildPlaybookDB.autoOpen = not (GuildPlaybookDB.autoOpen ~= false)
        print("|cff69ccf0Guild Playbook:|r auto-open " .. (GuildPlaybookDB.autoOpen and "ON — the playbook opens automatically when you enter a covered dungeon." or "off."))
        ns.safecall(ns.UI_SyncAutoOpen)
    elseif msg == "minimap" then
        if ns.ToggleMinimapButton then
            ns.ToggleMinimapButton()
        else
            print("|cff69ccf0Guild Playbook:|r minimap button unavailable (libraries failed to load).")
        end
    elseif msg == "commtest" then
        StartCommTest()
    elseif msg == "list" then
        for slug, d in pairs(ns.dungeons) do
            print(("  %s (%s, instanceID=%s)"):format(d.dungeon, d.season, tostring(d.instanceID)))
        end
    else
        Usage()
    end
end

function GuildPlaybook_OnAddonCompartmentClick()
    ns.safecall(ns.UI_Toggle)
end
