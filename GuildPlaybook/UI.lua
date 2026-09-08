local ADDON, ns = ...

-- ------------------------------------------------------------------
-- Colors (match the PDF playbook convention)
-- ------------------------------------------------------------------

-- The client's fonts have no bold cut, and a FontString can't change weight
-- part-way through its own text, so emphasis inside a call is carried by
-- brightness instead: LEAD is the "who and what" up to the colon, CALL is the
-- instruction after it, set a step darker so the lead reads as the heavier of
-- the two.
local C = {
    TANK   = "|cff4a9eff",
    HEALER = "|cff3fd47f",
    DPS    = "|cffff9333",
    WIPE   = "|cffff4040",
    HEAD   = "|cffffd100",
    BODY   = "|cffe8e8e8",
    LEAD   = "|cffffffff",
    CALL   = "|cffb9b9b9",
    DIM    = "|cff9d9d9d",
    R      = "|r",
}

local ROLE_LABEL = { TANK = "Tank", HEALER = "Healer", DPS = "DPS" }

-- ------------------------------------------------------------------
-- Ability markup
-- ------------------------------------------------------------------
-- Playbook prose calls out abilities as literal "[Ability Name]" markup.
-- ns.ABILITIES (Data/Abilities.lua, generated) maps that exact name to a
-- spell ID - currently a bare number, unresolved names simply omitted. That
-- shape has already changed once mid-implementation (a table with .spellID,
-- briefly), so both are accepted here rather than assuming either is final:
-- a future generator change can't break the UI. When an ID resolves, the
-- name becomes a clickable, hoverable spell link in guild gold; when it
-- doesn't - entry missing, wrong shape, or any other junk - it still
-- renders in gold, brackets stripped, but inert. The generator is supposed
-- to guarantee every markup resolves, but a content typo or a stale table
-- must never surface as a dead link or a UI error.
-- Two states, deliberately distinguishable. LINK is Blizzard's own spell-link
-- blue and gets square brackets, so a bracketed word always means "hover this
-- for the real tooltip" - it stays legible inside red wipe text and orange
-- role headings, where guild gold was too close to the surrounding color to
-- read as marked at all. GOLD marks an ability we could not resolve to a
-- spellID: still called out, but no brackets, because there is nothing to hover.
local LINK = "|cff71d5ff"
local GOLD = "|cffdfa55a"

-- `resumeColor` is the color code the surrounding text was already in
-- before this call. WoW's |r doesn't pop a color stack, it just reverts to
-- the FontString's base color, so without re-asserting it, any text after
-- an inline ability mention would lose its role/lead/call tint.
--
-- Renders a single known ability name: a bracketed, hoverable spell link in
-- link-blue when ns.ABILITIES resolves it, plain gold and inert otherwise. Shared by the "[Name]" markup path below and by any
-- structured field (e.g. overview.interrupts[].spell) that is already known
-- to be an ability name and so skips markup brackets entirely.
local function RenderKnownAbility(name, resumeColor)
    if type(name) ~= "string" then return name end
    resumeColor = resumeColor or ""
    local a = ns.ABILITIES and ns.ABILITIES[name]
    local id
    if type(a) == "number" then
        id = a
    elseif type(a) == "table" then
        id = a.spellID
    end
    local rendered = (type(id) == "number" and id > 0)
        and (LINK .. "|Hspell:" .. id .. "|h[" .. name .. "]|h")
        or (GOLD .. name)
    return rendered .. C.R .. resumeColor
end

local function RenderAbilityLinks(s, resumeColor)
    if type(s) ~= "string" then return s end
    resumeColor = resumeColor or ""
    return (s:gsub("%[([^%[%]]+)%]", function(name)
        return RenderKnownAbility(name, resumeColor)
    end))
end

-- ------------------------------------------------------------------
-- Text building
-- ------------------------------------------------------------------

local function bullets(lines, out, color)
    local c = color or C.BODY
    for _, line in ipairs(lines or {}) do
        out[#out + 1] = c .. "• " .. RenderAbilityLinks(line, c) .. C.R
    end
end

-- Section headings need clearly more air above them than the body's own line
-- spacing, or they read as part of the block above rather than as a label for
-- the block below. Two blank lines above, none below: the heading should sit
-- tight against what it labels.
local function heading(out, text, color)
    if #out > 0 then
        out[#out + 1] = " "
        out[#out + 1] = " "
    end
    out[#out + 1] = (color or C.HEAD) .. text .. C.R
end

-- Quick sheet trash calls are authored as one string per role holding several
-- separate mob calls, joined with ".; " (each call keeps its own full stop).
-- They are a list wearing a paragraph's clothing, so split them back apart and
-- render one bullet per call. Splitting on ".; " rather than "; " matters:
-- plenty of individual calls use a bare semicolon inside their own sentence
-- ("Interrupt; this is the must-stop cast").
local function splitCalls(line)
    local calls = {}
    local rest = line
    while true do
        local at = rest:find(".; ", 1, true)
        if not at then break end
        calls[#calls + 1] = rest:sub(1, at - 1)
        rest = rest:sub(at + 3)
    end
    calls[#calls + 1] = (rest:gsub("%.$", ""))
    return calls
end

-- Calls read "Target — Ability: what to do about it". The part up to the colon
-- names the thing on screen and is what the eye hunts for, so it gets the
-- brighter colour and the instruction gets the darker one.
--
-- The colon has to be an actual label separator, not one that happens to fall
-- mid-sentence, so only a colon near the start of the line and ahead of any
-- sentence-ending punctuation counts.
local LEAD_MAX = 64

local function emphasiseCall(line)
    local at = line:find(": ", 1, true)
    if not at or at > LEAD_MAX then return C.CALL .. RenderAbilityLinks(line, C.CALL) .. C.R end
    if line:sub(1, at):find("[%.!%?]") then return C.CALL .. RenderAbilityLinks(line, C.CALL) .. C.R end
    return C.LEAD .. RenderAbilityLinks(line:sub(1, at - 1), C.LEAD) .. ":" .. C.R .. " "
        .. C.CALL .. RenderAbilityLinks(line:sub(at + 2), C.CALL) .. C.R
end

local function callBullets(calls, out)
    for _, call in ipairs(calls) do
        out[#out + 1] = C.CALL .. "• " .. C.R .. emphasiseCall(call)
    end
end

-- One role's quick-sheet entry. A single call stays on the label's own line;
-- several get the label as a lead-in with a bullet each, so the reader scans a
-- list instead of parsing a run-on paragraph. A blank line before each role
-- keeps three stacked roles from reading as one continuous list.
local function roleBlock(out, role, line, first)
    local color = C[role] or C.HEAD
    local calls = splitCalls(line)
    if not first then out[#out + 1] = " " end
    if #calls == 1 then
        out[#out + 1] = color .. role .. ":|r " .. emphasiseCall(calls[1])
    else
        out[#out + 1] = color .. role .. C.R
        callBullets(calls, out)
    end
end

-- All-roles quick sheet: every role's one-liners, so each role knows the others' jobs.
local function BuildQuicksheetText(d)
    local out = {}
    local qs = d.quicksheet or {}
    if qs.trash then
        heading(out, "Priority trash calls")
        local first = true
        for _, role in ipairs({ "TANK", "HEALER", "DPS", "ROUTE" }) do
            local line = qs.trash[role]
            if line then
                roleBlock(out, role, line, first)
                first = false
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
                local firstRole = true
                for _, role in ipairs({ "TANK", "HEALER", "DPS" }) do
                    if boss.sheet[role] then
                        roleBlock(out, role, boss.sheet[role], firstRole)
                        firstRole = false
                    end
                end
                if boss.sheet.WIPE then
                    out[#out + 1] = " "
                    out[#out + 1] = C.WIPE .. "WIPE:|r " .. C.WIPE .. RenderAbilityLinks(boss.sheet.WIPE, C.WIPE) .. C.R
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
        -- it.spell is a structured field - always a bare ability name, never
        -- markup - so it's resolved by direct lookup. it.note is prose and
        -- may itself carry "[Ability]" markup, so it stays on that path.
        out[#out + 1] = C.BODY .. i .. ". " .. RenderKnownAbility(it.spell, C.BODY)
            .. (it.note and (C.BODY .. " — " .. RenderAbilityLinks(it.note, C.BODY)) or "") .. C.R
    end

    if role ~= "HEALER" then
        heading(out, "Kill first")
        for i, name in ipairs(o.killPriority or {}) do
            out[#out + 1] = C.BODY .. i .. ". " .. RenderAbilityLinks(name, C.BODY) .. C.R
        end
    end

    -- Headings stay gold throughout. Red is spent only on the blocks that
    -- describe how the group dies, so it still means something when it appears;
    -- tinting every heading by role turned the page into four competing hues.
    if role == "TANK" and o.tank then
        heading(out, "Dangerous tank damage")
        bullets(o.tank.damage, out)
        heading(out, "Pull warnings", C.WIPE)
        bullets(o.tank.pullWarnings, out)
    elseif role == "HEALER" and o.healer then
        heading(out, "Dispel first")
        bullets(o.healer.dispels, out)
        heading(out, "Biggest healing pressure")
        bullets(o.healer.pressure, out)
        heading(out, "Pull warnings", C.WIPE)
        bullets(o.healer.pullWarnings, out)
    elseif role == "DPS" and o.dps then
        if o.dps.purges then
            heading(out, "Purge and control")
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
            out[#out + 1] = C.BODY .. RenderAbilityLinks(o.tip, C.BODY) .. C.R
        end
    end

    return table.concat(out, "\n")
end

local function BuildBossText(boss, role)
    local body = (boss.roles or {})[role]
    local out = {}

    if body and body.reminder then
        local c = C[role] or C.HEAD
        out[#out + 1] = c .. RenderAbilityLinks(body.reminder, c) .. C.R
    end
    if body then
        heading(out, "Your job")
        bullets(body.job, out)
        if body.avoid then
            heading(out, "Avoid")
            bullets(body.avoid, out)
        end
        local def = body.defensive or body.cooldowns
        if def then
            heading(out, role == "HEALER" and "Cooldowns" or "Defensives")
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
        heading(out, "Your calls")
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
        -- No heading here: the section title above the body already names the
        -- mob, and printing it twice reads as a duplicated title.
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

-- MDT Route sits below the nav rows as a chrome button, not a row — same
-- fixed height as a role tab. It grows past that only for the (currently
-- unused) multi-route case, where the label wraps rather than clipping.
local ROUTE_BTN_H, ROUTE_BTN_GAP = 26, 4

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

-- Shared button chrome ----------------------------------------------
-- Blizzard's standard clicky button (backdrop, border, hover/press states),
-- as opposed to a nav row's flat highlighted-text look. Used by the role
-- tabs and by anything else that should read as an action rather than a
-- section to browse into.
local function CreateChromeButton(parent, width, height)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, height)
    return btn
end

-- Top-level tabs ----------------------------------------------------
-- Two unrelated things live in this panel: the dungeon playbooks, and material
-- that only concerns the guild. They share no state and no chrome - the role
-- filter and the boss nav mean nothing on the guild page - so they are split at
-- the top rather than folded in as another nav row.
--
-- The Guild tab exists only for members of ns.GUILD_NAME. Everyone else gets no
-- tab strip at all rather than a locked tab: the addon is public on CurseForge,
-- and a visible-but-refused tab would advertise a private Discord to every
-- stranger who installs it.

local TAB_W, TAB_H = 90, 24
-- The header rows are laid out from the top by hand. When the strip is present
-- it takes the band the role tabs used to have and pushes everything below it
-- down by exactly one row; when it isn't, the rows sit where they always did
-- and no gap is left behind. ApplyTabLayout drives both cases off these.
local HEADER_ROW_Y, HEADER_ROW_STEP, NAV_TOP_Y = -52, 30, -104

local activeTab = "dungeons"
local tabButtons = {}

local lastTabBtn
for _, tab in ipairs({ { key = "dungeons", label = "Dungeons" },
                       { key = "guild",    label = "Guild" } }) do
    local btn = CreateChromeButton(frame, TAB_W, TAB_H)
    if lastTabBtn then
        btn:SetPoint("LEFT", lastTabBtn, "RIGHT", 4, 0)
    else
        btn:SetPoint("TOPLEFT", 14, HEADER_ROW_Y)
    end
    btn:SetText(tab.label)
    btn:SetScript("OnClick", function()
        activeTab = tab.key
        ns.safecall(ns.UI_Refresh)
    end)
    tabButtons[tab.key] = btn
    lastTabBtn = btn
end

-- Role tabs -------------------------------------------------------

local roleButtons = {}
local function UpdateRoleTabs()
    for role, btn in pairs(roleButtons) do
        btn:SetAlpha(role == ns.role and 1 or 0.55)
    end
end

-- Only the first button is anchored to the frame; the rest chain off it, so
-- ApplyTabLayout moves the whole row by re-anchoring this one.
local firstRoleBtn, lastRoleBtn
for _, role in ipairs({ "TANK", "HEALER", "DPS" }) do
    local btn = CreateChromeButton(frame, 85, 26)
    if lastRoleBtn then
        btn:SetPoint("LEFT", lastRoleBtn, "RIGHT", 4, 0)
    else
        firstRoleBtn = btn
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

-- Auto-open setting -------------------------------------------------
-- Sits in the free space right of the role tabs, on the same row.

local autoOpenCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
autoOpenCheck:SetPoint("LEFT", lastRoleBtn, "RIGHT", 20, 0)
local autoOpenLabel = autoOpenCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
autoOpenLabel:SetPoint("LEFT", autoOpenCheck, "RIGHT", 4, 0)
autoOpenLabel:SetText("Auto-open on dungeon entry")
autoOpenCheck:HookScript("OnClick", function(self)
    GuildPlaybookDB.autoOpen = self:GetChecked() and true or false
end)

-- Reflects the saved setting onto the checkbox. Called on frame show and from
-- the /gp autoopen slash handler, so the box stays in sync if that's flipped
-- while the panel is already open.
function ns.UI_SyncAutoOpen()
    autoOpenCheck:SetChecked((GuildPlaybookDB and GuildPlaybookDB.autoOpen) ~= false)
end

frame:HookScript("OnShow", ns.UI_SyncAutoOpen)

-- MDT route copy-box ------------------------------------------------
-- The manual hand-off, used whenever the one-click import below can't run:
-- WoW has no clipboard-write API, so the route string is handed off by
-- selecting it in an EditBox and telling the player to press Ctrl+C. Defined
-- ahead of the nav section because the nav's "MDT Route" entry calls into it.

local mdtCopyBox

local function EnsureMdtCopyBox()
    if mdtCopyBox then return mdtCopyBox end

    local box = CreateFrame("Frame", "GuildPlaybookMdtCopyFrame", UIParent, "BackdropTemplate")
    box:SetSize(480, 220)
    box:SetPoint("CENTER")
    box:SetFrameStrata("DIALOG")
    box:SetMovable(true)
    box:EnableMouse(true)
    box:RegisterForDrag("LeftButton")
    box:SetClampedToScreen(true)
    box:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    box:SetScript("OnDragStart", box.StartMoving)
    box:SetScript("OnDragStop", box.StopMovingOrSizing)

    local boxTitle = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    boxTitle:SetPoint("TOPLEFT", 16, -14)
    box.title = boxTitle

    local closeBtn = CreateFrame("Button", nil, box, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetScript("OnClick", function() box:Hide() end)

    local hint = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", boxTitle, "BOTTOMLEFT", 0, -4)
    hint:SetText("Ctrl+C to copy, then paste in MDT > Import.")

    local editScroll = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
    editScroll:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -8)
    editScroll:SetPoint("BOTTOMRIGHT", -32, 14)

    local edit = CreateFrame("EditBox", nil, editScroll)
    edit:SetMultiLine(true)
    edit:SetFontObject("ChatFontNormal")
    edit:SetWidth(420)
    edit:SetAutoFocus(false)
    -- Route strings run several KB; the template's default cap would
    -- silently truncate them (same reasoning as MDT's own multi-line editors).
    edit:SetMaxLetters(0)
    edit:SetScript("OnEscapePressed", function()
        edit:ClearFocus()
        box:Hide()
    end)
    editScroll:SetScrollChild(edit)
    box.edit = edit

    -- Belt-and-suspenders: however the box gets hidden (Escape, close button,
    -- or a future caller), a hidden box should never be left holding focus.
    box:SetScript("OnHide", function() edit:ClearFocus() end)
    box:Hide()

    mdtCopyBox = box
    return box
end

local function OpenMdtCopyBox(route)
    local box = EnsureMdtCopyBox()
    box.title:SetText(route.name)
    box.edit:SetText(route.string)
    box:Show()
    box.edit:SetFocus()
    box.edit:HighlightText()
end

-- Opens MDT's own interface. Used on the copy-box path, where the route string
-- still has to be pasted by hand.
local function OpenMDT()
    if _G.MythicDungeonToolsAPI and _G.MythicDungeonToolsAPI.ShowInterface then
        _G.MythicDungeonToolsAPI:ShowInterface()
    else
        print("|cff69ccf0Guild Playbook:|r Mythic Dungeon Tools isn't installed - copy the route string below and paste it once it is.")
    end
end

-- One-click MDT import ----------------------------------------------
-- MDT still exposes no import call, but it does cache every preset that arrives
-- on its own addon channel and imports it when the matching chat link is
-- clicked (MDT's Modules/Transmission.lua, OnCommReceived + HandleChatLink).
-- So we whisper the route to ourselves through MDT's public SendCommMessage,
-- wait for the loopback to land, then fire the link MDT itself would have put
-- in chat. Only public API plus the global SetItemRef; no MDT internals.
--
-- Only MDT's newer CBOR exports survive that trip. Legacy "!" strings are
-- print-encoded, while MDT decodes channel traffic with the addon-channel
-- alphabet, so those still get the copy-box.

local MDT2_MARKER = "!~MDT2~"   -- MDT's encodingPrefix
local IMPORT_TIMEOUT = 5        -- seconds to wait for our own whisper to return

-- Mirror of MDT's StringToTable new-format branch. Pure Blizzard APIs, so it
-- works before MDT's load-on-demand UI (which owns the real decoder) is up.
local function DecodeRoute(routeString)
    if type(routeString) ~= "string" then return nil end
    if routeString:sub(1, #MDT2_MARKER) ~= MDT2_MARKER then return nil end
    local ok, preset = pcall(function()
        local decoded = C_EncodingUtil.DecodeBase64(routeString:sub(#MDT2_MARKER + 1))
        if not decoded then return nil end
        local raw = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
        if not raw then return nil end
        return C_EncodingUtil.DeserializeCBOR(raw)
    end)
    if not ok or type(preset) ~= "table" then return nil end
    -- The same structural checks MDT runs in ValidateImportPreset before it will
    -- cache anything. Failing them there drops the preset silently, which would
    -- surface here as the import hanging until the timeout and look like MDT's
    -- fault. The dungeon-membership half of that check is covered in
    -- StartMdtRoute, which requires GetDungeonName to return an actual name.
    if type(preset.text) ~= "string" or type(preset.value) ~= "table" then return nil end
    local value = preset.value
    if not value.currentDungeonIdx or not value.currentPull or not value.currentSublevel then return nil end
    if type(value.pulls) ~= "table" then return nil end
    return preset
end

-- MDT keys its cache on the sender as UnitFullName resolves it, which respects
-- the real casing of a name, while UnitFullName("player") always capitalises the
-- first letter. Re-resolving by name is the same correction MDT applies on its
-- own send path, and skipping it breaks players whose name is lower-case.
local function PlayerCacheName()
    local name, realm = UnitFullName("player")
    if not name or not realm or realm == "" then return nil end
    return (UnitFullName(name) or name), realm
end

local importWatcher
local pendingImport

local function StopWatching()
    pendingImport = nil
    if importWatcher then importWatcher:UnregisterEvent("CHAT_MSG_ADDON") end
end

-- Called once the whole payload has come back to us. MDT reports a cache miss
-- through its bug-report window, so the link is only ever fired after delivery
-- is confirmed - never on a speculative timer.
local function FireImportLink(pending)
    StopWatching()
    -- One frame of slack: our handler and AceComm's both run off CHAT_MSG_ADDON
    -- in an unspecified order, and MDT only caches once AceComm has reassembled.
    C_Timer.After(0, function()
        ns.safecall(SetItemRef, pending.link, pending.text, "LeftButton", DEFAULT_CHAT_FRAME)
    end)
end

local function EnsureImportWatcher()
    if importWatcher then return importWatcher end
    importWatcher = CreateFrame("Frame")
    importWatcher:SetScript("OnEvent", function(_, _, prefix, message, distribution, sender)
        local pending = pendingImport
        if not pending then return end
        if prefix ~= pending.commPrefix or distribution ~= "WHISPER" then return end
        -- Derive the sender exactly as MDT does rather than comparing the raw
        -- string: a self-whisper is always same-realm, so the realm arrives
        -- missing and Ambiguate cannot put back what was never there. This
        -- doubles as the real precondition - it passes only when MDT is about
        -- to file the preset under the key our link already encodes.
        -- Case-sensitive on purpose: MDT's cache lookup is, so a casing
        -- mismatch must miss here (timeout, copy-box) rather than fire a link
        -- MDT cannot resolve.
        local key = ns.MdtSenderKey(sender)
        if key ~= pending.fullName then return end
        -- AceComm tags every chunk of a split message except the last; anything
        -- that isn't a "first" or "next" marker means the payload is complete.
        local control = message:sub(1, 1)
        if control == "\001" or control == "\002" then return end
        FireImportLink(pending)
    end)
    return importWatcher
end

local function OpenMdtCopyBoxFallback(route)
    ns.safecall(OpenMDT)
    ns.safecall(OpenMdtCopyBox, route)
end

local function AbandonImport(token, route)
    if not pendingImport or pendingImport.token ~= token then return end
    StopWatching()
    print("|cff69ccf0Guild Playbook:|r MDT didn't pick the route up - copy the string below instead.")
    OpenMdtCopyBoxFallback(route)
end

-- Click target for the nav's "MDT Route" entry. Attempts the one-click import
-- and falls back to the copy-box whenever any precondition is missing, so the
-- entry always does something useful.
local function StartMdtRoute(route, forceCopyBox)
    local api = _G.MythicDungeonToolsAPI
    local preset = (not forceCopyBox) and DecodeRoute(route.string) or nil
    local ready = preset and api and api.SendCommMessage and api.GetPresetCommPrefix
        and api.GetDungeonName
        and not InCombatLockdown()  -- MDT refuses to import while in combat
        -- One whisper at a time: AceComm spools reassembly per prefix +
        -- distribution + sender, so a second send would corrupt the first.
        and not pendingImport

    if ready then
        local name, realm = PlayerCacheName()
        -- Also loads MDT's on-demand UI, so the preset is cached live rather
        -- than parked in MDT's pending-comm buffer.
        local dungeon = name and api:GetDungeonName(preset.value.currentDungeonIdx, true)
        -- MDT builds the cache key as "<dungeon>: <preset name>" and reads it
        -- back out of the first [...] in the link text, so a name carrying the
        -- link's own punctuation would not round-trip.
        if dungeon and not (dungeon .. preset.text):find("[%[%]|]") then
            local sender = name .. "+" .. realm
            local token = {}
            pendingImport = {
                token = token,
                commPrefix = api:GetPresetCommPrefix(),
                fullName = name .. "-" .. realm,
                link = "garrmission:mdt-" .. sender,
                text = "|Hgarrmission:mdt-" .. sender .. "|h["
                    .. dungeon .. ": " .. preset.text .. "]|h",
            }
            EnsureImportWatcher():RegisterEvent("CHAT_MSG_ADDON")
            -- NORMAL rather than MDT's own BULK: this is a button the player is
            -- waiting on, and ~1 KB fits inside ChatThrottleLib's burst anyway.
            api:SendCommMessage(pendingImport.commPrefix, route.string, "WHISPER",
                name .. "-" .. realm, "NORMAL")
            C_Timer.After(IMPORT_TIMEOUT, function() AbandonImport(token, route) end)
            return
        end
    end

    OpenMdtCopyBoxFallback(route)
end

-- Navigation (Overview + bosses) ----------------------------------

local navButtons = {}
-- MDT Route lives below the nav rows as its own pooled set of chrome buttons
-- (see CreateChromeButton) rather than being one more `navButtons` entry —
-- it never participates in `selected`, and its styling can't be bolted onto
-- a plain nav-row button after the fact.
local mdtRouteButtons = {}
-- `expanded` is the one accordion parent whose children are listed — a trash
-- segment or a boss/miniboss with adds. It lives in `selected` so the
-- fresh-table resets below clear it implicitly.
local selected = { kind = "overview", boss = nil, segment = nil, npc = nil, expanded = nil }
local viewedDungeon = nil   -- dungeon shown in the panel (may differ from ns.currentDungeon while browsing)

-- The Guild tab has a nav of its own and so needs its own selection, held
-- apart from the dungeon one rather than folded into it: switching tabs must
-- leave the other tab's page exactly where the player left it. Its rows go
-- through the same `navButtons` pool, so the shape matches - `kind` plus the
-- fields the highlight compares - with `section` standing in for boss/segment.
local guildSelected = { kind = "guild", section = ns.GUILD_PAGES and ns.GUILD_PAGES[1]
                                                  and ns.GUILD_PAGES[1].id or nil,
                        expanded = nil }

-- Whichever selection the visible nav is currently describing. Everything that
-- reads the nav (highlighting, scroll-into-view) goes through this rather than
-- naming one of the two tables, so neither tab has to know about the other.
local function ActiveSelection()
    return activeTab == "guild" and guildSelected or selected
end

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
-- TOPLEFT is set by ApplyTabLayout, which knows whether the tab strip is
-- taking a header row.
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
    local selected = ActiveSelection()
    for _, btn in ipairs(navButtons) do
        local isSelected = (btn.kind == selected.kind) and (btn.boss == selected.boss)
                           and (btn.segment == selected.segment) and (btn.npc == selected.npc)
                           and (btn.section == selected.section)
        btn:GetFontString():SetTextColor(isSelected and 1 or 0.82, isSelected and 0.82 or 0.82, isSelected and 0 or 0.82)
    end
end

-- Synthetic nav rows for the ns.Monday boards: not one of Data/Guild.lua's
-- pages (nothing there to add - each board is generated from ns.Monday, not
-- authored prose), so they're appended here rather than folded into
-- ns.GUILD_PAGES. Each still needs a `page` table of its own: the click
-- handler below reads `entry.page.children` for every "guild" row, and
-- neither of these has any. Order matches the nav: Mythic Monday first,
-- Open groups second, both after every real handbook page (Discord is last
-- in ns.GUILD_PAGES, so the boards sit below it). `title` is a static
-- fallback for the nav label itself (used before ns.Monday has loaded); the
-- page header inside SetMondayBody always asks ns.Monday.EventTitle(ev)
-- instead, so the two can't drift.
local MONDAY_BOARD_PAGES = {
    { id = "monday", title = "Mythic Monday" },
    { id = "open",   title = "Open groups" },
}
local MONDAY_BOARD_IDS = {}
for _, p in ipairs(MONDAY_BOARD_PAGES) do
    MONDAY_BOARD_IDS[p.id] = true
end

-- True for a synthetic ns.Monday board page id, as opposed to a real
-- Data/Guild.lua handbook page. Used everywhere a "guild" section id has to
-- be routed to SetMondayBody instead of GuildPage()/SetGuildBody.
local function IsBoardPage(id)
    return MONDAY_BOARD_IDS[id] == true
end

-- Guild handbook rows: one per top-level page, with a page's children folded
-- in behind the same accordion the trash segments use. A parent row is still
-- a page in its own right, so it selects as well as expands.
local function GuildNavEntries()
    local entries = {}
    for _, page in ipairs(ns.GUILD_PAGES or {}) do
        local kids = page.children or {}
        local open = (#kids > 0) and (guildSelected.expanded == page.id)
        local label = page.title
        if #kids > 0 then
            label = label .. "  " .. (open and GLYPH_OPEN or GLYPH_SHUT)
        end
        entries[#entries + 1] = { kind = "guild", section = page.id, page = page,
                                  label = label }
        if open then
            for _, child in ipairs(kids) do
                entries[#entries + 1] = { kind = "guild", section = child.id,
                                          page = child, parent = page,
                                          label = child.title, inset = INSET_NPC }
            end
        end
    end
    for _, p in ipairs(MONDAY_BOARD_PAGES) do
        local label = (ns.Monday and ns.Monday.EventTitle and ns.Monday.EventTitle(p.id)) or p.title
        entries[#entries + 1] = { kind = "guild", section = p.id, page = p, label = label }
    end
    return entries
end

-- `d` is the dungeon whose nav to build, and is ignored on the Guild tab: the
-- two navs share the button pool and the scroll frame but nothing else, so the
-- entry list forks here and the rest of the function stays common.
local function BuildNav(d)
    for _, btn in ipairs(navButtons) do btn:Hide() end
    for _, btn in ipairs(mdtRouteButtons) do btn:Hide() end
    local entries = {}
    if activeTab == "guild" then
        entries = GuildNavEntries()
        d = nil
    elseif not d then
        for _, dungeon in ipairs(SortedDungeons()) do
            entries[#entries + 1] = { kind = "dungeon", dungeon = dungeon, label = dungeon.dungeon }
        end
    else
        entries[#entries + 1] = { kind = "back", label = C.DIM .. "« Dungeons" .. C.R }
        if d.quicksheet then
            entries[#entries + 1] = { kind = "quicksheet", label = "Quick sheet (all roles)" }
        end
        entries[#entries + 1] = { kind = "overview", label = "Overview & Trash" }
        -- A boss (or miniboss) may share its pull with named adds. Same
        -- accordion shape as a trash segment: a leaf row when there's
        -- nothing to expand into, an expander + child NPC rows otherwise.
        local function addBoss(boss, label)
            local adds = boss.adds or {}
            local open = (#adds > 0) and (selected.expanded == boss)
            if #adds > 0 then
                label = label .. "  " .. (open and GLYPH_OPEN or GLYPH_SHUT)
            end
            entries[#entries + 1] = { kind = "boss", boss = boss, label = label }
            if open then
                for _, add in ipairs(adds) do
                    if type(add.name) == "string" and add.name ~= "" then
                        entries[#entries + 1] = { kind = "npc", boss = boss, npc = add,
                                                  label = add.name, inset = INSET_NPC }
                    end
                end
            end
        end
        for _, mb in ipairs(d.minibosses or {}) do
            addBoss(mb, "* " .. mb.name)
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
            addBoss(boss, i .. ". " .. boss.name)
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
        btn.section = entry.section
        btn:SetScript("OnClick", function()
            if entry.kind == "guild" then
                -- Same accordion as a trash segment, on the other selection
                -- table: a page with children toggles its own expansion and
                -- stays selected, a child keeps its parent open, and a
                -- childless top-level page collapses whatever was open.
                local expanded
                if #(entry.page.children or {}) > 0 then
                    -- Clicking the open parent again shuts it without dropping
                    -- the selection, so its own page keeps showing.
                    if guildSelected.expanded ~= entry.section then
                        expanded = entry.section
                    end
                elseif entry.parent then
                    expanded = entry.parent.id
                end
                guildSelected = { kind = "guild", section = entry.section,
                                  expanded = expanded }
                ns.safecall(ns.UI_Refresh)
            elseif entry.kind == "dungeon" then
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
            elseif entry.kind == "boss" and #(entry.boss.adds or {}) > 0 then
                -- Same accordion as trash: clicking the open boss again shuts
                -- it without dropping the selection. The boss is selected
                -- either way, so its own text and model keep showing.
                selected = {
                    kind = "boss", boss = entry.boss,
                    expanded = (selected.expanded ~= entry.boss) and entry.boss or nil,
                }
                ns.safecall(ns.UI_Refresh)
            else
                -- Only an NPC row keeps its parent (segment or boss) open;
                -- every other row collapses the accordion.
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

    -- MDT Route sits below the regular entries as chrome buttons instead of
    -- another `navButtons` row (see mdtRouteButtons above). No button at all
    -- for a dungeon with no route data.
    if d then
        local routes = d.mdtRoutes or {}
        for i, route in ipairs(routes) do
            local btn = mdtRouteButtons[i]
            if not btn then
                btn = CreateChromeButton(nav, NAV_W - 2, ROUTE_BTN_H)
                mdtRouteButtons[i] = btn
            end
            local label = (#routes > 1) and ("MDT Route: " .. route.name) or "MDT Route"
            btn:SetText(label)
            -- The common case (one route, short label) stays a single line at
            -- the fixed role-tab height; a long multi-route label wraps and
            -- grows the button instead of clipping.
            local fs = btn:GetFontString()
            fs:SetWordWrap(true)
            -- Explicit width, not anchors: that is what makes GetStringHeight
            -- report the wrapped height right away (same rule as the nav rows).
            fs:SetWidth(NAV_W - 2)
            local btnH = math.max(ROUTE_BTN_H, fs:GetStringHeight() + 8)
            btn:SetHeight(btnH)
            btn:ClearAllPoints()
            btn:SetPoint("LEFT")
            btn:SetPoint("RIGHT")
            if prev then
                total = total + ROUTE_BTN_GAP
                btn:SetPoint("TOP", prev, "BOTTOM", 0, -ROUTE_BTN_GAP)
            else
                btn:SetPoint("TOP", nav, "TOP", 0, 0)
            end
            total = total + btnH
            btn:SetScript("OnClick", function()
                -- Action, not a page: imports into MDT, or opens the copy-box
                -- when that isn't possible. Shift-click always takes the
                -- copy-box, as an escape hatch. `selected` is untouched, so
                -- the content pane and nav highlight don't change.
                ns.safecall(StartMdtRoute, route, IsShiftKeyDown())
            end)
            btn:Show()
            prev = btn
        end
    end

    nav:SetHeight(math.max(1, total))

    -- Keep the reading position across a rebuild: clamp what we had, then pull
    -- the selected row back into view only if the rebuild pushed it out. That
    -- keeps an expand from scrolling to top while still revealing the row the
    -- user just clicked.
    local selected = ActiveSelection()
    local view = navScroll:GetHeight() or 0
    local at = SetNavScroll(navScroll:GetVerticalScroll() or 0)
    if view > 0 then
        for _, btn in ipairs(navButtons) do
            if btn:IsShown() and btn.kind == selected.kind and btn.boss == selected.boss
               and btn.segment == selected.segment and btn.npc == selected.npc
               and btn.section == selected.section then
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

-- Spell links rendered by RenderAbilityLinks, and the Monday board's own
-- player-name links, both live in the body FontStrings below, which are
-- regions of this frame - hyperlink hit-testing and the OnHyperlink*
-- scripts belong on the frame that owns the regions, not on the FontStrings
-- themselves (FontStrings don't take mouse scripts). This holds for every
-- FontString in the pool: they are all created by content, so one set of
-- scripts on content serves all of them.
content:EnableMouse(true)
content:SetHyperlinksEnabled(true)
-- OnHyperlinkEnter/Leave/Click are set up later, in the Monday board section
-- (right before SetMondayBody), once that section's link/invite helpers
-- (ShortName, MondayInvite, ...) are in scope for those closures to close
-- over - a closure only captures a `local` that already exists in the
-- source above it, so defining them here would silently resolve those names
-- as globals instead.

-- Long call text at this size needs a shorter measure than the panel is wide,
-- and more leading than the 3px default, or every section reads as one block.
local TEXT_INSET, TEXT_MAX_W = 4, 520

-- WoW renders at most 9 hyperlinks per FontString; past that the link and its
-- color are both silently dropped and the raw "[Brackets]" show through. A
-- full playbook page carries well over 9 ability links, so the body cannot be
-- one FontString. Each authored line is given its own FontString instead - a
-- single line practically never holds more than three links - and they are
-- stacked to look exactly like the single block they replace.
local TEXT_W = math.min(PANEL_W - NAV_W - 60 - TEXT_INSET, TEXT_MAX_W)
-- Same 6px as SetSpacing: the gap between two FontStrings has to match the
-- leading inside one, or wrapped lines and authored lines space differently.
local LINE_GAP = 6

local bodyLines = {}

local function AcquireBodyLine(i)
    local fs = bodyLines[i]
    if not fs then
        fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        -- Explicit width, no anchor-derived sizing: that is what makes
        -- GetStringHeight report the wrapped height immediately after SetText,
        -- which the stacking below depends on.
        fs:SetWidth(TEXT_W)
        fs:SetJustifyH("LEFT")
        fs:SetSpacing(LINE_GAP)
        fs:SetWordWrap(true)
        bodyLines[i] = fs
    end
    return fs
end

-- Splits the built page on newlines, lays one FontString out per line, hides
-- the leftovers from a longer previous page, and returns the stacked height.
-- Every Build*Text function emits self-contained lines (each opens its own
-- color and closes with |r), so splitting them apart cannot strand a color.
-- `top` is where the first line sits, for a page that stacks something above
-- its prose (the guild landing page's hero banner). It is folded into the
-- returned height too, so callers still get one number for the whole page.
local function SetBodyText(s, top)
    s = tostring(s or "")
    local y, n, from = top or 0, 0, 1
    -- find/plain rather than gmatch: a gmatch pattern loose enough to keep
    -- empty lines also fires one extra empty match past the end of the string,
    -- which would add a phantom spacer line to every page.
    while true do
        local at = s:find("\n", from, true)
        local line = at and s:sub(from, at - 1) or s:sub(from)
        n = n + 1
        local fs = AcquireBodyLine(n)
        -- Blank lines are the section spacers; an empty string measures as
        -- nothing, so give it a space to keep the gap.
        fs:SetText(line ~= "" and line or " ")
        fs:ClearAllPoints()
        -- Anchored to content rather than chained to the previous line: the
        -- offsets are then plain arithmetic we can also sum for the height.
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", TEXT_INSET, -y)
        fs:Show()
        y = y + fs:GetStringHeight() + LINE_GAP
        if not at then break end
        from = at + 1
    end
    for i = n + 1, #bodyLines do
        bodyLines[i]:Hide()
    end
    -- The last line contributes no trailing gap.
    return y - LINE_GAP
end

local sectionTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sectionTitle:SetPoint("BOTTOMLEFT", scroll, "TOPLEFT", TEXT_INSET, 6)
sectionTitle:SetText("")

-- Guild page --------------------------------------------------------
-- Members-only content. The prose runs through the same body FontStrings as a
-- playbook page, but the invite itself cannot: WoW gives an addon no way to
-- write the clipboard, so a URL has to be handed over as selectable text in an
-- EditBox for the player to Ctrl+C - the same constraint that shapes the MDT
-- copy-box above. Hence one live widget stacked under the text.
--
-- It stays an EditBox because only an EditBox can hold a selection for Ctrl+C,
-- but it carries none of InputBoxTemplate's chrome: a sunken input well next
-- to a Copy button invites typing, and there is nothing here to type. Stripped
-- to bare text in link-blue, it reads as the URL it is.

local discordBox = CreateFrame("EditBox", nil, content)
discordBox:SetHeight(20)
discordBox:SetAutoFocus(false)
discordBox:SetFontObject("ChatFontNormal")
-- The same blue the ability links use, so "blue text" means the same thing on
-- every page of the addon: something to act on rather than only to read.
discordBox:SetTextColor(0.44, 0.84, 1)
discordBox:SetText(ns.DISCORD_URL)
-- Read-only in effect. The box exists to be copied out of, and a player who
-- typed over the invite would have no way to get it back. `user` is what
-- separates their keystrokes from our own SetText, which would otherwise
-- recurse through this same handler.
discordBox:SetScript("OnTextChanged", function(self, user)
    if user then
        self:SetText(ns.DISCORD_URL)
        self:HighlightText()
    end
end)
discordBox:SetScript("OnEditFocusGained", discordBox.HighlightText)
discordBox:SetScript("OnEscapePressed", discordBox.ClearFocus)
discordBox:Hide()

-- A real one-click copy isn't available to us: the client's CopyToClipboard is
-- marked #protected and so can only be called from Blizzard's own secure code -
-- an addon calling it gets blocked, which is why no addon ships a true copy
-- button. So the button does the half a player can't do in one action - focus
-- the box and select the whole invite - and says "Select", because that is what
-- it does. Ctrl+C stays the player's keystroke, and the hint under the box
-- tracks which half of the job is still outstanding.
local HINT_SELECTED = "Now press Ctrl+C"
local HINT_COPIED = "Copied - paste it into your browser"
local SELECT_BTN_W, SELECT_BTN_GAP = 62, 10
local selectButton = CreateChromeButton(content, SELECT_BTN_W, 22)
selectButton:SetText("Select")
selectButton:Hide()

-- Measures the invite so the box can be exactly as wide as its text: a fixed
-- width either pushed the button off the panel edge (which is what a full-width
-- box did) or left a stretch of dead selectable space after the URL. Hidden and
-- never drawn; it exists only to be measured.
local urlMeasure = content:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
urlMeasure:Hide()

-- Width of the invite text, clamped so the box and the button together always
-- fit the text column no matter how long a future invite runs.
local function DiscordBoxWidth()
    urlMeasure:SetText(discordBox:GetText() or "")
    local w = math.ceil(urlMeasure:GetStringWidth()) + 4
    local room = TEXT_W - SELECT_BTN_GAP - SELECT_BTN_W
    if w > room then w = room end
    return w
end

local copyHint = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
-- Text set once, visibility toggled: the page reserves this line's height
-- whether or not it is showing, and an empty FontString measures as nothing.
-- Both hints are one line at this width, so swapping them can't reflow the page.
copyHint:SetText(HINT_COPIED)
copyHint:Hide()

-- True once Ctrl+C has been seen, which is what keeps the "Copied" line up
-- after the box has released focus - the "press Ctrl+C" line, by contrast,
-- describes a live selection and has to go when that selection does.
local copied = false

local function ShowHint(text, r, g, b)
    copyHint:SetText(text)
    copyHint:SetTextColor(r, g, b)
    copyHint:Show()
end

selectButton:SetScript("OnClick", function()
    copied = false
    discordBox:SetFocus()
    discordBox:HighlightText()
    ShowHint(HINT_SELECTED, 1, 0.82, 0)
end)

-- Focusing an EditBox hands it the whole keyboard: until it lets go, WASD and
-- every keybind type into the box instead of moving the player, and
-- OnTextChanged silently reverts each keystroke, so it reads as the keys having
-- died. Releasing focus the moment the copy is done is what keeps a copy from
-- costing the player their movement keys. Same shape MDT uses for its own
-- external-link boxes (Modules/ExternalLinks.lua).
--
-- Control is tracked from OnKeyDown rather than tested on the way up: releasing
-- Ctrl before C is just as natural as the other order, and by then
-- IsControlKeyDown() is already false.
local ctrlHeld = false

discordBox:SetScript("OnKeyDown", function(_, key)
    if IsControlKeyDown() or key == "LCTRL" or key == "RCTRL" then
        ctrlHeld = true
    end
end)

discordBox:SetScript("OnKeyUp", function(self, key)
    if ctrlHeld and key == "C" then
        -- The client has already handled the copy by the time the key comes
        -- back up, so this is a statement of fact, not a promise.
        copied = true
        ShowHint(HINT_COPIED, 0.62, 0.83, 0.38)
        self:ClearFocus()
    elseif key == "LCTRL" or key == "RCTRL" then
        ctrlHeld = false
    end
end)

-- The "press Ctrl+C" hint describes the current selection, so it stops being
-- true the moment the selection goes away. "Copied" outlives it.
discordBox:HookScript("OnEditFocusLost", function()
    ctrlHeld = false
    if not copied then copyHint:Hide() end
end)

-- Takes the invite row off the page. Also drops focus: navigating away while
-- the box still holds the keyboard would strand the player with dead movement
-- keys and no visible box to explain why. `copied` resets with it, so coming
-- back to the page doesn't open on a stale "Copied".
local function HideInvite()
    if discordBox:HasFocus() then discordBox:ClearFocus() end
    copied, ctrlHeld = false, false
    discordBox:Hide()
    selectButton:Hide()
    copyHint:Hide()
end

-- The page Data/Guild.lua's id refers to, falling back to the first page so a
-- stale or missing id can never leave the panel blank.
local function GuildPage()
    local pages = ns.GUILD_PAGES or {}
    return (ns.GUILD_PAGE_BY_ID or {})[guildSelected.section] or pages[1]
end

-- Renders one handbook page's blocks into the same newline-separated string a
-- playbook page produces, so it goes through SetBodyText unchanged. Blocks are
-- separated by a blank line; a heading brings its own air (see `heading`) and
-- so is not given one on top of that.
local function BuildGuildPageText(page)
    local out = {}
    for _, block in ipairs(page and page.body or {}) do
        if type(block) == "table" and block.head then
            heading(out, block.head)
        else
            if #out > 0 then out[#out + 1] = " " end
            if type(block) == "string" then
                out[#out + 1] = C.BODY .. block .. C.R
            elseif block.bullets then
                bullets(block.bullets, out, C.BODY)
            elseif block.note then
                out[#out + 1] = C.DIM .. block.note .. C.R
            end
        end
    end
    return table.concat(out, "\n")
end

-- Hero banner ------------------------------------------------------
-- The landing page opens on the guild's name at a size the body text can't
-- reach: a FontString can't change size part-way through itself, so the banner
-- has to be its own widgets rather than another block in the body string. It
-- stacks above the prose and hands its height to SetBodyText as the offset to
-- start the first line at.

local hero = CreateFrame("Frame", nil, content)
hero:SetPoint("TOPLEFT", content, "TOPLEFT", TEXT_INSET, 0)
hero:SetWidth(TEXT_W)
hero:Hide()

local heroName = hero:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
heroName:SetPoint("TOPLEFT")
heroName:SetWidth(TEXT_W)
heroName:SetJustifyH("LEFT")
heroName:SetWordWrap(true)
-- The same gold the section headings use, so the banner reads as the loudest
-- instance of an existing voice rather than a new colour.
heroName:SetTextColor(1, 0.82, 0)

local heroTagline = hero:CreateFontString(nil, "OVERLAY", "GameFontNormal")
heroTagline:SetPoint("TOPLEFT", heroName, "BOTTOMLEFT", 0, -6)
heroTagline:SetWidth(TEXT_W)
heroTagline:SetJustifyH("LEFT")
heroTagline:SetWordWrap(true)
heroTagline:SetTextColor(0.91, 0.91, 0.91)

-- Closes the banner off so the prose beneath it reads as a new block. Anchored
-- rather than sized here; HERO_RULE_GAP below is what actually places it.
local heroRule = hero:CreateTexture(nil, "ARTWORK")
heroRule:SetColorTexture(1, 0.82, 0, 0.35)
heroRule:SetHeight(1)

local HERO_RULE_GAP, HERO_BOTTOM_GAP = 12, 16

-- Fills the banner in for a page and returns the height it occupies, or 0 for
-- a page that has no hero (every page but the landing one).
local function SetHero(page)
    local spec = page and page.hero
    if not spec then
        hero:Hide()
        return 0
    end
    heroName:SetText(ns.GUILD_NAME)
    heroTagline:SetText(spec.tagline or "")
    local h = heroName:GetStringHeight() + 6 + heroTagline:GetStringHeight()
    heroRule:ClearAllPoints()
    heroRule:SetPoint("TOPLEFT", hero, "TOPLEFT", 0, -(h + HERO_RULE_GAP))
    heroRule:SetWidth(TEXT_W)
    h = h + HERO_RULE_GAP + 1
    hero:SetHeight(h)
    hero:Show()
    return h + HERO_BOTTOM_GAP
end

-- The gap between the prose and the invite box. Wider than the body's own
-- leading, so the box reads as a separate thing rather than another line.
local GUILD_BOX_GAP = 12

-- The one handbook page that carries a live widget under its prose. Keyed by
-- id rather than by position so reordering Data/Guild.lua can't strand the box.
local DISCORD_PAGE_ID = "discord"

-- Lays a guild page out and returns its total height, matching what the
-- playbook branches of UI_Refresh get back from SetBodyText.
local function SetGuildBody(page)
    local y = SetBodyText(BuildGuildPageText(page), SetHero(page))
    if not page or page.id ~= DISCORD_PAGE_ID then
        HideInvite()
        return y
    end
    discordBox:ClearAllPoints()
    -- Flush with the prose: without a template there is no border texture to
    -- sit outside the text area, so no inset is needed to line the two up.
    discordBox:SetWidth(DiscordBoxWidth())
    discordBox:SetPoint("TOPLEFT", content, "TOPLEFT", TEXT_INSET, -(y + GUILD_BOX_GAP))
    discordBox:Show()
    selectButton:ClearAllPoints()
    selectButton:SetPoint("LEFT", discordBox, "RIGHT", SELECT_BTN_GAP, 0)
    selectButton:Show()
    -- Under the box rather than beside the button: the hint appears after a
    -- click, and growing the row sideways would shift the button out from
    -- under the cursor that just pressed it.
    copyHint:ClearAllPoints()
    copyHint:SetPoint("TOPLEFT", discordBox, "BOTTOMLEFT", 0, -6)
    -- Reserved whether or not the hint is showing, so the page height doesn't
    -- change under the player at the moment they click.
    return y + GUILD_BOX_GAP + discordBox:GetHeight() + 6 + copyHint:GetStringHeight()
end

-- Mythic Monday page -------------------------------------------------
-- Renders GuildPlaybook/Monday.lua's sign-up board. Unlike a prose page, most
-- rows here carry a live button pinned to that exact row (sign-up actions,
-- bracket toggles, per-group Join/Leave/Disband), so this doesn't go through
-- BuildGuildPageText/SetBodyText - rows and their buttons are collected
-- together first, then stacked in one pass so a button's Y always lands on
-- the line it belongs to. Text still goes through the same bodyLines pool
-- (one FontString per line, same hyperlink-cap rule as every other page).

local ROLE_FULL = { T = "Tank", H = "Healer", D = "DPS" }
local ROLE_COLOR = { T = C.TANK, H = C.HEALER, D = C.DPS }

-- InviteAll()'s per-skip reason code, turned into the word Invite()'s own
-- failure messages already use ("in party", not "inparty").
local MONDAY_SKIP_REASON = { inparty = "in party", offline = "offline", self = "self" }

-- Which bracket "Join a group" targets, kept per board (a bracket picked on
-- the Monday page shouldn't light up on Open groups and vice versa). Only
-- affects the join action, not what's already signed up. Not persisted -
-- both start at "any" each session, matching the contract's stated default.
local mondaySelectedBracket = { monday = "any", open = "any" }

local MONDAY_BTN_H, MONDAY_BTN_GAP = 22, 6

-- One flat pool for every button this page uses. They have nothing
-- structurally different from each other, so one pool beats one per role.
-- `mondayButtonCount` resets to 0 at the top of each redraw; whatever a
-- previous draw acquired past the new count gets hidden below.
local mondayButtons = {}
local mondayButtonCount = 0

local function NextMondayButton(width)
    mondayButtonCount = mondayButtonCount + 1
    local btn = mondayButtons[mondayButtonCount]
    if not btn then
        btn = CreateChromeButton(content, width, MONDAY_BTN_H)
        mondayButtons[mondayButtonCount] = btn
    end
    btn:SetSize(width, MONDAY_BTN_H)
    btn:Show()
    return btn
end

local function HideUnusedMondayButtons()
    for i = mondayButtonCount + 1, #mondayButtons do
        mondayButtons[i]:Hide()
    end
end

-- The board's own player key, matching the convention Monday.lua's protocol
-- uses for every entry/member/leader name: "Name-Realm". Guarded the same
-- way Monday.lua's own MyName is: GetNormalizedRealmName() can come back nil
-- (seen on a realm mid-connect), and a "Name-nil" key would never match a
-- member/leader name built the normal way.
local function MondayPlayerKey()
    local name = UnitName("player")
    local realm = GetNormalizedRealmName()
    if realm and realm ~= "" then
        return name .. "-" .. realm
    end
    return name
end

-- Members, leaders and pool entries arrive as "Name-Realm"; the board only
-- has room to show the name half.
local function ShortName(full)
    return (full and full:match("^[^%-]+")) or full or "?"
end

-- Renders a roster/pool name as a clickable custom link carrying the full
-- "Name-Realm" key: `|Hgpmm:Name-Realm|h|cff<LINK>Name|r|h`. Handled by the
-- OnHyperlinkClick script set on `content` below (left-click invite,
-- right-click menu) via the "gpmm:" prefix, same mechanism RenderAbilityLinks
-- already uses for spell links on this same frame. LINK is the same
-- link-blue every other clickable thing in this addon uses, so "blue text"
-- keeps meaning the same thing everywhere in the panel.
local function MondayNameLink(fullName)
    return "|Hgpmm:" .. fullName .. "|h" .. LINK .. ShortName(fullName) .. "|r|h"
end

local function FormatMondayAge(seconds)
    if not seconds or seconds < 0 then seconds = 0 end
    local mins = math.floor(seconds / 60)
    if mins < 60 then return mins .. "m" end
    return math.floor(mins / 60) .. "h"
end

-- Plain (uncoloured) "+12 Kings' Rest" - callers wrap it in whatever colour
-- span they're already inside, since where this lands (mid-status-line vs.
-- after a name in guild-lead colour) differs by row.
local function FormatMondayKey(level, name)
    if not level or not name then return "none" end
    return "+" .. level .. " " .. name
end

local MONDAY_MONTH_ABBR = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

-- TargetDate() is always a Monday by construction, so the weekday half of
-- the label never has to be computed - only day and month need parsing out
-- of the "YYYY-MM-DD" string.
local function FormatMondayDate(dateStr)
    local y, m, d = (dateStr or ""):match("^(%d+)-(%d+)-(%d+)$")
    if not (y and m and d) then return dateStr or "" end
    return "Mon " .. tonumber(d) .. " " .. (MONDAY_MONTH_ABBR[tonumber(m)] or m)
end

-- Brackets() carries the range on the same table as the label but not
-- folded into it ("mid" -> label "Mid", min=6, max=10), so the "Mid 6-10"
-- display string is built here rather than changing that table's shape.
-- "Any" (or any bracket with no range, or none found at all) falls back to
-- its bare label.
local function BracketDisplay(b)
    if not b then return "Any" end
    if b.min and b.max then
        return (b.label or b.id) .. " " .. b.min .. "-" .. b.max
    end
    return b.label or b.id or "Any"
end

local function FindMondayBracket(id)
    for _, b in ipairs((ns.Monday and ns.Monday.Brackets()) or {}) do
        if b.id == id then return b end
    end
    return nil
end

-- Shared by the per-bracket pool rows and the "Unspecified" catch-all below,
-- so a pool entry looks the same regardless of which bucket it landed in.
-- `showOffline` is false on the open board: those entries are pruned by the
-- module rather than flagged, so `e.online` there carries nothing worth
-- printing (and would misleadingly imply the flag is meaningful there).
local function PoolEntryLine(e, showOffline)
    local roleColor = ROLE_COLOR[e.role] or C.BODY
    local keyStr = (e.level and e.keyName)
                   and (C.BODY .. FormatMondayKey(e.level, e.keyName) .. C.R)
                   or (C.DIM .. "no key" .. C.R)
    local entryLine = MondayNameLink(e.name) .. "  "
                       .. roleColor .. (ROLE_FULL[e.role] or "?") .. C.R .. "  " .. keyStr
    if showOffline and not e.online then
        entryLine = entryLine .. C.DIM .. " (offline)" .. C.R
    end
    return entryLine
end

-- Shared by the left-click invite and the right-click menu's "Invite" entry,
-- so a single name link always fails the same way regardless of which path
-- triggered it. Silent on "self" - there's nothing useful to tell the player
-- about inviting themselves.
local function MondayInvite(name)
    if not (ns.Monday and ns.Monday.Invite) then return end
    local ok, reason = ns.Monday.Invite(name)
    if ok == false then
        if reason == "offline" then
            print("|cffff4040Mythic Monday:|r " .. ShortName(name) .. " appears offline")
        elseif reason == "inparty" then
            print("|cffff4040Mythic Monday:|r " .. ShortName(name) .. " is already in your party")
        end
    end
end

-- Right-click menu for a player-name link. MenuUtil.CreateContextMenu is the
-- 11.0+ Menu API; on a client where it isn't available, right-click just
-- does what the menu's other entry would have done.
local function ShowMondayNameMenu(owner, name)
    if MenuUtil and MenuUtil.CreateContextMenu then
        MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
            rootDescription:CreateButton("Invite", function() MondayInvite(name) end)
            rootDescription:CreateButton("Whisper", function() ChatFrame_OpenChat("/w " .. name .. " ") end)
        end)
    else
        ChatFrame_OpenChat("/w " .. name .. " ")
    end
end

-- content's hyperlink scripts, covering both RenderAbilityLinks' spell links
-- (the original behaviour, preserved below) and this board's own "gpmm:"
-- player-name links. Defined here rather than back where `content` was
-- created: these closures need ShortName/MondayInvite/ShowMondayNameMenu
-- already declared above them to close over the right locals.
content:SetScript("OnHyperlinkEnter", function(self, link)
    ns.safecall(function()
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        local name = link:match("^gpmm:(.+)$")
        if name then
            GameTooltip:SetText(ShortName(name))
            GameTooltip:AddLine("Click: invite  ·  Right-click: menu", 0.6, 0.6, 0.6)
        else
            GameTooltip:SetHyperlink(link)
        end
        GameTooltip:Show()
    end)
end)
content:SetScript("OnHyperlinkLeave", function()
    ns.safecall(GameTooltip.Hide, GameTooltip)
end)
content:SetScript("OnHyperlinkClick", function(self, link, text, button)
    ns.safecall(function()
        local name = link:match("^gpmm:(.+)$")
        if not name then return end   -- no other link type here needs a click handler
        if button == "RightButton" then
            ShowMondayNameMenu(self, name)
        else
            MondayInvite(name)
        end
    end)
end)

-- Lays a ns.Monday board out and returns its total height, matching what
-- SetGuildBody returns for a handbook page. `ev` is "monday" or "open" -
-- same renderer for both, per the v1.4.0 addendum.
local function SetMondayBody(ev)
    HideInvite()
    SetHero(nil)
    mondayButtonCount = 0

    if not ns.Monday then
        local staticTitle = (ev == "open") and "Open groups" or "Mythic Monday"
        local y = SetBodyText(C.DIM .. staticTitle .. " module not loaded." .. C.R)
        HideUnusedMondayButtons()
        return y
    end

    local rows = {}   -- { text = "...", buttons = { {label,width,onClick,...}, ... } }
    local function line(text, buttons)
        rows[#rows + 1] = { text = text, buttons = buttons }
    end
    -- Two blank lines above, none below - same spacing rule as `heading()`
    -- uses for a playbook page, kept separate here because a section header
    -- on this page never carries buttons of its own.
    local function headingRow(text)
        if #rows > 0 then
            line(" ")
            line(" ")
        end
        line(C.HEAD .. text .. C.R)
    end

    local me = ns.Monday.Me(ev)
    local myKey = ns.Monday.MyKey()
    local myRole = ns.Monday.MyRole()
    local groups = ns.Monday.Groups(ev) or {}

    -- Header -----------------------------------------------------------
    -- "monday" carries a target date in its header; "open" is a standing
    -- board with no single date to show. EventTitle(ev) gives the board
    -- name either way. Refresh isn't routed through ns.safecall: Refresh(ev)
    -- returns false, "throttled" on its cooldown, and safecall discards a
    -- wrapped call's return values, which would silently swallow that.
    -- pcall here instead, so a throttled click still says something rather
    -- than doing nothing.
    local title = ns.Monday.EventTitle(ev) or (ev == "open" and "Open groups" or "Mythic Monday")
    local headerTail = (ev == "open") and "right now" or FormatMondayDate(ns.Monday.TargetDate())
    line(C.HEAD .. title .. " — " .. headerTail .. C.R, {
        { label = "Refresh", width = 70, align = "right",
          onClick = function()
              local ok, refreshed = pcall(ns.Monday.Refresh, ev)
              if not ok then
                  print("|cffff4040Guild Playbook error:|r " .. tostring(refreshed))
              elseif refreshed == false then
                  print("|cffff4040Guild Playbook:|r board refresh is rate-limited, try again in a minute.")
              end
          end },
    })

    -- Status line --------------------------------------------------------
    local status
    if not me then
        status = "You: not signed up"
    elseif me.intent == "lead" then
        local mine
        for _, g in ipairs(groups) do
            if g.isMine then mine = g break end
        end
        local filled = "?"
        if mine then
            local missing = mine.missing or {}
            filled = 5 - (missing.T and 1 or 0) - (missing.H and 1 or 0) - (missing.D or 0)
        end
        status = "You: leading " .. FormatMondayKey(myKey and myKey.level, myKey and myKey.name)
                  .. " (" .. filled .. "/5)"
    elseif me.leader then
        status = "You: in " .. ShortName(me.leader) .. "'s group"
    else
        status = "You: in pool — " .. (ROLE_FULL[me.role] or "?") .. ", " .. BracketDisplay(FindMondayBracket(me.bracket))
    end
    line(C.BODY .. status .. C.R)

    -- Post to guild ----------------------------------------------------
    -- ChatLine(ev) itself is the "signed up" gate: it comes back nil (with
    -- a reason - "notsignedup", or "full" once my own group fills up) until
    -- there's something postable, so the button disables off the same nil
    -- rather than re-deriving "postable" a second way. Only "full" gets its
    -- own preview line ("notsignedup" stays silent - there's nothing to
    -- preview before signing up at all).
    local chatLine, chatReason
    if ns.Monday.ChatLine then
        chatLine, chatReason = ns.Monday.ChatLine(ev)
    end
    if chatLine then
        -- Same FontString/AcquireBodyLine path as every other row: fixed
        -- width, word-wrapped, height read back via GetStringHeight() in the
        -- stacking pass below, so a long preview just wraps and pushes the
        -- rest of the page down like any other line would.
        line(C.DIM .. "Post preview: " .. chatLine .. C.R)
    elseif chatReason == "full" then
        line(C.DIM .. "Group is full - nothing to post." .. C.R)
    end
    line(" ", {
        { label = "Post to guild", width = 120, disabled = (chatLine == nil),
          onClick = function() ns.safecall(function()
              if not ns.Monday.PostToGuild then return end
              local ok, reason = ns.Monday.PostToGuild(ev)
              if ok == false then
                  if reason == "full" then
                      print("|cffff4040Mythic Monday:|r Your group is full.")
                      return
                  end
                  local msg = "could not post"
                  if reason == "notsignedup" then msg = "sign up first"
                  elseif reason == "throttled" then msg = "rate-limited, try again in a minute"
                  elseif reason == "inkey" then msg = "can't post from inside a key"
                  elseif reason == "noguild" then msg = "not in a guild"
                  end
                  print("|cffff4040Mythic Monday:|r " .. msg)
              end
          end) end },
    })

    -- Your sign-up ---------------------------------------------------------
    headingRow("Your sign-up")
    local myKeyLabel = myKey and FormatMondayKey(myKey.level, myKey.name) or "none"
    line(C.BODY .. "Role: " .. (ROLE_FULL[myRole] or "?") .. "   Key: " .. myKeyLabel .. C.R)

    local signupButtons = {
        { label = "Lead with my key", width = 130, disabled = (myKey == nil),
          onClick = function() ns.safecall(function()
              local ok, reason = ns.Monday.SignUp(ev, { intent = "lead" })
              if ok == false then
                  print("|cffff4040Mythic Monday:|r " .. (reason or "could not lead"))
              end
          end) end },
        { label = "Join a group", width = 110,
          onClick = function() ns.safecall(function()
              local ok, reason = ns.Monday.SignUp(ev, { intent = "join", bracket = mondaySelectedBracket[ev] })
              if ok == false then
                  print("|cffff4040Mythic Monday:|r " .. (reason or "could not join"))
              end
          end) end },
    }
    if me then
        signupButtons[#signupButtons + 1] = { label = "Withdraw", width = 80,
            onClick = function() ns.safecall(ns.Monday.Withdraw, ev) end }
    end
    line(" ", signupButtons)

    -- Bracket toggles only steer "Join a group" above; they don't submit
    -- anything themselves, so the click just repaints which one is lit.
    local bracketButtons = {}
    for _, b in ipairs(ns.Monday.Brackets() or {}) do
        local id = b.id
        -- Wider than before now that the label carries a range ("Mid 6-10"
        -- instead of "Mid"); 4 * 88 + 3 gaps still clears TEXT_W (376).
        bracketButtons[#bracketButtons + 1] = { label = BracketDisplay(b), width = 88,
            dim = (id ~= mondaySelectedBracket[ev]),
            onClick = function()
                mondaySelectedBracket[ev] = id
                ns.safecall(ns.UI_Refresh)
            end }
    end
    line(" ", bracketButtons)

    -- Groups -----------------------------------------------------------
    headingRow("Groups")
    if #groups == 0 then
        line(C.DIM .. "No groups yet. Lead with your key to start one." .. C.R)
    else
        local myPlayerKey = MondayPlayerKey()
        -- Monday.lua stamps `seen` with GetServerTime(); comparing against
        -- time() (the client's own clock) would drift from that by whatever
        -- the client/server offset is.
        local now = GetServerTime()
        for _, g in ipairs(groups) do
            local leaderLine = C.LEAD .. ShortName(g.leader) .. C.R .. "  "
                                .. C.BODY .. FormatMondayKey(g.level, g.keyName) .. C.R
            -- Open-board groups are pruned (leader unseen > 15 min just drops
            -- the group) rather than flagged, so there's nothing meaningful
            -- to mark "offline" there - only Monday groups get the suffix.
            if ev == "monday" and g.seen and (now - g.seen) > 600 then
                leaderLine = leaderLine .. C.DIM .. " (offline " .. FormatMondayAge(now - g.seen) .. ")" .. C.R
            end

            local isMember = false
            for _, m in ipairs(g.members or {}) do
                if m.name == myPlayerKey then isMember = true end
            end
            -- Right-aligned buttons stack from the panel's right edge inward
            -- in the order pushed, so Disband goes first (keeps its original
            -- rightmost spot) and Invite all lands just to its left.
            local rowButtons = {}
            if g.isMine then
                rowButtons[#rowButtons + 1] = { label = "Disband", width = 70, align = "right",
                    onClick = function() ns.safecall(ns.Monday.Disband, ev) end }
                rowButtons[#rowButtons + 1] = { label = "Invite all", width = 90, align = "right",
                    onClick = function() ns.safecall(function()
                        if not ns.Monday.InviteAll then return end
                        local invited, skipped = ns.Monday.InviteAll(ev)
                        if skipped and #skipped > 0 then
                            local parts = {}
                            for _, s in ipairs(skipped) do
                                parts[#parts + 1] = ShortName(s.name) .. " (" .. (MONDAY_SKIP_REASON[s.reason] or s.reason or "?") .. ")"
                            end
                            print("|cffff4040Mythic Monday:|r Invited " .. (invited or 0) .. ". Skipped: " .. table.concat(parts, ", "))
                        else
                            print("|cffff4040Mythic Monday:|r Invited " .. (invited or 0) .. ".")
                        end
                    end) end }
            elseif isMember then
                rowButtons[#rowButtons + 1] = { label = "Leave", width = 70, align = "right",
                    onClick = function() ns.safecall(ns.Monday.Leave, ev) end }
            elseif not g.isFull then
                local leaderName = g.leader
                rowButtons[#rowButtons + 1] = { label = "Join", width = 70, align = "right",
                    onClick = function() ns.safecall(function()
                        local ok, reason = ns.Monday.Join(ev, leaderName)
                        if ok == false then
                            print("|cffff4040Mythic Monday:|r " .. (reason or "could not join"))
                        end
                    end) end }
            end
            line(leaderLine, #rowButtons > 0 and rowButtons or nil)

            local missing = g.missing or {}
            local tankName, healerName
            local dpsMembers = {}
            for _, m in ipairs(g.members or {}) do
                -- T/H are single slots (a later member of the same role just
                -- overwrites the last), so those two stay capped at one link
                -- each by construction. DPS accumulates into a list instead,
                -- so it needs an explicit cap below.
                local shortN = MondayNameLink(m.name)
                if m.role == "T" then tankName = shortN
                elseif m.role == "H" then healerName = shortN
                elseif m.role == "D" then dpsMembers[#dpsMembers + 1] = shortN end
            end
            -- Hard-capped at 3 dps link slots regardless of how many D
            -- members g.members actually carries: a malformed/hostile G
            -- could pack in far more than a real 5-person group ever holds,
            -- and every name here is its own hyperlink - past ~9 links in
            -- one FontString the client silently drops every link in it
            -- (and the FontString's colour), not just the extras. Combined
            -- with T/H's 1-link cap above, this line never exceeds 5 links.
            -- Anything past the cap becomes a DIM, non-link count instead.
            local DPS_SLOTS = 3
            local dpsNames = {}
            for i = 1, math.min(#dpsMembers, DPS_SLOTS) do
                dpsNames[#dpsNames + 1] = dpsMembers[i]
            end
            local dpsOverflow = #dpsMembers - DPS_SLOTS
            if dpsOverflow <= 0 then
                -- Only pad with empty-slot dashes when there's genuinely
                -- room left; missing.D should already read 0 once
                -- dpsMembers exceeds the cap, but this keeps the two from
                -- fighting even if it doesn't.
                for _ = 1, math.min(missing.D or 0, DPS_SLOTS - #dpsMembers) do
                    dpsNames[#dpsNames + 1] = C.DIM .. "——" .. C.R
                end
            end
            local tankStr = tankName or (C.DIM .. "——" .. C.R)
            local healerStr = healerName or (C.DIM .. "——" .. C.R)
            local dpsStr = table.concat(dpsNames, ", ")
            if dpsOverflow > 0 then
                dpsStr = dpsStr .. C.DIM .. " +" .. dpsOverflow .. C.R
            end
            line(C.TANK .. "T " .. C.R .. tankStr .. C.DIM .. " · " .. C.R ..
                 C.HEALER .. "H " .. C.R .. healerStr .. C.DIM .. " · " .. C.R ..
                 C.DPS .. "D " .. C.R .. dpsStr)
        end
    end

    -- Looking for group --------------------------------------------------
    headingRow("Looking for group")
    local pool = ns.Monday.Pool(ev) or {}
    local brackets = ns.Monday.Brackets() or {}
    -- Open-board pool entries are pruned rather than flagged (see the Groups
    -- offline comment above), so no "(offline)" suffix there either.
    local showOffline = (ev == "monday")
    -- Tracks whether anything actually got rendered rather than trusting
    -- #pool == 0: an entry whose bracket doesn't match any known id (nil,
    -- or a stale id) used to fall through every bucket and vanish silently.
    local renderedPool = false
    local usedIds = {}
    for _, b in ipairs(brackets) do
        usedIds[b.id] = true
        local members = {}
        for _, e in ipairs(pool) do
            if e.bracket == b.id then members[#members + 1] = e end
        end
        if #members > 0 then
            renderedPool = true
            line(C.LEAD .. BracketDisplay(b) .. C.R)
            for _, e in ipairs(members) do
                line(PoolEntryLine(e, showOffline))
            end
        end
    end
    -- Catch-all for entries whose bracket isn't one of Brackets()' ids, so
    -- they still show up somewhere instead of being dropped.
    local leftover = {}
    for _, e in ipairs(pool) do
        if not usedIds[e.bracket] then leftover[#leftover + 1] = e end
    end
    if #leftover > 0 then
        renderedPool = true
        line(C.LEAD .. "Unspecified" .. C.R)
        for _, e in ipairs(leftover) do
            line(PoolEntryLine(e, showOffline))
        end
    end
    if not renderedPool then
        line(C.DIM .. "Nobody in the pool." .. C.R)
    end

    -- Stack --------------------------------------------------------------
    -- Same shape as SetBodyText's own loop (one FontString per row, y is a
    -- running total), plus button placement synced to the row it belongs to.
    local y = 0
    for i, row in ipairs(rows) do
        local fs = AcquireBodyLine(i)
        fs:SetText(row.text ~= "" and row.text or " ")
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", TEXT_INSET, -y)
        fs:Show()
        local rowH = fs:GetStringHeight()
        if row.buttons then
            rowH = math.max(rowH, MONDAY_BTN_H)
            local bx = TEXT_INSET
            -- Right-aligned buttons stack inward from the panel's right edge
            -- in the order they appear in `row.buttons` (a group's own row
            -- can carry both Disband and Invite all), rather than all
            -- landing on top of each other at the same fixed edge.
            local rightX = TEXT_INSET + TEXT_W
            for _, spec in ipairs(row.buttons) do
                local btn = NextMondayButton(spec.width)
                btn:SetText(spec.label)
                btn:ClearAllPoints()
                if spec.align == "right" then
                    btn:SetPoint("TOPRIGHT", content, "TOPLEFT", rightX, -y)
                    rightX = rightX - spec.width - MONDAY_BTN_GAP
                else
                    btn:SetPoint("TOPLEFT", content, "TOPLEFT", bx, -y)
                    bx = bx + spec.width + MONDAY_BTN_GAP
                end
                if spec.disabled then btn:Disable() else btn:Enable() end
                btn:SetAlpha(spec.dim and 0.55 or 1)
                btn:SetScript("OnClick", spec.onClick)
            end
        end
        y = y + rowH + LINE_GAP
    end
    for i = #rows + 1, #bodyLines do
        bodyLines[i]:Hide()
    end
    HideUnusedMondayButtons()
    return y - LINE_GAP
end

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
-- Tab layout
-- ------------------------------------------------------------------
-- Places the header rows for the current membership and hides whatever the
-- active tab has no use for. Called from UI_Refresh, so every path that
-- redraws also re-settles the geometry.

local function ApplyTabLayout()
    -- Membership can drop while the guild page is open - a /gquit, or a
    -- reload on an alt outside the guild - so fall back before drawing
    -- anything the player is no longer entitled to.
    if activeTab == "guild" and not ns.isGuildMember then
        activeTab = "dungeons"
    end
    -- One tab is no tab: for a non-member there is nothing to switch to, so
    -- the strip is dead chrome and the rows below reclaim its band.
    local strip = ns.isGuildMember
    for key, btn in pairs(tabButtons) do
        btn:SetShown(strip)
        btn:SetAlpha(key == activeTab and 1 or 0.55)
    end
    local drop = strip and HEADER_ROW_STEP or 0
    firstRoleBtn:ClearAllPoints()
    firstRoleBtn:SetPoint("TOPLEFT", 14, HEADER_ROW_Y - drop)
    navScroll:ClearAllPoints()
    navScroll:SetPoint("TOPLEFT", 14, NAV_TOP_Y - drop)
    navScroll:SetPoint("BOTTOMLEFT", 14, 14)

    local guild = (activeTab == "guild")
    -- The role filter and the model side-cart are about a dungeon; neither
    -- means anything on a handbook page. The nav column stays: both tabs fill
    -- it, one with bosses and one with handbook sections.
    for _, btn in pairs(roleButtons) do btn:SetShown(not guild) end
    autoOpenCheck:SetShown(not guild)
    if guild then
        sidecar:Hide()
    else
        -- All owned by SetGuildBody while the guild tab is up. Nothing on the
        -- dungeon side ever draws them, so nothing else would hide them either,
        -- and a stale hero would sit on top of the playbook text.
        hero:Hide()
        HideInvite()
    end

    -- The board buttons are pooled and only ever repainted by SetMondayBody
    -- itself, so any render path that ISN'T a board page has to hide them
    -- here - otherwise a Lead/Join/Disband button from Monday or Open groups
    -- keeps floating over a handbook page or a dungeon playbook after
    -- navigating away (including navigating from one board straight to the
    -- other). SetMondayBody resets the same counter and re-hides on its own
    -- turn, so this only has to cover every path that skips it.
    if not (guild and IsBoardPage(guildSelected.section)) then
        mondayButtonCount = 0
        HideUnusedMondayButtons()
    end

    scroll:ClearAllPoints()
    scroll:SetPoint("BOTTOMRIGHT", -32, 14)
    scroll:SetPoint("TOPLEFT", navScroll, "TOPRIGHT", 10, 0)
end

-- ------------------------------------------------------------------
-- Public API used by Core.lua
-- ------------------------------------------------------------------

function ns.UI_Refresh()
    local d = viewedDungeon
    local bodyHeight = 0
    UpdateRoleTabs()
    ApplyTabLayout()
    -- The guild page shares nothing with a playbook page but the scroll frame,
    -- so it takes its own exit rather than threading a third case through the
    -- dungeon/boss/trash selection below.
    if activeTab == "guild" then
        BuildNav(nil)
        UpdateNavHighlight()
        subtitle:SetText(ns.GUILD_NAME .. C.DIM .. "  —  guild only" .. C.R)
        -- A ns.Monday board is generated from ns.Monday, not a Data/Guild.lua
        -- page, so it takes its own exit here rather than going through
        -- GuildPage()/SetGuildBody (GuildPage() would just fall back to the
        -- first real page for an id it doesn't recognise).
        if IsBoardPage(guildSelected.section) then
            local ev = guildSelected.section
            local title = (ns.Monday and ns.Monday.EventTitle(ev))
                          or (ev == "open" and "Open groups" or "Mythic Monday")
            sectionTitle:SetText(title)
            content:SetHeight(SetMondayBody(ev) + 20)
        else
            local page = GuildPage()
            sectionTitle:SetText(page and page.title or "Guild")
            content:SetHeight(SetGuildBody(page) + 20)
        end
        scroll:SetVerticalScroll(0)
        return
    end
    -- Expanding a segment changes which rows exist, so the nav is rebuilt from
    -- `selected` on every refresh rather than only when the dungeon changes.
    BuildNav(d)
    UpdateNavHighlight()
    if not d then
        subtitle:SetText(C.DIM .. "Pick a dungeon" .. C.R)
        sectionTitle:SetText("Playbooks")
        bodyHeight = SetBodyText(C.DIM .. "Select a dungeon on the left.\n\nThe playbook loads automatically when you enter a covered dungeon." .. C.R)
    else
        subtitle:SetText(d.dungeon .. C.DIM .. "  —  " .. (d.season or "") .. C.R)
        if selected.kind == "boss" and selected.boss then
            sectionTitle:SetText(selected.boss.name)
            bodyHeight = SetBodyText(BuildBossText(selected.boss, ns.role))
        elseif selected.kind == "npc" and selected.npc and selected.segment then
            sectionTitle:SetText(selected.npc.name)
            bodyHeight = SetBodyText(BuildNPCText(selected.segment, selected.npc, ns.role))
        elseif selected.kind == "npc" and selected.npc and selected.boss then
            -- An add under a boss, not a trash NPC: adds carry no calls of
            -- their own, so fall back to the boss's own playbook text.
            sectionTitle:SetText(selected.npc.name)
            bodyHeight = SetBodyText(BuildBossText(selected.boss, ns.role))
        elseif selected.kind == "trash" and selected.segment then
            sectionTitle:SetText(selected.segment.name)
            bodyHeight = SetBodyText(BuildTrashText(selected.segment, ns.role))
        elseif selected.kind == "quicksheet" then
            sectionTitle:SetText("Quick sheet (all roles)")
            bodyHeight = SetBodyText(BuildQuicksheetText(d))
        else
            sectionTitle:SetText("Overview & Trash")
            bodyHeight = SetBodyText(BuildOverviewText(d, ns.role))
        end
    end
    content:SetHeight(bodyHeight + 20)
    scroll:SetVerticalScroll(0)
    UpdateSidecar()
end

-- Quick Sheet (all roles) is the default landing section — it's the one page
-- every role reads before a pull, and again once a fight is over. Dungeons
-- without quicksheet data fall back to Overview & Trash rather than
-- defaulting into a nav entry that doesn't exist.
local function DefaultSelected(d)
    if d and d.quicksheet then
        return { kind = "quicksheet" }
    end
    return { kind = "overview", boss = nil }
end

function ns.UI_SetDungeon(d)
    viewedDungeon = d
    selected = DefaultSelected(d)
    ns.UI_Refresh()
end

function ns.UI_SelectBoss(dungeon, boss)
    viewedDungeon = dungeon
    selected = { kind = "boss", boss = boss }
    ns.UI_Refresh()
    -- Selection updates regardless, so the right boss is showing whenever the
    -- user opens the panel manually; auto-open off also suppresses this popup.
    if (GuildPlaybookDB and GuildPlaybookDB.autoOpen) ~= false then
        ns.UI_Show()
    end
end

-- Fired on ENCOUNTER_END: same landing rule as opening the dungeon, since a
-- boss fight ending is functionally a fresh look at the run.
function ns.UI_SelectDefault()
    selected = DefaultSelected(viewedDungeon)
    ns.UI_Refresh()
end

-- Called from Core when membership flips, which adds or removes a whole tab.
-- Only a visible panel needs redrawing; a hidden one gets its layout from
-- UI_Show on the way up.
function ns.UI_GuildMembershipChanged()
    if frame:IsShown() then
        ns.UI_Refresh()
    end
end

-- Shared show path for the toggle and for auto-open on dungeon entry: restores
-- the saved position and refreshes before revealing the frame.
function ns.UI_Show()
    if frame:IsShown() then return end
    local p = GuildPlaybookDB and GuildPlaybookDB.point or { "CENTER", 250, 0 }
    frame:ClearAllPoints()
    frame:SetPoint(p[1], UIParent, p[1], p[2], p[3])
    ns.UI_Refresh()
    frame:Show()
end

function ns.UI_Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        ns.UI_Show()
    end
end

-- Entry point for `/gp monday` and `/gp now` (Core.lua). `ev` defaults to
-- "monday" for nil or any id that isn't one of the two known boards, so a
-- stale/misspelled call can't land on a blank page. UI_Show() no-ops on an
-- already-open frame, so the tab/page switch is applied first and the
-- redraw is forced explicitly rather than relying on UI_Show to do it.
function ns.UI_ShowMonday(ev)
    if not IsBoardPage(ev) then ev = "monday" end
    activeTab = "guild"
    guildSelected = { kind = "guild", section = ev, expanded = nil }
    if frame:IsShown() then
        ns.safecall(ns.UI_Refresh)
    else
        ns.UI_Show()
    end
end

-- Monday.lua loads before UI.lua per the TOC, so ns.Monday is normally
-- present by the time this runs; guarded anyway since a load-order change or
-- a stripped file must not turn into a startup error. RegisterCallback now
-- hands back which board changed; redraw only if that's the board actually
-- on screen - a background change on the open board while Monday is showing
-- (or a hidden panel, or the dungeon tab) has nothing to repaint yet.
if ns.Monday then
    ns.Monday.RegisterCallback(function(ev)
        if frame:IsShown() and activeTab == "guild" and guildSelected.section == ev then
            ns.safecall(ns.UI_Refresh)
        end
    end)
end

ApplyTabLayout()
BuildNav(nil)   -- start in dungeon-list mode until zone detection kicks in

ns.uiLoaded = true
