osm.renderd backend
===================

Ask [mod_tile+renderd][1] to render and write metatile via renderd protocol. Based on tirex module.


Methods
=======

request
-------

**syntax:** *result = osm.renderd.request(map, x, y, z1, z2)*

Request enqueue command to rendering map 'map' with x/y/z1 cordination.  And also request to render
in background between zoom z1 to z2.  If request fails return nil.

When z1 == z2, just ask to render single tile.



[1]: https://github.com/openstreetmap/mod_tile
