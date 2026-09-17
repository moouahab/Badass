#!/bin/sh

ID="$1"

if [ -z "$ID" ]; then
    echo "Usage: sh set_leaf_underlay.sh <id>"
    exit 1
fi

echo "[+] Leaf underlay setup for leaf $ID"

# clean VXLAN
ip link del vxlan10 2>/dev/null
ip link del br0 2>/dev/null


# clean IP
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr flush dev lo 2>/dev/null
ip addr add 127.0.0.1/8 dev lo

case "$ID" in
    2)
        LO="1.1.1.2/32"
        WAN="10.1.1.2/30"
        ;;
    3)
        LO="1.1.1.3/32"
        WAN="10.1.1.6/30"
        ;;
    4)
        LO="1.1.1.4/32"
        WAN="10.1.1.10/30"
        ;;
    *)
        echo "Leaf must be 2, 3 or 4"
        exit 1
        ;;
esac

ip addr add "$LO" dev lo
ip link set lo up

ip addr add "$WAN" dev eth0
ip link set eth0 up

# eth1 = côté host, laissé sans IP pour l’instant
ip link set eth1 up

echo 1 > /proc/sys/net/ipv4/ip_forward

echo "[OK] Leaf $ID underlay configured"
ip a
