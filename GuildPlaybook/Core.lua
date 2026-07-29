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
    for _, boss in ipairs(d.bosses or {}) do
        if boss.encounterID then
            ns.byEncounterID[boss.encounterID] = { dungeon = d, boss = boss }
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

f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        GuildPlaybookDB = GuildPlaybookDB or {}
        GuildPlaybookDB.point = GuildPlaybookDB.point or { "CENTER", 250, 0 }
        local n = 0
        for _ in pairs(ns.dungeons) do n = n + 1 end
        print(("|cff69ccf0Guild Playbook|r v%s loaded — %d dungeon(s), UI %s. /gp to toggle.")
            :format(C_AddOns.GetAddOnMetadata(ADDON, "Version") or "?", n, ns.uiLoaded and "ok" or "|cffff4040FAILED|r"))
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        ns.UpdateRole()
        CheckZone()
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
            ns.safecall(ns.UI_SelectOverview)
        end
    end
end)

-- ------------------------------------------------------------------
-- Slash command + addon compartment
-- ------------------------------------------------------------------

local function Usage()
    print("|cff69ccf0Guild Playbook|r — /gp [command]")
    print("  /gp             toggle the playbook panel")
    print("  /gp tank|healer|dps   force a role view")
    print("  /gp auto        follow your assigned role again")
    print("  /gp ids         toggle ID capture mode (prints instance/encounter IDs)")
    print("  /gp list        list loaded dungeons")
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
