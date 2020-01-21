LUA ?=             lua
PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?=         install

POLY2LUA = utils/poly2lua/poly2lua

DATA = osm/data

.PHONY: build install

build: $(POLY2LUA) data

$(POLY2LUA): utils/poly2lua.cpp utils/CMakeLists.txt
	mkdir -p utils/poly2lua
	(cd utils/poly2lua; cmake ../)
	$(MAKE) -C utils/poly2lua

test:
	cd tests; \
	for F in test_*.lua; do \
		echo "*** TEST $$F ***"; \
		if ! $(LUA) $$F; then echo "*** FAIL $$F ***"; exit 1; fi \
	done

data:
	$(MAKE) -C $(DATA) build

clean:
	rm -rf utils/poly2lua
	$(MAKE) -C $(DATA) clean

install:
	$(INSTALL) -m 0755 -d $(DESTDIR)/$(LUA_LIB_DIR)/osm
	$(INSTALL) -m 0755 -d $(DESTDIR)/$(LUA_LIB_DIR)/osm/data
	$(INSTALL) -m 0644 osm/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/osm
	$(MAKE) -C $(DATA) install

# docker / podman image. if you're using podman, run `export DOCKER=podman` first
DOCKER ?= docker
.PHONY: docker-image docker-shell
docker-image:
	$(DOCKER) build . -t lua-nginx-osm

docker-shell:
	$(DOCKER) run -it -v $(PWD):/host lua-nginx-osm /bin/bash
