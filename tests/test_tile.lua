#!/usr/bin/env lua5.1

package.path = '../?.lua'

local osm_tile = require "osm.tile"
local map = "data"

print('TESTS FOR osm_tile')

--
-- test wrong uri first
--
local uri = '/data/-1/4294967295/4294967295.png'

print('TEST: get_mapname (wrong uri): uri='..uri)
assert(osm_tile.get_mapname(uri, "png") == nil)
print('  OK')

print('TEST: tile coordinations: uri='..uri)
local x, y, z = osm_tile.get_cordination(uri, map, "png")
print('TEST: get_cordination')
assert(tonumber(x) == nil)
assert(tonumber(y) == nil)
assert(tonumber(z) == nil)
print('  OK')

--
-- test good uri
--
local uri = '/data/18/233816/100256.png'
print('TEST: get_mapname (good uri): uri='..uri)
assert(osm_tile.get_mapname(uri, "png") == map)
print('  OK')

print('TEST: tile coordinations: uri='..uri)
local x, y, z = osm_tile.get_cordination(uri, map, "png")
print('TEST: get_cordination')
assert(tonumber(x) == 233816)
assert(tonumber(y) == 100256)
assert(tonumber(z) == 18)
print('  OK')

print('TEST: check_integrity_xyzm')
local minz=15
local maxz=18
assert(osm_tile.check_integrity_xyzm(x, y, z, minz, maxz))
maxz=17
assert(osm_tile.check_integrity_xyzm(x, y, z, minz, maxz) == nil)
print('  OK')

print('TEST: xyz_to_metatile_filename')
local tilefile = osm_tile.xyz_to_metatile_filename(x, y, z)
assert(tilefile == "18/49/152/23/90/128.meta")
print('  OK')

print('TEST: get_tile')
local tilepath = "./"..map.."/"..tilefile
local png, err = assert(osm_tile.get_tile(tilepath, x, y, z))
assert(png)
assert(err == nil)
assert(#png == 2054)
print('  OK: length is '..#png)
