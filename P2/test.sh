#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./lib.sh

r1=$(container_for routeur_moouahab-1)
r2=$(container_for routeur_moouahab-2)
h1=$(container_for host_moouahab-1)
h2=$(container_for host_moouahab-2)

for router in "$r1" "$r2"; do
    docker exec "$router" ip -d link show vxlan10 | grep -q 'vxlan id 10' || die "$router: VNI 10 absent"
    docker exec "$router" ip link show br0 | grep -q 'state UP' || die "$router: bridge br0 inactif"
    docker exec "$router" bridge link | grep -q 'master br0' || die "$router: aucune interface dans br0"
done
docker exec "$r1" ping -c 2 -W 2 192.168.100.2 >/dev/null || die "underlay R1 -> R2 inaccessible"
docker exec "$h1" ping -c 3 -W 2 10.0.0.2 >/dev/null || die "overlay H1 -> H2 inaccessible"
docker exec "$h2" ping -c 3 -W 2 10.0.0.1 >/dev/null || die "overlay H2 -> H1 inaccessible"
docker exec "$r1" bridge fdb show br br0 | grep -vq '^$' || die "table MAC vide sur R1"
ok "P2: underlay, bridge, VNI 10 et ping bidirectionnel validés"
