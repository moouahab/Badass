# ===== CONTAINERS =====

GW := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-1')
R2 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-2')
R3 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-3')
R4 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-4')

H1 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-1')
H2 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-2')
H3 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-3')

# ===== CHECK =====

check:
	@if [ -z "$(GW)" ] || [ -z "$(R2)" ] || [ -z "$(R3)" ] || [ -z "$(R4)" ] || \
	   [ -z "$(H1)" ] || [ -z "$(H2)" ] || [ -z "$(H3)" ]; then \
		echo "Containers not found. Start GNS3."; \
		exit 1; \
	fi

# ===== SETUP =====

gateway: check
	cat set_getway.sh | docker exec -i $(GW) sh
	@echo "[OK] Gateway configured"

branches: check
	cat set_branch.sh | docker exec -i $(R2) sh -s 1
	cat set_branch.sh | docker exec -i $(R3) sh -s 2
	cat set_branch.sh | docker exec -i $(R4) sh -s 3
	@echo "[OK] Branches configured"

hosts: check
	cat setup_host.sh | docker exec -i $(H1) sh -s 1
	cat setup_host.sh | docker exec -i $(H2) sh -s 2
	cat setup_host.sh | docker exec -i $(H3) sh -s 3
	@echo "[OK] Hosts configured"

all: gateway branches hosts

# ===== TEST =====

test:
	@echo "[+] Testing connectivity"
	docker exec $(H1) ping -c 2 192.168.2.10
	docker exec $(H1) ping -c 2 192.168.3.10
	@echo "[OK] Test done"

# ===== RESET =====

reset:
	-echo "Reset not implemented"
	@echo "[OK] Reset done"

# ===== DEBUG =====

ps:
	docker ps | grep GNS3
