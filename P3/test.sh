#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./lib.sh
rr=$(container_for _moouahab-1)
l2=$(container_for _moouahab-2)
l3=$(container_for _moouahab-3)
l4=$(container_for _moouahab-4)
h1=$(container_for host_moouahab-1)
h2=$(container_for host_moouahab-2)
h3=$(container_for host_moouahab-3)
wait_for "3 voisins OSPF sur le RR" sh -c "docker exec '$rr' vtysh -c 'show ip ospf neighbor' | grep -c Full | grep -q '^3$'"
for leaf in "$l2" "$l3" "$l4"; do
    wait_for "session BGP EVPN de $leaf" sh -c "docker exec '$leaf' vtysh -c 'show bgp l2vpn evpn neighbors 1.1.1.1' | grep -q 'BGP state = Established'"
    docker exec "$leaf" ip -d link show vxlan10 | grep -q 'vxlan id 10' || die "$leaf: VNI 10 absent"
done
docker exec "$h1" ping -c 3 -W 2 20.1.1.2 >/dev/null || die "H1 -> H2 inaccessible via EVPN"
docker exec "$h1" ping -c 3 -W 2 20.1.1.3 >/dev/null || die "H1 -> H3 inaccessible via EVPN"
docker exec "$h3" ping -c 3 -W 2 20.1.1.1 >/dev/null || die "H3 -> H1 inaccessible via EVPN"
docker exec "$rr" vtysh -c 'show bgp l2vpn evpn route type macip' | grep -q '\[2\]:' || die "aucune route EVPN type 2 sur le RR"
ok "P3: OSPF, BGP EVPN, VNI 10, routes type 2 et pings inter-hôtes validés"
