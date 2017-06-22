#!/bin/bash
IP=$(/sbin/ifconfig net0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
/usr/local/bin/kube-scheduler \
  --leader-elect=true \
  --master=http://$IP:8080 \
  --v=2
