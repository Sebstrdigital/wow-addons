# Playbook Content Guide — for the info gatherer

*How to research and structure dungeon playbooks so they drop straight into the Guild Playbook addon and website. Written for Raven (or anyone gathering with AI assistance). Last updated 2026-07-29.*

## How the pipeline works

Whatever you produce gets converted into one YAML file per dungeon (`GuildPlaybook/content/<season>/<dungeon>.yaml`). That single file feeds **both** the in-game addon and the second-screen website. The closer your output is to the structure below, the less gets lost in conversion — the v0.2.0 release dropped some role tips and DPS pull warnings purely because the PDFs had content the structure didn't anticipate.

You don't have to write YAML. PDFs or markdown are fine **as long as the structure below is followed consistently** — consistent structure is what makes the conversion lossless.

## What to gather, per dungeon

### 1. All-roles quick sheet (one page, most important)
The at-a-glance page everyone reads before the key — and the only section every role sees together, so each role learns the others' responsibilities.

- **Priority trash calls**: one line each for `TANK:`, `HEALER:`, `DPS:`, plus a `ROUTE:` line (buffs to collect, packs to limit/stagger).
- **Per boss**: exactly four one-liners — `TANK:`, `HEALER:`, `DPS:`, `WIPE:`. Keep each under ~15 words; these are calls, not explanations.

### 2. Dungeon overview, per role
- **Interrupt priority** (ordered, with severity: "must stop" / "high priority" / "use spare kicks")
- **Kill priority** (ordered)
- **Tank**: dangerous tank damage (ability — what to do about it), pull warnings
- **Healer**: dispel priority (with dispel type), biggest healing pressure (ability — source — pattern), pull warnings
- **DPS**: purges, personal-defensive warnings, pull warnings
- **Practical tip per role** — one line each. Three separate lines, not one shared line (the schema stores all three).

### 3. Bosses — and mini-bosses as first-class entries
For each boss AND each mini-boss (mini-bosses get the same full treatment — this was the gap in the original PDFs):

- **Quick reminder**: one arrow line, e.g. "Edge puddles → defensive for Slam → stop the orbs."
- **Your job** / **Avoid** / **Defensives** (healers: **Cooldowns**): bullet lists per role
- **Wipe mechanic**: shared bullets (what actually ends the key)

### 4. Trash packs worth naming
Notable packs/gauntlets that need more than a one-liner (assignments, CD rotations). Give them the same structure as mini-bosses; they'll live as ★ entries between bosses.

## Rules that matter

1. **Never invent.** If a mechanic is unverified on PTR, write "needs live verification" — the conversion keeps that flag; a wrong instruction in a key is worse than a gap.
2. **Name abilities exactly** as the Dungeon Journal spells them (the addon may key off these names later).
3. **Same heading names every time.** "Your Job / Avoid / Defensive / Cooldowns / Wipe Mechanic / Quick Reminder / Practical tip" — the converter matches on these.
4. **Version and label**: every document carries dungeon name, season (e.g. Midnight S2), patch, and a draft version. Bump the version on every revision.
5. **Cite sources** at the end (Dungeon Journal, Wowhead, Method, Icy Veins, logs).
6. Keep per-role text **in that role's voice** ("Face the boss away") — no third-person summaries.

## Paste-ready prompt for your AI

> You are compiling a Mythic+ dungeon playbook for a WoW guild, for the dungeon **[DUNGEON, SEASON, PATCH]**. Research the current mechanics (Dungeon Journal via Wowhead, Method, Icy Veins; flag anything not yet verifiable on live as "needs live verification" rather than guessing). Produce, in this exact order and with these exact headings:
>
> 1. **ALL-ROLES QUICK SHEET** — "Priority trash calls": one line each for TANK, HEALER, DPS, ROUTE. Then for every boss, numbered: TANK / HEALER / DPS / WIPE, one line each, max 15 words per line.
> 2. **DUNGEON OVERVIEW** per role — Interrupt first (ordered, severity-tagged); Kill first (ordered); Tank: Dangerous tank damage + Pull warnings; Healer: Dispel first (with dispel school) + Biggest healing pressure + Pull warnings; DPS: Purge and control + Personal defensive warnings + Pull warnings. End with three "Practical tip" lines: one for Tank, one for Healer, one for DPS.
> 3. **PER BOSS AND PER MINI-BOSS** (treat named mini-bosses and major trash gauntlets exactly like bosses) — Quick Reminder (one "A → B → C" line); then per role (Tank, Healer, DPS): Your Job, Avoid, Defensive (Healer: Cooldowns) as bullet lists; then Wipe Mechanic bullets shared by all roles.
>
> Rules: use the Dungeon Journal's exact ability names; never invent — mark unverified items "needs live verification"; write each role's text as instructions to that role; keep the quick-sheet lines terse and the playbook bullets specific (ability — what to do — why it kills). Header on page 1: dungeon, season, patch, draft version, date. Footer: sources used.

## Even better: skip PDFs

If your AI can output the YAML directly, ask it to follow the schema in `GuildPlaybook/content/midnight-s1/magisters-terrace.yaml` (the reference file, including `quicksheet` and per-boss `sheet` blocks) and validate it survives `python3 tools/generate.py`. Then a content update is a pull request instead of a conversion job — PDFs stay as the pretty distribution format if you still want them.
