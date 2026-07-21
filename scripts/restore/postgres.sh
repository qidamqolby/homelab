#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly POSTGRES_DIR="/srv/databases/postgres"

###############################################################################
# Validation
###############################################################################

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "  $0 <backup-file.sql.gz>"
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

source "$POSTGRES_DIR/.env"

: "${POSTGRES_USER:?POSTGRES_USER is not set}"

###############################################################################
# Variables
###############################################################################

readonly START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

###############################################################################
# Confirmation
###############################################################################

echo "========================================"
echo " PostgreSQL Restore"
echo "========================================"
echo

echo "Started : $START_TIME"
echo "Source  : $BACKUP_FILE"
echo "Target  : PostgreSQL container"
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
echo "Restoring PostgreSQL..."

gunzip -c "$BACKUP_FILE" | \
docker compose \
    --project-directory "$POSTGRES_DIR" \
    exec -T postgres \
    psql \
        --username="$POSTGRES_USER"

echo

echo "Restore completed."
