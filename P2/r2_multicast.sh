#!/bin/sh

ip addr add 192.168.100.2/24 dev eth0
ip link set eth0 up

ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up

ip link add vxlan10 type vxlan id 10 group 239.1.1.1 dev eth0 dstport 4789
ip link set vxlan10 up
ip link set vxlan10 master br0

echo "R2 multicast configured"
