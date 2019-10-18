#!/usr/bin/env lua5.1

package.path = '../?.lua'

local osm_tile = require 'osm.tileobj'

print('TESTS FOR osm_tileobj')

--
-- test wrong uri fist
--
local uri = '/data/-1/4294967295/4294967295.png'
local tile, err = osm_tile.new_from_uri(uri, '.')

print('TEST: tile object (wrong uri): uri='..uri)

assert(tile == nil)
assert(err == "unable to get map name from uri: "..uri)
print('  OK')

--
-- test good uri
--
local uri = '/data/18/233816/100256.png'
local tile, err = osm_tile.new_from_uri(uri, '.')

print('TEST: tile object (good uri): uri='..uri)
assert(tile)
assert(err == nil)
assert(tile.map == 'data')
assert(tile.z == 18)
assert(tile.x == 233816)
assert(tile.y == 100256)
assert(tile.ext == 'png')
assert(tile.content_type == 'image/png')
print('  OK: '..uri..' equal to '..tile)

print('TEST: is_inside_maps')
assert(tile:is_inside_maps({'data', 'map2'}))
assert(not tile:is_inside_maps({'map3'}))
print('  OK')

print('TEST: check_integrity_xyzm')
local minz = 15
local maxz = 18
assert(tile:check_integrity_xyzm(minz, maxz))
maxz = 17
assert(not tile:check_integrity_xyzm(minz, maxz))
print('  OK')

print('TEST: xyz_to_metatile_filename')
local metatile = tile:xyz_to_metatile_filename()
assert(metatile, "18/49/152/23/90/128.meta")
print('  OK')

print('TEST: get_tile')
local data, err = tile:get_tile()
assert(data)
assert(err == nil)
assert(#data == 2054)
print('  OK: length is '..#data)
