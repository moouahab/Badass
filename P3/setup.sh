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
if [ "${1:-}" = reset ]; then
    for router in "$rr" "$l2" "$l3" "$l4"; do run_script "$router" reset.sh; done
    ok "P3 réinitialisé"
    exit 0
fi
run_script "$rr" set_rr_underlay.sh
run_script "$l2" set_leaf_underlay.sh 2
run_script "$l3" set_leaf_underlay.sh 3
run_script "$l4" set_leaf_underlay.sh 4
run_script "$rr" set_rr_controlplane.sh
run_script "$l2" set_leaf_evpn.sh 2
run_script "$l3" set_leaf_evpn.sh 3
run_script "$l4" set_leaf_evpn.sh 4
run_script "$h1" set_host_evpn.sh 1
run_script "$h2" set_host_evpn.sh 2
run_script "$h3" set_host_evpn.sh 3
ok "P3 configuré: OSPF + iBGP EVPN + VXLAN VNI 10"
