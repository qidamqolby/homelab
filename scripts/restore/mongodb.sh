#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly MONGODB_DIR="/srv/databases/mongodb"

###############################################################################
# Validation
###############################################################################

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "  $0 <backup-file.archive.gz>"
    exit 1
fi

readonly BACKUP_FILE="$1"

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "[ERROR] Backup file not found:"
    echo "$BACKUP_FILE"
    exit 1
fi

###############################################################################
# Load Environment
###############################################################################

source "$MONGODB_DIR/.env"

: "${MONGO_INITDB_ROOT_USERNAME:?MONGO_INITDB_ROOT_USERNAME is not set}"
: "${MONGO_INITDB_ROOT_PASSWORD:?MONGO_INITDB_ROOT_PASSWORD is not set}"

###############################################################################
# Variables
###############################################################################

readonly START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

###############################################################################
# Confirmation
###############################################################################

echo "========================================"
echo " MongoDB Restore"
echo "========================================"
echo

echo "Started : $START_TIME"
echo "Source  : $BACKUP_FILE"
echo "Target  : MongoDB container"
echo

read -rp "Continue restore? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo
    echo "Restore cancelled."
    exit 0
fi

###############################################################################
# Restore
###############################################################################

echo
echo "Restoring MongoDB..."

docker compose \
    --project-directory "$MONGODB_DIR" \
    exec -T mongodb \
    mongorestore \
        --username="$MONGO_INITDB_ROOT_USERNAME" \
        --password="$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase=admin \
        --archive \
        --gzip \
	--drop \
        < "$BACKUP_FILE"

echo

echo "Restore completed."
