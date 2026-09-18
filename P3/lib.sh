#!/bin/sh
set -eu
die() { printf 'ERREUR: %s\n' "$*" >&2; exit 1; }
ok() { printf '[OK] %s\n' "$*"; }
container_for() {
    node="$1"
    # GNS3 names Docker nodes as GNS3.<node>.<project UUID>.
    matches=$(docker ps --format '{{.Names}}' | grep -E "(^|[._-])${node}(\.[[:xdigit:]-]+)?$" || true)
    count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')
    [ "$count" -eq 1 ] || die "conteneur '$node' introuvable ou ambigu ($count résultat(s)). Ouvrez et démarrez uniquement P3 dans GNS3."
    printf '%s\n' "$matches"
}
run_script() {
    container="$1" script="$2" arg="${3:-}"
    if [ -n "$arg" ]; then docker exec -i "$container" sh -s -- "$arg" < "$script"
    else docker exec -i "$container" sh < "$script"
    fi
}
wait_for() {
    label="$1"; shift
    tries=20
    while [ "$tries" -gt 0 ]; do
        "$@" >/dev/null 2>&1 && return 0
        tries=$((tries - 1)); sleep 1
    done
    die "délai dépassé: $label"
}
