# Proposal: Guild Mythic+ Playbook Addon

*Drafted July 2026 against live patch Midnight 12.0.7. Companion document: [WOW-ADDON-GUIDE.md](WOW-ADDON-GUIDE.md), especially §8 (Secret Values), which constrains everything below.*

## 1. The problem

The guild's Mythic+ knowledge — role-specific tactics, boss mechanics, and damage profiles for trash, mini-bosses, and bosses — lives in PDFs maintained by a guild member. Using it mid-dungeon means alt-tabbing, and the content goes stale each season when the dungeon pool rotates. The goal is an addon that surfaces that curated content **inside the game, filtered to the player's role, at the moment it's relevant**.

## 2. Why now, and why the design must be what it is

Blizzard's Midnight "addon disarmament" (live since 12.0, early 2026) is the defining constraint — it kills one whole category of design and validates another.

**What is impossible now** (see guide §8 for mechanics):

- **Per-mob tooltips/overlays.** Creature names, GUIDs, and npcIDs are unconditionally secret inside instances. QE Dungeon Tips — the canonical role-aware mob-tooltip addon — is dead and architecturally unrevivable.
- **Reactive triggers** ("when boss casts X, show note Y"). The combat log errors on registration, aura reading is being locked down further in 12.1, and Blizzard's direction of travel is tighter every patch.
- **Mid-run syncing.** Addon messages are blocked from keystone activation until the key completes.

**What is explicitly preserved and safe:** static pre-authored content keyed off non-secret signals — dungeon identity (`GetInstanceInfo`), keystone level and affixes (`C_ChallengeMode.GetActiveKeystoneInfo`), `CHALLENGE_MODE_START/COMPLETED`, `ENCOUNTER_START/END`, and the player's own role and spec. This is exactly the category Blizzard has said it wants addons to remain: "personalized presentation of information."

The restrictions are also the market opportunity: the addons that used to occupy this space are dead or diminished, and nothing curated has replaced them for trash.

## 3. Landscape and gap

| Existing addon | Covers | Misses |
|---|---|---|
| **Boss Mentor** (closest competitor) | 48 S1 bosses, 285 abilities, role-tagged (Tank/Healer/DPS), type-tagged (interrupt/soak/dispel/…), TLDR lines | **Bosses only — no trash, no mini-bosses.** Not editable; you get the author's opinions |
| DBM / BigWigs + LittleWigs | Timers (now reformatting Blizzard's native Encounter Timeline) | The *when*, never the *why* or what your role does about it |
| Mythic Dungeon Tools | Routes, pulls, enemy forces, freehand map notes | No structured/role-filtered prose, no tactics content |
| KwikTip, TL;DR Dungeon Guide, Mythic Mentor | Generic contextual tips | Public one-size-fits-all content |
| WarpDeplete / Angry Keystones | M+ timer HUDs | No guidance at all |

**The gap, in order of strength:**

1. **Trash and mini-boss guidance** — keys die on trash; nobody covers it in curated, role-specific form anymore.
2. **Guild-owned content** — the value is that a trusted guild member wrote it and it encodes *this guild's* strategies, CD assignments, and pull conventions. No public addon can provide that.
3. **Single source of truth in-game** — replaces the alt-tab-to-PDF loop.

Pitch in one sentence: **a guild playbook viewer** — dungeon-scoped, role-filtered panels of the guild's own content, opened on demand and auto-surfaced at the right moments — not a combat mod.

## 4. Proposed v1 scope

### In scope

- **Playbook panel**: a movable, resizable frame showing the current dungeon's content as structured sections — per boss, per mini-boss, per trash *section* (see below) — with tabs or a filter for Tank / Healer / DPS / All, defaulting to the player's own role (`UnitGroupRolesAssigned("player")`, spec via `GetSpecialization`).
- **Content model**: per entry — TLDR line, role-tagged ability notes, type tags (interrupt, soak, dispel, movement, tank CD, healer CD), damage-profile notes from the PDFs, optional key-level/affix-conditional notes (keystone level and affixes are readable).
- **Context switching on non-secret signals**:
  - Entering a dungeon → load that dungeon's playbook, show a summary page.
  - `ENCOUNTER_START` → auto-open that boss's page (encounter IDs in the event payload are the trigger; this is the one per-boss signal that survives).
  - `ENCOUNTER_END` → return to dungeon overview / next section.
  - Trash guidance follows the structure the guild's PDFs actually use: **dungeon-level priority calls per role** (interrupt order, kill order, dispel/purge lists, tank-damage warnings, pull warnings) shown on the dungeon overview page — not per-pull sections. This is route-independent and matches the source material; optional route sections can come later if the PDFs evolve that way. (Per-mob detection is impossible under Midnight rules either way.)
- **Keybind + slash command** (`/gp`, keybinding) to toggle the panel; compact "TLDR bar" mode showing just the current section's one-liner.
- **Season-partitioned content**: Season 1 pool now (Windrunner Spire, Maisara Caverns, Magisters' Terrace, Nexus-Point Xenas, Algeth'ar Academy, Seat of the Triumvirate, Skyreach, Pit of Saron); Season 2 drop as the proving milestone (§7). *(Verify the S2 list against Wowhead's season overview before shipping — sourced from secondary sites.)*

### Explicitly out of scope

- Timers and warnings (BigWigs/DBM + Blizzard's native timeline own this).
- Routes (MDT owns this — but playbook section names can mirror an agreed MDT route).
- Per-mob tooltips, aura/cast-reactive triggers, in-run data sync — impossible under Midnight rules.
- Localization (structure strings so it's possible later; guild runs in English).

### Nice-to-have (v2 candidates)

- Restyle Blizzard's native boss warnings per guild convention via `C_EncounterEvents.SetEventColor`/`SetEventSound` — a sanctioned, restriction-proof form of guild standardization.
- Pre-run "readiness" broadcast: before the key activates (comms work then), members' addons exchange versions so the party sees who has the current playbook.
- MDT route-string import to auto-name trash sections.

## 5. Architecture

### 5.1 Content pipeline — the PDFs become the source of truth

```
guild PDFs  →  content/  (one YAML file per dungeon, per season)
                 └─ tools/generate.py  →  Data/S2/<Dungeon>.lua  (static Lua tables)
                                            └─ shipped in the addon zip
```

- The guild member authors **YAML, not Lua** — reviewable in a PR, diffable, and far easier for a non-programmer than Lua tables. The generator validates (unknown role tags, missing TLDRs, malformed sections) and emits Lua at build time. Runtime JSON/YAML parsing is deliberately avoided (load cost, no build-time validation) — compiling to Lua is the established pattern (MDT ships one static Lua file per dungeon; HandyNotes plugins likewise).
- The schema mirrors the structure the guild's PDF playbooks already use (verified against the Magisters' Terrace tank/healer/DPS set): a per-role **dungeon overview** (interrupt priority, kill order, dispels, purges, tank-damage list, pull warnings, practical tip) plus **per-boss sections** with the PDFs' fixed headings — *Your Job / Avoid / Defensive / Wipe Mechanic / Quick Reminder* — where wipe mechanics are shared across roles:

```yaml
dungeon: "Magisters' Terrace"
slug: magisters-terrace
season: midnight-s1
patch: "12.0.7"
instanceID: 585          # GetInstanceInfo() — confirm in-game via /gp ids
overview:
  interrupts:
    - { spell: "Terror Wave", note: "must stop" }
  killPriority: ["Lightward Healer", "Blazing Pyromancer"]
  tank:
    damage: ["Arcane Blade — purge the Enforcer or use a defensive."]
    pullWarnings: ["Face every Runed Spellbreaker away from the group."]
  healer:
    dispels: ["Ethereal Shackles — remove the root and damage."]
    pressure: ["Ignition — heavy group damage from Blazing Pyromancers."]
  dps:
    purges: ["Hastening Ward — purge from Seranel immediately."]
  tip: "Collect the library's 5% Haste tome; 30 min, persists through death."
bosses:
  - name: "Arcanotron Custos"
    encounterID: null    # fill via /gp ids capture mode
    wipe: ["Never let an Energy Orb reach the boss."]
    roles:
      TANK:
        job: ["Edge puddles.", "Move off residue."]
        avoid: [...]
        defensive: [...]
        reminder: "Edge puddles → defensive for Slam → stop the orbs."
      HEALER: { job: [...], cooldowns: [...], reminder: "..." }
      DPS:    { job: [...], avoid: [...], reminder: "..." }
```

- Mini-bosses: not present in the current PDFs (trash is covered as dungeon-level calls); the schema treats them as additional `bosses` entries without an `encounterID` if the docs add them later.
- Encounter/instance IDs aren't in the PDFs and Midnight's reworked Magisters' Terrace IDs need in-game confirmation — the addon ships a capture mode (`/gp ids`) that prints `GetInstanceInfo()` and `ENCOUNTER_START` IDs to fill into the YAML once.

### 5.2 Addon runtime

- Plain Ace3 addon (AceAddon + AceDB for panel position/settings + AceConsole); AceGUI or hand-rolled frames for the panel.
- Event surface: `PLAYER_ENTERING_WORLD` + `GetInstanceInfo()` for dungeon detection, `CHALLENGE_MODE_START/COMPLETED`, `ENCOUNTER_START/END`, `GROUP_ROSTER_UPDATE` for role.
- The panel is an unprotected display frame → can be shown/hidden in combat. **Keep it in its own frame tree and never feed it secret values**, so its position stays readable and saveable (the secret-anchoring trap, guide §8).
- SavedVariables: settings and panel layout only — never gameplay data (secrets serialize to nil anyway).

### 5.3 Repo layout

```
GuildPlaybook/
├── GuildPlaybook.toc
├── Core.lua / UI.lua / Router.lua
├── Data/                 ← generated, committed
├── content/              ← YAML source of truth
├── tools/generate.py
├── .pkgmeta
└── .github/workflows/release.yml   (BigWigs packager)
```

## 6. Distribution

**Recommendation: public GitHub repo (unremarkable name) + BigWigs packager tag-driven releases + members install via WowUp's install-from-GitHub-URL.**

- There is no real "private addon" channel: WowUp's private-repo support is unreliable (multiple open issues), and CurseForge has no access-controlled tier (its "Experimental" type only hides from search). Manual zips in Discord work but guarantee version drift mid-season.
- Public is also the compliant posture: Blizzard's policy requires fully visible code — obfuscating to keep guild strategies private would itself be a violation. The competitive edge is in executing the strategies, not reading them. License MIT so the guild isn't locked to one maintainer.
- Addon must remain free, no ads, no donation solicitation (policy).

## 7. Milestones

1. **Skeleton (a weekend)** — TOC, panel frame, slash command, dungeon detection, one hand-written dungeon's data. Validates the UX.
2. **Pipeline (week 2)** — YAML schema + generator + validation; guild member converts one full dungeon from the PDFs; iterate on the schema together.
3. **S1 coverage + role filtering + ENCOUNTER_START routing (weeks 3–4)** — convert remaining dungeons; test with `secretChallengeModeRestrictionsForced` CVar and real keys.
4. **The proof: Season 2 day-one drop (~Aug 18)** — S2's pool (five new/returning dungeons incl. Altar of Fangs, Murder Row, Den of Nalorakk, The Blinding Vale, Voidscar Arena + Ruby Life Pools, Temple of Sethraliss, King's Rest — verify list) lands when public addons are least up to date and the guild needs guidance most. Shipping the S2 playbook on day one proves the pipeline and the addon's whole reason to exist.

## 8. Risks and open questions

| Risk / question | Impact | Mitigation |
|---|---|---|
| `ENCOUNTER_START` payload details / encounter ID stability in 12.x | Boss auto-routing granularity | Verify in-game early (milestone 1); Blizzard added test encounter dummies near The MOTHERLODE!! entrance for exactly this |
| Is party role/name readable **during** an active key (player units are conditionally, not unconditionally, secret)? | Whether role auto-selection can re-evaluate mid-run | Read role at dungeon entry, cache it; manual role tabs as fallback |
| Does `C_EncounterEvents` expose any *readable* static timeline data? | Would enable phase-aware notes (v2) | Investigate on PTR; v1 doesn't depend on it |
| 12.1 aura refactor and further tightening | Could break assumptions | v1 deliberately touches no combat state — the design is restriction-proof by construction |
| Content maintenance burden each season | Addon dies if YAML rots | Pipeline optimized for the guild member's workflow; PDFs remain their working format, YAML is the export |
| wiki under maintenance since 2026-07-23 | Some exact API names unverifiable right now | Cross-check against `Gethe/wow-ui-source` |

## 9. Decision asked of the guild

- Approve the **playbook-viewer** framing (vs. waiting for public addons to cover trash — none are).
- Confirm the content owner is willing to author YAML (with schema help) instead of only PDFs.
- Pick the target: S1 validation now, **S2 day-one as the real launch**.
