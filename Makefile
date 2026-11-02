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

ALL_PROFILES = --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 --profile m10 --profile m11

.PHONY: help m03 m05 m06 m08 m09 m10 m11 stop down reset reset-m03 reset-m05 reset-m06 reset-m08 reset-m09 reset-m10 reset-m11 \
        status logs console smoke pull fix-m05 break-m05 fix-m08 break-m08 fix-m09 break-m09 fix-m10 break-m10 fix-m11 break-m11 check-m11

help:
	@echo "Enterprise Estate Labs (staff/advanced)"
	@echo ""
	@echo "  Students:  ./start.sh m05   (or m03, m06, m08, m09, m10, m11; see ./start.sh help)"
	@echo ""
	@echo "  make m03          Start the Module 03 state (web, db, tools)"
	@echo "  make m05          Start the cumulative Module 05 state (adds internal DNS)"
	@echo "  make m06          Start the cumulative Module 06 state (adds proxy/TLS)"
	@echo "  make m08          Start the cumulative Module 08 state (adds identity)"
	@echo "  make m09          Start the cumulative Module 09 state (adds shared volume)"
	@echo "  make m10          Start the cumulative Module 10 state (adds backup and restore)"
	@echo "  make m11          Start the cumulative Module 11 state (adds security and logs)"
	@echo "  make console      Shell on the tools container (needs m03 or later)"
	@echo "  make status       Show running services"
	@echo "  make logs         Follow logs"
	@echo "  make smoke        Run the smoke test"
	@echo "  make stop         Stop the estate, keep volumes"
	@echo "  make down         Remove containers and networks, keep volumes"
	@echo "  make reset-m03    Remove everything and return to the Module 03 state"
	@echo "  make reset-m05    Remove everything and return to the Module 05 state"
	@echo "  make reset-m06    Remove everything and return to the Module 06 state"
	@echo "  make reset-m08    Remove everything and return to the Module 08 state"
	@echo "  make reset-m09    Remove everything and return to the Module 09 state"
	@echo "  make reset-m10    Remove everything and return to the Module 10 state"
	@echo "  make reset-m11    Remove everything and return to the Module 11 state"
	@echo "  make fix-m05      Restore the Module 05 DNS record"
	@echo "  make break-m05    Point the Module 05 portal name at the wrong address"
	@echo "  make fix-m08      Restore the Module 08 reporting group membership"
	@echo "  make break-m08    Remove the reporting service from the reporting group"
	@echo "  make fix-m09      Repair the Module 09 share permissions"
	@echo "  make break-m09    Put the Module 09 share back into the broken state"
	@echo "  make fix-m10      Restore the Module 10 backup command"
	@echo "  make break-m10    Put the Module 10 backup back into the schema-only fault"
	@echo "  make fix-m11      Close the admin leak and rotate the secret"
	@echo "  make break-m11    Reintroduce the admin leak and the weak secret mode"
	@echo "  make check-m11    Verify the leak is closed and the secret is rotated"
	@echo ""
	@echo "  Podman: make m06 CONTAINER_ENGINE=podman"

m03:
	$(COMPOSE) --profile m03 up -d

m05:
	$(COMPOSE) --profile m03 --profile m05 up -d

m06:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 up -d

m08:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 up -d

m09:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 up -d

m10:
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 --profile m10 up -d

m11:
	$(COMPOSE) $(ALL_PROFILES) up -d

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

reset-m08:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 up -d

reset-m09:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 up -d

reset-m10:
	$(COMPOSE) $(ALL_PROFILES) down -v --remove-orphans
	$(COMPOSE) --profile m03 --profile m05 --profile m06 --profile m08 --profile m09 --profile m10 up -d

reset-m11:
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

fix-m08:
	./scenarios/m08/fix.sh

break-m08:
	./scenarios/m08/break.sh

fix-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown -R 1000:1000 /share && chmod 775 /share'

break-m09:
	$(COMPOSE) --profile m09 run --rm --user root writer sh -c 'chown root:root /share && chmod 755 /share'

fix-m10:
	./scenarios/m10/fix.sh

break-m10:
	./scenarios/m10/break.sh

fix-m11:
	./scenarios/m11/fix.sh

break-m11:
	./scenarios/m11/break.sh

check-m11:
	./scenarios/m11/check.sh
