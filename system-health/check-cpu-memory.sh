#!/bin/bash
# check-cpu-memory.sh
# Checks CPU and memory usage
# Alerts if usage exceeds defined thresholds
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
CPU_THRESHOLD=80      # CPU warning threshold percentage
MEM_THRESHOLD=85      # Memory warning threshold percentage
LOG_FILE="./cpu-memory-report-$(date +%Y%m%d).log"

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " CPU and Memory Health Check"
    echo " Date: $(date)"
    echo " Host: $(hostname)"
    echo " Uptime: $(uptime -p)"
    echo "================================================="
}

check_cpu() {
    echo ""
    echo "── CPU Usage ─────────────────────────────────"

    # Get CPU usage percentage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \
        awk '{print $2}' | cut -d'%' -f1 | cut -d',' -f1)

    # Round to integer
    CPU_INT=${CPU_USAGE%.*}

    if [ "$CPU_INT" -ge "$CPU_THRESHOLD" ]; then
        echo -e "${RED}WARNING: CPU usage is ${CPU_USAGE}%${NC}"
        echo "WARNING: CPU at ${CPU_USAGE}%" >> $LOG_FILE
    else
        echo -e "${GREEN}OK: CPU usage is ${CPU_USAGE}%${NC}"
        echo "OK: CPU at ${CPU_USAGE}%" >> $LOG_FILE
    fi

    # Show top 5 CPU consuming processes
    echo ""
    echo "Top 5 CPU consuming processes:"
    ps aux --sort=-%cpu | head -6 | tail -5 | \
        awk '{printf "  %-20s %s%%\n", $11, $3}'
}

check_memory() {
    echo ""
    echo "── Memory Usage ──────────────────────────────"

    # Get total and used memory
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    USED_MEM=$(free -m | awk '/^Mem:/{print $3}')
    FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')

    # Calculate percentage
    MEM_USAGE=$((USED_MEM * 100 / TOTAL_MEM))

    echo "Total Memory:  ${TOTAL_MEM}MB"
    echo "Used Memory:   ${USED_MEM}MB"
    echo "Free Memory:   ${FREE_MEM}MB"

    if [ $MEM_USAGE -ge $MEM_THRESHOLD ]; then
        echo -e "${RED}WARNING: Memory usage is ${MEM_USAGE}%${NC}"
        echo "WARNING: Memory at ${MEM_USAGE}%" >> $LOG_FILE
    else
        echo -e "${GREEN}OK: Memory usage is ${MEM_USAGE}%${NC}"
        echo "OK: Memory at ${MEM_USAGE}%" >> $LOG_FILE
    fi

    # Show top 5 memory consuming processes
    echo ""
    echo "Top 5 memory consuming processes:"
    ps aux --sort=-%mem | head -6 | tail -5 | \
        awk '{printf "  %-20s %s%%\n", $11, $4}'
}

print_summary() {
    echo ""
    echo "================================================="
    echo " Report saved to: $LOG_FILE"
    echo " CPU Threshold: ${CPU_THRESHOLD}%"
    echo " Memory Threshold: ${MEM_THRESHOLD}%"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
check_cpu
check_memory
print_summary