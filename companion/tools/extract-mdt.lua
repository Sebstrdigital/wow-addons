-- Extract enemy data from an installed MDT dungeon file into JSON.
-- Usage: lua extract-mdt.lua <MDT dungeon lua> <dungeonIndex> <out.json>
local src, dungeonIndex, outPath = arg[1], tonumber(arg[2]), arg[3]

MDT = setmetatable({}, { __index = function(t, k)
  local v = setmetatable({}, { __index = function() return nil end })
  rawset(t, k, v)
  return v
end })
MDT.L = setmetatable({}, { __index = function(_, k) return k end })
MDT.dungeonList, MDT.mapInfo, MDT.zoneIdToDungeonIdx = {}, {}, {}
MDT.dungeonMaps, MDT.dungeonSubLevels, MDT.dungeonTotalCount = {}, {}, {}
MDT.mapPOIs, MDT.dungeonEnemies, MDT.dungeonBosses = {}, {}, {}

local chunk = assert(loadfile(src))
chunk("MythicDungeonTools")

local enemies = MDT.dungeonEnemies[dungeonIndex]
local total = MDT.dungeonTotalCount[dungeonIndex] or {}
assert(enemies, "no enemies for index " .. tostring(dungeonIndex))

local function jstr(s) return '"' .. tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"') .. '"' end
local out = { '{ "totalCount": ' .. tostring(total.normal or 0) .. ', "enemies": [' }
local rows = {}
for i, e in ipairs(enemies) do
  local clones = {}
  for ci, c in ipairs(e.clones or {}) do
    clones[#clones + 1] = string.format('{ "i": %d, "x": %.2f, "y": %.2f, "sublevel": %d }',
      ci, c.x or 0, c.y or 0, c.sublevel or 1)
  end
  rows[#rows + 1] = string.format(
    '  { "index": %d, "id": %s, "name": %s, "count": %s, "isBoss": %s, "scale": %s, "positions": [%s] }',
    i, tostring(e.id or 0), jstr(e.name or "?"), tostring(e.count or 0),
    tostring(e.isBoss == true), tostring(e.scale or 1), table.concat(clones, ", "))
end
out[#out + 1] = table.concat(rows, ",\n")
out[#out + 1] = '] }'

local f = assert(io.open(outPath, "w"))
f:write(table.concat(out, "\n"))
f:close()
print("wrote " .. outPath .. " (" .. #rows .. " enemies, total " .. tostring(total.normal) .. ")")
