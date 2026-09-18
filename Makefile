SHELL := /bin/sh

.PHONY: help build p1 p2-static p2-multicast p3 test-p1 test-p2 test-p3 check start-p1 start-p2 start-p3 stop-p1 stop-p2 stop-p3

help:
	@printf '%s\n' \
	  'make build          construit les deux images Docker' \
	  'make test-p1        teste les images et les services FRR' \
	  'make p2-static      configure et teste le VXLAN statique' \
	  'make p2-multicast   configure et teste le VXLAN multicast' \
	  'make p3             configure et teste OSPF/BGP EVPN' \
	  'make start-p2       ouvre et démarre P2 via l API GNS3' \
	  'make stop-p2        arrête et ferme P2 via l API GNS3' \
	  'make check          vérifie la syntaxe de toute l’automatisation'

build:
	@$(MAKE) -C P1 build
p1: build test-p1
test-p1:
	@$(MAKE) -C P1 test
p2-static:
	@$(MAKE) -C P2 test-static
p2-multicast:
	@$(MAKE) -C P2 test-multicast
p3:
	@$(MAKE) -C P3 all
test-p2:
	@$(MAKE) -C P2 test
test-p3:
	@$(MAKE) -C P3 test
start-p1:
	@./scripts/gns3-control.sh start gns3-P1
start-p2:
	@./scripts/gns3-control.sh start gns3-p2
start-p3:
	@./scripts/gns3-control.sh start gns3-P3-1-1
stop-p1:
	@./scripts/gns3-control.sh stop gns3-P1
stop-p2:
	@./scripts/gns3-control.sh stop gns3-p2
stop-p3:
	@./scripts/gns3-control.sh stop gns3-P3-1-1
check:
	@./scripts/check.sh
