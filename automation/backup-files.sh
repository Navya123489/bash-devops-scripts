#!/bin/bash
# backup-files.sh
# Creates timestamped backups of important directories
# Compresses and stores them with retention policy
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
SOURCE_DIR="${1:-/etc}"           # Directory to backup
BACKUP_DIR="${2:-./backups}"      # Where to store backups
RETENTION_DAYS=7                  # Keep backups for this many days
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.tar.gz"
LOG_FILE="./backup-log.txt"

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " File Backup Script"
    echo " Date: $(date)"
    echo " Source: $SOURCE_DIR"
    echo " Destination: $BACKUP_DIR"
    echo "================================================="
}

create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "Created backup directory: $BACKUP_DIR"
    fi
}

create_backup() {
    echo ""
    echo "── Creating Backup ───────────────────────────"
    echo "Source: $SOURCE_DIR"
    echo "File: $BACKUP_FILE"

    # Create compressed backup
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
        "$SOURCE_DIR" 2>/dev/null

    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}Backup created successfully — Size: $SIZE${NC}"
        echo "$(date) - Backup created: $BACKUP_FILE ($SIZE)" \
            >> $LOG_FILE
    else
        echo -e "${RED}ERROR: Backup failed${NC}"
        echo "$(date) - ERROR: Backup failed for $SOURCE_DIR" \
            >> $LOG_FILE
        exit 1
    fi
}

cleanup_old_backups() {
    echo ""
    echo "── Cleaning Old Backups ──────────────────────"

    # Find and delete backups older than retention period
    OLD_BACKUPS=$(find "$BACKUP_DIR" \
        -name "backup_*.tar.gz" \
        -mtime +$RETENTION_DAYS)

    if [ -z "$OLD_BACKUPS" ]; then
        echo "No old backups to clean up"
    else
        echo "Removing backups older than $RETENTION_DAYS days:"
        echo "$OLD_BACKUPS" | while read FILE; do
            rm "$FILE"
            echo "  Removed: $FILE"
            echo "$(date) - Removed old backup: $FILE" >> $LOG_FILE
        done
    fi
}

list_backups() {
    echo ""
    echo "── Current Backups ───────────────────────────"
    ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || \
        echo "No backups found"
}

print_summary() {
    echo ""
    echo "================================================="
    echo " Backup complete"
    echo " Retention policy: $RETENTION_DAYS days"
    echo " Log file: $LOG_FILE"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
create_backup_dir
create_backup
cleanup_old_backups
list_backups
print_summary