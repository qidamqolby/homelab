#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly MONGODB_DIR="/srv/databases/mongodb"
readonly BACKUP_DIR="/srv/backup/mongodb"

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
    log " MongoDB Backup"
    log "========================================"
    log
}

cleanup_old_backups() {
    mapfile -t backups < <(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "mongodb-*.archive.gz" \
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

source "$MONGODB_DIR/.env"

: "${MONGO_INITDB_ROOT_USERNAME:?MONGO_INITDB_ROOT_USERNAME is not set}"
: "${MONGO_INITDB_ROOT_PASSWORD:?MONGO_INITDB_ROOT_PASSWORD is not set}"

mkdir -p "$BACKUP_DIR"

readonly TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
readonly START_TIME="$(date +%s)"

readonly BACKUP_FILE="$BACKUP_DIR/mongodb-$TIMESTAMP.archive.gz"

print_header

log "Started : $(date '+%Y-%m-%d %H:%M:%S')"
log "Source  : $MONGODB_DIR"
log "Output  : $BACKUP_FILE"
log

log "Creating MongoDB backup..."

docker compose \
    --project-directory "$MONGODB_DIR" \
    exec -T mongodb \
    mongodump \
        --username="$MONGO_INITDB_ROOT_USERNAME" \
        --password="$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase=admin \
        --archive \
        --gzip \
> "$BACKUP_FILE"

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
