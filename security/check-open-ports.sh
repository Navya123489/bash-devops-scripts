#!/bin/bash
# check-open-ports.sh
# Audits open ports on the system
# Identifies unexpected or suspicious listening ports
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
LOG_FILE="./open-ports-report-$(date +%Y%m%d).log"

# Known expected ports — add your own here
EXPECTED_PORTS=(22 80 443 8080 5432 6379)

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " Open Port Security Audit"
    echo " Date: $(date)"
    echo " Host: $(hostname)"
    echo "================================================="
}

is_expected_port() {
    PORT=$1
    for EXPECTED in "${EXPECTED_PORTS[@]}"; do
        if [ "$PORT" -eq "$EXPECTED" ]; then
            return 0    # 0 means true in Bash
        fi
    done
    return 1            # 1 means false in Bash
}

check_ports() {
    echo ""
    echo "── Listening Ports ───────────────────────────"

    # Get all listening ports
    PORTS=$(ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null)

    echo "$PORTS" | grep LISTEN | while read LINE; do
        # Extract port number
        PORT=$(echo $LINE | awk '{print $4}' | \
            rev | cut -d: -f1 | rev)

        # Extract process name
        PROCESS=$(echo $LINE | awk '{print $6}' | \
            cut -d'"' -f2)

        if is_expected_port "$PORT" 2>/dev/null; then
            echo -e "${GREEN}EXPECTED  Port $PORT — $PROCESS${NC}"
            echo "EXPECTED: Port $PORT - $PROCESS" >> $LOG_FILE
        else
            echo -e "${YELLOW}REVIEW    Port $PORT — $PROCESS${NC}"
            echo "REVIEW: Port $PORT - $PROCESS" >> $LOG_FILE
        fi
    done
}

print_summary() {
    echo ""
    echo "================================================="
    echo " Expected ports: ${EXPECTED_PORTS[*]}"
    echo " Review any YELLOW ports above"
    echo " Report saved to: $LOG_FILE"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
check_ports
print_summary