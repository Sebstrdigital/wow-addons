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

-- Role tabs -------------------------------------------------------

local roleButtons = {}
local function UpdateRoleTabs()
    for role, btn in pairs(roleButtons) do
        btn:SetAlpha(role == ns.role and 1 or 0.55)
    end
end

local lastRoleBtn
for _, role in ipairs({ "TANK", "HEALER", "DPS" }) do
    local btn = CreateChromeButton(frame, 85, 26)
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
    for _, btn in ipairs(mdtRouteButtons) do btn:Hide() end
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

-- Spell links rendered by RenderAbilityLinks live in the body FontStrings
-- below, which are regions of this frame - hyperlink hit-testing and the
-- OnHyperlink* scripts belong on the frame that owns the regions, not on the
-- FontStrings themselves (FontStrings don't take mouse scripts). This holds
-- for every FontString in the pool: they are all created by content, so one
-- pair of scripts on content serves all of them.
content:EnableMouse(true)
content:SetHyperlinksEnabled(true)
content:SetScript("OnHyperlinkEnter", function(self, link)
    ns.safecall(function()
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
end)
content:SetScript("OnHyperlinkLeave", function()
    ns.safecall(GameTooltip.Hide, GameTooltip)
end)

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
local function SetBodyText(s)
    s = tostring(s or "")
    local y, n, from = 0, 0, 1
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
    local bodyHeight = 0
    UpdateRoleTabs()
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

BuildNav(nil)   -- start in dungeon-list mode until zone detection kicks in

ns.uiLoaded = true
