# Guild Playbook

Guild-curated Mythic+ tactics, shown in-game and filtered to your role. Content comes from the guild's playbook PDFs, converted to YAML and compiled into the addon as static Lua data — fully compatible with the Midnight addon restrictions, since it only reads non-secret signals (zone, encounter start/end, your own role).

## Install (manual, for now)

Copy the `GuildPlaybook` folder into `World of Warcraft/_retail_/Interface/AddOns/`. The folder must contain `GuildPlaybook.toc` at its top level. Restart the client or `/reload`.

## Use

- `/gp` — toggle the panel. It auto-loads the playbook when you enter a covered dungeon and jumps to the boss page on pull (`ENCOUNTER_START`), back to the overview after the fight.
- `/gp tank` / `/gp healer` / `/gp dps` — force a role view; `/gp auto` follows your assigned role again. Role tabs in the panel do the same.
- `/gp ids` — capture mode: prints the zone's `instanceID` and each boss's `encounterID` to chat so they can be filled into the YAML (needed once per dungeon; the reworked Midnight IDs aren't documented yet).
- `/gp list` — show loaded playbooks.

## Editing content

1. Edit or add a YAML file under `content/<season>/` — one file per dungeon. Follow the structure of `content/midnight-s1/magisters-terrace.yaml`: a per-role dungeon overview plus one entry per boss with `job` / `avoid` / `defensive` (healers: `cooldowns`) / `reminder` lists per role and a shared `wipe` list.
2. Run `python3 tools/generate.py` from the `GuildPlaybook` folder (needs PyYAML). It validates the YAML and writes `Data/<Season>/<Dungeon>.lua`.
3. Add any **new** Data file to `GuildPlaybook.toc` (below `Core.lua`).
4. `/reload` in-game.

The generated `Data/` files are committed so players never need Python — only content editors run the generator.
