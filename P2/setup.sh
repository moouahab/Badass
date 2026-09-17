#!/bin/sh
set -eu
cd "$(dirname "$0")"
. ./lib.sh

mode="${1:-static}"
case "$mode" in static|multicast|reset) ;; *) die "usage: $0 {static|multicast|reset}" ;; esac

r1=$(container_for routeur_moouahab-1)
r2=$(container_for routeur_moouahab-2)
run_script "$r1" reset.sh
run_script "$r2" reset.sh
[ "$mode" = reset ] && { ok "P2 réinitialisé"; exit 0; }

h1=$(container_for host_moouahab-1)
h2=$(container_for host_moouahab-2)
run_script "$r1" "r1_${mode}.sh"
run_script "$r2" "r2_${mode}.sh"
run_script "$h1" h1.sh
run_script "$h2" h2.sh
ok "P2 configuré en VXLAN $mode (VNI 10)"
