R1 := $(shell docker ps --format '{{.Names}}' | grep routeur_moouahab-1)
R2 := $(shell docker ps --format '{{.Names}}' | grep routeur_moouahab-2)
H1 := $(shell docker ps --format '{{.Names}}' | grep host_moouahab-1)
H2 := $(shell docker ps --format '{{.Names}}' | grep host_moouahab-2)

check:
	@if [ -z "$(R1)" ] || [ -z "$(R2)" ] || [ -z "$(H1)" ] || [ -z "$(H2)" ]; then \
		echo "Containers not found. Start GNS3 first."; \
		exit 1; \
	fi

static: check reset
	cat r1_static.sh | docker exec -i $(R1) sh
	cat r2_static.sh | docker exec -i $(R2) sh
	cat h1.sh | docker exec -i $(H1) sh
	cat h2.sh | docker exec -i $(H2) sh
	@echo "Static VXLAN configured."

multicast: check reset
	cat r1_multicast.sh | docker exec -i $(R1) sh
	cat r2_multicast.sh | docker exec -i $(R2) sh
	cat h1.sh | docker exec -i $(H1) sh
	cat h2.sh | docker exec -i $(H2) sh
	@echo "Multicast VXLAN configured."

test:
	docker exec $(H1) ping -c 4 10.0.0.2

reset:
	-cat reset.sh | docker exec -i $(R1) sh
	-cat reset.sh | docker exec -i $(R2) sh
	@echo "Reset complete."

ps:
	docker ps | grep GNS3
