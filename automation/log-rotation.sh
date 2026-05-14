#!/bin/bash
# log-rotation.sh
# Rotates and compresses log files to manage disk space
# Archives old logs and removes logs beyond retention period
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
LOG_DIR="${1:-/var/log}"          # Directory containing logs
ARCHIVE_DIR="${2:-./log-archive}" # Where to store archived logs
MAX_SIZE_MB=100                   # Rotate logs larger than this
RETENTION_DAYS=30                 # Keep archived logs this long
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " Log Rotation Script"
    echo " Date: $(date)"
    echo " Log Directory: $LOG_DIR"
    echo " Archive Directory: $ARCHIVE_DIR"
    echo " Max Size: ${MAX_SIZE_MB}MB"
    echo "================================================="
}

create_archive_dir() {
    if [ ! -d "$ARCHIVE_DIR" ]; then
        mkdir -p "$ARCHIVE_DIR"
        echo "Created archive directory: $ARCHIVE_DIR"
    fi
}

rotate_large_logs() {
    echo ""
    echo "── Rotating Large Log Files ──────────────────"

    # Find log files larger than MAX_SIZE_MB
    find "$LOG_DIR" -name "*.log" \
        -size +${MAX_SIZE_MB}M 2>/dev/null | \
        while read LOGFILE; do

        FILENAME=$(basename "$LOGFILE")
        ARCHIVE_NAME="${FILENAME%.log}_${TIMESTAMP}.log.gz"

        echo -e "${YELLOW}Rotating: $LOGFILE${NC}"

        # Compress and archive
        gzip -c "$LOGFILE" > "$ARCHIVE_DIR/$ARCHIVE_NAME"

        # Clear the original log file
        > "$LOGFILE"

        SIZE=$(du -sh "$ARCHIVE_DIR/$ARCHIVE_NAME" | cut -f1)
        echo -e "${GREEN}Archived to: $ARCHIVE_NAME ($SIZE)${NC}"
    done
}

cleanup_old_archives() {
    echo ""
    echo "── Cleaning Old Archives ─────────────────────"

    OLD_ARCHIVES=$(find "$ARCHIVE_DIR" \
        -name "*.log.gz" \
        -mtime +$RETENTION_DAYS 2>/dev/null)

    if [ -z "$OLD_ARCHIVES" ]; then
        echo "No archives older than $RETENTION_DAYS days"
    else
        echo "Removing archives older than $RETENTION_DAYS days:"
        echo "$OLD_ARCHIVES" | while read FILE; do
            rm "$FILE"
            echo -e "  ${GREEN}Removed: $FILE${NC}"
        done
    fi
}

show_disk_savings() {
    echo ""
    echo "── Current Log Directory Size ────────────────"
    du -sh "$LOG_DIR" 2>/dev/null
    echo ""
    echo "── Archive Directory Size ────────────────────"
    du -sh "$ARCHIVE_DIR" 2>/dev/null
}

print_summary() {
    echo ""
    echo "================================================="
    echo " Log rotation complete"
    echo " Logs larger than ${MAX_SIZE_MB}MB were rotated"
    echo " Archives kept for $RETENTION_DAYS days"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
create_archive_dir
rotate_large_logs
cleanup_old_archives
show_disk_savings
print_summary