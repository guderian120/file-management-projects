#!/bin/bash

# ======= General Logger Function =======
#This script will act as my general logger script which 
#I will import into my bash files to log and send log files as email
# Log file (can be overridden by parent script)

LOG_FILE="${LOG_FILE:-/var/log/bash_logger.log}"
LOGGER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMAIL_SCRIPT="$LOGGER_DIR/email_server.py"  # Full path to the Python script

# Timestamp function
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Logging function
log_info() {
    echo "$(timestamp) [INFO] $1" >> "$LOG_FILE"
}

log_warn() {
    echo "$(timestamp) [WARNING] $1" >> "$LOG_FILE"
}

log_error() {
    echo "$(timestamp) [ERROR] $1" >> "$LOG_FILE"
}

log_debug() {
    echo "$(timestamp) [DEBUG] $1" >> "$LOG_FILE"
}

is_email() {
    local input="$1"
    if [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  # Valid email
    else
        return 1  # Invalid email
    fi
}
# ======= Email Alert Function =======
# Expected usage: send_email_to_admin <admin_email> <log_file>
send_email_to_admin() {
    local admin_email="${1:-realamponsah10@yahoo.com}"
    local log_file="${2:-$LOG_FILE}"
    local subject="${3:-Subject Not Provided}"
    
    if [[ -x "$EMAIL_SCRIPT" ]]; then
        log_info "Sending log file '$log_file' via '$EMAIL_SCRIPT' to '$admin_email'"
        python3 "$EMAIL_SCRIPT" "$admin_email" "$log_file"  "$subject"
    else
        log_error "Email script not found or not executable at $EMAIL_SCRIPT"
    fi
}

