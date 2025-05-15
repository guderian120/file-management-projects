#!/bin/bash

#This script is designed to rename files in a specified directory by adding a prefix to their names.
# It takes a target directory, an admin email address, and an optional prefix as arguments.
# The script checks if the user has provided the required arguments, ensures that it is run with root privileges,
# Log configurations: To enable writing to log and sending log files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../general_logger/logger.sh"

LOG_FILE="$SCRIPT_DIR/bulk_rename.log"
COUNTER=0

# Function to check if script is run with required arguments
check_arguments() {
    # Check if a directory argument was provided
    if [[ -z "$1" ]]; then
        echo "Usage: $0 [target_directory]  <admin_email@example.com>  <optional_prefix>" 1>&2
        log_error "Usage error: No target directory provided"
        exit 1
    fi
    # Check if the provided argument is a valid directory
    if [[ ! -d "$1" ]]; then
        echo "Usage: $0 [target_directory]  Should be a valid directory and first argument" 1>&2
        log_error "Usage error: Invalid target directory provided"
    fi
    # Check if the admin email argument was provided
    if [[ -z "$2" ]]; then
        echo "Usage: $0 [target_directory]  <admin_email@example.com>  <optional_prefix>" 1>&2
        log_error "Usage error: No admin email provided"
        exit 1
    fi
}

# Function to ensure the script is run as root
require_root() {
    # Force the user to run script as sudo else exit
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "This script must be run as root (with sudo)." 1>&2
        log_error "Usage error: Script must be run with sudo"
        exit 1
    fi
}

# Function to rename files with a prefix if they haven't already been renamed
bulk_rename_files() {
    #instantiate the variables pass to the function
    # Get the target directory, admin email, and prefix from arguments
    local target_dir="$1"
    local admin_email="$2"
    local prefix="$3"

    # Iterate through the files in the directory
    # Rename the file only if the prefix isn't already present in the name
    # This avoids renaming files multiple times
    for file in "$target_dir"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            ext="${filename##*.}"           # Extract file extension
            name="${filename%.*}"           # Extract file name without extension

            # Only rename if the filename does not already start with the prefix
            # This prevents files from being renamed more than once
            if [[ "$name" != "$prefix"* ]]; then
                new_name="${prefix}_${COUNTER}.${ext}"   # Create new name with prefix
                mv "$file" "$target_dir/$new_name"       # Rename the file
                echo "Renamed: $filename → $new_name" 1>&2
                log_error "Renamed: $filename → $new_name" # Log the rename operation
                COUNTER=$((COUNTER + 1))  # Increment the counter after renaming
               
            fi
        fi
    done
}

### Main Script Execution ###

# Ensure the script is being run as root (sudo)
require_root

# Get the directory, admin email, and optional prefix from arguments
DIR="$1"
ADMIN_EMAIL="$2"  # Target directory from the first argument
PREFIX="${3:-Bulk_Renamer}"  # Optional prefix, defaults to "Bulk_Renamer"

check_arguments "$1" "$2"

if is_email "$ADMIN_EMAIL"; then
    echo "Email is valid: $ADMIN_EMAIL"
else
    echo "Invalid Email Provided: $ADMIN_EMAIL" 1>&2
    log_error "Usage error: Invalid email address provided $ADMIN_EMAIL" 
    exit 1  # Optional: Exit script if email is invalid
fi
# Check if the necessary arguments are provided

# Perform bulk renaming of files in the target directory
bulk_rename_files "$DIR" "$ADMIN_EMAIL" "$PREFIX"

# If any files were renamed, send a log email to the admin
if (( COUNTER >= 1 )); then
    echo -e "==========================Sending LogFiles To Admin==========================="
    send_email_to_admin "$ADMIN_EMAIL" "$LOG_FILE" "Bulk Rename"  # Send email with the log file to the admin
fi

