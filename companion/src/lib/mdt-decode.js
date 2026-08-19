// Decoder for Mythic Dungeon Tools export strings.
//
// Two formats are in the wild:
//
// Legacy (MDT Modules/Transmission.lua, pre-"MDT2"):
//   "!" .. LibDeflate:EncodeForPrint( LibDeflate:CompressDeflate( AceSerializer:Serialize(preset) ) )
//
//   EncodeForPrint uses a custom 64-char alphabet with little-endian 6-bit
//   packing (NOT base64 bit order). CompressDeflate emits raw DEFLATE, which
//   maps to the browser-native DecompressionStream("deflate-raw").
//   AceSerializer is a text format: "^1" header, "^S/^N/^F^f/^B/^b/^Z/^T…^t"
//   typed tokens, "^^" terminator.
//
// Current ("MDT2", every route we ship now uses this):
//   "!~MDT2~" .. Base64( RawDeflate( CBOR(preset) ) )
//
//   Standard base64 (not LibDeflate's alphabet), raw DEFLATE (same
//   deflate-raw as above), then CBOR (RFC 8949) instead of AceSerializer.
//   Lua doesn't distinguish binary from text, so the Lua-side CBOR encoder
//   writes every string — map keys included — as a CBOR byte string (major
//   type 2); we decode those as UTF-8 on the way out.

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

// --- standard base64 (MDT2 uses the normal alphabet, not LibDeflate's) -----

const B64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
const B64_VALUE = new Map([...B64_ALPHABET].map((c, i) => [c, i]));

// Tolerant of missing "=" padding — MDT2 strings omit it.
export function decodeBase64(str) {
  const clean = str.replace(/\s+/g, "").replace(/=+$/, "");
  const vals = [];
  for (const ch of clean) {
    const v = B64_VALUE.get(ch);
    if (v === undefined) throw new Error(`invalid character ${JSON.stringify(ch)} in base64 data`);
    vals.push(v);
  }
  const bytes = [];
  let i = 0;
  // 4 chars -> 24-bit big-endian group -> 3 bytes
  for (; i + 4 <= vals.length; i += 4) {
    const n = (vals[i] << 18) | (vals[i + 1] << 12) | (vals[i + 2] << 6) | vals[i + 3];
    bytes.push((n >>> 16) & 255, (n >>> 8) & 255, n & 255);
  }
  const rem = vals.length - i;
  if (rem === 1) throw new Error("truncated base64 data");
  if (rem === 2) {
    const n = (vals[i] << 18) | (vals[i + 1] << 12);
    bytes.push((n >>> 16) & 255);
  } else if (rem === 3) {
    const n = (vals[i] << 18) | (vals[i + 1] << 12) | (vals[i + 2] << 6);
    bytes.push((n >>> 16) & 255, (n >>> 8) & 255);
  }
  return new Uint8Array(bytes);
}

// --- CBOR (RFC 8949) — subset MDT2 emits: maps, arrays, ints, byte/text ----
// --- strings, bools, null and floats. No self-describing tag or bignum.  --

function halfFloatToNumber(bits) {
  const sign = bits & 0x8000 ? -1 : 1;
  const exponent = (bits >> 10) & 0x1f;
  const fraction = bits & 0x03ff;
  if (exponent === 0) return sign * 2 ** -14 * (fraction / 1024);
  if (exponent === 0x1f) return fraction ? NaN : sign * Infinity;
  return sign * 2 ** (exponent - 15) * (1 + fraction / 1024);
}

// Lua strings arrive as raw bytes (major type 2 or 3, treated the same);
// decode as UTF-8 and fall back to a lossy latin1 string rather than throw.
function cborBytesToString(raw) {
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(raw);
  } catch {
    return String.fromCharCode(...raw);
  }
}

function makeCborReader(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let pos = 0;

  function need(n) {
    if (pos + n > bytes.length) throw new Error("truncated CBOR data");
  }

  // additional-info -> length/value, per RFC 8949 §3
  function readArgument(info) {
    if (info < 24) return info;
    if (info === 24) { need(1); return bytes[pos++]; }
    if (info === 25) { const v = view.getUint16(pos); pos += 2; return v; }
    if (info === 26) { const v = view.getUint32(pos); pos += 4; return v; }
    if (info === 27) {
      const v = view.getBigUint64(pos);
      pos += 8;
      return v <= BigInt(Number.MAX_SAFE_INTEGER) ? Number(v) : v;
    }
    throw new Error(`unsupported CBOR length encoding (info=${info})`);
  }

  function readRawBytes(len) {
    need(len);
    const out = bytes.subarray(pos, pos + len);
    pos += len;
    return out;
  }

  // definite or indefinite-length byte/text string -> raw bytes
  function readStringBytes(info) {
    if (info !== 31) return readRawBytes(readArgument(info));
    const chunks = [];
    for (;;) {
      need(1);
      if (bytes[pos] === 0xff) { pos++; break; }
      const chunkHead = bytes[pos++];
      const chunkMajor = chunkHead >> 5;
      if (chunkMajor !== 2 && chunkMajor !== 3) throw new Error("indefinite-length string with non-string chunk");
      chunks.push(readRawBytes(readArgument(chunkHead & 0x1f)));
    }
    const total = chunks.reduce((n, c) => n + c.length, 0);
    const out = new Uint8Array(total);
    let o = 0;
    for (const c of chunks) { out.set(c, o); o += c.length; }
    return out;
  }

  function readValue() {
    need(1);
    const head = bytes[pos++];
    const major = head >> 5;
    const info = head & 0x1f;

    switch (major) {
      case 0: return readArgument(info);
      case 1: {
        const v = readArgument(info);
        return typeof v === "bigint" ? -1n - v : -1 - v;
      }
      case 2: // byte string
      case 3: // text string — Lua's encoder doesn't reliably distinguish; treat the same
        return cborBytesToString(readStringBytes(info));
      case 4: { // array
        const arr = [];
        if (info === 31) {
          for (need(1); bytes[pos] !== 0xff; need(1)) arr.push(readValue());
          pos++;
        } else {
          const len = readArgument(info);
          for (let i = 0; i < len; i++) arr.push(readValue());
        }
        return arr;
      }
      case 5: { // map
        const obj = {};
        const readEntry = () => { const key = readValue(); obj[key] = readValue(); };
        if (info === 31) {
          for (need(1); bytes[pos] !== 0xff; need(1)) readEntry();
          pos++;
        } else {
          const len = readArgument(info);
          for (let i = 0; i < len; i++) readEntry();
        }
        return obj;
      }
      case 6: // tag — semantics unused by MDT, decode and return the tagged value
        readArgument(info);
        return readValue();
      case 7:
        switch (info) {
          case 20: return false;
          case 21: return true;
          case 22: return null;      // null
          case 23: return null;      // undefined
          case 24: need(1); pos++; return null; // simple(n), unused by MDT
          case 25: { const v = halfFloatToNumber(view.getUint16(pos)); pos += 2; return v; }
          case 26: { const v = view.getFloat32(pos); pos += 4; return v; }
          case 27: { const v = view.getFloat64(pos); pos += 8; return v; }
          default: throw new Error(`unsupported CBOR simple value (info=${info})`);
        }
      default:
        throw new Error(`unsupported CBOR major type ${major}`);
    }
  }

  return { readValue };
}

export function decodeCbor(bytes) {
  return makeCborReader(bytes).readValue();
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

const MDT2_PREFIX = "!~MDT2~";

export async function decodeMdtString(exportString) {
  const trimmed = exportString.trim();

  if (trimmed.startsWith(MDT2_PREFIX)) {
    const compressed = decodeBase64(trimmed.slice(MDT2_PREFIX.length));
    const serialized = await inflateRaw(compressed);
    const preset = decodeCbor(serialized);
    if (!preset || typeof preset !== "object") throw new Error("decoded data is not an MDT preset");
    return preset;
  }

  if (trimmed.startsWith("!")) {
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

  throw new Error(`Not a recognised MDT export string (expected it to start with "!" or "${MDT2_PREFIX}").`);
}

// Normalise a decoded preset into a render-friendly route model.
// `value.pulls` is an object keyed by pull number in the legacy AceSerializer
// format, and a plain array (in pull order) in MDT2/CBOR — handle both.
export function presetToRoute(preset) {
  const value = preset.value ?? {};
  const rawPulls = value.pulls ?? {};
  const pullEntries = Array.isArray(rawPulls)
    ? rawPulls.map((pull, i) => [i + 1, pull])
    : Object.keys(rawPulls)
        .filter((k) => /^\d+$/.test(k))
        .sort((a, b) => Number(a) - Number(b))
        .map((k) => [Number(k), rawPulls[k]]);
  const pulls = pullEntries.map(([number, pull]) => {
    const enemies = Object.keys(pull)
      .filter((ek) => /^\d+$/.test(ek))
      .map((ek) => ({
        enemyIndex: Number(ek),
        clones: Object.values(pull[ek]).filter((v) => typeof v === "number"),
      }));
    return { number, color: typeof pull.color === "string" ? pull.color : null, enemies };
  });
  return {
    name: typeof preset.text === "string" ? preset.text : "Unnamed route",
    week: preset.week ?? null,
    difficulty: preset.difficulty ?? null,
    dungeonIndex: value.currentDungeonIdx ?? null,
    pulls,
  };
}
