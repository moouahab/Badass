# P1 — Images Docker pour GNS3

P1 prépare les deux images réutilisées dans les autres parties. Elles restent génériques : aucune adresse IP de topologie n'y est inscrite.

## Images

| Image | Base | Rôle | Contenu principal |
|---|---|---|---|
| `moouahab-host:latest` | Alpine 3.20 | Machine terminale | BusyBox, iproute2, ping, tcpdump, bash |
| `moouahab-router:latest` | Debian Bookworm | Routeur/VTEP | FRRouting, iproute2, ping, tcpdump, tini |

### Hôte

`docker/host/Dockerfile` utilise Alpine pour obtenir une image légère. `iproute2` configure les interfaces, `ping` valide la connectivité et `tcpdump` observe les paquets. La commande par défaut est `sh` ; GNS3 attache les interfaces, puis les scripts P2/P3 les configurent avec `docker exec`.

### Routeur

`docker/router/Dockerfile` installe FRRouting. Le fichier `daemons` active :

- `zebra`, interface entre FRR et la table de routage Linux ;
- `bgpd`, pour BGP et EVPN ;
- `ospfd`, pour l'underlay de P3 ;
- `isisd`, demandé et validé dans P1.

`frr.conf` fournit une configuration initiale minimale. `tini`, utilisé comme PID 1, gère proprement les signaux et les processus enfants. Le conteneur routeur doit être privilégié pour manipuler la pile réseau.

## Construction

```sh
make build                    # depuis la racine
make -C P1 build              # deux images
make -C P1 build-host         # hôte seulement
make -C P1 build-router       # routeur seulement
```

Docker télécharge les bases si nécessaire, installe les paquets, copie la configuration FRR et crée les deux tags `latest`.

## Validation

```sh
make test-p1
```

`P1/test.sh` contrôle :

1. l'existence des deux images ;
2. la présence de BusyBox dans l'hôte ;
3. le démarrage de FRR dans le routeur ;
4. l'activité de Zebra, BGP, OSPF et IS-IS ;
5. l'absence d'adresse IP statique dans les images.

Cette dernière règle permet de réutiliser la même image pour tous les nœuds. Résultat attendu :

```text
[OK] P1: images, BusyBox, Zebra, BGP, OSPF et IS-IS validés
```

## Autres commandes

```sh
make -C P1 run-host     # shell dans un hôte temporaire
make -C P1 run-router   # routeur temporaire privilégié
make -C P1 clean        # supprime les images locales
make -C P1 re           # supprime puis reconstruit
```

Après une reconstruction, redémarrer les nœuds GNS3 pour utiliser l'image à jour. Le fichier `P1/P1.gns3project` peut être importé directement dans GNS3.

## Dépannage

- **Image absente** : exécuter `make build`, puis vérifier `docker image ls`.
- **Démon FRR absent** : vérifier `docker/router/daemons` et les privilèges du conteneur.
- **Ancienne image dans GNS3** : contrôler le tag du template, puis recréer ou redémarrer le nœud.

Diagnostic manuel :

```sh
docker run --rm --privileged moouahab-router:latest \
  sh -c '/usr/lib/frr/frrinit.sh start; ps aux; cat /etc/frr/daemons'
```
