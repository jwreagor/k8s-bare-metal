#!/bin/bash
TOKEN=$(head /dev/urandom | base32 | head -c 8)
cp /dev/stdin /var/lib/kubernetes/token.csv <<< \
"${TOKEN},admin,admin
${TOKEN},scheduler,scheduler
${TOKEN},kubelet,kubelet
"
