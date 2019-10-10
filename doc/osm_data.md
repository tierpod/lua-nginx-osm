Data methods
============

Required [lua-filesystem][1] module: for centos7: yum install -y lua-filesystem

get_region
----------

**syntax:** *region = data.get_region("japan"))*

Get region definition table of argument country/area.
This can use for is_inside_region() method.

Now provide following area/country data:

    japan
    asia
    world
