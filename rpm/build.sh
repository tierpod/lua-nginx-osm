#!/bin/bash

set -eu

SPEC=lua-nginx-osm.spec
VER=$(awk '/Version:/ {print $2}' $SPEC)
SRC=$HOME/rpmbuild/SOURCES/$VER.tar.gz

if ! [ -e "$SRC" ]; then
	spectool -g -R $SPEC
fi

rpmbuild -ba $SPEC
