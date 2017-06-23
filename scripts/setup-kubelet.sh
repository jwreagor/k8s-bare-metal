#!/bin/bash

kubectl config set-cluster k8s-triton \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin --token ${COMMON_TOKEN}

kubectl config set-context default-context \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context default-context

kubectl get componentstatuses

kubectl get nodes
