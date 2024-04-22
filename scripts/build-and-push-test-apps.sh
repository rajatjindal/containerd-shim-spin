#!/bin/bash

set -euo pipefail

DOCKER_IMAGES=("spin" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")
IMAGES=("spin-hello-world" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")

# Iterate through the Docker images and build them
for i in "${!DOCKER_IMAGES[@]}"; do
  echo "building and pushing docker-build and spin-registry-push version of ${DOCKER_IMAGES[$i]}"

  ## we can push images to localhost:5000 registry, and pull will still work using registry name
  docker buildx build -t "localhost:5000/${IMAGES[$i]}:latest" "./images/${DOCKER_IMAGES[$i]}"
  docker push "localhost:5000/${IMAGES[$i]}:latest"

  ## also do spin builds and spin registry push
  spin build -f "./images/${DOCKER_IMAGES[$i]}/spin.toml"
  spin registry push "localhost:5000/spin-registry-push/${IMAGES[$i]}:latest" -f "./images/${DOCKER_IMAGES[$i]}/spin.toml" -k
done
