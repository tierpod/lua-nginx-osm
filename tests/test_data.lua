#!/usr/bin/env lua5.1

package.path = '../?.lua'

local osm_data = require 'osm.data'

local file1 = 'data/18/49/152/23/90/128.meta'
-- create temporary new file
io.popen('touch /tmp/now')
local file2 = '/tmp/now'

print('is_file_newer: check if '..file2..' newer than '..file1..':')
assert(osm_data.is_file_newer(file2, file1))
print('  ok')

print('is_file_newer: check if '..file1..' newer than '..file2..':')
assert(osm_data.is_file_newer(file1, file2) == false)
print('  ok')

print('is_file_newer: check if file2 does not exist:')
assert(osm_data.is_file_newer('/tmp/noexist.123', file1) == false)
print('  ok')

