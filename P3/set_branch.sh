#!/bin/sh

# Usage:
# sh setup_branch.sh <id>
# Exemple:
# sh setup_branch.sh 1   -> pour _moouahab-2
# sh setup_branch.sh 2   -> pour _moouahab-3
# sh setup_branch.sh 3   -> pour _moouahab-4

ID="$1"

if [ -z "$ID" ]; then
    echo "Usage: sh setup_branch.sh <id>"
    exit 1
fi

WAN_IF="eth0"
LAN_IF="eth1"

WAN_IP="10.0.${ID}.2/24"
LAN_IP="192.168.${ID}.1/24"
GW_IP="10.0.${ID}.1"

echo "[+] Setup branch $ID"

# Activer le forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Nettoyage
ip addr flush dev "$WAN_IF" 2>/dev/null
ip addr flush dev "$LAN_IF" 2>/dev/null
ip route del default 2>/dev/null

# Configuration interfaces
ip addr add "$WAN_IP" dev "$WAN_IF"
ip link set "$WAN_IF" up

ip addr add "$LAN_IP" dev "$LAN_IF"
ip link set "$LAN_IF" up

# Route par défaut vers le gateway
ip route add default via "$GW_IP"

echo "[OK] Branch $ID configured"
echo "    $WAN_IF -> $WAN_IP"
echo "    $LAN_IF -> $LAN_IP"
echo "    default via $GW_IP"
