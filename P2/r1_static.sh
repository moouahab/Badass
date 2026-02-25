#!/bin/sh

# =================================
# Configuration Underlay (réseau IP physique)
# =================================

# Attribution de l’adresse IP 192.168.100.1/24 sur eth0
# Cette interface transporte les paquets VXLAN encapsulés (UDP 4789)
ip addr add 192.168.100.1/24 dev eth0

# Activation de l’interface underlay
ip link set eth0 up


# =================================
# Création du bridge Layer 2
# =================================

# Création d’un bridge Linux (switch virtuel)
ip link add br0 type bridge

# Activation du bridge
ip link set br0 up

# Ajout de l’interface LAN locale (eth1) au bridge
# Cela permet aux machines locales de rejoindre le domaine Layer 2
ip link set eth1 master br0

# Activation de l’interface LAN
ip link set eth1 up


# =================================
# Configuration VXLAN en mode static (unicast)
# =================================

# Création de l’interface VXLAN :
# id 10                 → VNI (identifiant du réseau virtuel)
# dev eth0              → interface underlay utilisée
# remote 192.168.100.2  → IP du VTEP distant (envoi direct en unicast)
# dstport 4789          → port UDP standard VXLAN
ip link add vxlan10 type vxlan id 10 dev eth0 remote 192.168.100.2 dstport 4789

# Activation de l’interface VXLAN
ip link set vxlan10 up

# Ajout de l’interface VXLAN au bridge
# Cela relie le LAN local au tunnel VXLAN
ip link set vxlan10 master br0