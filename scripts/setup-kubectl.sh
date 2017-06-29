#!/bin/bash

echo "--> Configure cluster within kubectl"
kubectl config set-cluster ${cluster_name} \
     --certificate-authority=/var/lib/kubernetes/ca.pem \
     --embed-certs=true \
     --server=https://${master_ip}:6443

echo "--> Configure credentials within kubectl"
kubectl config set-credentials admin --token ${secret_token}

echo "--> Configure context within kubectl"
kubectl config set-context default-context \
     --cluster=${cluster_name} \
     --user=admin

echo "--> Use context as default context"
kubectl config use-context default-context

