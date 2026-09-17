#!/bin/sh

# Delete VXLAN
ip link delete vxlan10 2>/dev/null

# Delete bridge
ip link delete br0 2>/dev/null

# Flush IP
ip addr flush dev eth0
ip addr flush dev eth1

ip link set eth0 up 2>/dev/null || true
ip link set eth1 up 2>/dev/null || true

echo "Reset complete"
