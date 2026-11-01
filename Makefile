SHELL := /usr/bin/env bash

# Staff and advanced entry point. Students should use ./start.sh.
# Docker by default; CONTAINER_ENGINE=podman switches the whole lab to Podman.
ENGINE  ?= $(CONTAINER_ENGINE)
ENGINE  := $(if $(ENGINE),$(ENGINE),$(shell command -v docker >/dev/null 2>&1 && echo docker || echo podman))
ifeq ($(ENGINE),podman)
COMPOSE ?= $(shell podman compose version >/dev/null 2>&1 && echo "podman compose" || echo "podman-compose")
else
COMPOSE ?= docker compose
endif

.PHONY: help m03 m06 m09 stop down reset reset-m03 reset-m06 reset-m09 \
        status logs console smoke pull fix-m09 break-m09

help:
	@echo "Enterprise Estate Labs (staff/advanced)"
	@echo ""
	@echo "  Students:  ./start.sh m03   (or m06, m09; see ./start.sh help)"
	@echo ""
	@echo "  make m03          Start the Module 03 state (web, db, tools)"
	@echo "  make m06          Start the cumulative Module 06 state (adds proxy/TLS)"
	@echo "  make m09          Start the cumulative Module 09 state (adds shared volume)"
	@echo "  make console      Shell on the tools container (needs m03 or later)"
	@echo "  make status       Show running services"
	@echo "  make logs         Follow logs"
	@echo "  make smoke        Run the smoke test"
	@echo "  make stop         Stop the estate, keep volumes"
	@echo "  make down         Remove containers and networks, keep volumes"
	@echo "  make reset-m03    Remove everything and return to the Module 03 state"
	@echo "  make reset-m06    Remove everything and return to the Module 06 state"
	@echo "  make reset-m09    Remove everything and return to the Module 09 state"
	@echo "  make fix-m09      Repair the Module 09 share permissions"
	@echo "  make break-m09    Put the Module 09 share back into the broken state"
	@echo ""
	@echo "  Podman: make m06 CONTAINER_ENGINE=podman"

m03:
	$(COMPOSE) --profile m03 up -d

m06:
	$(COMPOSE) --profile m03 --profile m06 up -d

m09:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 up -d

stop:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 stop

down:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 down --remove-orphans

reset-m03:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 down -v --remove-orphans
	$(COMPOSE) --profile m03 up -d

reset-m06:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m06 up -d

reset-m09:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m06 --profile m09 up -d

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 logs --tail=100 -f

console:
	$(COMPOSE) --profile m03 exec tools sh

smoke:
	./tests/smoke.sh

pull:
	$(COMPOSE) --profile m03 --profile m06 --profile m09 pull

fix-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown -R 1000:1000 /share && chmod 775 /share'

break-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown root:root /share && chmod 755 /share'
