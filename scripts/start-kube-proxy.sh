#!/bin/bash

exec /usr/bin/kube-proxy \
  --masquerade-all \
  --master=${master_ip} \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --proxy-mode=iptables \
  --v=2
