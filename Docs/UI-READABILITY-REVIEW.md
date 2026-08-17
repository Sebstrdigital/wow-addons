# UI readability review — playbook panel

Feedback: "text not breathing, overwhelming". Diagnosis below. Nothing implemented yet.

## Root cause

`GuildPlaybook/UI.lua:918-923` — **whole panel body is ONE FontString**. Every
section, heading, bullet and wrapped line is `\n`-joined into a single string
with colour escapes.

```lua
local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetSpacing(3)
```

`SetSpacing(3)` is uniform. So the gap between two separate bullets is exactly
the gap between wrapped line 1 and line 2 of the *same* bullet. Nothing groups.
That is the "wall of text" feeling — not font size, not colour.

## Findings

### L1 — no visual grouping (UI.lua:922)
3px leading on 12px font, applied everywhere. Paragraph and item boundaries are
indistinguishable. Screenshot 3 ("Biggest healing pressure") is three bullets
that read as six lines of undifferentiated text.

### L2 — heading separator is a fake blank line (UI.lua:30-33)
`heading()` pushes a `" "` line. That is ~15px. A heading needs ~2x the body
leading above it and ~0.5x below (asymmetric). Currently symmetric and too
small, so gold headings sit *inside* the block they label.

### L3 — no hanging indent on bullets (UI.lua:24-28)
`"• " .. line`. Wrapped continuation lines return flush to the left margin,
under the `•`. Reader loses the item boundary. Visible in shot 3 on the
Rav'i / Feeding Frenzy bullet. Unfixable inside one FontString.

### L4 — too many hues competing
Gold headings + role blue/green/orange + red + near-white body + dim grey, all
on screen at once (shot 3 has 4 heading colours in one viewport). Role colour
is doing two jobs: labelling a role tag *and* colouring whole headings. Result
reads as alarm, not hierarchy.

### L5 — measure too long
`text:SetWidth(PANEL_W - NAV_W - 60)` at 12px. Wide panel = long lines with no
paragraph breaks (L1) = worst case for scanning under combat pressure.

### L6 — content width has no left padding
`text:SetPoint("TOPLEFT")` at 0,0 in `content`. Body starts flush against the
scroll edge; `sectionTitle` (UI.lua:925) aligns to the same 0. No optical margin.

## Copy findings

### C1 — quicksheet trash is a semicolon run-on (worst offender)
`content/midnight-s2/altar-of-fangs.yaml:80-82` and every other dungeon: 4-5
separate mob calls concatenated into one string per role, joined with `; `.
Renders as shot 2's TANK/HEALER/DPS paragraph blocks. These are *lists*
authored as prose. Should be `list[str]`, one call per bullet.

Affected: all 8 dungeon YAMLs, `quicksheet.trash.{TANK,HEALER,DPS}`.

### C2 — `.;` double punctuation
Fallout of C1. Sentences kept their period, then got `; `-joined.
`"...prioritise the High Evolutionist.; Ascendant Serpent — ..."`.
Present in every dungeon file (blinding-vale:53-55, kings-rest:66-68,
altar-of-fangs:80-82, ruby-life-pools:37-39, murder-row:62-64,
voidscar-arena:71-73, den-of-nalorakk:53-54).

### C3 — DPS/HEALER/TANK quicksheet lines are near-duplicates
kings-rest.yaml:66-68 — all three roles have the *identical* string.
murder-row.yaml:62-64 differ in one clause each. Reader sees the same paragraph
three times and stops reading. Either collapse to an "ALL" block with per-role
deltas, or cut to what actually differs.

### C4 — PTR hedges leak into combat copy
232 hits for `PTR|needs checking|live verification` in `content/`.
Mid-call examples: "Highlighted on current PTR; hard swap to them",
"current PTR duration is 30 sec with fewer pools",
"exact live dispel behaviour needs checking" (shot 3),
"PTR dispel behaviour and trash pull order require live verification" (shot 3,
sitting inside a red **Pull warnings** block).
Worst: `voidscar-arena.yaml:71-73` has a mob literally named
"Watchful Harrower — Live Verification" as if it were a spell.

Author caveats are not combat instructions. They belong in a dim footer
("Verified 9 Aug 2026 · PTR data") or a tooltip, not in the same red block as
"stay 5 yd apart".

### C5 — inconsistent labels
Nav says "Quick sheet (all roles)", section title says
"Quick sheet — all roles". Nav "Overview & Trash", section title
"Dungeon overview". Pick one string each.

### C6 — bullets end in periods, headings don't
Mixed. Short imperative calls read faster without terminal periods.

## Recommended fixes

### Tier 1 — cheap, no restructure (~30 min, UI.lua only)
1. `SetSpacing(3)` → `6`. Immediate breathing room.
2. `heading()`: push two `" "` lines instead of one (~30px above heading).
3. Cut heading colours to two: `C.HEAD` gold for all section headings,
   `C.WIPE` red reserved for the wipe/pull-warning block only. Drop per-role
   heading tint — keep role colour on the `TANK:` inline tag only.
4. Add left padding: `text:SetPoint("TOPLEFT", 4, 0)`.
5. Cap measure: `text:SetWidth(math.min(PANEL_W - NAV_W - 60, 520))`.

Gets ~70% of the perceived improvement. Does **not** fix hanging indents (L3).

### Tier 2 — block renderer (~150 lines, UI.lua)
Replace the single FontString with a stacked-block model. Builders return
`{ {kind="heading", text=...}, {kind="bullet", text=...}, ... }` instead of a
concat'd string. Renderer pools FontStrings, anchors each below the previous
with a per-kind gap (heading 16 above / 6 below, bullet 5, para 9), and draws
bullets as two FontStrings (dot at x=0, text at x=14, width-14) for a real
hanging indent. `content:SetHeight` becomes the running Y.

Unlocks: hanging indents, hairline rules under headings, subtle alternating
background on quicksheet role rows, per-block colour without escape soup.

### Tier 3 — content pass (all 8 YAMLs)
1. `quicksheet.trash.<ROLE>` string → list of strings, one call per entry.
   Fixes C1 + C2 in one edit.
2. Strip PTR/verification hedges from calls; move to a per-dungeon
   `meta.verified` field rendered dim at the bottom of Overview (C4).
3. Rename the fake "Live Verification" mob entries (C4).
4. Collapse identical per-role quicksheet blocks (C3).
5. Normalise nav/section labels (C5), drop terminal periods on bullets (C6).

## Suggested order

Tier 1 → look at it in-game → Tier 3 (biggest single win is C1) → Tier 2 if
still cramped. Tier 3 needs a re-scout of source playbooks anyway per the open
post-launch item.
