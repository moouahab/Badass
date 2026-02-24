#!/bin/sh

# Delete VXLAN
ip link delete vxlan10 2>/dev/null

# Delete bridge
ip link delete br0 2>/dev/null

# Flush IP
ip addr flush dev eth0
ip addr flush dev eth1

echo "Reset complete"
