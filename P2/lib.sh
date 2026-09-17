#!/bin/sh
set -eu

die() { printf 'ERREUR: %s\n' "$*" >&2; exit 1; }
ok() { printf '[OK] %s\n' "$*"; }

container_for() {
    node="$1"
    matches=$(docker ps --format '{{.Names}}' | grep -E "(^|[._-])${node}(-[0-9]+)?$" || true)
    count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')
    [ "$count" -eq 1 ] || die "conteneur '$node' introuvable ou ambigu ($count résultat(s)). Ouvrez et démarrez P2 dans GNS3."
    printf '%s\n' "$matches"
}

run_script() {
    container="$1"
    script="$2"
    docker exec -i "$container" sh < "$script"
}
