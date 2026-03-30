#!/bin/sh

ID="$1"

if [ -z "$ID" ]; then
    echo "Usage: sh set_host_evpn.sh <id>"
    exit 1
fi

case "$ID" in
    1) IP="20.1.1.1/24" ;;
    2) IP="20.1.1.2/24" ;;
    3) IP="20.1.1.3/24" ;;
    *)
        echo "Host must be 1, 2 or 3"
        exit 1
        ;;
esac

ip addr flush dev eth0 2>/dev/null
ip addr add "$IP" dev eth0
ip link set eth0 up

echo "[OK] Host $ID configured with $IP"
ip a
