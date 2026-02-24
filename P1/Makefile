# ===============================
# P1 - GNS3 Docker Build
# ===============================

HOST_IMAGE = moouahab-host
ROUTER_IMAGE = moouahab-router

HOST_TAG = latest
ROUTER_TAG = latest

DOCKER_HOST_DIR = docker/host
DOCKER_ROUTER_DIR = docker/router

# ===============================

all: build

build: build-host build-router

build-host:
	docker build -t $(HOST_IMAGE):$(HOST_TAG) $(DOCKER_HOST_DIR)

build-router:
	docker build -t $(ROUTER_IMAGE):$(ROUTER_TAG) $(DOCKER_ROUTER_DIR)

run-host:
	docker run -it --rm $(HOST_IMAGE):$(HOST_TAG)

run-router:
	docker run -it --rm --privileged $(ROUTER_IMAGE):$(ROUTER_TAG)

clean:
	docker rmi -f $(HOST_IMAGE):$(HOST_TAG) || true
	docker rmi -f $(ROUTER_IMAGE):$(ROUTER_TAG) || true

re: clean build

.PHONY: all build build-host build-router run-host run-router clean re
