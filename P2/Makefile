SHELL := /bin/sh

.PHONY: all static multicast test test-static test-multicast reset ps

all: static test

static:
	@./setup.sh static

multicast:
	@./setup.sh multicast

test:
	@./test.sh

test-static: static test

test-multicast: multicast test

reset:
	@./setup.sh reset

ps:
	@docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E 'NAMES|moouahab'
