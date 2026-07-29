#!/usr/bin/env python3
"""Compile Guild Playbook YAML content into static Lua data files.

Usage:  python3 tools/generate.py          (run from the GuildPlaybook directory)

Reads   content/<season>/<dungeon>.yaml
Writes  Data/<SeasonPascal>/<DungeonPascal>.lua

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


def fail(msg):
    sys.exit(f"error: {msg}")


def validate(doc, path):
    for key in ("dungeon", "slug", "season", "overview", "bosses"):
        if key not in doc:
            fail(f"{path}: missing top-level key '{key}'")
    for i, boss in enumerate(doc["bosses"] + doc.get("minibosses", []), 1):
        where = f"{path}: boss/miniboss #{i}"
        if "name" not in boss:
            fail(f"{where}: missing 'name'")
        if "roles" not in boss:
            fail(f"{where} ({boss['name']}): missing 'roles'")
        for role, body in boss["roles"].items():
            if role not in ROLES:
                fail(f"{where} ({boss['name']}): unknown role '{role}' (use {'/'.join(ROLES)})")
            for section in body:
                if section not in ROLE_SECTIONS:
                    fail(f"{where} ({boss['name']}) {role}: unknown section '{section}'")
            if "reminder" not in body:
                fail(f"{where} ({boss['name']}) {role}: missing 'reminder' (the TLDR line)")


def lua_str(s):
    # WoW's default fonts have no glyph for "→" (renders as a box) — keep
    # arrows in the YAML for readability, ship ">" in-game.
    s = str(s).replace("→", ">")
    s = s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
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


def generate(src):
    doc = yaml.safe_load(src.read_text(encoding="utf-8"))
    validate(doc, src.relative_to(ROOT))

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
    sources = sorted(CONTENT.glob("*/*.yaml"))
    if not sources:
        fail(f"no YAML files found under {CONTENT}")
    for src in sources:
        generate(src)
    print(f"{len(sources)} dungeon(s) generated. Remember: Data files must be listed in the TOC.")


if __name__ == "__main__":
    main()
