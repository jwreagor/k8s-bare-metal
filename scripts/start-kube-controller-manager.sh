#!/bin/bash
IP=$(/sbin/ifconfig net0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
/usr/local/bin/kube-controller-manager \
  --allocate-node-cidrs=true \
  # --cloud-provider=triton \
  # --cloud-config=/etc/kubernetes/cloud_config \
  --cluster-cidr=10.200.0.0/16 \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --master=http://${controller_ip}:8080 \
  --root-ca-file=/var/lib/kubernetes/ca.pem \
  --service-account-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-cluster-ip-range=10.32.0.0/16 \
  --v=2