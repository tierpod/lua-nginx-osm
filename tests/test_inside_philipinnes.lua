#!/usr/bin/env lua5.1

package.path = '../?.lua'

local funcs = require "tests.funcs"
local osm_data = require "osm.data"

local regname = "philippines"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname))
print('  ok')
funcs.table_print(region,0)

funcs.test_inside(region, 'ph', 17, 110649, 61763)
funcs.test_inside(region, 'ph davao', 17, 111268, 62952)
funcs.test_inside(region, 'ph manila', 12, 3424, 1880)
funcs.test_inside(region, 'ph mapun', 16, 54341, 31486)

funcs.test_outside(region, 'id', 14, 12783, 8178)
funcs.test_outside(region, 'japan', 18, 233816, 100256)
funcs.test_outside(region, 'kurgan', 17, 89319, 41167)
