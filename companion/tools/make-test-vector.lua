-- Generate an authentic MDT export string using MDT's own bundled libraries.
-- Usage: lua make-test-vector.lua <mdt-libs-dir> <out-string-file>
local libsDir, outPath = arg[1], arg[2]

-- Lua 5.4 removed math.frexp/ldexp; AceSerializer needs them.
if not math.frexp then
  math.frexp = function(x)
    if x == 0 then return 0, 0 end
    local e = math.floor(math.log(math.abs(x), 2)) + 1
    local m = x / 2 ^ e
    -- normalise into [0.5, 1)
    while math.abs(m) >= 1 do m = m / 2; e = e + 1 end
    while math.abs(m) < 0.5 do m = m * 2; e = e - 1 end
    return m, e
  end
end
if not math.ldexp then math.ldexp = function(m, e) return m * 2 ^ e end end
-- WoW string helpers AceSerializer expects
strjoin = function(sep, ...) return table.concat({ ... }, sep) end
strmatch, strfind, strrep, strlen = string.match, string.find, string.rep, string.len
strlower, strupper, strtrim = string.lower, string.upper, function(s) return s:match("^%s*(.-)%s*$") end
strchar, strbyte, strsub, gsub, format = string.char, string.byte, string.sub, string.gsub, string.format
tostringall = function(...) local t = {} for i = 1, select("#", ...) do t[i] = tostring(select(i, ...)) end return table.unpack(t) end
strsplit = function(sep, s) local out = {} for piece in (s..sep):gmatch("(.-)"..sep:gsub("%W","%%%1")) do out[#out+1] = piece end return table.unpack(out) end

dofile(libsDir .. "/LibStub/LibStub.lua")
dofile(libsDir .. "/AceSerializer-3.0/AceSerializer-3.0.lua")
LibDeflate = dofile(libsDir .. "/LibDeflate/LibDeflate.lua")
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate") or LibDeflate

local preset = {
  text = "Test Route åäö",
  week = 1,
  difficulty = 10,
  value = {
    currentDungeonIdx = 153,
    currentPull = 2,
    currentSublevel = 1,
    pulls = {
      [1] = { [3] = { 1, 2 }, [5] = { 1 }, color = "ff3465a4" },
      [2] = { [11] = { 1, 4, 5 }, color = "ff4e9a06" },
      [3] = { [1] = { 2 } },
    },
  },
}

local serialized = Serializer:Serialize(preset)
local compressed = LibDeflate:CompressDeflate(serialized, { level = 5 })
local encoded = "!" .. LibDeflate:EncodeForPrint(compressed)

local f = assert(io.open(outPath, "w"))
f:write(encoded)
f:close()
print("export string (" .. #encoded .. " chars) written")
print(encoded)
