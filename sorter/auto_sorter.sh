#!/bin/bash

# Auto Sorter Script
# This script organizes files in a target directory into subfolders
# based on their file extensions.

# Check if target directory is provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 [target_directory]"
  exit 1
fi

# Pass the target directory as a variable
TARGET_DIR="$1"

# Create subdirectories for file organization
# This function creates directories where files will be sorted and saved
create_directories() {
  # The -p flag ensures that parent directories are created if they don't exist
  mkdir -p \
    "$TARGET_DIR/Documents" \
    "$TARGET_DIR/Images" \
    "$TARGET_DIR/Videos" \
    "$TARGET_DIR/Others"
}

# Move files to respective directories based on file extension
organize_files() {
  for file in "$TARGET_DIR"/*; do
    if [[ -f "$file" ]]; then
      ext="${file##*.}"
      case "${ext,,}" in  # Convert extension to lowercase
        pdf|doc|docx|txt)
          echo -e "[+] Moving $file to Documents folder"
          mv "$file" "$TARGET_DIR/Documents/"
          ;;
        jpg|jpeg|png|gif)
          echo -e "[+] Moving $file to Images folder"
          mv "$file" "$TARGET_DIR/Images/"
          ;;
        mp4|mov|avi)
          echo -e "[+] Moving $file to Videos folder"
          mv "$file" "$TARGET_DIR/Videos/"
          ;;
        *)
          echo -e "[+] Moving $file to Others folder"
          mv "$file" "$TARGET_DIR/Others/"
          ;;
      esac
    fi
  done
}

# Run the functions
create_directories
organize_files
