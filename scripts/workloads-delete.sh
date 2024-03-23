#!/bin/bash

set -euo pipefail


## test that the workload pods can be terminated
NODE=`kubectl get pod $(kubectl get pod -l app=wasm-spin --no-headers | awk '{print $1}') --no-headers -o custom-columns=":spec.nodeName"`
echo "node is $NODE"

kubectl delete pod -l app=wasm-spin --timeout 50s || true
kubectl describe pod -l app=wasm-spin

CID=`docker ps | grep "$NODE" | awk '{print $1}'`
echo "cid is $CID"

docker exec $CID ps -ef
docker exec $CID cat /var/lib/rancher/k3s/agent/containerd/containerd.log
