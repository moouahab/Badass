#!/bin/sh
set -eu
ip link del vxlan10 2>/dev/null || true
ip link del br0 2>/dev/null || true
for dev in eth0 eth1 eth2; do
    ip addr flush dev "$dev" 2>/dev/null || true
    ip link set "$dev" up 2>/dev/null || true
done
ip addr flush dev lo 2>/dev/null || true
ip addr add 127.0.0.1/8 dev lo
ip link set lo up
vtysh -c 'configure terminal' -c 'no router bgp 65000' -c 'no router ospf' -c 'end' -c 'write memory' 2>/dev/null || true
