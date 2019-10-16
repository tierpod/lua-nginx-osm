Name
====

lua-nginx-osm - Lua Tirex/renderd/http client drivers for the ngx_lua based on the cosocket API.

Status
======

Current version is 0.43, 21, October, 2013.
This library is considered active development status.

Description
===========

This Lua library is a tirex/renderd/http client drivers for the ngx_lua nginx module:

http://wiki.nginx.org/HttpLuaModule

This Lua library takes advantage of ngx_lua's cosocket API, which ensures
100% nonblocking behavior.

It also includes utility to handle metatile, URIs in Lua language.
These utility is not depend on nginx, means pure lua implementation.

Note that at least [ngx_lua 0.8.1](https://github.com/chaoslawful/lua-nginx-module/tags) is required.

If you use Ubuntu Linux 12.04 (LTS) and after, there is a PPA(private package archive) for you.
http://launchpad.net/~osmjapan/+archive/ppa
Please see the above page for detail instructions.

Synopsis
========

    lua_package_path "/path/to/lua-nginx-osm/?.lua;;";
    lua_shared_dict osm_tirex 10m; ## mandatory to use osm.tirex module

    server {
        location /example {
            content_by_lua '
                local tirex = require "osm.tirex"
                local tile = require "osm.tile"
                local data = require "osm.data"

                -- --------------------------------------------------
                -- check uri
                -- --------------------------------------------------
                local uri = ngx.var.uri
                local map = "example"
                local x, y, z = tile.get_cordination(uri, map, ".png")
                if not x then
                    return ngx.exit(ngx.HTTP_FORBIDDEN)
                end

                -- check x, y, z range
                local max_zoom = 18
                local min_zoom = 5
                if not tile.check_integrity_xyzm(x, y, z, minz, maxz) then
                    return ngx.exit(ngx.HTTP_FORBIDDEN)
                end

                -- check x, y, z supported to generate
                local region = data.get_region("japan")
                if not osm_tile.is_inside_region(region, x, y, z)
                    -- try upstream server?
                    return ngx.exit(ngx.HTTP_FORBIDDEN)
                end

                -- try renderd file
                local tilefile = tile.xyz_to_metatile_filename(x, y, z)
                local tilepath = tirex_tilepath.."/"..map.."/"..tilefile
                local png, err = tile.get_tile(tilepath, x, y, z)
                if png then
                    ngx.header.content_type = "image/png"
                    ngx.print(png)
                    return ngx.OK
                end

                -- ask tirex to render it
                local ok = tirex.send_request(map, x, y, z)
                if not ok then
                    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
                end

                -- get tile image from metatile
                local png, err = tile.get_tile(tilepath, x, y, z)
                if png then
                    ngx.header.content_type = "image/png"
                    ngx.print(png)
                    return ngx.OK
                end
                return ngx.exit(ngx.HTTP_NOT_FOUND)
            ';
        }
    }

Modules documentation
=====================

* [tile methods](doc/osm_tile.md)
* [data methods](doc/osm_data.md)
* [tirex methods](doc/osm_tirex.md)
* [mod_tile+renderd methods](doc/osm_renderd.md)
* [custom http backend methods](doc/osm_http.md)
* [update methods](doc/osm_update.md)


TODO
====

* build more data definitions

* and more on issue tracker.


Community
=========

English Mailing List
--------------------

The [tile-serving](https://lists.openstreetmap.org/lists/tile-serving) mailing list is for English speakers.
It is for all topic about tile serving development of openstreetmap, not only this project.

Web Chat
--------------------

The [osmfj-devel](http://lingr.com/signup?letmein=osmfj_devel) web chat is in Japanese/English.
It is a chat room mainly for OSM Japan site and related software development.


Bugs and Patches
================

Please report bugs or submit patches by

1. creating a ticket on the [GitHub Issue Tracker](http://github.com/miurahr/lua-nginx-osm/issues),

1. There are known problem that Tirex cannot response properly so we need to patch to tirex.

  https://trac.openstreetmap.org/ticket/4869

  If you use Tirex 0.4.1(original)  or  tirex-0.4.1ppa4 and below, you need to patch to tirex.
  Here is a patch file in misc/tirex-peer.diff.

Author
======

Hiroshi Miura <miurahr@osmf.jp>, OpenStreetMap Foundation Japan

Copyright and License
=====================

Hiroshi Miura, 2013
OpenStreetMap Foundation Japan, 2013
Mikhail Okhotin, 2016
Pavel Podkorytov, 2017

Distributed under GPLv3 License.

See Also
========
* the ngx_lua module: http://wiki.nginx.org/HttpLuaModule




[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/miurahr/lua-nginx-osm/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
