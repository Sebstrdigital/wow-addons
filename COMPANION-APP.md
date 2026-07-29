# Proposal: Second-Screen Companion App

*Drafted 2026-07-29. Companion to [PROPOSAL.md](PROPOSAL.md) (the in-game addon). Request from a guild tank: the playbook content plus an MDT-style route, viewable outside WoW on a second monitor.*

## 1. What the research found

- **The gap is real.** Nothing renders MDT routes standalone outside the game. The raid side has raidplan.io / raidstrats.gg; no Mythic+ equivalent exists. Current second-screen practice is simply "keystone.guru open in a browser" — that's the incumbent to improve on.
- **keystone.guru is alive and covers Midnight S1** (all 8 dungeons, owned by Raider.IO since 2023, actively developed). Crucially, its **route embeds work in iframes** — `https://keystone.guru/<routeKey>/embed?showAffixes=0` serves with no frame-blocking headers, is interactive (zoom, mob tooltips, pull sidebar), and imports/exports MDT strings natively.
- **Self-hosting keystone.guru is a dead end**: the repo has no license (all rights reserved), and the dungeon map tiles are deliberately excluded from it.
- **Decoding MDT export strings in a browser is feasible and small** (~200 LOC): `"!"` prefix + LibDeflate `EncodeForPrint` (custom little-endian 6-bit alphabet) + raw DEFLATE (browser-native `DecompressionStream('deflate-raw')`) + AceSerializer text format. The decoder isn't the hard part — resolving enemy indices to map positions requires vendoring MDT's per-dungeon data tables (GPL v2, 23–68 KB per dungeon, per-season maintenance).
- **Map imagery is the genuine blocker for self-rendering.** MDT and keystone.guru ship Blizzard-derived art; extraction (wago.tools, since wow.tools retired) is universally practiced with no known takedowns against route tools, but it has no explicit Blizzard permission, and keystone.guru withholding its tiles from an otherwise-public repo shows the author treats them as the sensitive asset.

## 2. Recommendation: two phases, ship Phase 1

The design splits cleanly along the asset-risk / offline axis.

### Phase 1 — static companion site (days of work, zero legal exposure)

A static web app generated **from the same YAML the addon uses** — one content source feeds both the in-game panel and the website.

- **Stack**: Astro 5 (already used in the workspace, YAML content collections are first-class) → fully static bundle → **GitHub Pages** from this repo. Content updates ship on `git push`, same as the addon.
- **Pages**: per dungeon — role-tabbed tactics (same Tank/Healer/DPS structure and color convention as the addon and PDFs), boss pages with wipe callouts, and an **embedded keystone.guru route** per dungeon via iframe. The guild agrees on a route in MDT, exports the string, imports it to keystone.guru once, and pins the route key in the YAML (`routeKey: b9WvtJb`).
- **Second-screen niceties**: dark theme, large-type "during the key" mode, keyboard navigation between bosses, optional per-pull tank notes rendered beside the embed.
- **Costs / limits**: needs network (iframe can't work offline); our tactics can't be overlaid *onto* the map — they sit beside it; dependency on keystone.guru keeping embeds open.

### Phase 2 — own route renderer (weeks, only if Phase 1 proves demand)

Leaflet map with a local tile pyramid + the MDT string decoder above, overlaying **our role-specific tactics directly on the map** and enabling a full offline PWA.

Takes on: tile extraction from wago.tools (the legal grey zone), vendoring MDT's GPL v2 data tables (copyleft applies to the renderer), and per-patch maintenance. Decision point after the guild has used Phase 1 for a few weeks.

## 3. Architecture (Phase 1)

```
GuildPlaybook/content/<season>/<dungeon>.yaml      ← single source of truth
        ├── tools/generate.py  → Data/*.lua        → addon (unchanged)
        └── companion/ (Astro)  → GitHub Pages     → second screen
              src/content/  reads ../GuildPlaybook/content/ directly
              dungeon page = tactics tabs + <iframe keystone.guru/<routeKey>/embed>
```

YAML additions: per-dungeon `routeKeys: { tank: "…" }` (allows multiple named routes later: pug route, high-key route).

## 4. Open questions

| Question | Why it matters | Action |
|---|---|---|
| keystone.guru API keys are not self-serve (`/api/v1/*` returns Unauthenticated; no public signup) | Only needed for deeper integration (route thumbnails, pull data) — embeds work without it | Ask Wotuu (Discord `Wotuu#1937`) / Raider.IO early; not a Phase 1 blocker |
| Embed longevity | Phase 1's map depends on it | Low risk (shipped feature, tracked in their issue #544); Phase 2 is the hedge |
| Who maintains the route? | Route quality is the tank's domain | Tank owns the MDT route → exports to keystone.guru → PRs the route key |

## 5. Decision asked

1. Green-light Phase 1 (Astro site in `companion/`, GitHub Pages on this repo)?
2. Tank provides the Magisters' Terrace MDT route → keystone.guru import → route key.
3. Phase 2 revisited after real usage.
