local ADDON, ns = ...

-- Minimap button via LibDataBroker + LibDBIcon. The soft dependency check
-- means the addon keeps working (slash command, compartment) if the libs
-- ever fail to load.
local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
local dbicon = LibStub and LibStub("LibDBIcon-1.0", true)
if not (ldb and dbicon) then return end

local ROLE_CYCLE = { TANK = "HEALER", HEALER = "DPS", DPS = nil }

local broker = ldb:NewDataObject("GuildPlaybook", {
    type = "launcher",
    text = "Stand as One's Playbook",
    icon = "Interface\\AddOns\\GuildPlaybook\\Media\\icon",
    OnClick = function(_, button)
        if button == "RightButton" then
            -- Cycle role view: auto -> TANK -> HEALER -> DPS -> auto,
            -- mirroring /gp tank|healer|dps and /gp auto.
            if ns.roleOverride == nil then
                ns.roleOverride = "TANK"
            else
                ns.roleOverride = ROLE_CYCLE[ns.roleOverride]
            end
            if ns.roleOverride then
                ns.role = ns.roleOverride
                ns.safecall(ns.UI_Refresh)
                print("|cff69ccf0Guild Playbook:|r showing " .. ns.roleOverride .. " view (/gp auto to reset).")
            else
                ns.UpdateRole()
                ns.safecall(ns.UI_Refresh)
                print("|cff69ccf0Guild Playbook:|r following assigned role (" .. ns.role .. ").")
            end
        else
            ns.safecall(ns.UI_Toggle)
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Stand as One's Playbook")
        tt:AddLine("|cffeda55fClick|r to toggle the playbook", 0.7, 0.7, 0.7)
        tt:AddLine("|cffeda55fRight-click|r to cycle role view (" .. (ns.roleOverride or "auto") .. ")", 0.7, 0.7, 0.7)
    end,
})

-- Core.lua's ADDON_LOADED handler runs first (registered earlier) and
-- initializes GuildPlaybookDB before this fires.
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, _, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")
    GuildPlaybookDB.minimap = GuildPlaybookDB.minimap or {}
    dbicon:Register("GuildPlaybook", broker, GuildPlaybookDB.minimap)
end)

-- /gp minimap toggles the button; state persists in GuildPlaybookDB.minimap.hide
function ns.ToggleMinimapButton()
    local db = GuildPlaybookDB and GuildPlaybookDB.minimap
    if not db then return end
    db.hide = not db.hide
    if db.hide then
        dbicon:Hide("GuildPlaybook")
        print("|cff69ccf0Guild Playbook:|r minimap button hidden (/gp minimap to restore).")
    else
        dbicon:Show("GuildPlaybook")
        print("|cff69ccf0Guild Playbook:|r minimap button shown.")
    end
end
