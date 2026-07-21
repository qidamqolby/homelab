#!/usr/bin/env bash

set -euo pipefail

echo "================================="
echo " Docker Status"
echo "================================="
echo

echo "[Docker Service]"
if systemctl is-active --quiet docker; then
    echo "OK: Docker daemon running"
else
    echo "ERROR: Docker daemon not running"
    exit 1
fi

echo

echo "[Containers]"
docker ps \
    --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

echo

echo "[Unhealthy Containers]"
UNHEALTHY=$(docker ps --filter health=unhealthy --format "{{.Names}}")

if [ -z "$UNHEALTHY" ]; then
    echo "None"
else
    echo "$UNHEALTHY"
fi

echo

echo "[Docker Resource Usage]"
docker system df

echo

echo "================================="
echo " Done"
echo "================================="
