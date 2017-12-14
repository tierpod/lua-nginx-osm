osm.tirex backend
=================

Ask tirex to render and write metatile via tirex protocol.


Methods
=======


request
-------------

**syntax:** *result = osm.tirex.request(map, x, y, z1, z2, priority)*

Request enqueue command to rendering map 'map' with x/y/z1 cordination and
priority. And also request to render in background between zoom z1 to z2.
If request fails return nil.

When z1 == z2, just ask to render single tile.


cancel
-------------

**syntax:** *result = osm.tirex.cancel(map, x, y, z1, z2, priority)*

Request dequeue command to rendering map 'map' with x/y/z1 cordination and
priority.And also request to cancel in background between zoom z1 to z2.
If request fails return nil.


ping
-------------

**syntax:** *result = osm.tirex.ping()*

Request ping command. If request fails return nil.


Obsolete functions
=============

send_request
-------------

**syntax:** *result = osm.tirex.send_request(map, x, y, z)*

Request enqueue command to rendering map 'map' with x/y/z cordination.
If request fails return nil.


enqueue_request
-------------

**syntax:** *result = osm.tirex.enqueue_request(map, x, y, z, priority)*

Request enqueue command to rendering map 'map' with x/y/z cordination and
priority.
If request fails return nil.

dequeue_request
-------------

**syntax:** *result = osm.tirex.dequeue_request(map, x, y, z, priority)*

Request dequeue command to rendering map 'map' with x/y/z cordination and
priority.
If request fails return nil.
