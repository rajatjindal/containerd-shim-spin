#!/bin/bash

set -euo pipefail

top

## test that the workload pods can be terminated
NODE=`kubectl get pod $(kubectl get pod -l app=wasm-spin --no-headers | awk '{print $1}') --no-headers -o custom-columns=":spec.nodeName"`
echo "node is $NODE"

top 

CID=`docker ps | grep "$NODE" | awk '{print $1}'`
echo "cid is $CID"

top

kubectl delete pod -l app=wasm-spin --timeout 20s || true

top

docker exec $CID ps -ef

kubectl describe pod -l app=wasm-spin

docker exec $CID ps -ef
docker exec $CID cat /var/lib/rancher/k3s/agent/containerd/containerd.log
