#!/bin/sh

# Usage:
# sh setup_host.sh <id>
# Exemple:
# sh setup_host.sh 1  -> host_moouahab-1
# sh setup_host.sh 2  -> host_moouahab-2

ID="$1"

if [ -z "$ID" ]; then
    echo "Usage: sh setup_host.sh <id>"
    exit 1
fi

IFACE="eth0"
IP="192.168.${ID}.10/24"
GW="192.168.${ID}.1"

echo "[+] Setup host $ID"

# Nettoyage
ip addr flush dev "$IFACE" 2>/dev/null
ip route del default 2>/dev/null

# Config IP
ip addr add "$IP" dev "$IFACE"
ip link set "$IFACE" up

# Gateway
ip route add default via "$GW"

echo "[OK] Host $ID configured"
echo "    IP  -> $IP"
echo "    GW  -> $GW"
