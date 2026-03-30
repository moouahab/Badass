#!/bin/sh

# === CONFIG ===
N=3   # nombre de branches
echo "[+] Setup gateway..."

# Activer le forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# Config interfaces + routes
i=1
while [ $i -le $N ]; do
    iface="eth$((i-1))"
    echo "[+] Config $iface -> 10.0.$i.1"
    ip addr add 10.0.$i.1/24 dev $iface
    ip link set $iface up
    echo "[+] Route vers 192.168.$i.0/24"
    ip route add 192.168.$i.0/24 via 10.0.$i.2 dev $iface
    i=$((i+1))
done
echo "[+] Gateway ready"
