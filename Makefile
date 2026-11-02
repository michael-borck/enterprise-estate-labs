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

ALL_PROFILES = --profile m03 --profile m05 --profile m06 --profile m09

.PHONY: help m03 m05 m06 m09 stop down reset reset-m03 reset-m05 reset-m06 reset-m09 \
        status logs console smoke pull fix-m05 break-m05 fix-m09 break-m09

help:
	@echo "Enterprise Estate Labs (staff/advanced)"
	@echo ""
	@echo "  Students:  ./start.sh m05   (or m03, m06, m09; see ./start.sh help)"
	@echo ""
	@echo "  make m03          Start the Module 03 state (web, db, tools)"
	@echo "  make m05          Start the cumulative Module 05 state (adds internal DNS)"
	@echo "  make m06          Start the cumulative Module 06 state (adds proxy/TLS)"
	@echo "  make m09          Start the cumulative Module 09 state (adds shared volume)"
	@echo "  make console      Shell on the tools container (needs m03 or later)"
	@echo "  make status       Show running services"
	@echo "  make logs         Follow logs"
	@echo "  make smoke        Run the smoke test"
	@echo "  make stop         Stop the estate, keep volumes"
	@echo "  make down         Remove containers and networks, keep volumes"
	@echo "  make reset-m03    Remove everything and return to the Module 03 state"
	@echo "  make reset-m05    Remove everything and return to the Module 05 state"
	@echo "  make reset-m06    Remove everything and return to the Module 06 state"
	@echo "  make reset-m09    Remove everything and return to the Module 09 state"
	@echo "  make fix-m05      Restore the Module 05 DNS record"
	@echo "  make break-m05    Point the Module 05 portal name at the wrong address"
	@echo "  make fix-m09      Repair the Module 09 share permissions"
	@echo "  make break-m09    Put the Module 09 share back into the broken state"
	@echo ""
	@echo "  Podman: make m06 CONTAINER_ENGINE=podman"

m03:
	$(COMPOSE) --profile m03 up -d

m05:
	$(COMPOSE) --profile m03 --profile m05 up -d

m06:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 up -d

m09:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m09 up -d

stop:
	$(COMPOSE) $(ALL_PROFILES) stop

down:
	$(COMPOSE) $(ALL_PROFILES) down --remove-orphans

reset-m03:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 up -d

reset-m05:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m05 up -d

reset-m06:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m05 --profile m06 up -d

reset-m09:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) $(ALL_PROFILES) up -d

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) $(ALL_PROFILES) logs --tail=100 -f

console:
	$(COMPOSE) --profile m03 exec tools sh

smoke:
	./tests/smoke.sh

pull:
	$(COMPOSE) $(ALL_PROFILES) pull

fix-m05:
	./scenarios/m05/fix.sh

break-m05:
	./scenarios/m05/break.sh

fix-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown -R 1000:1000 /share && chmod 775 /share'

break-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown root:root /share && chmod 755 /share'
