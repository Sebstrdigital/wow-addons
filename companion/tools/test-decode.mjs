import { readFileSync } from "node:fs";
import { decodeMdtString, presetToRoute } from "../src/lib/mdt-decode.js";

const vector = readFileSync(new URL("./test-vector.txt", import.meta.url), "utf-8");
const preset = await decodeMdtString(vector);
const route = presetToRoute(preset);

function assertEq(actual, expected, label) {
  const a = JSON.stringify(actual), e = JSON.stringify(expected);
  if (a !== e) throw new Error(`FAIL ${label}: got ${a}, expected ${e}`);
  console.log(`ok  ${label} = ${e}`);
}

assertEq(route.name, "Test Route åäö", "name (incl. UTF-8)");
assertEq(route.week, 1, "week");
assertEq(route.difficulty, 10, "difficulty");
assertEq(route.dungeonIndex, 153, "dungeonIndex");
assertEq(route.pulls.length, 3, "pull count");
assertEq(route.pulls[0].enemies.find(e => e.enemyIndex === 3)?.clones, [1, 2], "pull1 enemy3 clones");
assertEq(route.pulls[0].enemies.find(e => e.enemyIndex === 5)?.clones, [1], "pull1 enemy5 clones");
assertEq(route.pulls[0].color, "ff3465a4", "pull1 color");
assertEq(route.pulls[1].enemies[0].clones, [1, 4, 5], "pull2 enemy11 clones");
assertEq(route.pulls[2].enemies[0].enemyIndex, 1, "pull3 enemy index");
console.log("\nALL PASS — decoder matches MDT's own libraries");
