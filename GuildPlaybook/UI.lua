local ADDON, ns = ...

-- ------------------------------------------------------------------
-- Colors (match the PDF playbook convention)
-- ------------------------------------------------------------------

local C = {
    TANK   = "|cff4a9eff",
    HEALER = "|cff3fd47f",
    DPS    = "|cffff9333",
    WIPE   = "|cffff4040",
    HEAD   = "|cffffd100",
    BODY   = "|cffe8e8e8",
    DIM    = "|cff9d9d9d",
    R      = "|r",
}

local ROLE_LABEL = { TANK = "Tank", HEALER = "Healer", DPS = "DPS" }

-- ------------------------------------------------------------------
-- Text building
-- ------------------------------------------------------------------

local function bullets(lines, out, color)
    for _, line in ipairs(lines or {}) do
        out[#out + 1] = (color or C.BODY) .. "• " .. line .. C.R
    end
end

local function heading(out, text, color)
    if #out > 0 then out[#out + 1] = " " end
    out[#out + 1] = (color or C.HEAD) .. text .. C.R
end

local function BuildOverviewText(d, role)
    local o = d.overview or {}
    local out = {}

    heading(out, "Interrupt first")
    for i, it in ipairs(o.interrupts or {}) do
        out[#out + 1] = C.BODY .. i .. ". " .. it.spell .. (it.note and (C.DIM .. " — " .. it.note) or "") .. C.R
    end

    if role ~= "HEALER" then
        heading(out, "Kill first")
        for i, name in ipairs(o.killPriority or {}) do
            out[#out + 1] = C.BODY .. i .. ". " .. name .. C.R
        end
    end

    if role == "TANK" and o.tank then
        heading(out, "Dangerous tank damage", C.TANK)
        bullets(o.tank.damage, out)
        heading(out, "Pull warnings", C.WIPE)
        bullets(o.tank.pullWarnings, out)
    elseif role == "HEALER" and o.healer then
        heading(out, "Dispel first", C.HEALER)
        bullets(o.healer.dispels, out)
        heading(out, "Biggest healing pressure", C.HEALER)
        bullets(o.healer.pressure, out)
        heading(out, "Pull warnings", C.WIPE)
        bullets(o.healer.pullWarnings, out)
    elseif role == "DPS" and o.dps then
        heading(out, "Purge and control", C.DPS)
        bullets(o.dps.purges, out)
        heading(out, "Personal defensive warnings", C.WIPE)
        bullets(o.dps.defensives, out)
    end

    if o.tip then
        heading(out, "Practical tip")
        out[#out + 1] = C.BODY .. o.tip .. C.R
    end

    return table.concat(out, "\n")
end

local function BuildBossText(boss, role)
    local body = (boss.roles or {})[role]
    local out = {}

    if body and body.reminder then
        out[#out + 1] = (C[role] or C.HEAD) .. body.reminder .. C.R
    end
    if body then
        heading(out, "Your job", C[role])
        bullets(body.job, out)
        if body.avoid then
            heading(out, "Avoid", C[role])
            bullets(body.avoid, out)
        end
        local def = body.defensive or body.cooldowns
        if def then
            heading(out, role == "HEALER" and "Cooldowns" or "Defensives", C[role])
            bullets(def, out)
        end
    else
        out[#out + 1] = C.DIM .. "No " .. (ROLE_LABEL[role] or role) .. " notes for this boss." .. C.R
    end

    if boss.wipe then
        heading(out, "Wipe mechanic", C.WIPE)
        bullets(boss.wipe, out, C.WIPE)
    end

    return table.concat(out, "\n")
end

-- ------------------------------------------------------------------
-- Frame
-- ------------------------------------------------------------------

local PANEL_W, PANEL_H, NAV_W = 600, 680, 160

local frame = CreateFrame("Frame", "GuildPlaybookFrame", UIParent, "BackdropTemplate")
frame:SetSize(PANEL_W, PANEL_H)
frame:SetFrameStrata("MEDIUM")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 },
})
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    GuildPlaybookDB.point = { point, x, y }
end)
frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -14)
title:SetText("Guild Playbook")

local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
subtitle:SetText("")

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -6, -6)

-- Role tabs -------------------------------------------------------

local roleButtons = {}
local function UpdateRoleTabs()
    for role, btn in pairs(roleButtons) do
        btn:SetAlpha(role == ns.role and 1 or 0.55)
    end
end

local lastRoleBtn
for _, role in ipairs({ "TANK", "HEALER", "DPS" }) do
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(85, 26)
    if lastRoleBtn then
        btn:SetPoint("LEFT", lastRoleBtn, "RIGHT", 4, 0)
    else
        btn:SetPoint("TOPLEFT", 14, -52)
    end
    btn:SetText((C[role] or "") .. ROLE_LABEL[role] .. C.R)
    btn:SetScript("OnClick", function()
        ns.roleOverride = role
        ns.role = role
        ns.safecall(ns.UI_Refresh)
    end)
    roleButtons[role] = btn
    lastRoleBtn = btn
end

-- Navigation (Overview + bosses) ----------------------------------

local navButtons = {}
local selected = { kind = "overview", boss = nil }
local viewedDungeon = nil   -- dungeon shown in the panel (may differ from ns.currentDungeon while browsing)

local function SortedDungeons()
    local list = {}
    for _, d in pairs(ns.dungeons) do list[#list + 1] = d end
    table.sort(list, function(a, b) return a.dungeon < b.dungeon end)
    return list
end

local nav = CreateFrame("Frame", nil, frame)
nav:SetPoint("TOPLEFT", 14, -104)
nav:SetPoint("BOTTOMLEFT", 14, 14)
nav:SetWidth(NAV_W)

local function UpdateNavHighlight()
    for _, btn in ipairs(navButtons) do
        local isSelected = (btn.kind == selected.kind) and (btn.boss == selected.boss)
        btn:GetFontString():SetTextColor(isSelected and 1 or 0.82, isSelected and 0.82 or 0.82, isSelected and 0 or 0.82)
    end
end

local function BuildNav(d)
    for _, btn in ipairs(navButtons) do btn:Hide() end
    local entries = {}
    if not d then
        for _, dungeon in ipairs(SortedDungeons()) do
            entries[#entries + 1] = { kind = "dungeon", dungeon = dungeon, label = dungeon.dungeon }
        end
    else
        entries[#entries + 1] = { kind = "back", label = C.DIM .. "« Dungeons" .. C.R }
        entries[#entries + 1] = { kind = "overview", label = "Overview" }
        for i, boss in ipairs(d.bosses or {}) do
            entries[#entries + 1] = { kind = "boss", boss = boss, label = i .. ". " .. boss.name }
        end
    end
    local prev
    for i, entry in ipairs(entries) do
        local btn = navButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, nav)
            btn:SetHeight(30)
            btn:SetPoint("LEFT")
            btn:SetPoint("RIGHT")
            local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fs:SetPoint("LEFT", 2, 0)
            fs:SetPoint("RIGHT", -2, 0)
            fs:SetJustifyH("LEFT")
            fs:SetWordWrap(false)
            btn:SetFontString(fs)
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            navButtons[i] = btn
        end
        btn:ClearAllPoints()
        btn:SetPoint("LEFT")
        btn:SetPoint("RIGHT")
        if prev then
            btn:SetPoint("TOP", prev, "BOTTOM", 0, -2)
        else
            btn:SetPoint("TOP", nav, "TOP", 0, 0)
        end
        btn:SetText(entry.label)
        btn.kind, btn.boss = entry.kind, entry.boss
        btn:SetScript("OnClick", function()
            if entry.kind == "dungeon" then
                ns.safecall(ns.UI_SetDungeon, entry.dungeon)
            elseif entry.kind == "back" then
                ns.safecall(ns.UI_SetDungeon, nil)
            else
                selected = { kind = entry.kind, boss = entry.boss }
                ns.safecall(ns.UI_Refresh)
            end
        end)
        btn:Show()
        prev = btn
    end
end

-- Content ---------------------------------------------------------

local scroll = CreateFrame("ScrollFrame", "GuildPlaybookScroll", frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", nav, "TOPRIGHT", 10, 0)
scroll:SetPoint("BOTTOMRIGHT", -32, 14)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(PANEL_W - NAV_W - 60, 1)
scroll:SetScrollChild(content)

local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("TOPLEFT")
text:SetWidth(PANEL_W - NAV_W - 60)
text:SetJustifyH("LEFT")
text:SetSpacing(3)
text:SetWordWrap(true)

local sectionTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sectionTitle:SetPoint("BOTTOMLEFT", scroll, "TOPLEFT", 0, 6)
sectionTitle:SetText("")

-- Model side-cart: shows the boss model when the selected boss has a
-- displayID (preferred, always renders) or npcID (needs client cache).
local sidecar = CreateFrame("Frame", "GuildPlaybookModelFrame", frame, "BackdropTemplate")
sidecar:SetSize(300, 420)
sidecar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -6, -30)
sidecar:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 },
})
sidecar:Hide()

local modelTitle = sidecar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
modelTitle:SetPoint("TOP", 0, -16)

local model = CreateFrame("PlayerModel", nil, sidecar)
model:SetPoint("TOPLEFT", 12, -34)
model:SetPoint("BOTTOMRIGHT", -12, 12)

local function UpdateSidecar()
    local boss = (selected.kind == "boss") and selected.boss or nil
    if not boss or not (boss.displayID or boss.npcID) then
        sidecar:Hide()
        return
    end
    modelTitle:SetText(boss.name)
    model:ClearModel()
    if boss.displayID then
        model:SetDisplayInfo(boss.displayID)
    else
        model:SetCreature(boss.npcID)
    end
    model:SetRotation(0.5)
    sidecar:Show()
end

-- ------------------------------------------------------------------
-- Public API used by Core.lua
-- ------------------------------------------------------------------

function ns.UI_Refresh()
    local d = viewedDungeon
    UpdateRoleTabs()
    UpdateNavHighlight()
    if not d then
        subtitle:SetText(C.DIM .. "Pick a dungeon" .. C.R)
        sectionTitle:SetText("Playbooks")
        text:SetText(C.DIM .. "Select a dungeon on the left.\n\nThe playbook loads automatically when you enter a covered dungeon." .. C.R)
    else
        subtitle:SetText(d.dungeon .. C.DIM .. "  —  " .. (d.season or "") .. C.R)
        if selected.kind == "boss" and selected.boss then
            sectionTitle:SetText(selected.boss.name)
            text:SetText(BuildBossText(selected.boss, ns.role))
        else
            sectionTitle:SetText("Dungeon overview")
            text:SetText(BuildOverviewText(d, ns.role))
        end
    end
    content:SetHeight(text:GetStringHeight() + 20)
    scroll:SetVerticalScroll(0)
    UpdateSidecar()
end

function ns.UI_SetDungeon(d)
    viewedDungeon = d
    selected = { kind = "overview", boss = nil }
    BuildNav(d)
    ns.UI_Refresh()
end

function ns.UI_SelectBoss(dungeon, boss)
    if viewedDungeon ~= dungeon then
        viewedDungeon = dungeon
        BuildNav(dungeon)
    end
    selected = { kind = "boss", boss = boss }
    ns.UI_Refresh()
    frame:Show()
end

function ns.UI_SelectOverview()
    selected = { kind = "overview", boss = nil }
    ns.UI_Refresh()
end

function ns.UI_Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        local p = GuildPlaybookDB and GuildPlaybookDB.point or { "CENTER", 250, 0 }
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[1], p[2], p[3])
        ns.UI_Refresh()
        frame:Show()
    end
end

BuildNav(nil)   -- start in dungeon-list mode until zone detection kicks in

ns.uiLoaded = true
