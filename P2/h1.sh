#!/bin/sh

# On attribue l’adresse IP 10.0.0.1 avec un masque /24 (255.255.255.0)
# à l’interface réseau eth0
# Cela définit l’adresse de la machine sur le réseau local
ip addr flush dev eth0
ip addr add 10.0.0.1/24 dev eth0

# On active l’interface réseau eth0
# Sans cette commande, l’interface resterait désactivée (DOWN)
ip link set eth0 up
