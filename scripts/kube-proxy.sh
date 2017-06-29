#!/bin/bash

exec /usr/bin/kube-proxy \
  --master=https://${master_ip}:6443 \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --proxy-mode=iptables \
  --v=2
