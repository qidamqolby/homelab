#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly MARIADB_DIR="/srv/databases/mariadb"

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

source "$MARIADB_DIR/.env"

: "${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD is not set}"

###############################################################################
# Variables
###############################################################################

readonly START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

###############################################################################
# Confirmation
###############################################################################

echo "========================================"
echo " MariaDB Restore"
echo "========================================"
echo

echo "Started : $START_TIME"
echo "Source  : $BACKUP_FILE"
echo "Target  : MariaDB container"
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
echo "Restoring MariaDB..."

gunzip -c "$BACKUP_FILE" | \
docker compose \
    --project-directory "$MARIADB_DIR" \
    exec -T mariadb \
    mariadb \
        --user=root \
        --password="$MARIADB_ROOT_PASSWORD"

echo

echo "Restore completed."
