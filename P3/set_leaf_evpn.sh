#!/bin/sh
set -eu
id="${1:?usage: set_leaf_evpn.sh 2|3|4}"
case "$id" in 2|3|4) ;; *) exit 2 ;; esac
rid="1.1.1.$id"
ip link del vxlan10 2>/dev/null || true
ip link del br0 2>/dev/null || true
ip link add br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up
ip link add vxlan10 type vxlan id 10 local "$rid" dstport 4789 nolearning
ip link set vxlan10 master br0
ip link set vxlan10 up
vtysh <<EOF
configure terminal
no router ospf
router ospf
 ospf router-id $rid
 passive-interface lo
exit
interface eth0
 ip ospf area 0
interface lo
 ip ospf area 0
exit
no router bgp 65000
router bgp 65000
 bgp router-id $rid
 no bgp default ipv4-unicast
 neighbor 1.1.1.1 remote-as 65000
 neighbor 1.1.1.1 update-source lo
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
end
write memory
EOF
