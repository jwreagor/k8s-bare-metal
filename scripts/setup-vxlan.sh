#!/bin/bash

#
# Creates VXLANs on worker nodes for pod communication
#

IP=$(ifconfig net0 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}')
VXLAN_CIDR=172.16.0.${IP##*.}/24
GETNODES=$(kubectl get nodes --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}')
VXLAN_D=$(awk '!/'$IP'/{print $1}' <<< "$GETNODES")

echo "--> Adding VXLAN and configuring bridge"
ip link add vxlan0 type vxlan id 1 dstport 0
for node in $VXLAN_D; do
  bridge fdb append to 00:00:00:00:00:00 dev vxlan0 dst $node
done
ip addr add ${VXLAN_CIDR} dev vxlan0
ip link set up vxlan0

ROUTES=$(awk '!/'$IP'/{GW=$1;gsub("10.20","172.16",GW);print "ip route add "$2" via "GW}' <<< "$GETNODES")
$ROUTES
