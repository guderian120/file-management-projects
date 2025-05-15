#!/bin/bash

: '
Backup Script (Interactive + Cron-Compatible)

This script creates compressed backups of one or more directories,
optionally filtered by file extensions.

Interactive mode lets users pick extensions
Cron mode reads saved preferences from a config file
Sends logs to an admin email
'

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/backup_config.env"
source "$SCRIPT_DIR/../general_logger/logger.sh"

base_dir="$(pwd)"
LOG_FILE="$base_dir/backup_log.log"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
declare -a selected_extensions

# === FUNCTIONS ===

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "This script must be run as root." >&2
        log_error "Script must be run as root"
        exit 1
    fi
}

check_arguments() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 [source_dirs...] <admin_email>"
        log_error "Insufficient arguments"
        exit 1
    fi
}

query_extensions() {
    if [[ -t 0 ]]; then
        echo "=== File Extension Selection ==="
        echo "Enter file extensions to back up (comma-separated, e.g., txt,jpg,png)."
        echo "Leave empty to back up all files."
        read -p "Extensions: " extensions_input

        echo "SELECTED_EXTENSIONS=\"$extensions_input\"" > "$CONFIG_FILE"
    elif [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        extensions_input="$SELECTED_EXTENSIONS"
    else
        echo "No config found and not interactive. Backing up all files."
        extensions_input=""
    fi

    if [[ -n "$extensions_input" ]]; then
        IFS=',' read -ra selected_extensions <<< "$extensions_input"
        echo "Using extensions: ${selected_extensions[*]}"
    else
        selected_extensions=()
        echo "Backing up all files."
    fi
}

cleanup_empty_backup_dirs() {
    local backup_root="$1"
    if [[ -d "$backup_root" ]]; then
        find "$backup_root" -type d -empty -print -delete
        echo "🧼 Cleaned up empty directories in $backup_root"
    fi
}

backup_directories() {
    local dest="$1"
    shift
    local src_dirs=("$@")

    mkdir -p "$dest" || {
        log_error "Cannot create backup directory: $dest"
        return 1
    }

    for src in "${src_dirs[@]}"; do
        if [[ -d "$src" ]]; then
            local dir_name
            dir_name=$(basename "$src")
            local dest_path="$dest/$dir_name"
            mkdir -p "$dest_path"

            if ! touch "$dest_path/test_write" 2>/dev/null; then
                log_error "No write permission in: $dest_path"
                rm -f "$dest_path/test_write"
                continue
            fi
            rm -f "$dest_path/test_write"

            (
                cd "$src" || { log_error "Cannot cd to $src"; exit 1; }

                if [[ ${#selected_extensions[@]} -eq 0 ]]; then
                    tmp_file_list=$(mktemp)
                    find . -type f > "$tmp_file_list"
                    if [[ -s "$tmp_file_list" ]]; then
                        backup_name="${dir_name}_backup_${DATE}_ALL.tar.gz"
                        file_path="$base_dir/Backup/$dir_name/$backup_name"
                        tar -czf "$file_path" -T "$tmp_file_list" && log_info "Backed up ALL files to $file_path"
                    fi
                    rm -f "$tmp_file_list"
                else
                    for ext in "${selected_extensions[@]}"; do
                        tmp_file_list=$(mktemp)
                        find . -type f -name "*.$ext" > "$tmp_file_list"

                        if [[ -s "$tmp_file_list" ]]; then
                            backup_name="${dir_name}_backup_${DATE}_${ext}.tar.gz"
                            file_path="$base_dir/Backup/$dir_name/$backup_name"
                            tar -czf "$file_path" -T "$tmp_file_list" && log_info "Backed up *.$ext files to $file_path"
                        else
                            echo "⚠️ No *.$ext files found in $src, skipping archive."
                        fi
                        rm -f "$tmp_file_list"
                    done
                fi
            )
        else
            log_error "Source directory does not exist: $src"
        fi
    done

    cleanup_empty_backup_dirs "$base_dir/Backup"
}

# === MAIN EXECUTION ===

if [[ "$1" == "--configure" ]]; then
    query_extensions
    exit 0
fi

require_root
check_arguments "$@"

# Parse arguments
ADMIN_EMAIL="${@: -1}"
SRC_DIRS=("${@:1:$(($#-1))}")
DEST_DIR="$base_dir/Backup"

# Validate email
if ! is_email "$ADMIN_EMAIL"; then
    echo "Invalid email address: $ADMIN_EMAIL"
    log_error "Invalid email: $ADMIN_EMAIL"
    exit 1
fi

# Query extensions interactively or load from config
query_extensions

# Backup
backup_directories "$DEST_DIR" "${SRC_DIRS[@]}"

# Email logs if backups were created
if grep -q "Backed up" "$LOG_FILE"; then
    send_email_to_admin "$ADMIN_EMAIL" "$LOG_FILE" "Backup Report"
fi
