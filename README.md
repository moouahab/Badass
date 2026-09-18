# BADASS — BGP At Doors of Autonomous Systems is Simple

Ce dépôt met en œuvre dans GNS3, avec des conteneurs Docker, une progression en trois étapes vers un réseau de datacenter VXLAN/EVPN :

1. **[P1](P1/README.md)** construit les images Docker des hôtes et des routeurs FRRouting.
2. **[P2](P2/README.md)** crée un tunnel VXLAN entre deux VTEP, en unicast statique ou en multicast.
3. **[P3](P3/Readme.md)** remplace la découverte statique par BGP EVPN, avec OSPF pour l'underlay.

## Vue d'ensemble

| Partie | Objectif | Plan de données | Plan de contrôle |
|---|---|---|---|
| P1 | Préparer les images | Docker et interfaces Linux | Services FRR disponibles |
| P2 | Étendre un LAN niveau 2 | Bridge Linux + VXLAN VNI 10 | Statique ou multicast |
| P3 | Construire un fabric EVPN | Bridge Linux + VXLAN VNI 10 | OSPF + iBGP EVPN |

### Underlay et overlay

L'**underlay** est le réseau IP qui relie les équipements. Il transporte les paquets UDP contenant le trafic VXLAN et doit fonctionner avant l'overlay.

L'**overlay** est le réseau Ethernet virtuel construit au-dessus. VXLAN encapsule une trame Ethernet dans UDP, normalement sur le port `4789`. Le **VNI** identifie le réseau virtuel ; ce dépôt utilise le VNI `10`.

```text
Trame Ethernet → bridge br0 → vxlan10 (VNI 10)
                                  ↓ encapsulation UDP/4789
                             underlay IP
                                  ↓ décapsulation
                 hôte distant ← br0 ← vxlan10
```

## Prérequis

- Docker et GNS3 opérationnels ;
- `make` et un shell POSIX ;
- `curl`, `python3` et `zip` pour contrôler et exporter les projets ;
- les droits permettant de lancer des conteneurs Docker privilégiés.

Ouvrir et démarrer **un seul projet à la fois**. Plusieurs projets contenant des nœuds de même nom rendraient la détection des conteneurs ambiguë.

## Démarrage rapide

```sh
# Construire et vérifier les images
make p1

# Générer les projets portables si nécessaire
make export

# Ouvrir P2 dans GNS3 et démarrer ses nœuds
make p2-static
# ou : make p2-multicast

# Fermer P2, ouvrir P3 et démarrer ses nœuds
make p3
```

À la première utilisation, importer le fichier `.gns3project` concerné dans GNS3. Les commandes `start-*` peuvent ensuite ouvrir le projet et démarrer ses nœuds via l'API.

## Commandes principales

| Commande | Action |
|---|---|
| `make help` | Affiche les principales cibles |
| `make build` | Construit les images hôte et routeur |
| `make test-p1` | Vérifie les images et les démons FRR |
| `make p2-static` | Configure et teste P2 en VXLAN unicast |
| `make p2-multicast` | Configure et teste P2 en VXLAN multicast |
| `make p3` | Configure et teste OSPF, iBGP EVPN et VXLAN |
| `make test-p2` / `make test-p3` | Relance seulement les tests |
| `make start-p1`, `start-p2`, `start-p3` | Ouvre le projet et démarre ses nœuds |
| `make stop-p1`, `stop-p2`, `stop-p3` | Arrête les nœuds et ferme le projet |
| `make export` | Reconstruit les projets portables depuis les archives |
| `make check` | Vérifie la syntaxe des scripts shell |

Le contrôle GNS3 utilise `http://127.0.0.1:3080/v2` par défaut. Pour un serveur différent :

```sh
GNS3_URL=http://serveur:3080/v2 make start-p3
```

## Organisation

```text
P1/          images Docker et validation de FRR
P2/          VXLAN statique et multicast
P3/          fabric OSPF + BGP EVPN + VXLAN
scripts/     validation, export et pilotage de GNS3
sujet/       sujet du projet
Makefile     point d'entrée général
```

## Méthode de diagnostic

Vérifier les couches dans cet ordre :

1. conteneurs démarrés avec `docker ps` ;
2. interfaces et adresses avec `ip address` ;
3. connectivité underlay avec `ping` ;
4. bridges/VXLAN avec `ip -d link` et `bridge link` ;
5. convergence OSPF avec `show ip ospf neighbor` ;
6. état EVPN avec `show bgp l2vpn evpn summary` ;
7. routes EVPN et entrées MAC ;
8. communication entre hôtes dans l'overlay.

Les guides de chaque partie détaillent l'architecture, l'exécution, les tests et le dépannage.
