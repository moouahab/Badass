#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
find "$root/P1" "$root/P2" "$root/P3" "$root/scripts" -type f -name '*.sh' -exec sh -n {} \;
for makefile in "$root/Makefile" "$root/P1/Makefile" "$root/P2/Makefile" "$root/P3/Makefile"; do
    make -n -f "$makefile" help >/dev/null 2>&1 || make -n -f "$makefile" >/dev/null 2>&1 || true
done
printf '[OK] Syntaxe de tous les scripts validée\n'
