#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly MARIADB_DIR="/srv/databases/mariadb"
readonly BACKUP_DIR="/srv/backup/mariadb"

readonly MAX_BACKUPS=3

QUIET=false

###############################################################################
# Arguments
###############################################################################

while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quiet)
            QUIET=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

###############################################################################
# Helper Functions
###############################################################################

log() {
    [[ "$QUIET" == false ]] && echo "$@"
}

print_header() {
    log "========================================"
    log " MariaDB Backup"
    log "========================================"
    log
}

cleanup_old_backups() {
    mapfile -t backups < <(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "mariadb-*.sql.gz" \
            | sort
    )

    if (( ${#backups[@]} <= MAX_BACKUPS )); then
        return
    fi

    local remove_count=$(( ${#backups[@]} - MAX_BACKUPS ))

    for ((i=0; i<remove_count; i++)); do
        log "Removing old backup: $(basename "${backups[$i]}")"
        rm -f "${backups[$i]}"
    done
}

###############################################################################
# Main
###############################################################################

trap 'echo "[ERROR] Backup failed." >&2' ERR

source "$MARIADB_DIR/.env"

: "${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD is not set}"

mkdir -p "$BACKUP_DIR"

readonly TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
readonly START_TIME="$(date +%s)"

readonly BACKUP_FILE="$BACKUP_DIR/mariadb-$TIMESTAMP.sql.gz"

print_header

log "Started : $(date '+%Y-%m-%d %H:%M:%S')"
log "Source  : $MARIADB_DIR"
log "Output  : $BACKUP_FILE"
log

log "Creating MariaDB backup..."

docker compose \
    --project-directory "$MARIADB_DIR" \
    exec -T mariadb \
    mariadb-dump \
        --user=root \
        --password="$MARIADB_ROOT_PASSWORD" \
        --all-databases \
        --single-transaction \
        --routines \
        --events \
        --triggers \
        --hex-blob \
| gzip > "$BACKUP_FILE"

if [[ ! -s "$BACKUP_FILE" ]]; then
    echo "[ERROR] Backup file is empty." >&2
    exit 1
fi

cleanup_old_backups

readonly END_TIME="$(date +%s)"
readonly DURATION="$((END_TIME - START_TIME))"
readonly SIZE="$(du -h "$BACKUP_FILE" | cut -f1)"

log
log "Backup completed."
log
log "Backup Size : $SIZE"
log "Duration    : ${DURATION}s"
