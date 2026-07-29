// Decoder for Mythic Dungeon Tools export strings.
//
// Format (MDT Modules/Transmission.lua):
//   "!" .. LibDeflate:EncodeForPrint( LibDeflate:CompressDeflate( AceSerializer:Serialize(preset) ) )
//
// EncodeForPrint uses a custom 64-char alphabet with little-endian 6-bit
// packing (NOT base64 bit order). CompressDeflate emits raw DEFLATE, which
// maps to the browser-native DecompressionStream("deflate-raw").
// AceSerializer is a text format: "^1" header, "^S/^N/^F^f/^B/^b/^Z/^T…^t"
// typed tokens, "^^" terminator.

const ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()";
const CHAR_VALUE = new Map([...ALPHABET].map((c, i) => [c, i]));

export function decodeForPrint(str) {
  str = str.replace(/^[\x00-\x20]+/, "").replace(/[\x00-\x20]+$/, "");
  const vals = [];
  for (const ch of str) {
    const v = CHAR_VALUE.get(ch);
    if (v === undefined) throw new Error(`invalid character ${JSON.stringify(ch)} in export string`);
    vals.push(v);
  }
  const bytes = [];
  let i = 0;
  // 4 chars -> 24-bit little-endian group -> 3 bytes
  for (; i + 4 <= vals.length; i += 4) {
    const cache = vals[i] + vals[i + 1] * 64 + vals[i + 2] * 4096 + vals[i + 3] * 262144;
    bytes.push(cache & 255, (cache >>> 8) & 255, (cache >>> 16) & 255);
  }
  // trailing chars: accumulate 6 bits at a time, emit whole bytes
  let cache = 0;
  let bitlen = 0;
  for (; i < vals.length; i++) {
    cache += vals[i] * 2 ** bitlen;
    bitlen += 6;
  }
  while (bitlen >= 8) {
    bytes.push(cache % 256);
    cache = Math.floor(cache / 256);
    bitlen -= 8;
  }
  return new Uint8Array(bytes);
}

export async function inflateRaw(bytes) {
  const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream("deflate-raw"));
  return new Uint8Array(await new Response(stream).arrayBuffer());
}

// --- AceSerializer ---------------------------------------------------------

function unescapeAceString(latin1) {
  const out = latin1.replace(/~(.)/g, (_, c) => {
    const n = c.charCodeAt(0);
    if (n === 0x7a) return "\x1e"; // "~z" -> \030 (special-cased: 30+64 would be "^")
    if (n === 0x7b) return "\x7f"; // "~{" -> DEL
    if (n === 0x7c) return "~";    // "~|" -> ~
    if (n === 0x7d) return "^";    // "~}" -> ^
    return String.fromCharCode(n - 64); // nonprints + space
  });
  // latin1 char codes are raw bytes; re-decode as UTF-8 for display strings
  const raw = Uint8Array.from(out, (ch) => ch.charCodeAt(0));
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(raw);
  } catch {
    return out;
  }
}

function parseAceNumber(data) {
  if (data === "1.#INF" || data === "inf") return Infinity;
  if (data === "-1.#INF" || data === "-inf") return -Infinity;
  const n = Number(data);
  if (Number.isNaN(n)) throw new Error(`bad number token: ${data}`);
  return n;
}

export function deserializeAce(latin1) {
  const tokens = [...latin1.matchAll(/\^(.)([^^]*)/gs)].map((m) => ({ ctl: m[1], data: m[2] }));
  if (!tokens.length || tokens[0].ctl !== "1") throw new Error("not an AceSerializer string");
  let pos = 1;

  function readValue() {
    if (pos >= tokens.length) throw new Error("unexpected end of data");
    const { ctl, data } = tokens[pos++];
    switch (ctl) {
      case "S": return unescapeAceString(data);
      case "N": return parseAceNumber(data);
      case "F": {
        const next = tokens[pos++];
        if (!next || next.ctl !== "f") throw new Error("^F without ^f");
        return Number(data) * 2 ** Number(next.data);
      }
      case "B": return true;
      case "b": return false;
      case "Z": return null;
      case "T": {
        const obj = {};
        for (;;) {
          if (tokens[pos]?.ctl === "t") { pos++; return obj; }
          const key = readValue();
          obj[key] = readValue();
        }
      }
      default: throw new Error(`unknown token ^${ctl}`);
    }
  }

  const values = [];
  while (pos < tokens.length && tokens[pos].ctl !== "^") values.push(readValue());
  return values;
}

// --- top level -------------------------------------------------------------

export async function decodeMdtString(exportString) {
  const trimmed = exportString.trim();
  if (!trimmed.startsWith("!")) {
    throw new Error("Unsupported (legacy) export string — re-export from a current MDT version.");
  }
  const compressed = decodeForPrint(trimmed.slice(1));
  const serialized = await inflateRaw(compressed);
  // AceSerializer output is a byte string; keep bytes as latin1 chars for parsing
  let latin1 = "";
  const CHUNK = 0x8000;
  for (let i = 0; i < serialized.length; i += CHUNK) {
    latin1 += String.fromCharCode(...serialized.subarray(i, i + CHUNK));
  }
  const [preset] = deserializeAce(latin1);
  if (!preset || typeof preset !== "object") throw new Error("decoded data is not an MDT preset");
  return preset;
}

// Normalise a decoded preset into a render-friendly route model.
export function presetToRoute(preset) {
  const value = preset.value ?? {};
  const rawPulls = value.pulls ?? {};
  const pulls = Object.keys(rawPulls)
    .filter((k) => /^\d+$/.test(k))
    .sort((a, b) => Number(a) - Number(b))
    .map((k) => {
      const pull = rawPulls[k];
      const enemies = Object.keys(pull)
        .filter((ek) => /^\d+$/.test(ek))
        .map((ek) => ({
          enemyIndex: Number(ek),
          clones: Object.values(pull[ek]).filter((v) => typeof v === "number"),
        }));
      return { number: Number(k), color: typeof pull.color === "string" ? pull.color : null, enemies };
    });
  return {
    name: typeof preset.text === "string" ? preset.text : "Unnamed route",
    week: preset.week ?? null,
    difficulty: preset.difficulty ?? null,
    dungeonIndex: value.currentDungeonIdx ?? null,
    pulls,
  };
}
