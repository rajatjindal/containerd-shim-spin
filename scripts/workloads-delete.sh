#!/bin/bash

set -euo pipefail

top -b -n 1

## test that the workload pods can be terminated
NODE=`kubectl get pod $(kubectl get pod -l app=wasm-spin --no-headers | awk '{print $1}') --no-headers -o custom-columns=":spec.nodeName"`
echo "node is $NODE"

top -b -n 1

CID=`docker ps | grep "$NODE" | awk '{print $1}'`
echo "cid is $CID"

top -b -n 1

docker exec $CID ps -ef

kubectl delete pod -l app=wasm-spin --timeout 20s || true

top -b -n 1

docker exec $CID ps -ef

kubectl describe pod -l app=wasm-spin

## hopefully wait for process to get killed after 30s timeout
sleep 15

docker exec $CID ps -ef
docker exec $CID cat /var/lib/rancher/k3s/agent/containerd/containerd.log
