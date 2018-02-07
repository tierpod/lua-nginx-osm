-- included from content_by_lua_file

local osm_tile = require 'osm.tile'
local osm_renderd = require 'osm.renderd'

local map = osm_tile.get_mapname(ngx.var.uri, 'png')
local x, y, z = osm_tile.get_cordination(ngx.var.uri, map, 'png')

local cache_dir = '/var/lib/mod_tile'
local planet_import_complete = cache_dir..'/planet-import-complete'

local tilefile = osm_tile.xyz_to_metatile_filename(x, y, z)
local tilepath = cache_dir..'/'..map..'/'..tilefile

-- add http header for debug
-- ngx.header['X-Message-Metatile'] = tilepath

local is_outdated = false
-- we can update metatiles for this style if outdated
if map == "style1" then
  is_outdated = osm_tile.is_outdated(tilepath, planet_import_complete, map, 14400) -- store in cache for 4 hours
end

-- try get tile from local metatile if not outdated
if is_outdated then
  ngx.log(ngx.ERR, 'metatile '..tilepath..' is outdated, rerender it')
else
  local png, err = osm_tile.get_tile(tilepath, x, y, z)
  if png then
    ngx.header.content_type = 'image/png'
    ngx.print(png)
    return ngx.OK
  end
end

-- if local metatile does not exist, ask renderd to render it
local ok = osm_renderd.request(map, x, y, z, z)
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
