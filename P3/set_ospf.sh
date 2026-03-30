#!/bin/sh

RID=$(ip -4 addr show lo | awk '/inet / {print $2}' | cut -d/ -f1)

echo "[+] Setup OSPF CLEAN with router-id $RID"

HOST=$(hostname)

vtysh << EOF
configure terminal

no router ospf

router ospf
 ospf router-id $RID
EOF

# 👉 RR = toutes interfaces
if echo "$HOST" | grep -q "_moouahab-1"; then
vtysh << EOF
configure terminal

interface eth0
 ip ospf area 0

interface eth1
 ip ospf area 0

interface eth2
 ip ospf area 0

interface lo
 ip ospf area 0

end
write memory
EOF

else
# 👉 LEAF = seulement eth0
vtysh << EOF
configure terminal

interface eth0
 ip ospf area 0

interface lo
 ip ospf area 0

end
write memory
EOF

fi

echo "[OK] OSPF configured clean"
