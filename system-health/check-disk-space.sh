#!/bin/bash
# check-disk-space.sh
# Checks disk space usage across all mounted drives
# Sends a warning if usage exceeds the threshold
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
THRESHOLD=80          # Warning threshold percentage
CRITICAL=90           # Critical threshold percentage
LOG_FILE="./disk-space-report-$(date +%Y%m%d).log"

# ── Colours for output ───────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'          # No colour — resets back to normal

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " Disk Space Check"
    echo " Date: $(date)"
    echo " Host: $(hostname)"
    echo "================================================="
}

check_disk() {
    # Get disk usage for each mounted drive
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | while read LINE; do

        # Extract the usage percentage and mount point
        USAGE=$(echo $LINE | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo $LINE | awk '{print $6}')

        # Check against thresholds
        if [ $USAGE -ge $CRITICAL ]; then
            echo -e "${RED}CRITICAL: $MOUNT is at ${USAGE}% — immediate action required${NC}"
            echo "CRITICAL: $MOUNT is at ${USAGE}%" >> $LOG_FILE

        elif [ $USAGE -ge $THRESHOLD ]; then
            echo -e "${YELLOW}WARNING: $MOUNT is at ${USAGE}% — monitor closely${NC}"
            echo "WARNING: $MOUNT is at ${USAGE}%" >> $LOG_FILE

        else
            echo -e "${GREEN}OK: $MOUNT is at ${USAGE}%${NC}"
            echo "OK: $MOUNT is at ${USAGE}%" >> $LOG_FILE
        fi
    done
}

print_summary() {
    echo "================================================="
    echo " Report saved to: $LOG_FILE"
    echo " Threshold: ${THRESHOLD}% | Critical: ${CRITICAL}%"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
check_disk
print_summary