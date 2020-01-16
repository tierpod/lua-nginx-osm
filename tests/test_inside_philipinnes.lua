#!/usr/bin/env lua5.1

package.path = '../?.lua'

function table_print(t1)
    indent_string = string.rep(" ", 4)
    if t1 then
        for _, b in pairs(t1) do
            print('polygon:')
            for _, v in pairs(b) do
                print(indent_string,'lon=',v.lon,',lat=', v.lat)
            end
        end
    end
end

local osm_tile = require "osm.tile"
local osm_data = require "osm.data"

local regname = "philippines"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname))
print('  ok')
table_print(region,0)

print('ph (inside?):')
local z = 17
local x = 110649
local y = 61763
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

print('ph davao (inside?):')
local z = 17
local x = 111268
local y = 62952
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

print('ph manila (inside?):')
local z = 12
local x = 3424
local y = 1880
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

print('ph mapun (inside?):')
local z = 16
local x = 54341
local y = 31486
assert(osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')

print('ph (outside?):')
local z = 14
local x = 12783
local y = 8178
assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')


-- japan
print('japan (outside?):')
local z = 18
local x = 233816
local y = 100256
assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')

-- kurgan
print('kurgan (outside):')
local z = 17
local x = 89319
local y = 41167
assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')
