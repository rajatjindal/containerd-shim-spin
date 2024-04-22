#!/bin/bash

set -euo pipefail

DOCKER_IMAGES=("spin" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")
IMAGES=("spin-hello-world" "spin-keyvalue" "spin-outbound-redis" "spin-multi-trigger-app")

# Iterate through the Docker images and build them
for i in "${!DOCKER_IMAGES[@]}"; do
  ## we can push images to localhost:5000 registry, and pull will still work using registry name
  docker buildx build -t "localhost:5000/${IMAGES[$i]}:latest" "./images/${DOCKER_IMAGES[$i]}"
  docker push "localhost:5000/${IMAGES[$i]}:latest"
done
