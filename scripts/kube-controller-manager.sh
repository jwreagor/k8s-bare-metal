#!/bin/bash
export IP=$(ifconfig eth0 |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}')

# --cloud-provider=triton
# --cloud-config=/etc/kubernetes/cloud_config

exec /usr/local/bin/kube-controller-manager \
  --allocate-node-cidrs=true \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --master=http://${master_ip}:8080 \
  --root-ca-file=/var/lib/kubernetes/ca.pem \
  --service-account-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-cluster-ip-range=10.32.0.0/16 \
  --v=2
