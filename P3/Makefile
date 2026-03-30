# ===== CONTAINERS =====

RR := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-1')
L2 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-2')
L3 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-3')
L4 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3._moouahab-4')

H1 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-1')
H2 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-2')
H3 := $(shell docker ps --format '{{.Names}}' | grep '^GNS3.host_moouahab-3')

# ===== CHECK =====

check:
	@if [ -z "$(RR)" ] || [ -z "$(L2)" ] || [ -z "$(L3)" ] || [ -z "$(L4)" ] || \
	   [ -z "$(H1)" ] || [ -z "$(H2)" ] || [ -z "$(H3)" ]; then \
		echo "Containers not found. Start GNS3."; \
		exit 1; \
	fi

# ===== UNDERLAY =====

underlay: check
	@echo "[+] Setup UNDERLAY"
	cat set_rr_underlay.sh | docker exec -i $(RR) sh
	cat set_leaf_underlay.sh | docker exec -i $(L2) sh -s 2
	cat set_leaf_underlay.sh | docker exec -i $(L3) sh -s 3
	cat set_leaf_underlay.sh | docker exec -i $(L4) sh -s 4
	@echo "[OK] Underlay configured"

# ===== HOSTS (EVPN MODE) =====

hosts: check
	@echo "[+] Setup EVPN hosts"
	cat set_host_evpn.sh | docker exec -i $(H1) sh -s 1
	cat set_host_evpn.sh | docker exec -i $(H2) sh -s 2
	cat set_host_evpn.sh | docker exec -i $(H3) sh -s 3
	@echo "[OK] Hosts configured"

ospf: check
	@echo "[+] Setup OSPF"
	cat set_ospf.sh | docker exec -i $(RR) sh
	cat set_ospf.sh | docker exec -i $(L2) sh
	cat set_ospf.sh | docker exec -i $(L3) sh
	cat set_ospf.sh | docker exec -i $(L4) sh
	@echo "[OK] OSPF configured"


# ===== ALL =====

all: underlay hosts ospf

# ===== TEST =====

test:
	@echo "[+] Testing UNDERLAY"
	docker exec $(L2) ping -c 2 10.1.1.1
	docker exec $(L3) ping -c 2 10.1.1.5
	docker exec $(L4) ping -c 2 10.1.1.9
	@echo "[OK] Underlay test done"

# ===== DEBUG =====

ps:
	docker ps | grep GNS3
