# bash-devops-scripts
Bash scripts for Linux DevOps automation — system health, security auditing and operational tasks

# Bash DevOps Scripts

Production-grade Bash scripts for Linux system administration,
security auditing, and operational automation.

## Repository Structure
system-health/
├── check-disk-space.sh     # Disk usage monitoring with thresholds
└── check-cpu-memory.sh     # CPU and memory monitoring
security/
├── check-open-ports.sh     # Open port security audit
└── audit-user-accounts.sh  # User account security audit
automation/
├── backup-files.sh         # Automated file backup with retention
└── log-rotation.sh         # Log rotation and archiving

## Scripts

### system-health/

**check-disk-space.sh**
Checks disk usage across all mounted drives. Flags WARNING at
80% and CRITICAL at 90%. Exports timestamped CSV report.

```bash
chmod +x check-disk-space.sh
./check-disk-space.sh
```

**check-cpu-memory.sh**
Monitors CPU and memory usage. Shows top 5 processes by
resource consumption. Alerts when thresholds are exceeded.

```bash
chmod +x check-cpu-memory.sh
./check-cpu-memory.sh
```

### security/

**check-open-ports.sh**
Audits all listening ports on the system. Compares against
expected ports list and flags unexpected ones for review.

```bash
chmod +x check-open-ports.sh
./check-open-ports.sh
```

**audit-user-accounts.sh**
Audits user accounts — sudo access, empty passwords, login
activity, and system vs regular accounts.

```bash
chmod +x audit-user-accounts.sh
sudo ./audit-user-accounts.sh
```

### automation/

**backup-files.sh**
Creates compressed timestamped backups with configurable
retention policy. Automatically removes backups older than
retention period.

```bash
chmod +x backup-files.sh
./backup-files.sh /etc ./backups
```

**log-rotation.sh**
Rotates log files exceeding size threshold. Compresses and
archives rotated logs. Removes archives beyond retention period.

```bash
chmod +x log-rotation.sh
./log-rotation.sh /var/log ./log-archive
```

## How to run any script

```bash
# Make script executable
chmod +x script-name.sh

# Run the script
./script-name.sh

# Run with sudo for scripts needing elevated permissions
sudo ./script-name.sh
```

## Key concepts demonstrated

| Concept | Where used |
|---|---|
| Variables | All scripts |
| If statements | All scripts |
| Loops | check-disk-space.sh, check-open-ports.sh |
| Functions | All scripts |
| Colour output | All scripts |
| Log file generation | All scripts |
| Command line arguments | backup-files.sh, log-rotation.sh |
| Error handling | backup-files.sh |
| System commands | check-cpu-memory.sh, audit-user-accounts.sh |

## Requirements

- Linux or macOS
- Bash 4.0+
- sudo access for security scripts

## Author
Navya Kanchisamudram — Azure Administrator (AZ-104)
GitHub: github.com/Navya123489
