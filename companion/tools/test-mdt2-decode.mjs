import { readdirSync, readFileSync } from "node:fs";
import { decodeMdtString, presetToRoute } from "../src/lib/mdt-decode.js";

// Real routes exported from live MDT2 strings — see tools/mdt2-vectors/.
// Expected values cross-checked against MDT's own Modules/Transmission.lua
// pipeline (base64 -> raw deflate -> CBOR) via Python's cbor2.
const EXPECTED = {
  "keystoneguru-altar-of-fangs": { dungeonIndex: 164, pullCount: 12 },
  "keystoneguru-den-of-nalorakk": { dungeonIndex: 161, pullCount: 13 },
  "keystoneguru-kings-rest": { dungeonIndex: 17, pullCount: 15 },
  "keystoneguru-murder-row": { dungeonIndex: 160, pullCount: 12 },
  "keystoneguru-ruby-life-pools": { dungeonIndex: 42, pullCount: 11 },
  "keystoneguru-temple-of-sethraliss": { dungeonIndex: 20, pullCount: 16 },
  "keystoneguru-the-blinding-vale": { dungeonIndex: 162, pullCount: 11 },
  "keystoneguru-voidscar-arena": { dungeonIndex: 163, pullCount: 11 },
};

const dir = new URL("./mdt2-vectors/", import.meta.url);
let failures = 0;

for (const file of readdirSync(dir).sort()) {
  const key = file.replace(/\.txt$/, "");
  const expected = EXPECTED[key];
  if (!expected) continue;
  const raw = readFileSync(new URL(file, dir), "utf-8");
  const preset = await decodeMdtString(raw);
  const route = presetToRoute(preset);
  const ok = route.dungeonIndex === expected.dungeonIndex && route.pulls.length === expected.pullCount;
  console.log(
    `${ok ? "ok  " : "FAIL"} ${key.padEnd(34)} dungeonIndex=${route.dungeonIndex} (exp ${expected.dungeonIndex})  pulls=${route.pulls.length} (exp ${expected.pullCount})`,
  );
  if (!ok) failures++;
  // sanity: every engaged enemy resolved at least one clone index (an empty
  // pull, e.g. a boss-room marker with only a color and no mobs, is valid)
  for (const pull of route.pulls) {
    for (const enemy of pull.enemies) {
      if (!enemy.clones.length) {
        console.log(`FAIL   ${key} pull ${pull.number} enemy ${enemy.enemyIndex} has no clones`);
        failures++;
      }
    }
  }
}

if (failures) {
  console.log(`\n${failures} FAILURE(S)`);
  process.exit(1);
}
console.log("\nALL PASS — MDT2/CBOR decoder matches expected values for all live routes");
