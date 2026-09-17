#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./lib.sh
rr=$(container_for _moouahab-1)
printf '\n=== OSPF ===\n'
docker exec "$rr" vtysh -c 'show ip ospf neighbor'
printf '\n=== BGP EVPN ===\n'
docker exec "$rr" vtysh -c 'show bgp l2vpn evpn summary'
printf '\n=== Routes EVPN ===\n'
docker exec "$rr" vtysh -c 'show bgp l2vpn evpn'
