#!/usr/bin/env bash

set -euo pipefail

MODE="dry-run"

if [[ "${1:-}" == "--execute" ]]; then
    MODE="execute"
fi


echo "================================="
echo " Docker Cleanup"
echo " Mode: $MODE"
echo "================================="
echo


echo "[Docker Disk Usage]"
docker system df


echo
echo "[Dangling Images]"
docker image ls --filter dangling=true


echo
echo "[Unused Networks]"
docker network ls --filter dangling=true


if [[ "$MODE" == "execute" ]]; then

    echo
    read -r -p "Continue cleanup? (yes/no): " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Cancelled"
        exit 0
    fi


    echo
    echo "Removing dangling images..."
    docker image prune -f


    echo
    echo "Removing unused networks..."
    docker network prune -f


    echo
    echo "Removing build cache..."
    docker builder prune -f


    echo
    echo "Cleanup completed"

else

    echo
    echo "Dry run only."
    echo "Run:"
    echo
    echo "$0 --execute"
    echo
    echo "to apply cleanup."

fi
