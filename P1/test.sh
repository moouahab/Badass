#!/bin/sh
set -eu

fail() { printf 'ERREUR: %s\n' "$*" >&2; exit 1; }
for image in moouahab-host:latest moouahab-router:latest; do
    docker image inspect "$image" >/dev/null 2>&1 || fail "image absente: $image (lancez make build)"
done

docker run --rm moouahab-host:latest sh -c 'command -v busybox >/dev/null' || fail "BusyBox absent de l'image hôte"
docker run --rm --privileged moouahab-router:latest sh -c '
    /usr/lib/frr/frrinit.sh start >/dev/null
    sleep 2
    for daemon in zebra bgpd ospfd isisd; do pidof "$daemon" >/dev/null || exit 1; done
 ' || fail "un ou plusieurs démons FRR sont absents"
grep -RqiE 'ip addr(ess)? add|address [0-9]+\.' docker/host docker/router && fail "une IP statique est configurée dans une image"
printf '[OK] P1: images, BusyBox, Zebra, BGP, OSPF et IS-IS validés\n'
