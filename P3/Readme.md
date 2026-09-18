# P3 — Fabric VXLAN avec BGP EVPN

P3 construit un petit fabric de datacenter. Trois feuilles fournissent les VTEP VXLAN et un quatrième routeur sert de **route reflector**. OSPF assure la connectivité IP de l'underlay ; iBGP EVPN distribue les informations nécessaires à l'overlay.

## Topologie

```text
                            _moouahab-1
                         RR — 1.1.1.1/32
                       /         |         \
           10.1.1.0/30    10.1.1.4/30    10.1.1.8/30
                    /           |           \
          _moouahab-2      _moouahab-3      _moouahab-4
          VTEP 1.1.1.2     VTEP 1.1.1.3     VTEP 1.1.1.4
                |                |                |
             host-1           host-2           host-3
          20.1.1.1/24      20.1.1.2/24      20.1.1.3/24
```

Le RR distribue les routes mais n'est pas dans le chemin VXLAN : le trafic circule directement entre VTEP.

## Plan d'adressage

| Nœud | Loopback/VTEP | Underlay | Côté hôte |
|---|---|---|---|
| RR | `1.1.1.1/32` | `.1/30`, `.5/30`, `.9/30` | — |
| Leaf 2 | `1.1.1.2/32` | `10.1.1.2/30` sur `eth0` | `eth1` dans `br0` |
| Leaf 3 | `1.1.1.3/32` | `10.1.1.6/30` sur `eth0` | `eth1` dans `br0` |
| Leaf 4 | `1.1.1.4/32` | `10.1.1.10/30` sur `eth0` | `eth1` dans `br0` |
| Hosts 1–3 | — | — | `20.1.1.1–3/24` |

Les `/30` forment trois liens point à point. Les loopbacks stables servent de router-id, d'extrémités iBGP et d'adresses VTEP.

## Underlay OSPF

OSPF area 0 annonce toutes les loopbacks. Le RR forme trois voisinages sur `eth0`, `eth1` et `eth2`. Chaque feuille forme un voisinage sur `eth0`. Les loopbacks sont annoncées en passif : elles ne forment pas de voisinage.

La connectivité OSPF doit être établie avant BGP, puisque les sessions utilisent les loopbacks.

## Plan de contrôle iBGP EVPN

Tous les routeurs sont dans l'AS `65000`. Le RR maintient une session avec chaque feuille dans la famille `l2vpn evpn` et leur applique `route-reflector-client`. Les feuilles n'ont donc pas besoin d'un maillage iBGP complet.

`no bgp default ipv4-unicast` désactive l'activation implicite d'IPv4 unicast : seule la famille EVPN demandée est utilisée.

## Plan de données VXLAN

Chaque feuille crée `br0`, y attache `eth1` et `vxlan10`, puis associe le VXLAN au VNI `10`, à UDP `4789` et à sa loopback locale. `nolearning` indique que les destinations distantes sont apprises par EVPN.

Les trois hôtes appartiennent au même domaine Ethernet `20.1.1.0/24`.

## Routes EVPN

- **Type 2 (MAC/IP Advertisement)** : indique derrière quel VTEP se trouve une MAC/IP.
- **Type 3 (Inclusive Multicast Ethernet Tag)** : annonce la participation d'un VTEP au VNI et sert au trafic BUM.

`advertise-all-vni` annonce les VNI du noyau Linux. Le RR reçoit puis réfléchit ces routes.

## Automatisation

Après avoir ouvert P3 et démarré ses sept nœuds :

```sh
make p3
```

`setup.sh` détecte les conteneurs, configure l'underlay, OSPF, le RR, les feuilles/VXLAN puis les hôtes. Les noms GNS3 ont la forme `GNS3.<nœud>.<UUID>` ; `lib.sh` accepte ce suffixe mais exige une seule correspondance.

`test.sh` attend la convergence puis vérifie :

- trois voisins OSPF `Full` sur le RR ;
- une session EVPN établie pour chaque feuille ;
- le VNI 10 sur chaque feuille ;
- les pings entre les trois hôtes ;
- au moins une route EVPN type 2 sur le RR.

Une valeur numérique dans `State/PfxRcd` signifie que BGP est établi et indique le nombre de préfixes reçus.

Résultat attendu :

```text
[OK] P3: OSPF, BGP EVPN, VNI 10, routes type 2 et pings inter-hôtes validés
```

## Commandes

```sh
make setup   # applique toute la configuration
make test    # valide OSPF, BGP EVPN, VNI, type 2 et les pings
make status  # affiche les preuves utiles pour la soutenance
make reset   # remet les routeurs à zéro
make ps      # liste les conteneurs utiles
```

Depuis la racine, `make p3` enchaîne setup et test.

## Diagnostic

```sh
# Sur le RR
docker exec <RR> vtysh -c 'show ip ospf neighbor'
docker exec <RR> vtysh -c 'show ip route ospf'
docker exec <RR> vtysh -c 'show bgp l2vpn evpn summary'
docker exec <RR> vtysh -c 'show bgp l2vpn evpn'
docker exec <RR> vtysh -c 'show bgp l2vpn evpn route type macip'

# Sur une feuille
docker exec <LEAF> ip -d link show vxlan10
docker exec <LEAF> bridge link
docker exec <LEAF> bridge fdb show br br0
docker exec <LEAF> ping -c 3 1.1.1.1
docker exec <LEAF> tcpdump -ni eth0 udp port 4789
```

Ordre de dépannage :

1. **Conteneur absent** : démarrer uniquement P3 et vérifier `docker ps`.
2. **OSPF non Full** : vérifier liens, adresses `/30`, interfaces et configuration OSPF.
3. **BGP Idle/Connect/Active** : tester le ping des loopbacks, l'AS, `update-source lo` et la famille EVPN.
4. **Aucune route type 2** : vérifier `br0`, `vxlan10`, `eth1` et générer du trafic ARP avec un ping.
5. **Routes présentes mais ping en échec** : contrôler FDB, VNI, UDP 4789 et connectivité entre VTEP.

L'avertissement FRR sur `passive-interface lo` est une recommandation liée aux VRF, pas un échec ; les tests confirment que la configuration fonctionne.
