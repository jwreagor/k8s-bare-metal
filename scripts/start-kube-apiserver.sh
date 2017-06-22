#!/bin/bash
IP=$(/sbin/ifconfig net0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
/usr/local/bin/kube-apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
  --advertise-address=${IP} \
  --allow-privileged=true \
  --apiserver-count=1 \
  --authorization-mode=ABAC \
  --authorization-policy-file=/var/lib/kubernetes/authorization-policy.jsonl \
  --bind-address=0.0.0.0 \
  --enable-swagger-ui=true \
  --etcd-cafile=/var/lib/kubernetes/ca.pem \
  --etcd-servers=${etcd_servers} \
  --insecure-bind-address=0.0.0.0 \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
  --service-account-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --token-auth-file=/var/lib/kubernetes/token.csv \
  --v=2
