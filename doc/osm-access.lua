-- included from access_by_lua_file

local osm_tile = require 'osm.tile'
local data = require 'osm.data'

local minz = 1
local maxz = 18
local map = osm_tile.get_mapname(ngx.var.uri, 'png')

-- stop processing if map not found in uri
if not map then
  ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- redefine max zoom level for some styles
if map == 'style1' then
  maxz = 17
end

local x, y, z = osm_tile.get_cordination(ngx.var.uri, map, 'png')

-- redefine max zoom level for some regions
local region = data.get_region('japan')
if osm_tile.is_inside_region(region, x, y, z) then
  maxz = 19
  -- ngx.log(ngx.ERR, 'inside region')
end

local ok = osm_tile.check_integrity_xyzm(x, y, z, minz, maxz)
if not ok then
  ngx.log(ngx.ERR, 'check integrity failed')
  ngx.exit(ngx.HTTP_FORBIDDEN)
end
