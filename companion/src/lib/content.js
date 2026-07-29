import fs from "node:fs";
import path from "node:path";
import yaml from "js-yaml";

const CONTENT_DIR = path.resolve(process.cwd(), "../GuildPlaybook/content");
const MDT_DIR = path.resolve(process.cwd(), "src/data/mdt");

export function loadDungeons() {
  const out = [];
  for (const season of fs.readdirSync(CONTENT_DIR)) {
    const dir = path.join(CONTENT_DIR, season);
    if (!fs.statSync(dir).isDirectory()) continue;
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith(".yaml") && !file.endsWith(".yml")) continue;
      out.push(yaml.load(fs.readFileSync(path.join(dir, file), "utf-8")));
    }
  }
  return out.sort((a, b) => a.dungeon.localeCompare(b.dungeon));
}

export function loadMdtData(slug) {
  const file = path.join(MDT_DIR, `${slug}.json`);
  if (!fs.existsSync(file)) return null;
  return JSON.parse(fs.readFileSync(file, "utf-8"));
}
