## Networking

The following is how the VXLAN tunnel is setup across worker nodes. It's a bit
of a PITA.

```sh
$ kubectl get nodes \
  --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}'
10.240.0.9 10.200.1.0/24
10.240.0.11 10.200.2.0/24
10.240.0.10 10.200.0.0/24
```

```sh
IP=$(triton ip worker0)
# set the VXLAN_CIDR to 172.16.0.N where N is the last quad of IP
VXLAN_CIDR=172.16.0.${IP##*.}/24
# Get the ouput of the kubectl command shown above in "Populate the Routing Table"
GETNODES=$(ssh root@$BASTION "kubectl get nodes --output=jsonpath='{range .items[*]} {.status.addresses[?(@.type==\"InternalIP\")].address} {.spec.podCIDR}{\"\\n\"}{end}'")
# Get the vxlan destination addresses from the kubectl output (every other worker IP)
VXLAN_D=$(awk '!/'$IP'/{print $1}' <<< "$GETNODES")
# create the unicast vxlan endpoint FDB table entries
BRIDGE_COMMANDS=$(xargs printf "bridge fdb append to 00:00:00:00:00:00 dev vxlan0 dst %s\n" <<< $VXLAN_D)
echo $BRIDGE_COMMANDS

proxyssh root@$IP <<< "
ip link add vxlan0 type vxlan id 1 dstport 0
$BRIDGE_COMMANDS
ip addr add $VXLAN_CIDR dev vxlan0
ip link set up vxlan0
"
```

```sh
# create the L3 route commands to forward pod traffic over the vxlan
ROUTES=$(awk '!/'$IP'/{GW=$1;gsub("10.240","172.16",GW);print "ip route add "$2" via "GW}' <<< "$GETNODES")
echo $ROUTES
proxyssh root@$IP <<< "$ROUTES"
```
