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

local regname = "iran"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname))
print('  ok')
table_print(region,0)

-- iran
print('iran (inside?):')
local z = 14
local x = 10530
local y = 6451
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

local z = 10
local x = 658
local y = 403
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

local z = 7
local x = 85
local y = 52
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

print('iran (outside?):')
local z = 7
local x = 79
local y = 53
assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')

print('iran (outside?):')
local z = 11
local x = 1369
local y = 797
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
