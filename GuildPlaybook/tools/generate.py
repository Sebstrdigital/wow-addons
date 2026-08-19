#!/usr/bin/env python3
"""Compile Guild Playbook YAML content into static Lua data files.

Usage:  python3 tools/generate.py          (run from the GuildPlaybook directory)

Reads   content/<season>/<dungeon>.yaml
Writes  Data/<SeasonPascal>/<DungeonPascal>.lua

Also reads   content/abilities.yaml
Also writes  Data/Abilities.lua   (a single shared name -> spellID lookup)

The generated files call ns.RegisterDungeon(...) which Core.lua defines,
so every Data file must be listed in the TOC after Core.lua.
"""

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML required: pip3 install pyyaml")

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
DATA = ROOT / "Data"

ROLES = ("TANK", "HEALER", "DPS")
ROLE_SECTIONS = ("job", "avoid", "defensive", "cooldowns", "reminder")

# Anything not listed here is a typo. A misspelled key used to survive
# generation and then be silently ignored by the Lua side, which lost a whole
# feature for that dungeon without a single error anywhere.
TOP_LEVEL_KEYS = (
    "dungeon", "slug", "season", "patch", "sourceVersion", "instanceID",
    "quicksheet", "overview", "bosses", "minibosses", "trashSegments",
    "mdtRoutes",
)
MDT_ROUTE_KEYS = ("name", "string")
SEGMENT_KEYS = ("name", "after", "npcs", "roles")
BOSS_KEYS = ("name", "roles", "sheet", "wipe", "encounterID", "npcID", "displayID", "adds")
ABILITY_KEYS = ("name", "spellID", "caster")


def fail(msg):
    sys.exit(f"error: {msg}")


def validate_overview(o, path, abilities):
    def want_str_list(val, name):
        if val is None:
            return
        if not isinstance(val, list) or not all(isinstance(x, str) for x in val):
            fail(f"{path}: overview.{name} must be a list of strings")
    tip = o.get("tip")
    if tip is not None and not isinstance(tip, str):
        if not (isinstance(tip, list) and all(isinstance(x, str) for x in tip)):
            fail(f"{path}: overview.tip must be a string or a list of strings")
    ints = o.get("interrupts")
    if ints is not None:
        if not isinstance(ints, list) or not all(isinstance(x, dict) and isinstance(x.get("spell"), str) for x in ints):
            fail(f"{path}: overview.interrupts must be a list of {{spell, note}} entries")
        # interrupts[].spell is a bare ability name, not "[Ability Name]"
        # markup, so it never passes through validate_ability_refs' bracket
        # scan below. Without this check a bad name here silently ships with
        # no tooltip instead of failing the build.
        for i, it in enumerate(ints):
            spell = it.get("spell")
            if spell not in abilities:
                fail(f"{path}: overview.interrupts[{i}].spell: unknown ability '{spell}' — "
                     f"add '{spell}' to content/abilities.yaml")
    want_str_list(o.get("killPriority"), "killPriority")
    for role, keys in (("tank", ("damage", "pullWarnings")),
                       ("healer", ("dispels", "pressure", "pullWarnings")),
                       ("dps", ("purges", "defensives", "pullWarnings"))):
        block = o.get(role)
        if block is None:
            continue
        if not isinstance(block, dict):
            fail(f"{path}: overview.{role} must be a mapping")
        for k in block:
            if k not in keys:
                fail(f"{path}: unknown key overview.{role}.{k}")
            want_str_list(block[k], f"{role}.{k}")


def validate_quicksheet(doc, path):
    qs = doc.get("quicksheet")
    if qs is not None:
        trash = qs.get("trash")
        if trash is not None:
            for k, v in trash.items():
                if k not in ("TANK", "HEALER", "DPS", "ROUTE") or not isinstance(v, str):
                    fail(f"{path}: quicksheet.trash keys must be TANK/HEALER/DPS/ROUTE with string values (got {k})")
    for boss in doc.get("bosses", []) + doc.get("minibosses", []):
        sheet = boss.get("sheet")
        if sheet is not None:
            for k, v in sheet.items():
                if k not in ("TANK", "HEALER", "DPS", "WIPE") or not isinstance(v, str):
                    fail(f"{path}: {boss.get('name')}: sheet keys must be TANK/HEALER/DPS/WIPE with string values (got {k})")


def validate_npcs(npcs, where):
    if npcs is None:
        return
    if not isinstance(npcs, list):
        fail(f"{where}: 'npcs' must be a list")
    for j, npc in enumerate(npcs, 1):
        if not isinstance(npc, dict):
            fail(f"{where}: npcs #{j} must be a mapping")
        name = npc.get("name")
        if not isinstance(name, str) or not name.strip():
            fail(f"{where}: npcs #{j} 'name' must be a non-empty string")
        for key in npc:
            if key not in ("name", "npcID", "displayID"):
                fail(f"{where}: npcs '{name}': unknown key '{key}' (use name/npcID/displayID)")
        for key in ("npcID", "displayID"):
            val = npc.get(key)
            # Most trash IDs are still unknown, so null is the expected state:
            # names are authored now and the IDs backfilled later.
            if val is None:
                continue
            if isinstance(val, bool) or not isinstance(val, int) or val <= 0:
                fail(f"{where}: npcs '{name}': {key} must be null or a positive integer (got {val!r})")


def validate_trash_segments(doc, path):
    segments = doc.get("trashSegments")
    if segments is None:
        return
    if not isinstance(segments, list):
        fail(f"{path}: trashSegments must be a list")
    boss_names = [b.get("name") for b in doc.get("bosses", [])]
    for i, seg in enumerate(segments, 1):
        where = f"{path}: trashSegments #{i}"
        if not isinstance(seg, dict):
            fail(f"{where}: must be a mapping")
        name = seg.get("name")
        if not isinstance(name, str) or not name.strip():
            fail(f"{where}: 'name' must be a non-empty string")
        where = f"{path}: trashSegments '{name}'"
        for key in seg:
            if key not in SEGMENT_KEYS:
                fail(f"{where}: unknown key '{key}' (use {'/'.join(SEGMENT_KEYS)})")
        after = seg.get("after")
        if after is not None:
            if not isinstance(after, str):
                fail(f"{where}: 'after' must be a string or null (got {after!r})")
            if after not in boss_names:
                fail(f"{where}: 'after' is {after!r}, which is not a boss in this file "
                     f"(valid: {', '.join(repr(n) for n in boss_names)})")
        validate_npcs(seg.get("npcs"), where)
        roles = seg.get("roles")
        if roles is None:
            continue
        if not isinstance(roles, dict):
            fail(f"{where}: 'roles' must be a mapping")
        for role, calls in roles.items():
            if role not in ROLES:
                fail(f"{where}: unknown role '{role}' (use {'/'.join(ROLES)})")
            if not isinstance(calls, list) or not calls:
                fail(f"{where} {role}: must be a non-empty list of strings")
            for call in calls:
                if not isinstance(call, str) or not call.strip():
                    fail(f"{where} {role}: every call must be a non-empty string (got {call!r})")


def validate_mdt_routes(doc, path):
    routes = doc.get("mdtRoutes")
    if routes is None:
        return
    if not isinstance(routes, list):
        fail(f"{path}: mdtRoutes must be a list")
    for i, route in enumerate(routes, 1):
        where = f"{path}: mdtRoutes #{i}"
        if not isinstance(route, dict):
            fail(f"{where}: must be a mapping")
        for key in route:
            if key not in MDT_ROUTE_KEYS:
                fail(f"{where}: unknown key '{key}' (use {'/'.join(MDT_ROUTE_KEYS)})")
        name = route.get("name")
        if not isinstance(name, str) or not name.strip():
            fail(f"{where}: 'name' must be a non-empty string")
        string = route.get("string")
        if not isinstance(string, str) or not string.strip():
            fail(f"{where} ({name!r}): 'string' must be a non-empty string")
        # MDT's own export alphabet is printable ASCII. lua_str() rewrites
        # "→" to ">" for prose, which would silently corrupt a route string
        # containing one — reject non-ASCII/control characters here instead
        # of teaching lua_str a data-specific exception.
        elif not all(0x20 <= ord(c) <= 0x7E for c in string):
            fail(f"{where} ({name!r}): 'string' must be printable ASCII (MDT export strings are ASCII-only)")


def validate_abilities(doc, path):
    if not isinstance(doc, dict) or "abilities" not in doc:
        fail(f"{path}: document must be a mapping with an 'abilities' key")
    entries = doc["abilities"]
    if not isinstance(entries, list):
        fail(f"{path}: 'abilities' must be a list")
    abilities = {}
    for i, entry in enumerate(entries, 1):
        where = f"{path}: abilities #{i}"
        if not isinstance(entry, dict):
            fail(f"{where}: must be a mapping")
        for key in entry:
            if key not in ABILITY_KEYS:
                fail(f"{where}: unknown key '{key}' (use {'/'.join(ABILITY_KEYS)})")
        name = entry.get("name")
        if not isinstance(name, str) or not name.strip():
            fail(f"{where}: 'name' must be a non-empty string")
        where = f"{path}: abilities '{name}'"
        if name in abilities:
            fail(f"{where}: duplicate ability name")
        spell_id = entry.get("spellID")
        if spell_id is not None and (isinstance(spell_id, bool) or not isinstance(spell_id, int) or spell_id <= 0):
            fail(f"{where}: spellID must be null or a positive integer (got {spell_id!r})")
        caster = entry.get("caster")
        if caster is not None and not isinstance(caster, str):
            fail(f"{where}: caster must be a string or null (got {caster!r})")
        abilities[name] = entry
    return abilities


def load_abilities():
    path = CONTENT / "abilities.yaml"
    rel = path.relative_to(ROOT)
    if not path.exists():
        fail(f"{rel}: file not found (required — it defines every [Ability Name] reference)")
    doc = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    return validate_abilities(doc, rel)


def _bracket_spans(s):
    # Returns (spans, error): spans is the list of inner texts found inside
    # [Ability Name] markup; error is a short description if the brackets in
    # this string are nested or unbalanced.
    spans = []
    depth = 0
    start = None
    for i, ch in enumerate(s):
        if ch == "[":
            if depth > 0:
                return None, f"nested '[' at position {i}"
            depth = 1
            start = i + 1
        elif ch == "]":
            if depth == 0:
                return None, f"unmatched ']' at position {i}"
            depth = 0
            spans.append(s[start:i])
    if depth != 0:
        return None, "unmatched '[' (missing closing ']')"
    return spans, None


def validate_ability_refs(node, path, abilities, where=""):
    # Walks every string in the document looking for [Ability Name] markup.
    # mdtRoutes is skipped entirely — it's an opaque MDT export blob (already
    # constrained to printable ASCII by validate_mdt_routes), never prose.
    if isinstance(node, dict):
        for k, v in node.items():
            if k == "mdtRoutes":
                continue
            validate_ability_refs(v, path, abilities, f"{where}.{k}" if where else k)
    elif isinstance(node, list):
        for i, item in enumerate(node):
            validate_ability_refs(item, path, abilities, f"{where}[{i}]")
    elif isinstance(node, str):
        spans, err = _bracket_spans(node)
        if err:
            fail(f"{path}: {where}: {err} (in {node!r})")
        for name in spans:
            if name not in abilities:
                fail(f"{path}: {where}: unknown ability '[{name}]' — "
                     f"add '{name}' to content/abilities.yaml (in {node!r})")


def validate(doc, path, abilities):
    if not isinstance(doc, dict):
        fail(f"{path}: document must be a mapping (got {type(doc).__name__})")
    for key in ("dungeon", "slug", "season", "overview", "bosses"):
        if key not in doc:
            fail(f"{path}: missing top-level key '{key}'")
    for key in doc:
        if key not in TOP_LEVEL_KEYS:
            fail(f"{path}: unknown top-level key '{key}' "
                 f"(valid: {', '.join(TOP_LEVEL_KEYS)})")
    validate_overview(doc.get("overview") or {}, path, abilities)
    validate_quicksheet(doc, path)
    validate_trash_segments(doc, path)
    validate_mdt_routes(doc, path)
    for i, boss in enumerate(doc["bosses"] + doc.get("minibosses", []), 1):
        where = f"{path}: boss/miniboss #{i}"
        if "name" not in boss:
            fail(f"{where}: missing 'name'")
        for key in boss:
            if key not in BOSS_KEYS:
                fail(f"{where} ({boss['name']}): unknown key '{key}' (use {'/'.join(BOSS_KEYS)})")
        if "roles" not in boss:
            fail(f"{where} ({boss['name']}): missing 'roles'")
        validate_npcs(boss.get("adds"), f"{where} ({boss['name']})")
        for role, body in boss["roles"].items():
            if role not in ROLES:
                fail(f"{where} ({boss['name']}): unknown role '{role}' (use {'/'.join(ROLES)})")
            for section in body:
                if section not in ROLE_SECTIONS:
                    fail(f"{where} ({boss['name']}) {role}: unknown section '{section}'")
            if "reminder" not in body:
                fail(f"{where} ({boss['name']}) {role}: missing 'reminder' (the TLDR line)")
    validate_ability_refs(doc, path, abilities)


def lua_str(s):
    # WoW's default fonts have no glyph for "→" (renders as a box) — keep
    # arrows in the YAML for readability, ship ">" in-game.
    s = str(s).replace("→", ">")
    s = s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r")
    return f'"{s}"'


def lua_value(v, indent):
    pad = "  " * indent
    if v is None:
        return "nil"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, str):
        return lua_str(v)
    if isinstance(v, list):
        if not v:
            return "{}"
        items = ",\n".join(f"{pad}  {lua_value(x, indent + 1)}" for x in v)
        return "{\n" + items + f",\n{pad}}}"
    if isinstance(v, dict):
        if not v:
            return "{}"
        items = ",\n".join(
            f'{pad}  ["{k}"] = {lua_value(x, indent + 1)}' for k, x in v.items()
        )
        return "{\n" + items + f",\n{pad}}}"
    fail(f"unsupported YAML value type: {type(v)}")


def pascal(slug):
    return "".join(part.capitalize() for part in slug.replace("_", "-").split("-"))


def emit_abilities_file(abilities):
    # A single shared lookup so the UI can resolve [Ability Name] markup to a
    # spellID at render time: ns.ABILITIES["Blaze Volley"] = 373017. Interface
    # frozen by the team lead — plain name -> spellID map. Unresolved
    # abilities (spellID: null) are omitted entirely rather than emitted as
    # nil/false/0, so the UI's "no tooltip" check is a plain missing-key test.
    # caster is intentionally not emitted (the real spell tooltip covers it).
    lookup = {name: entry["spellID"] for name, entry in abilities.items() if entry.get("spellID") is not None}
    DATA.mkdir(parents=True, exist_ok=True)
    out = DATA / "Abilities.lua"
    body = lua_value(lookup, 0)
    out.write_text(
        "-- GENERATED FILE — do not edit by hand.\n"
        "-- Source: content/abilities.yaml   (regenerate with tools/generate.py)\n"
        "local _, ns = ...\n\n"
        f"ns.ABILITIES = {body}\n",
        encoding="utf-8",
    )
    print(f"wrote {out.relative_to(ROOT)}")
    return out


def generate(src, abilities):
    doc = yaml.safe_load(src.read_text(encoding="utf-8"))
    validate(doc, src.relative_to(ROOT), abilities)

    out_dir = DATA / pascal(doc["season"])
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{pascal(doc['slug'])}.lua"

    body = lua_value(doc, 0)
    out.write_text(
        "-- GENERATED FILE — do not edit by hand.\n"
        f"-- Source: content/{doc['season']}/{src.name}   (regenerate with tools/generate.py)\n"
        "local _, ns = ...\n\n"
        f"ns.RegisterDungeon({body})\n",
        encoding="utf-8",
    )
    print(f"wrote {out.relative_to(ROOT)}")
    return out


def main():
    abilities = load_abilities()
    emit_abilities_file(abilities)
    sources = sorted(CONTENT.glob("*/*.yaml"))
    if not sources:
        fail(f"no YAML files found under {CONTENT}")
    for src in sources:
        generate(src, abilities)
    print(f"{len(sources)} dungeon(s) generated. Remember: Data files must be listed in the TOC.")


if __name__ == "__main__":
    main()
