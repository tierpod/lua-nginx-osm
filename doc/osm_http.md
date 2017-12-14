osm.http backend
================

Ask backend to render and write metatile via http. Based on tirex module.

Use [lua-resty-http][1] for http requests, so it must be installed in lua_package_path directory.

Methods
=======

request
-------

**syntax:** *result = osm.http.request(map, x, y, z1, z2)*

Request enqueue command to fetching map 'map' with x/y/z1 cordination.  And also request to render
in background between zoom z1 to z2. If request fails return nil.

When z1 == z2, just ask to render single tile.



[1]: https://github.com/pintsized/lua-resty-http
