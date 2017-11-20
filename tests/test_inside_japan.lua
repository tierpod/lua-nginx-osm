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

local regname = "japan"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname), 'expected region coordinates')
print('  ok')
table_print(region,0)

print('japan (inside?):')
local z = 18
local x = 233816
local y = 100256
assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
print('  ok')

print('kurgan (outside?):')
local z = 17
local x = 89319
local y = 41167

assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')

print('iran (outside?):')
local z = 12
local x = 2632
local y = 1612

assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
print('  ok')

