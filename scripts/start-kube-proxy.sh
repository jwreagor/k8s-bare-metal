#!/bin/bash
/usr/bin/kube-proxy \
  --masquerade-all \
  --master=${controller_ip} \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --proxy-mode=iptables \
  --v=2
