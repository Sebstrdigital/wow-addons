# Stand as One's Playbook

Guild-curated Mythic+ tactics, in-game and filtered to your role — so you read the plan before the pull instead of alt-tabbing to a document after the wipe.

## What it does

- **Auto-loads the playbook for the dungeon you're in** and jumps to the boss page when the encounter starts.
- **Role-aware**: detects whether you're tanking, healing, or DPSing and shows that role's guidance — tabs let you peek at the other roles.
- **All-roles Quick Sheet** per dungeon: priority trash calls and per-boss one-liners for every role at once, so each role knows what the others are doing.
- **Per-boss pages**: Your Job / Avoid / Defensives (Cooldowns for healers) / Wipe Mechanics, plus a one-line reminder — with a 3D model of the boss.
- **Dungeon overview**: interrupt priority, kill order, dispels, purges, tank-damage warnings, pull warnings, practical tips per role.
- **Guild tab** (guild members only): the guild's Discord invite and guild-specific info, kept separate from the dungeon material. Players outside the guild see the dungeon playbooks exactly as before, with no extra chrome.

## Coverage

All Midnight Season 2 dungeons (Altar of Fangs, Den of Nalorakk, King's Rest, Murder Row, Ruby Life Pools, Temple of Sethraliss, The Blinding Vale, Voidscar Arena) plus Magisters' Terrace. Content is updated as the season develops.

## Design

Fully compatible with the Midnight addon rules: the addon reads only non-secret signals (zone, encounter start/end, your own role) and displays pre-authored guidance — no combat-state automation of any kind.

Content is curated by our guild's playbook author and maintained openly on GitHub; a companion website with an MDT route viewer lives at https://sebstrdigital.github.io/wow-addons/.

`/gp` toggles the panel · `/gp tank|healer|dps` forces a role view · `/gp auto` follows your assigned role.
