#!/bin/bash
# Install packages, needed for building poly2lua and testing lua-nginx-osm.

set -eu

yum install -y epel-release
yum install -y tmux mc git vim lua lua-bitop lua-filesystem htop curl

# CGAL-devel for building poly2lua.cpp, contains in official postgresql repo.
REPO_FILE=/etc/yum.repos.d/pgdg-96-centos.repo
if ! [ -f "$REPO_FILE" ]; then
  yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
  yum install -y CGAL-devel gcc-c++
fi

# https://nginx.ru/en/linux_packages.html
# nginx mainline for nginx-module-lua, contains in official nginx repo.
REPO_FILE=/etc/yum.repos.d/nginx.repo
if ! [ -f "$REPO_FILE" ]; then
  cat <<'EOF' > "$REPO_FILE"
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
EOF

  yum install -y nginx
fi

# https://copr.fedorainfracloud.org/coprs/khara/nginx-module-ndk-lua/
# nginx-module-lua for lua-nginx-osm, contains in unofficial copr repo.
REPO_FILE=/etc/yum.repos.d/khara-nginx-module-ndk-lua-epel-7.repo
if ! [ -f "$REPO_FILE" ]; then
  cat <<'EOF' > "$REPO_FILE"
[khara-nginx-module-ndk-lua]
name=Copr repo for nginx-module-ndk-lua owned by khara
baseurl=https://copr-be.cloud.fedoraproject.org/results/khara/nginx-module-ndk-lua/epel-7-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/khara/nginx-module-ndk-lua/pubkey.gpg
repo_gpgcheck=0
enabled=1
EOF

  yum install -y nginx-module-lua
fi
