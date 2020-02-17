#!/usr/bin/env lua5.1

local _M = {}

local osm_tile = require "osm.tile"

function _M.table_print(t1)
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

function _M.test_inside(region, name, z, x, y)
    print(name..' (inside?):')
    assert(osm_tile.is_inside_region(region, x, y, z), 'expected true')
    print('  ok')
end

function _M.test_outside(region, name, z, x, y)
    print(name..' (outside?):')
    assert(not osm_tile.is_inside_region(region, x, y, z), 'expected false')
    print('  ok')
end

return _M
