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

// Build-safe map lookup (import.meta.url is unreliable across compiled pages)
export function mapUrlFor(slug, baseUrl) {
  const file = path.resolve(process.cwd(), `public/maps/${slug}.webp`);
  return fs.existsSync(file) ? `${baseUrl}/maps/${slug}.webp` : null;
}

export function loadMdtSlugs() {
  if (!fs.existsSync(MDT_DIR)) return [];
  return fs.readdirSync(MDT_DIR)
    .filter((f) => f.endsWith(".json"))
    .map((f) => f.replace(/\.json$/, ""))
    .sort();
}

export function loadMdtData(slug) {
  const file = path.join(MDT_DIR, `${slug}.json`);
  if (!fs.existsSync(file)) return null;
  return JSON.parse(fs.readFileSync(file, "utf-8"));
}

// name -> spellID (or null for unresolved) from GuildPlaybook/content/abilities.yaml.
// Tolerant of the file not existing yet — prose markup then renders unlinked.
export function loadAbilities() {
  const file = path.join(CONTENT_DIR, "abilities.yaml");
  if (!fs.existsSync(file)) return new Map();
  const doc = yaml.load(fs.readFileSync(file, "utf-8"));
  return new Map((doc?.abilities ?? []).map((a) => [a.name, a.spellID ?? null]));
}
