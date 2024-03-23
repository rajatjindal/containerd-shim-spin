#!/bin/bash

set -euo pipefail

## test that the workload pods can be terminated
kubectl delete pod -l app=wasm-spin --timeout 20s || true
kubectl describe pod -l app=wasm-spin

NODE=`kubectl get pod $(kubectl get pod -l app=wasm-spin --no-headers | grep -i Terminating | awk '{print $1}') --no-headers -o custom-columns=":spec.nodeName"`
echo "node is $NODE"

CID=`docker ps | grep "$NODE" | awk '{print $1}'`
echo "cid is $CID"

docker exec -it $CID tail -f /var/lib/rancher/k3s/agent/containerd/containerd.log
