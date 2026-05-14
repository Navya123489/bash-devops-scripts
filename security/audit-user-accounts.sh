#!/bin/bash
# audit-user-accounts.sh
# Audits user accounts on the system
# Identifies accounts with sudo access, empty passwords,
# and accounts that haven't logged in recently
# Author: Navya Kanchisamudram

# ── Configuration ────────────────────────────────────────
LOG_FILE="./user-audit-report-$(date +%Y%m%d).log"
INACTIVE_DAYS=90      # Flag accounts inactive for this many days

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Functions ────────────────────────────────────────────

print_header() {
    echo "================================================="
    echo " User Account Security Audit"
    echo " Date: $(date)"
    echo " Host: $(hostname)"
    echo " Run by: $(whoami)"
    echo "================================================="
    echo "User Account Security Audit - $(date)" > $LOG_FILE
}

check_sudo_users() {
    echo ""
    echo "── Users with Sudo Access ────────────────────"

    # Get users in sudo group
    if getent group sudo > /dev/null 2>&1; then
        SUDO_USERS=$(getent group sudo | cut -d: -f4)
        if [ -z "$SUDO_USERS" ]; then
            echo "No users in sudo group"
        else
            echo -e "${YELLOW}Users with sudo access: $SUDO_USERS${NC}"
            echo "Sudo users: $SUDO_USERS" >> $LOG_FILE
        fi
    fi

    # Check sudoers file
    echo ""
    echo "Sudoers entries:"
    grep -v "^#" /etc/sudoers 2>/dev/null | \
        grep -v "^$" | \
        grep -v "^Defaults" | \
        while read LINE; do
            echo -e "  ${YELLOW}$LINE${NC}"
        done
}

check_system_accounts() {
    echo ""
    echo "── System vs Regular Accounts ────────────────"

    # Users with UID >= 1000 are regular users
    echo "Regular user accounts:"
    awk -F: '$3 >= 1000 && $3 != 65534 {print $1, "UID:"$3}' \
        /etc/passwd | while read LINE; do
        echo -e "  ${GREEN}$LINE${NC}"
        echo "Regular user: $LINE" >> $LOG_FILE
    done
}

check_empty_passwords() {
    echo ""
    echo "── Password Security ─────────────────────────"

    # Check for accounts with empty passwords
    EMPTY_PASS=$(awk -F: '($2 == "" || $2 == "!") \
        {print $1}' /etc/shadow 2>/dev/null)

    if [ -z "$EMPTY_PASS" ]; then
        echo -e "${GREEN}OK: No accounts with empty passwords${NC}"
        echo "OK: No empty passwords found" >> $LOG_FILE
    else
        echo -e "${RED}WARNING: Accounts with empty/locked passwords:${NC}"
        echo "$EMPTY_PASS" | while read USER; do
            echo -e "  ${RED}$USER${NC}"
            echo "WARNING: Empty password - $USER" >> $LOG_FILE
        done
    fi
}

check_last_login() {
    echo ""
    echo "── Recent Login Activity ─────────────────────"

    echo "Last login for each user:"
    lastlog 2>/dev/null | grep -v "Never logged in" | \
        grep -v "Username" | \
        while read LINE; do
            echo "  $LINE"
        done
}

print_summary() {
    echo ""
    echo "================================================="
    echo " Audit complete"
    echo " Review RED items immediately"
    echo " Review YELLOW items — verify they are expected"
    echo " Report saved to: $LOG_FILE"
    echo "================================================="
}

# ── Main ─────────────────────────────────────────────────
print_header
check_sudo_users
check_system_accounts
check_empty_passwords
check_last_login
print_summary