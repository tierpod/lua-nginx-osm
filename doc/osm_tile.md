Tile Methods
=======

get_cordination
-----------------

**syntax:** *x, y, z = get_cordination(uri, map, ext)*

Retrive x/y/z from uri path.
If client GET uri   /example/9/3/1.png   then example map, z =9, x=3 and y=1
and extension is png.

xyz_to_metatile_filename
-------------------------

**syntax:** *filename = osm.tile.xyz_to_metatile_filename(x, y, z)*

Generate metatile filename from x/y/z cordination.

get_tile
--------

**syntax:** *png, err = osm.tile.get_tile(tilepath, x, y, z)*

Get chunk of png image data of x/y/z cordination from metatile tilepath.

check_integrity_xyzm
----------------------

**syntax:** *ok = osm.tile.check_integrity_xyzm(x, y, z, minz, maxz)*

Check whether x/y/z integrity.
Tile x/y/z definition details are in
   https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames

check_integrity_xyz
----------------------

**syntax:** *ok = osm.tile.check_integrity_xyzm(x, y, z)*

Same as check_integrity_xyzm() but don't check z range.

is_inside_region
--------

**syntax:** *include = osm.tile.is_inside_region(region, x, y, z)*

Check x/y/z cordination is located and inside of region.
region should be get from 'osm.data'

is_outdated
-----------

**syntax:** *is_outdated = osm.tile.is_outdated(metafilename, flagfilename, map, exptime)*

Checks if metatile file is outdated.

Implements mod_tile-like logic: if modification time of metatile file (metafilename) older than
modification time of /var/lib/mod_tile/planet-import-complete (flagfilename), mark metatile file
as outdated and rerender it.

Use nginx shared dict for cache mtime of flagfilename per map name (does not need to read this file
on every request).

get_last_update
---------------

**syntax:** *time = get_last_update(map)*

Get last update time stored in nginx shared memory cache for given map.
