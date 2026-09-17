SHELL := /bin/sh

.PHONY: all setup test reset ps status
all: setup test
setup:
	@./setup.sh
test:
	@./test.sh
reset:
	@./setup.sh reset
status:
	@./status.sh
ps:
	@docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E 'NAMES|moouahab'
