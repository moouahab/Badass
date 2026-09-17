#!/bin/sh
# Utilise le shell /bin/sh pour exécuter le script

# Attribution de l’adresse IP 10.0.0.2 avec un masque /24
# /24 = 255.255.255.0
# Cela place cette machine dans le réseau 10.0.0.0/24
ip addr flush dev eth0
ip addr add 10.0.0.2/24 dev eth0

# Activation de l’interface réseau eth0
# Sans cette commande, l’interface reste DOWN
ip link set eth0 up
