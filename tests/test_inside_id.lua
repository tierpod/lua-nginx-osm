#!/usr/bin/env lua5.1

package.path = '../?.lua'

local funcs = require "tests.funcs"
local osm_data = require "osm.data"

local regname = "indonesia"

print('Region: ', regname)
print('tile.data test:')
local region = assert(osm_data.get_region(regname))
print('  ok')
funcs.table_print(region,0)

funcs.test_inside(region, 'id palembang', 9, 405, 260)
funcs.test_inside(region, 'id jakarta', 14, 13054, 8475)
funcs.test_inside(region, 'id padang harapan', 18, 205551, 133852)
funcs.test_inside(region, 'id medan', 15, 25365, 16057)

funcs.test_outside(region, 'ph mapun', 16, 54341, 31486)
funcs.test_outside(region, 'japan', 18, 233816, 100256)
funcs.test_outside(region, 'kurgan', 17, 89319, 41167)
