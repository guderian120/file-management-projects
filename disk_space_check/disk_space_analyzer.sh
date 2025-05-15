#!/bin/bash




# This script analyzes disk space usage in a specified directory and its subdirectories.
# It lists the largest files and directories, sorted by size or type.
# Users can specify how many results to show and how to sort them.
# Usage:
#   ./disk_space_analyzer.sh <directory_path>
# Example:
#   ./disk_space_analyzer.sh /home/user

# Function to print usage
usage() {
    echo "Usage: $0 [path_to_directory]"
    echo "Example: $0 /home/user"
    exit 1
}

# Validate input and ensure a path is provided
if [[ -z "$1" ]]; then
    echo "❌ Error: No path provided."
    usage
fi

# Check if the provided path exists and is a directory
if [[ ! -d "$1" ]]; then
    echo "❌ Error: '$1' is not a valid directory."
    usage
fi

TARGET_DIR="$1"

# Ask user for number of results
read -p "🔢 How many top items do you want to display? (default: 20): " NUM_RESULTS
NUM_RESULTS=${NUM_RESULTS:-20}  # Use 20 if input is empty

# Ask user for sort preference
echo "📊 How would you like to sort the results?"
echo "1. Largest files/directories (default)"
echo "2. By name (alphabetical)"
echo "3. By file type"
read -p "Enter your choice [1-3]: " SORT_OPTION
SORT_OPTION=${SORT_OPTION:-1}

# Execute based on sorting preference
echo -e "\n📦 Analyzing disk usage in: $TARGET_DIR"
echo "------------------Please Wait--------------------------------"

case "$SORT_OPTION" in
    1)
        echo "🔠 Sorted by size (largest first):"
        du -ah "$TARGET_DIR" 2>/dev/null | sort -rh | head -n "$NUM_RESULTS"
        ;;
    2)
        echo "🔠 Sorted by name:"
        du -ah "$TARGET_DIR" 2>/dev/null | sort | head -n "$NUM_RESULTS"
        ;;
    3)
        echo "🔤 Sorted by file type:"
        find "$TARGET_DIR" -type f 2>/dev/null | while read -r file; do
            file_size=$(du -h "$file" 2>/dev/null | cut -f1)
            file_type=$(file --brief --mime-type "$file")
            echo -e "$file_size\t$file_type\t$file"
        done | sort -k2 | head -n "$NUM_RESULTS"
        ;;
    *)
        echo "⚠️ Invalid option. Showing top $NUM_RESULTS largest files and directories."
        du -ah "$TARGET_DIR" 2>/dev/null | sort -rh | head -n "$NUM_RESULTS"
        ;;
esac

echo -e "\n✅ Disk Space Analysis Completed."

