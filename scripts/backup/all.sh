#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAILED_BACKUPS=()

###############################################################################
# Helper Functions
###############################################################################

run_backup() {
    local name="$1"
    local script="$2"

    echo "========================================"
    echo " Running $name Backup"
    echo "========================================"
    echo

    if "$SCRIPT_DIR/$script"; then
        echo "[OK] $name backup completed."
    else
        echo "[FAILED] $name backup failed."
        FAILED_BACKUPS+=("$name")
    fi

    echo
}

###############################################################################
# Main
###############################################################################

echo "========================================"
echo " Database Backup"
echo "========================================"
echo

START_TIME=$(date +%s)

run_backup "PostgreSQL" "postgres.sh"
run_backup "MariaDB" "mariadb.sh"
run_backup "MongoDB" "mongodb.sh"

END_TIME=$(date +%s)

DURATION=$((END_TIME - START_TIME))

###############################################################################
# Summary
###############################################################################

echo "========================================"
echo " Backup Summary"
echo "========================================"
echo

if (( ${#FAILED_BACKUPS[@]} == 0 )); then
    echo "Status   : SUCCESS"
else
    echo "Status   : FAILED"
    echo
    echo "Failed backup:"
    
    for backup in "${FAILED_BACKUPS[@]}"; do
        echo "- $backup"
    done
fi

echo
echo "Duration : ${DURATION}s"

echo

if (( ${#FAILED_BACKUPS[@]} > 0 )); then
    exit 1
fi

exit 0
