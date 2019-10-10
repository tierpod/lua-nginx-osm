Update mechanism methods
========================

This module uses external module "lfs" (package lua-filesystem in centos 7 repo).

This module uses shared dict **ngx.shared.osm_last_update** to cache:

* current update mechanism state: enabled or disabled
* mtime for flag file per map

You need to set in nginx configuration file:

```plain
lua_shared_dict osm_last_update 8k;

init_worker_by_lua_block {
    local lfs = require "lfs"
}
```

You can change default module configuration after import:

```lua
local osm_update = require 'osm_update'
osm_update.FLAGFILE = '/path/to/flag-file' -- default: '/var/lib/mod_tile/planet-import-complete
osm_update.EXPTIME = 600 -- default 3600
```

get_state
---------

**syntax:** *osm_update.get_state()*

Returns current update mechanism state: true if it's enabled; false or nil if it's disabled.

enable
------

**syntax:** *osm_update.enable()*

Enables osm_update mechanism.

safe_enable
-----------

**syntax:** *osm_update.safe_enable()*

Enables osm_update mechanism only if current state is nil (is not set).

disable
-------

**syntax:** *osm_update.disable()*

Disables osm_update mechanism.

get_list
--------

**syntax:** *osm_update.get_list()*

Returns list of all cached items.

is_outdated
-----------

**syntax:** *is_outdated = osm_update.is_outdated(metafilename, map)*

Checks if metatile file is outdated.

Implements mod_tile-like logic: if modification time of metatile file (metafilename) older than
modification time of /var/lib/mod_tile/planet-import-complete (FLAGFILE), mark metatile file
as outdated and rerender it.

Uses nginx shared dict to cache mtime of flagfilename per map name (does not need to read this file
on every request).

get_last_update
---------------

**syntax:** *time = osm_update.get_last_update(map)*

Get last update time stored in nginx shared memory cache for given map.

get_mtime
---------

**syntax:** *mtime = data.get_mtime("/var/lib/mod_tile/planet-import-complete")*

Get modification time of file. If file does not exists, returns nil.

is_file_newer
-------------

**syntax:** *is_outdated = data.is_file_newer("/var/lib/mod_tile/planet-import-complete", "/var/lib/mod_tile/map/1/1/1.png")*

Compare modification time of two files. Returns true if file1 newer than file2.

[1]: https://keplerproject.github.io/luafilesystem
