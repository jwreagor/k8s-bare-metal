#!/bin/bash
exec /usr/bin/kubelet \
  --allow-privileged=true \
  --api-servers=https://${master_ip}:6443 \
  --cluster-dns=10.100.0.10 \
  --cluster-domain=cluster.local \
  --container-runtime=docker \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --logtostderr=true \
  --network-plugin-dir=/etc/cni/net.d \
  --network-plugin=cni \
  --serialize-image-pulls=false \
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --v=2
