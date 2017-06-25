#!/bin/bash
IP=$(ifconfig eth0 |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}')

exec /usr/local/bin/kube-scheduler \
  --leader-elect=true \
  --master=http://$IP:8080 \
  --v=2
