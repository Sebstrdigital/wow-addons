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

-- All-roles quick sheet: every role's one-liners, so each role knows the others' jobs.
local function BuildQuicksheetText(d)
    local out = {}
    local qs = d.quicksheet or {}
    if qs.trash then
        heading(out, "Priority trash calls")
        for _, role in ipairs({ "TANK", "HEALER", "DPS", "ROUTE" }) do
            local line = qs.trash[role]
            if line then
                local color = C[role] or C.HEAD
                out[#out + 1] = color .. role .. ":|r " .. C.BODY .. line .. C.R
            end
        end
    end
    local lists = { d.minibosses or {}, d.bosses or {} }
    local n = 0
    for _, list in ipairs(lists) do
        for _, boss in ipairs(list) do
            if boss.sheet then
                n = n + 1
                heading(out, n .. "  " .. boss.name)
                for _, role in ipairs({ "TANK", "HEALER", "DPS" }) do
                    if boss.sheet[role] then
                        out[#out + 1] = (C[role] or C.HEAD) .. role .. ":|r " .. C.BODY .. boss.sheet[role] .. C.R
                    end
                end
                if boss.sheet.WIPE then
                    out[#out + 1] = C.WIPE .. "WIPE:|r " .. C.WIPE .. boss.sheet.WIPE .. C.R
                end
            end
        end
    end
    if #out == 0 then
        out[1] = C.DIM .. "No quick sheet for this dungeon yet." .. C.R
    end
    return table.concat(out, "\n")
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
        if o.dps.purges then
            heading(out, "Purge and control", C.DPS)
            bullets(o.dps.purges, out)
        end
        if o.dps.defensives then
            heading(out, "Personal defensive warnings", C.WIPE)
            bullets(o.dps.defensives, out)
        end
        if o.dps.pullWarnings then
            heading(out, "Pull warnings", C.WIPE)
            bullets(o.dps.pullWarnings, out)
        end
    end

    if o.tip then
        heading(out, "Practical tip")
        if type(o.tip) == "table" then
            bullets(o.tip, out)
        else
            out[#out + 1] = C.BODY .. o.tip .. C.R
        end
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

-- A named trash segment sitting between two bosses.
local function BuildTrashText(segment, role)
    local calls = (segment.roles or {})[role]
    local out = {}

    if calls and #calls > 0 then
        heading(out, "Your calls", C[role])
        bullets(calls, out)
    else
        out[#out + 1] = C.DIM .. "No " .. (ROLE_LABEL[role] or role) .. " calls for this trash." .. C.R
    end

    return table.concat(out, "\n")
end

-- Trash calls are authored "Mob Name — advice", so a call belongs to the mob
-- whose name it opens with. Authors mix the typographic apostrophe with the
-- ASCII one, hence the fold.
local CURLY_APOS, EM_DASH, EN_DASH = "\226\128\153", "\226\128\148", "\226\128\147"

local function normalize(s)
    return (s:gsub(CURLY_APOS, "'"):lower())
end

local function opensWithSeparator(rest)
    if rest == "" then return true end
    local t = rest:match("^%s*(.*)$") or rest
    local c = t:sub(1, 1)
    if c == ":" or c == "-" then return true end
    local wide = t:sub(1, 3)
    return wide == EM_DASH or wide == EN_DASH
end

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

-- A call may name several mobs at once ("Frigid Mauler / Terra Rumbler — ..."),
-- so walk the slash-separated head and collect every mob named there. Matching
-- anchors on the mob names rather than on the first punctuation, because names
-- like "Keen-Eyed Screecher" contain a hyphen of their own. The walk stops at
-- the chunk carrying the separator, so a slash later in the sentence is inert.
-- Longest name wins within a chunk, so a name that prefixes another does not
-- steal the more specific mob's calls.
local function NPCsForCall(call, npcs)
    if type(call) ~= "string" then return nil end
    local found, any = {}, false
    local rest = normalize(call)

    while true do
        local head, tail = rest:match("^([^/]*)/(.*)$")
        local chunk = trim(head or rest)
        local exact, prefixed, prefixedLen = nil, nil, -1

        for _, npc in ipairs(npcs or {}) do
            local name = npc and npc.name
            if type(name) == "string" and name ~= "" then
                local n = normalize(name)
                if chunk == n then
                    exact = npc
                elseif #n > prefixedLen and chunk:sub(1, #n) == n
                       and opensWithSeparator(chunk:sub(#n + 1)) then
                    prefixed, prefixedLen = npc, #n
                end
            end
        end

        if exact and tail then
            -- A bare mob name followed by "/": the head continues.
            found[exact], any = true, true
            rest = tail
        else
            local hit = prefixed or exact
            if hit then found[hit], any = true, true end
            break
        end
    end

    return any and found or nil
end

-- One mob inside a segment: only the calls that name it. Calls naming no mob
-- stay on the segment view rather than being dropped here.
local function BuildNPCText(segment, npc, role)
    local out = {}
    local mine = {}
    for _, call in ipairs((segment.roles or {})[role] or {}) do
        local named = NPCsForCall(call, segment.npcs)
        if named and named[npc] then
            mine[#mine + 1] = call
        end
    end

    if #mine > 0 then
        heading(out, npc.name, C[role])
        bullets(mine, out)
    else
        out[#out + 1] = C.DIM .. "No " .. (ROLE_LABEL[role] or role) .. " call names "
            .. tostring(npc.name) .. " on its own. Open the segment above for calls that "
            .. "cover the whole pull." .. C.R
    end

    return table.concat(out, "\n")
end

-- ------------------------------------------------------------------
-- Frame
-- ------------------------------------------------------------------

local PANEL_W, PANEL_H, NAV_W = 600, 680, 160

-- Nav rows size themselves to their wrapped label. Trash segment names run well
-- past the column width, and truncating them made distinct entries read alike.
local NAV_ROW_MIN, NAV_ROW_PAD = 30, 10

-- Nav depth is carried by the label's left inset. Indentation alone marks trash
-- as subordinate to the bosses; its NPCs sit one step further in.
local INSET_TOP, INSET_TRASH, INSET_NPC = 2, 10, 22
-- ASCII only: the default client font has no glyph for U+25BE/U+25B8 (they draw
-- as empty boxes), the same gap that makes the generator rewrite "→" to ">".
local GLYPH_OPEN, GLYPH_SHUT = "-", "+"

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
title:SetText("Stand as One's Playbook")

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
-- `expanded` is the one trash segment whose NPCs are listed (accordion). It
-- lives in `selected` so the fresh-table resets below clear it implicitly.
local selected = { kind = "overview", boss = nil, segment = nil, npc = nil, expanded = nil }
local viewedDungeon = nil   -- dungeon shown in the panel (may differ from ns.currentDungeon while browsing)

local function SortedDungeons()
    local list = {}
    for _, d in pairs(ns.dungeons) do list[#list + 1] = d end
    table.sort(list, function(a, b) return a.dungeon < b.dungeon end)
    return list
end

-- The nav column scrolls: a dungeon with four trash segments overflows the
-- available height once one of them is expanded, and the rows below would
-- otherwise be unreachable.
local navScroll = CreateFrame("ScrollFrame", nil, frame)
navScroll:SetPoint("TOPLEFT", 14, -104)
navScroll:SetPoint("BOTTOMLEFT", 14, 14)
navScroll:SetWidth(NAV_W)

local nav = CreateFrame("Frame", nil, navScroll)
nav:SetSize(NAV_W, 1)
navScroll:SetScrollChild(nav)

local NAV_SCROLL_STEP = 28

local function NavScrollRange()
    local extent = (nav:GetHeight() or 0) - (navScroll:GetHeight() or 0)
    return extent > 0 and extent or 0
end

local function SetNavScroll(value)
    local range = NavScrollRange()
    if value < 0 then value = 0 elseif value > range then value = range end
    navScroll:SetVerticalScroll(value)
    return value
end

navScroll:EnableMouseWheel(true)
navScroll:SetScript("OnMouseWheel", function(self, delta)
    if NavScrollRange() <= 0 then return end
    SetNavScroll((self:GetVerticalScroll() or 0) - delta * NAV_SCROLL_STEP)
end)

-- Slim indicator living in the 10px gutter between the nav column and the
-- content panel, so it never overlaps a label. Hidden when everything fits.
local navBar = CreateFrame("Frame", nil, frame)
navBar:SetWidth(4)
navBar:SetPoint("TOPLEFT", navScroll, "TOPRIGHT", 3, 0)
navBar:SetPoint("BOTTOMLEFT", navScroll, "BOTTOMRIGHT", 3, 0)
navBar:Hide()

local navBarTrack = navBar:CreateTexture(nil, "BACKGROUND")
navBarTrack:SetAllPoints()
navBarTrack:SetColorTexture(1, 1, 1, 0.07)

local navBarThumb = navBar:CreateTexture(nil, "ARTWORK")
navBarThumb:SetColorTexture(1, 0.82, 0, 0.45)

local function UpdateNavBar()
    local range = NavScrollRange()
    if range <= 0 then
        navBar:Hide()
        return
    end
    local viewH = navScroll:GetHeight() or 0
    local total = nav:GetHeight() or 1
    local frac = viewH / total
    if frac > 1 then frac = 1 end
    local thumbH = math.max(20, viewH * frac)
    local offset = (navScroll:GetVerticalScroll() or 0) / range * (viewH - thumbH)
    navBarThumb:ClearAllPoints()
    navBarThumb:SetPoint("TOPLEFT", navBar, "TOPLEFT", 0, -offset)
    navBarThumb:SetSize(4, thumbH)
    navBar:Show()
end

local function UpdateNavHighlight()
    for _, btn in ipairs(navButtons) do
        local isSelected = (btn.kind == selected.kind) and (btn.boss == selected.boss)
                           and (btn.segment == selected.segment) and (btn.npc == selected.npc)
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
        if d.quicksheet then
            entries[#entries + 1] = { kind = "quicksheet", label = "Quick sheet (all roles)" }
        end
        entries[#entries + 1] = { kind = "overview", label = "Overview & Trash" }
        for _, mb in ipairs(d.minibosses or {}) do
            entries[#entries + 1] = { kind = "boss", boss = mb, label = "* " .. mb.name }
        end
        -- Trash segments sit in dungeon order: after == nil before the first
        -- boss, otherwise straight after the boss they name.
        local function addTrash(afterBoss)
            for _, seg in ipairs(d.trashSegments or {}) do
                if seg.after == afterBoss then
                    local npcs = seg.npcs or {}
                    -- A segment with no named mobs has nothing to expand into,
                    -- so it gets no expander and stays a leaf.
                    local open = (#npcs > 0) and (selected.expanded == seg)
                    local label = seg.name
                    if #npcs > 0 then
                        label = label .. "  " .. (open and GLYPH_OPEN or GLYPH_SHUT)
                    end
                    entries[#entries + 1] = { kind = "trash", segment = seg,
                                              label = label, inset = INSET_TRASH }
                    if open then
                        for _, npc in ipairs(npcs) do
                            if type(npc.name) == "string" and npc.name ~= "" then
                                entries[#entries + 1] = { kind = "npc", segment = seg, npc = npc,
                                                          label = npc.name, inset = INSET_NPC }
                            end
                        end
                    end
                end
            end
        end
        addTrash(nil)
        for i, boss in ipairs(d.bosses or {}) do
            entries[#entries + 1] = { kind = "boss", boss = boss, label = i .. ". " .. boss.name }
            addTrash(boss.name)
        end
    end
    local prev
    local total = 0
    for i, entry in ipairs(entries) do
        local btn = navButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, nav)
            btn:SetPoint("LEFT")
            btn:SetPoint("RIGHT")
            local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fs:SetJustifyH("LEFT")
            fs:SetWordWrap(true)
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
        -- Indent by moving the label in, narrowing it to match: an explicit
        -- width (rather than a LEFT/RIGHT anchor pair) is what makes
        -- GetStringHeight report the wrapped height right away, so the width
        -- has to absorb the inset or deep rows would clip.
        local fs = btn:GetFontString()
        local inset = entry.inset or INSET_TOP
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", inset, 0)
        fs:SetWidth(NAV_W - 2 - inset)
        btn:SetText(entry.label)
        local rowH = math.max(NAV_ROW_MIN, fs:GetStringHeight() + NAV_ROW_PAD)
        btn:SetHeight(rowH)
        -- Offset from the top of the scroll child, used to scroll a row into view.
        if i > 1 then total = total + 2 end
        btn.navTop = total
        total = total + rowH
        btn.kind, btn.boss, btn.segment, btn.npc = entry.kind, entry.boss, entry.segment, entry.npc
        btn:SetScript("OnClick", function()
            if entry.kind == "dungeon" then
                ns.safecall(ns.UI_SetDungeon, entry.dungeon)
            elseif entry.kind == "back" then
                ns.safecall(ns.UI_SetDungeon, nil)
            elseif entry.kind == "trash" then
                -- Accordion: opening one segment shuts any other. Clicking the
                -- open one again shuts it without dropping the selection.
                local expandable = #(entry.segment.npcs or {}) > 0
                selected = {
                    kind = "trash", segment = entry.segment,
                    expanded = (expandable and selected.expanded ~= entry.segment)
                               and entry.segment or nil,
                }
                ns.safecall(ns.UI_Refresh)
            else
                -- Only an NPC row keeps its parent segment open; every other
                -- row collapses the accordion.
                selected = {
                    kind = entry.kind, boss = entry.boss, segment = entry.segment,
                    npc = entry.npc,
                    expanded = (entry.kind == "npc") and selected.expanded or nil,
                }
                ns.safecall(ns.UI_Refresh)
            end
        end)
        btn:Show()
        prev = btn
    end

    nav:SetHeight(math.max(1, total))

    -- Keep the reading position across a rebuild: clamp what we had, then pull
    -- the selected row back into view only if the rebuild pushed it out. That
    -- keeps an expand from scrolling to top while still revealing the row the
    -- user just clicked.
    local view = navScroll:GetHeight() or 0
    local at = SetNavScroll(navScroll:GetVerticalScroll() or 0)
    if view > 0 then
        for _, btn in ipairs(navButtons) do
            if btn:IsShown() and btn.kind == selected.kind and btn.boss == selected.boss
               and btn.segment == selected.segment and btn.npc == selected.npc then
                local top, bottom = btn.navTop or 0, (btn.navTop or 0) + (btn:GetHeight() or 0)
                if top < at then
                    at = SetNavScroll(top)
                elseif bottom > at + view then
                    at = SetNavScroll(bottom - view)
                end
                break
            end
        end
    end
    UpdateNavBar()
end

-- Content ---------------------------------------------------------

local scroll = CreateFrame("ScrollFrame", "GuildPlaybookScroll", frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", navScroll, "TOPRIGHT", 10, 0)
scroll:SetPoint("BOTTOMRIGHT", -32, 14)

-- Only show the scrollbar when the content actually overflows.
local scrollBar = scroll.ScrollBar or GuildPlaybookScrollScrollBar
if scrollBar then
    scroll:HookScript("OnScrollRangeChanged", function(_, _, yrange)
        scrollBar:SetShown(yrange and yrange > 1)
    end)
    scrollBar:Hide()
end

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

-- Bosses and trash NPCs are both just {name, displayID, npcID}, so they drive
-- the model the same way.
local function HasModel(e)
    return e ~= nil and (e.displayID or e.npcID) ~= nil
end

local function ApplyModel(e)
    model:ClearModel()
    if e.displayID then
        model:SetDisplayInfo(e.displayID)
    else
        model:SetCreature(e.npcID)
    end
    model:SetRotation(0.5)
end

-- Trash is authored with names alone and the IDs backfilled later, so a segment
-- usually has none yet; take the first that can actually render.
local function FirstModelledNPC(segment)
    for _, npc in ipairs(segment.npcs or {}) do
        if HasModel(npc) then return npc end
    end
end

local function UpdateSidecar()
    local subject
    if selected.kind == "boss" then
        subject = HasModel(selected.boss) and selected.boss or nil
    elseif selected.kind == "npc" then
        subject = HasModel(selected.npc) and selected.npc or nil
    elseif selected.kind == "trash" and selected.segment then
        subject = FirstModelledNPC(selected.segment)
    end
    if not subject then
        sidecar:Hide()
        return
    end
    -- flip to the left side when the default right-side anchor would go off-screen
    local right = frame:GetRight()
    sidecar:ClearAllPoints()
    if right and (right + 300) > UIParent:GetWidth() then
        sidecar:SetPoint("TOPRIGHT", frame, "TOPLEFT", 6, -30)
    else
        sidecar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -6, -30)
    end
    modelTitle:SetText(subject.name)
    ApplyModel(subject)
    sidecar:Show()
end

-- ------------------------------------------------------------------
-- Public API used by Core.lua
-- ------------------------------------------------------------------

function ns.UI_Refresh()
    local d = viewedDungeon
    UpdateRoleTabs()
    -- Expanding a segment changes which rows exist, so the nav is rebuilt from
    -- `selected` on every refresh rather than only when the dungeon changes.
    BuildNav(d)
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
        elseif selected.kind == "npc" and selected.npc and selected.segment then
            sectionTitle:SetText(selected.npc.name)
            text:SetText(BuildNPCText(selected.segment, selected.npc, ns.role))
        elseif selected.kind == "trash" and selected.segment then
            sectionTitle:SetText(selected.segment.name)
            text:SetText(BuildTrashText(selected.segment, ns.role))
        elseif selected.kind == "quicksheet" then
            sectionTitle:SetText("Quick sheet — all roles")
            text:SetText(BuildQuicksheetText(d))
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
    ns.UI_Refresh()
end

function ns.UI_SelectBoss(dungeon, boss)
    viewedDungeon = dungeon
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
