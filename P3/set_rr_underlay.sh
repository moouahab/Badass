#!/bin/sh

echo "[+] RR underlay setup"

# clean
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr flush dev eth2 2>/dev/null
ip addr flush dev lo 2>/dev/null

# loopback
ip addr add 1.1.1.1/32 dev lo
ip link set lo up

# links to leaves
ip addr add 10.1.1.1/30 dev eth0
ip addr add 10.1.1.5/30 dev eth1
ip addr add 10.1.1.9/30 dev eth2

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 1 > /proc/sys/net/ipv4/ip_forward

echo "[OK] RR underlay configured"
ip a
