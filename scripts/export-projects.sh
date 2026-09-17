#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
command -v zip >/dev/null 2>&1 || { echo 'ERREUR: zip est requis' >&2; exit 1; }
for part in P1 P2 P3; do
    src="$root/$part/$part.tar"
    dst="$root/$part/$part.gns3project"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT HUP INT TERM
    tar -xf "$src" -C "$tmp"
    project_file=$(find "$tmp" -maxdepth 1 -type f -name '*.gns3' -print -quit)
    [ -n "$project_file" ] || { echo "ERREUR: aucun fichier .gns3 dans $src" >&2; exit 1; }
    mv "$project_file" "$tmp/project.gns3"
    (cd "$tmp" && zip -qr "$dst" .)
    rm -rf "$tmp"
    trap - EXIT HUP INT TERM
    printf '[OK] %s\n' "$dst"
done
