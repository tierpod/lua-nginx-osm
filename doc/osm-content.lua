-- included from content_by_lua_file

local osm_tile = require 'osm.tile'
local osm_renderd = require 'osm.renderd'
local osm_update = require 'osm.update'

local content_type = 'image/png'
local map = osm_tile.get_mapname(ngx.var.uri, 'png')
local x, y, z = osm_tile.get_cordination(ngx.var.uri, map, 'png')

local planet_import_complete = '/var/lib/mod_tile/planet-import-complete'
local tilefile = osm_tile.xyz_to_metatile_filename(x, y, z)
local tilepath = '/var/lib/mod_tile/'..map..'/'..tilefile

local is_update_enabled = osm_update.get_state()

-- add http header for debug
-- ngx.header['X-Message-Metatile'] = tilepath

-- try to get tile from local metatile
local png, err = osm_tile.get_tile(tilepath, x, y, z)
if png then
  -- if metatile exist, check if it outdated
  if is_update_enabled and (map == 'style1' or map == 'style2') then
    local is_outdated = osm_update.is_outdated(tilepath, map)
    if is_outdated then
      -- ngx.log(ngx.WARN, 'metatile '..tilepath..' is outdated, rerender')
      osm_renderd.request(map, x, y, z, z, true)
    end
  end

  -- reply tile data
  ngx.header.content_type = content_type
  ngx.print(png)
  return ngx.OK
end

-- if local metatile does not exist, ask renderd to render it
local ok = osm_renderd.request(map, x, y, z, z)
if not ok then
  return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- try to get tile from local metatile again
local png, err = osm_tile.get_tile(tilepath, x, y, z)
if png then
  ngx.header.content_type = content_type
  ngx.print(png)
  return ngx.OK
end

-- if local metatile not found
return ngx.exit(ngx.HTTP_NOT_FOUND)
