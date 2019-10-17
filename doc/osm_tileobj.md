Tile object methods
===================

This module provides a thin object-style wrapper around *osm_tile* module methods.

```lua
osm_tile = require 'osm.tileobj'

local tile = osm_tile.new_from_uri('/mystyle1/18/233816/100256.png')
if tile:is_inside_maps({'mystyle1', 'mystyle2'}) then
  ngx.log(ngx.ERR, 'tile'..tile..' belongs to selected styles')
end

data, err = tile:get_tile()
if data then
  ngx.header.content_type = tile.content_type
  ngx.print(data)
  return ngx.OK
end
```

new_from_uri
------------

**syntax:** *tile = new_from_uri(uri, metatiles_dir?)*

Returns new tile object with attributes:

* x, y, z (number): tile coordinates
* map (string): mapname
* ext (string): tile extension
* content_type (string): content_type (based on ext)
* is_vector (bool): true if given uri ends with '.mvt'

*metatiles_dir* is the optional argument ('/var/lib/mod_tile' if not set)

is_inside_maps
--------------

**syntax:** *is_inside = tile:is_inside_maps(maps)*

Checks if tile.map contains in maps list.

is_inside_region
----------------

**syntax:** *is_inside = tile:is_inside_region(region)*

where *region* is the region from osm_data module.

get_tile
--------

**syntax:** *data, err = tile:get_tile()*

Gets tile from metatile file.

check_integrity_xyzm
--------------------

**syntax:** *ok = tile:check_integrity_xyzm(minz, maxz)*

xyz_to_metatile_filename
------------------------

**syntax:** *metatile = tile:xyz_to_metatile_filename()*
