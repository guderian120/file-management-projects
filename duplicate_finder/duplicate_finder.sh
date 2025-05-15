#!/bin/bash

: '

This script finds duplicates using hashes instead of files. WHY? 
===========================================
 Why I Used Hashes Instead of File Names
===========================================

When checking for duplicate files, comparing just the file names is unreliable.
Here is why hashes are reliable  (like MD5) instead:

1. File names can differ even when contents are identical.
   - Example: "photo1.jpg" and "copy_photo.jpg" may be exact copies but have different names.
   - A name-based comparison would miss this duplication.

2. Hash functions generate a unique signature based on the files actual content.
   - This means if two files produce the same hash, their contents are (almost always) identical.
   - Even a single byte difference will result in a different hash.

3. Hash-based comparison ensures that we’re identifying true duplicates, not just files that look similar.

In short: Hashes provide a content-aware comparison, while names are purely cosmetic.
'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../general_logger/logger.sh"

LOG_FILE="$SCRIPT_DIR/duplicates.log"
LOG_COUNT=0


# Global array to store duplicates
declare -a duplicates_list

# Function to check if the user provided a directory argument
check_arguments() {
    # Check if the target directory argument was provided
    if [[ -z "$1" ]]; then
        echo "Usage: $0 [target_directory] [admin_email]" 1>&2
        log_error "Usage error: No target directory provided"
        exit 1
    fi

    # Check if the admin email argument was provided
    if [[ -z "$2" ]]; then
        echo "Usage: $0 [target_directory] [admin_email]" 1>&2
        log_error "Usage error: No admin email provided"
        exit 1
    fi
}


# Function to scan the directory and detect duplicate files by comparing their hashes
find_duplicate_files() {

    local target_dir="$1"          # Directory to search for duplicates
    # This file hash will store the MD5 hash of each file so we can compare them to other files
    declare -A filehash           # Associative array: key=MD5 hash, value=file path
    duplicates_list=()            # Reset global duplicates list

    # Find all duplicate files and build hash map
    # IFS= enables white spaces are preserved and not split
    #read -r -d '' reads null-terminated strings, which is safer for filenames with special characters
    while IFS= read -r -d '' file; do
        # Only process regular files (skip directories and others)
        if [[ -f "$file" ]]; then
            # Generate an MD5 hash of the file's contents
            # The md5sum command computes the hash, and awk extracts just the hash value
            hash=$(md5sum "$file" | awk '{ print $1 }')
            # Check if we've seen this hash before
            # If the hash already exists in the associative array, it means we have a duplicate
            if [[ -n "${filehash[$hash]}" ]]; then
                # Append the duplicate file to the duplicates list
                # The original file is stored in the associative array, and the duplicate is the current file
                duplicates_list+=("${filehash[$hash]}|$file")  # Store original|duplicate pair
                # Log the duplicate files
                # The log_info function is defined in the logger.sh script in the general_logger directory
                log_info "Duplicate found: Original: ${filehash[$hash]}, Duplicate: $file"
                ((LOG_COUNT++))
            else
                filehash[$hash]="$file"
            fi
        fi
    # This line scans the directory with the find command, the -type f option ensures only files are processed, and -print0 handles filenames with spaces.
    # The while loop reads each file found by find, and the -d '' option allows for null-terminated strings, which is safer for filenames with special characters.
    done < <(find "$target_dir" -type f -print0)
}

: '
This handle_duplicates function processes the duplicates found in the directory.
It provides options to move, delete, or review each duplicate file.

'
handle_duplicates() {
    local action=""
    local target_dir=""

    echo "Found ${#duplicates_list[@]} duplicate files(s)"
    if [[ ${#duplicates_list[@]} -eq 0 ]]; then
        echo "No duplicates to process"
        return
    fi

    # Display action menu
    echo "Select action for all duplicates:"
    echo "1) Move all duplicates to a directory"
    echo "2) Delete all duplicates"
    echo "3) Review each duplicate individually"
    echo "4) Cancel"
    read -p "Enter your choice (1-4): " choice

    case $choice in
        1)
            read -p "Enter directory to move duplicates to: " target_dir
            mkdir -p "$target_dir" || {
                echo "Error: Failed to create directory $target_dir"
                return 1
            }
            action="move"
            ;;
        2)
            action="delete"
            ;;
        3)
            action="interactive"
            ;;
        4)
            echo "Cancelled duplicate processing"
            return
            ;;
        *)
            echo "Invalid choice, cancelling"
            return 1
            ;;
    esac

    # Process all duplicates
    for pair in "${duplicates_list[@]}"; do
        IFS='|' read -r original duplicate <<< "$pair"

        case $action in
            move)
                echo "Moving duplicate: $duplicate"
                mv "$duplicate" "$target_dir/" && {
                    log_info "Moved duplicate $duplicate to $target_dir/"
                } || {
                    log_error "Failed to move duplicate $duplicate"
                }
                ;;
            delete)
                echo "Deleting duplicate: $duplicate"
                rm "$duplicate" && {
                    log_info "Deleted duplicate: $duplicate"
                } || {
                    log_error "Failed to delete duplicate $duplicate"
                }
                ;;
            interactive)
                echo -e "\nDuplicate pair:"
                echo "Original: $original"
                echo "Duplicate: $duplicate"
                echo "1) Move this duplicate"
                echo "2) Delete this duplicate"
                echo "3) Skip this duplicate"
                echo "4) Cancel remaining processing"
                read -p "Enter choice (1-4): " file_choice

                case $file_choice in
                    1)
                        read -p "Enter directory to move this duplicate to: " file_dir
                        mkdir -p "$file_dir" || {
                            echo "Error: Failed to create directory $file_dir"
                            continue
                        }
                        mv "$duplicate" "$file_dir/" && {
                            echo "Moved duplicate to $file_dir/"
                            log_info "Moved duplicate $duplicate to $file_dir/"
                        } || {
                            echo "Error: Failed to move $duplicate"
                            log_error "Failed to move duplicate $duplicate"
                        }
                        ;;
                    2)
                        rm "$duplicate" && {
                            echo "Deleted duplicate"
                            log_info "Deleted duplicate: $duplicate"
                        } || {
                            echo "Error: Failed to delete $duplicate"
                            log_error "Failed to delete duplicate $duplicate"
                        }
                        ;;
                    3)
                        echo "Skipping this duplicate"
                        ;;
                    4)
                        echo "Cancelling remaining processing"
                        return
                        ;;
                    *)
                        echo "Invalid choice, skipping this duplicate"
                        ;;
                esac
                ;;
        esac
    done
}

### Main Script Execution ###
TARGET_DIR="$1" #get the first argument as the directory
ADMIN_EMAIL="$2" #get the second argument as the admin email
check_arguments "$TARGET_DIR" "$ADMIN_EMAIL"

# Validate the provided email address
# The is_email function is defined in the logger.sh script in the general_logger directory
if is_email "$ADMIN_EMAIL"; then
    echo "Email is valid: $ADMIN_EMAIL"
else
    echo "Invalid Email Provided: Usage: $0 [target_directory] [admin_email]" 1>&2
    log_error "Usage error: Invalid email address provided $ADMIN_EMAIL" 
    exit 1  # Optional: Exit script if email is invalid
fi
# Run main logic
find_duplicate_files "$TARGET_DIR"

#Send Log file to admin if there are duplicates

if (( LOG_COUNT >= 1 )); then
  handle_duplicates
  echo -e "==========================Sending LogFiles To Admin==========================="
  log_info "Sending log file '$LOG_FILE' to admin '$ADMIN_EMAIL'"
  send_email_to_admin "$ADMIN_EMAIL" "$LOG_FILE" "Duplicate"
fi
