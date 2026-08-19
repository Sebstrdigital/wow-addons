# Stand as One's Playbook (GuildPlaybook)

Guild-curated Mythic+ tactics, shown in-game and filtered to your role. Content comes from the guild's playbook PDFs, converted to YAML and compiled into the addon as static Lua data — fully compatible with the Midnight addon restrictions, since it only reads non-secret signals (zone, encounter start/end, your own role).

## Install (manual, for now)

Copy the `GuildPlaybook` folder into `World of Warcraft/_retail_/Interface/AddOns/`. The folder must contain `GuildPlaybook.toc` at its top level. Restart the client or `/reload`.

## Use

- `/gp` — toggle the panel. It auto-loads the playbook when you enter a covered dungeon and jumps to the boss page on pull (`ENCOUNTER_START`), back to the overview after the fight.
- `/gp tank` / `/gp healer` / `/gp dps` — force a role view; `/gp auto` follows your assigned role again. Role tabs in the panel do the same.
- `/gp ids` — capture mode: prints the zone's `instanceID` and each boss's `encounterID` to chat so they can be filled into the YAML (needed once per dungeon; the reworked Midnight IDs aren't documented yet).
- `/gp list` — show loaded playbooks.

## Editing content

1. Edit or add a YAML file under `content/<season>/` — one file per dungeon. Follow the structure of `content/midnight-s2/ruby-life-pools.yaml`: a per-role dungeon overview plus one entry per boss with `job` / `avoid` / `defensive` (healers: `cooldowns`) / `reminder` lists per role and a shared `wipe` list. Optional per boss: `displayID` (or `npcID`) shows a 3D model of the boss next to the panel, and `adds` lists the named adds that boss summons — each an entry of `name` plus `npcID` / `displayID`, exactly like a trash `npcs` entry. A boss with `adds` becomes expandable in the nav, and selecting an add shows its 3D model alongside that boss's playbook text. Optional per dungeon: `trashSegments`, the named trash packs between bosses — each has a `name`, the boss it follows (`after`, or null before the first), per-role calls, and the `npcs` involved, which drive the same 3D model panel. Write trash calls as `Mob Name — advice` so the UI can attribute each call to a mob when one is selected.

Both ID numbers come from [Mythic Dungeon Tools' dungeon data](https://github.com/Nnoggie/MythicDungeonTools) (`Midnight/<Dungeon>.lua`, where each enemy carries `id` and `displayId`), or from the boss's Wowhead page (npc ID is in the URL, display ID under "Screenshots/Modelviewer"). Leave an ID `null` rather than guessing — a wrong `displayID` renders the wrong creature in-game, and the panel simply hides when there is nothing to show.
2. Run `python3 tools/generate.py` from the `GuildPlaybook` folder (needs PyYAML). It validates the YAML and writes `Data/<Season>/<Dungeon>.lua`.
3. Add any **new** Data file to `GuildPlaybook.toc` (below `Core.lua`).
4. `/reload` in-game.

The generated `Data/` files are committed so players never need Python — only content editors run the generator.
