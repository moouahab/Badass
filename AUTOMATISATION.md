# Automatisation BADASS

## Préparation

1. Démarrer Docker Desktop et GNS3.
2. Construire les images avec `make build`.
3. Générer les projets portables avec `make export`, puis ouvrir une première fois dans GNS3 le projet de la partie testée afin de l'importer.
4. Les lancements suivants sont automatisés avec `make start-p1`, `make start-p2` ou `make start-p3`. Garder un seul projet ouvert à la fois.

## Commandes

- `make test-p1` vérifie les images, l'absence d'IP par défaut et les services Zebra, BGP, OSPF et IS-IS.
- `make p2-static` applique le VXLAN unicast VNI 10 et teste l'underlay, le bridge et les pings.
- `make p2-multicast` applique le VXLAN multicast `239.1.1.1` et exécute les mêmes tests.
- `make p3` configure l'underlay, OSPF, le route reflector iBGP EVPN, les trois VTEP, le VNI 10 et les hôtes, puis vérifie les voisinages, routes type 2 et pings.
- `make -C P3 status` affiche les voisins et routes pour la soutenance.
- `make stop-p1`, `make stop-p2` et `make stop-p3` arrêtent et ferment proprement les projets via l'API GNS3.
- `make check` valide la syntaxe de tous les scripts sans toucher au réseau.

Les scripts sont idempotents : une même commande peut être rejouée pour remettre la topologie dans l'état attendu.
