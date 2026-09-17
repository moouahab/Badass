#!/bin/sh
set -eu
vtysh <<'EOF'
configure terminal
no router ospf
router ospf
 ospf router-id 1.1.1.1
 passive-interface lo
exit
interface eth0
 ip ospf area 0
interface eth1
 ip ospf area 0
interface eth2
 ip ospf area 0
interface lo
 ip ospf area 0
exit
no router bgp 65000
router bgp 65000
 bgp router-id 1.1.1.1
 no bgp default ipv4-unicast
 neighbor EVPN peer-group
 neighbor EVPN remote-as 65000
 neighbor EVPN update-source lo
 neighbor 1.1.1.2 peer-group EVPN
 neighbor 1.1.1.3 peer-group EVPN
 neighbor 1.1.1.4 peer-group EVPN
 address-family l2vpn evpn
  neighbor EVPN activate
  neighbor EVPN route-reflector-client
 exit-address-family
end
write memory
EOF
