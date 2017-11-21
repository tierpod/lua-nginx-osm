-- included from content_by_lua_file

-- local print = print
local osm_tile = require 'osm.tile'
local renderd = require 'osm.renderd'

local map = osm_tile.get_mapname(ngx.var.uri, 'png')
local x, y, z = osm_tile.get_cordination(ngx.var.uri, map, 'png')

local renderd_tilepath = '/var/lib/mod_tile'
local tilefile = osm_tile.xyz_to_metatile_filename(x, y, z)
local tilepath = renderd_tilepath..'/'..map..'/'..tilefile
-- add http header for debug
-- ngx.header['X-Message-Metatile'] = tilepath

-- try get tile from local metatile
local png, err = osm_tile.get_tile(tilepath, x, y, z)
if png then
  ngx.header.content_type = 'image/png'
  ngx.print(png)
  return ngx.OK
end

-- if local metatile does not exist, ask renderd to render it
local ok = renderd.request(map, x, y, z, z)
if not ok then
  return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- try get tile from local metatile again
local png, err = osm_tile.get_tile(tilepath, x, y, z)
if png then
  ngx.header.content_type = 'image/png'
  ngx.print(png)
  return ngx.OK
end

-- if local metatile not found
return ngx.exit(ngx.HTTP_NOT_FOUND)
