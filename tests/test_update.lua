#!/usr/bin/env lua5.1

package.path = '../?.lua'
package.cpath = '/usr/lib64/lua/5.1/?.so;' .. package.cpath

-- fake empty ngx object
ngx = {shared = {}}

local osm_update = require 'osm.update'

local file1 = 'data/18/49/152/23/90/128.meta'
-- create new temporary file
local file2 = os.tmpname()

print('is_file_newer: check if '..file2..' newer than '..file1..':')
assert(osm_update.is_file_newer(file2, file1))
print('  ok')

print('is_file_newer: check if '..file1..' newer than '..file2..':')
assert(osm_update.is_file_newer(file1, file2) == false)
print('  ok')

print('is_file_newer: check if file2 does not exist:')
assert(osm_update.is_file_newer('/tmp/noexist.123', file1) == false)
print('  ok')

-- cleanup
os.remove(file2)
