#!/bin/sh

# =================================
# Configuration IP pour R1 (Underlay)
# =================================

# Attribution de l'adresse IP 192.168.100.1/24 sur eth0
# Cette interface servira d’underlay (réseau IP physique)
# Elle transporte les paquets VXLAN encapsulés
ip addr add 192.168.100.1/24 dev eth0

# Activation de l’interface eth0
ip link set eth0 up


# ===================================
# Création du bridge pour relier LAN et VXLAN
# ===================================

# Création d’un bridge Linux br0
# Il agit comme un switch virtuel Layer 2
ip link add br0 type bridge

# Activation du bridge
ip link set br0 up

# Ajout de l’interface eth1 au bridge
# eth1 représente ici le LAN local (ex: machine connectée)
ip link set eth1 master br0

# Activation de eth1
ip link set eth1 up


# ===================================
# Configuration du VXLAN en mode multicast
# ===================================

# Création de l’interface VXLAN :
# id 10           → VNI (VXLAN Network Identifier)
# group 239.1.1.1 → adresse multicast utilisée pour diffuser le trafic inconnu
# dev eth0        → interface underlay utilisée pour transporter le VXLAN
# dstport 4789    → port UDP standard VXLAN
ip link add vxlan10 type vxlan id 10 group 239.1.1.1 dev eth0 dstport 4789

# Activation de l’interface VXLAN
ip link set vxlan10 up

# Ajout de l’interface VXLAN au bridge
# Cela permet de relier le LAN local au réseau VXLAN distant
ip link set vxlan10 master br0


echo "R1 multicast configured"