# P2 — VXLAN statique et multicast

P2 étend un même domaine Ethernet entre deux sites séparés par un réseau IP. Deux routeurs Linux jouent le rôle de **VTEP** : ils encapsulent les trames des hôtes dans UDP et les transportent sur l'underlay.

## Topologie et adressage

```text
H1 10.0.0.1/24 ─ eth1 — br0 — vxlan10  R1
                                  │
                         eth0 192.168.100.1/24
                                  ║ underlay
                         eth0 192.168.100.2/24
                                  │
H2 10.0.0.2/24 ─ eth1 — br0 — vxlan10  R2
```

| Nœud | Interface | Adresse | Fonction |
|---|---|---|---|
| R1 | `eth0` | `192.168.100.1/24` | Underlay/VTEP |
| R1 | `eth1` | aucune | Port du bridge vers H1 |
| R2 | `eth0` | `192.168.100.2/24` | Underlay/VTEP |
| R2 | `eth1` | aucune | Port du bridge vers H2 |
| H1 | `eth0` | `10.0.0.1/24` | Hôte overlay |
| H2 | `eth0` | `10.0.0.2/24` | Hôte overlay |

H1 et H2 sont dans le même sous-réseau logique malgré la séparation physique. VXLAN étend le niveau 2 ; aucune passerelle n'est nécessaire entre eux.

## Composants Linux

- `eth0` transporte les paquets underlay ;
- `eth1` est le port local relié à l'hôte ;
- `br0` est un commutateur Ethernet logiciel ;
- `vxlan10` est le port virtuel VNI 10 du bridge ;
- UDP `4789` transporte les trames encapsulées.

Une requête ARP de H1 entre par `eth1`, traverse `br0` et sort par `vxlan10`. R1 l'encapsule, R2 la décapsule puis la transmet à H2.

## Mode statique unicast

Chaque VTEP connaît explicitement l'autre : R1 utilise `remote 192.168.100.2` et R2 `remote 192.168.100.1`.

```sh
make p2-static
```

Ce mode est simple pour deux extrémités, mais devient difficile à maintenir avec beaucoup de VTEP.

## Mode multicast

Les VTEP rejoignent le groupe `239.1.1.1`. Le trafic broadcast, unknown-unicast et multicast peut être envoyé à ce groupe. L'underlay doit donc accepter le multicast.

```sh
make p2-multicast
```

La commande VXLAN centrale est :

```text
vxlan id 10 group 239.1.1.1 dev eth0 dstport 4789
```

## Déroulement de l'automatisation

`setup.sh` :

1. trouve R1 et R2 dans les conteneurs GNS3 ;
2. supprime les anciennes interfaces VXLAN, bridges et adresses ;
3. applique le mode choisi aux routeurs ;
4. configure `10.0.0.1/24` et `10.0.0.2/24` sur les hôtes.

La remise à zéro préalable rend la commande rejouable et évite les erreurs lors de la recréation de `br0` et `vxlan10`.

## Tests effectués

`test.sh` vérifie :

- `vxlan10` et le VNI 10 sur les deux routeurs ;
- l'état actif de `br0` ;
- la présence d'interfaces dans le bridge ;
- le ping underlay R1 → R2 ;
- les pings overlay H1 ↔ H2 ;
- l'apprentissage d'adresses MAC dans la FDB de R1.

Résultat attendu :

```text
[OK] P2: underlay, bridge, VNI 10 et ping bidirectionnel validés
```

## Observation et démonstration

Remplacer `<R1>` par son nom complet retourné par `docker ps` :

```sh
docker ps --format 'table {{.Names}}\t{{.Status}}'
docker exec <R1> ip address
docker exec <R1> ip -d link show vxlan10
docker exec <R1> bridge link
docker exec <R1> bridge fdb show br br0
docker exec <R1> ping -c 3 192.168.100.2
docker exec <R1> tcpdump -ni eth0 udp port 4789
```

La capture sur `eth0` montre l'encapsulation UDP lorsque l'on lance un ping entre H1 et H2.

## Réinitialisation

```sh
make -C P2 reset
```

Cette commande retire `vxlan10`, `br0` et les adresses des interfaces routeur.

## Dépannage

- **Conteneur introuvable/ambigu** : ouvrir et démarrer seulement P2, puis contrôler `docker ps`.
- **Underlay inaccessible** : vérifier les adresses `192.168.100.1/24` et `.2/24`, les liens GNS3 et l'état `UP` de `eth0`.
- **Overlay inaccessible** : vérifier le VNI, UDP 4789, les membres de `br0` et la FDB.
- **Multicast seulement en échec** : vérifier que l'underlay accepte le groupe `239.1.1.1`.
