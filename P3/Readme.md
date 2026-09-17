# P3 — BGP EVPN/VXLAN

La topologie forme un petit fabric datacenter :

```text
                    _moouahab-1
                  Route Reflector
                     1.1.1.1
                 /      |      \
        _moouahab-2  _moouahab-3  _moouahab-4
          VTEP .2      VTEP .3      VTEP .4
             |            |            |
          host-1        host-2        host-3
         20.1.1.1      20.1.1.2      20.1.1.3
```

## Fonctionnement

- OSPF area 0 annonce les loopbacks `1.1.1.1/32` à `1.1.1.4/32` dans l'underlay.
- iBGP AS 65000 transporte la famille `l2vpn evpn`.
- `_moouahab-1` est le route reflector; les trois feuilles sont ses clients EVPN.
- Chaque feuille est un VTEP et relie `eth1` au VXLAN VNI 10 via `br0`.
- Les routes EVPN type 3 annoncent les VTEP; les routes type 2 annoncent les MAC des hôtes.

## Automatisation

Après avoir ouvert le projet portable et démarré ses nœuds :

```sh
make setup   # applique toute la configuration
make test    # valide OSPF, BGP EVPN, VNI, type 2 et les pings
make status  # affiche les preuves utiles pour la soutenance
make reset   # remet les routeurs à zéro
```

Depuis la racine du dépôt, `make p3` enchaîne la mise en place et tous les tests.
