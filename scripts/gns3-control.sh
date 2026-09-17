#!/bin/sh
set -eu

action="${1:-}"
project="${2:-}"
[ "$action" = start ] || [ "$action" = stop ] || { echo "usage: $0 {start|stop} PROJECT" >&2; exit 2; }
[ -n "$project" ] || { echo "nom de projet manquant" >&2; exit 2; }

if command -v curl.exe >/dev/null 2>&1; then curl_cmd=curl.exe; else curl_cmd=curl; fi
base="${GNS3_URL:-http://127.0.0.1:3080/v2}"
projects=$($curl_cmd --silent --show-error --fail "$base/projects") || {
    echo "ERREUR: serveur GNS3 inaccessible sur $base" >&2; exit 1;
}
project_id=$(printf '%s' "$projects" | python3 -c '
import json, sys
name = sys.argv[1]
items = json.load(sys.stdin)
print(next((p["project_id"] for p in items if p["name"] == name), ""))
' "$project")
[ -n "$project_id" ] || {
    echo "ERREUR: projet '$project' non importé. Ouvrez une fois son fichier .gns3project dans GNS3." >&2; exit 1;
}

post() { $curl_cmd --silent --show-error --fail -X POST "$base/projects/$project_id/$1" >/dev/null; }
if [ "$action" = start ]; then
    post open
    post nodes/start
    echo "[OK] projet $project ouvert et tous les nœuds démarrés"
else
    post nodes/stop || true
    post close
    echo "[OK] projet $project arrêté et fermé"
fi
