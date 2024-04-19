#!/bin/bash

set -euo pipefail

cluster_name="test-cluster"       # name of the k3d cluster
dockerfile_path="deployments/k3d" # path to the Dockerfile

DOCKER_IMAGES=("spin" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")
OUT_DIRS=("test/out_spin" "test/out_spin_keyvalue" "test/out_spin_outbound_redis" "test/out_spin_multi_trigger_app")
IMAGES=("spin-hello-world" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")

# build the Docker image for the k3d cluster
docker build -t k3d-shim-test "$dockerfile_path"

k3d cluster create "$cluster_name" \
  --image k3d-shim-test --api-port 6551 -p '8082:80@loadbalancer' --agents 2 \
  --registry-create test-registry:0.0.0.0:5000

kubectl wait --for=condition=ready node --all --timeout=120s

# Iterate through the Docker images and build them
for i in "${!DOCKER_IMAGES[@]}"; do
  ## we can push images to localhost:5000 registry, and pull will still work using registry name
  docker buildx build -t "localhost:5000/${IMAGES[$i]}:latest" "./images/${DOCKER_IMAGES[$i]}"
  docker push "localhost:5000/${IMAGES[$i]}:latest"
done

sleep 5

## wait for middleware crd. without this intermittent failures occur on local setup
for run in {1..60}; do
  kubectl get crd/middlewares.traefik.containo.us && break || echo "waiting for traefik crd. try #$run of 60"
  sleep 1
done

echo ">>> cluster is ready"
