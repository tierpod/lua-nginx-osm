#!/usr/bin/env lua5.1

package.path = '../?.lua'

local funcs = require "tests.funcs"
local osm_data = require "osm.data"

local regname = "iran"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname))
print('  ok')
funcs.table_print(region,0)

funcs.test_inside(region, 'ir', 14, 10530, 6451)
funcs.test_inside(region, 'ir', 10, 658, 403)
funcs.test_inside(region, 'ir', 7, 85, 52)

funcs.test_outside(region, '?', 7, 79, 53)
funcs.test_outside(region, '?', 11, 1369, 797)
funcs.test_outside(region, 'japan', 18, 233816, 100256)
funcs.test_outside(region, 'ru kurgan', 17, 89319, 41167)
