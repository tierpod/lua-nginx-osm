#!/bin/bash
# Install packages, needed for building poly2lua and testing lua-nginx-osm.

set -eu

yum install -y epel-release
yum install -y tmux mc git lua lua-filesystem curl yum-utils make

# CGAL-devel for building poly2lua.cpp, contains in official postgresql repo.
REPO_FILE=/etc/yum.repos.d/pgdg-redhat-all.repo
if ! [ -f "$REPO_FILE" ]; then
  yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  yum install -y CGAL-devel gcc-c++
fi

# nginx openresty https://openresty.org/en/linux-packages.html
REPO_FILE=/etc/yum.repos.d/openresty.repo
if ! [ -f "$REPO_FILE" ]; then
  yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
  yum install -y openresty
fi
