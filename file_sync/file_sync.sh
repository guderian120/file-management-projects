#!/bin/bash

# Two-way folder sync with conflict handling and logging

# Usage:
# ./sync_folders.sh /path/to/folder1 /path/to/folder2

SRC="$1"
DEST="$2"
LOGFILE="./sync_folders.log"

if [[ ! -d "$SRC" ]] || [[ ! -d "$DEST" ]]; then
    echo "❌ Both arguments must be valid directories."
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

log "Starting two-way sync: $SRC <-> $DEST"

# Function to sync from SRC to DEST without overwriting newer files in DEST
sync_dir() {
    local from="$1"
    local to="$2"

    log "Syncing $from -> $to"

    # Rsync with update flag (-u) to avoid overwriting newer files
    rsync -av --update --exclude '*.syncconflict' "$from"/ "$to"/

    # Now check for conflicts: files modified in both folders since last sync
    # We will mark conflicts by copying conflicting files with a ".syncconflict" suffix in DEST

    while IFS= read -r -d '' file; do
        relative_path="${file#$from/}"
        dest_file="$to/$relative_path"

        # If file exists in dest, compare modification times
        if [[ -f "$dest_file" ]]; then
            src_mtime=$(stat -c %Y "$file")
            dest_mtime=$(stat -c %Y "$dest_file")

            # If both files modified after last sync, flag conflict
            # For demo, assume last sync was more than the older mod time
            # Here simply if both modified times differ and both are newer than a threshold (e.g. 1 minute ago)
            # You can customize conflict criteria here

            if [[ $src_mtime -ne $dest_mtime ]]; then
                # Conflict detected if both files modified recently (within last 24h)
                now=$(date +%s)
                threshold=$((24*3600))
                if (( now - src_mtime < threshold && now - dest_mtime < threshold )); then
                    log "⚠️ Conflict detected on file: $relative_path"
                    cp "$dest_file" "$dest_file.syncconflict"
                    log "Copied conflict file as $dest_file.syncconflict"
                fi
            fi
        fi
    done < <(find "$from" -type f -print0)
}

# Sync in both directions
sync_dir "$SRC" "$DEST"
sync_dir "$DEST" "$SRC"

log "Two-way sync completed."
