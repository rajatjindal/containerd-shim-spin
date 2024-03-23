#!/bin/bash

set -euo pipefail

## test that the workload pods can be terminated
kubectl delete pod -l app=wasm-spin --timeout 20s || true
kubectl describe pod -l app=wasm-spin

