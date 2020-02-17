#!/usr/bin/env lua5.1

package.path = '../?.lua'

local funcs = require "tests.funcs"
local osm_data = require "osm.data"

local regname = "japan"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname), 'expected region coordinates')
print('  ok')
funcs.table_print(region,0)

funcs.test_inside(region, 'japan', 18, 233816, 100256)

funcs.test_outside(region, 'ru kurgan', 17, 89319, 41167)
funcs.test_outside(region, 'ir', 12, 2632, 1612)
