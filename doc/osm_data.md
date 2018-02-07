Data methods
============

get_region
----------

**syntax:** *region = data.get_region("japan"))*

Get region definition table of argument country/area.
This can use for is_inside_region() method.

Now provide following area/country data:

    japan
    asia
    world

get_mtime
---------

**syntax:** *mtime = data.get_mtime("/var/lib/mod_tile/planet-import-complete")*

Get modification time of file. If file does not exists, returns nil.

is_file_newer
-------------

**syntax:** *is_outdated = data.is_file_newer("/var/lib/mod_tile/planet-import-complete", "/var/lib/mod_tile/map/1/1/1.png")*

Compare modification time of two files. Returns true if file1 newer than file2.