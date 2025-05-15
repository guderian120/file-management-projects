
# 🔄 Two-Way Folder Sync Script (with Conflict Detection)

This Bash script performs a **two-way synchronization** between two folders using `rsync`, ensuring files are updated without overwriting newer versions. It intelligently detects **conflicts**, logs every action, and preserves conflicting files with a `.syncconflict` suffix.

---

## 📦 Features

* ✅ Two-way sync between two directories
* 🔄 Uses `rsync` to avoid overwriting newer files (`--update`)
* ⚠️ Detects recent conflicts (files modified on both sides)
* 📝 Logs all sync operations and conflicts
* 🗃️ Saves conflict copies with `.syncconflict` extension for review

---

## 🛠️ Usage

```bash
./sync_folders.sh /path/to/folder1 /path/to/folder2
```

### Example:

```bash
./sync_folders.sh ~/Documents/Work ~/Documents/Backup
```

---

## 📁 How It Works

1. **Validation**: Checks that both input arguments are valid directories.
2. **Sync Direction 1**: Syncs from `folder1` → `folder2`:

   * Uses `rsync -av --update` to sync only older or missing files.
   * Deletes files from destination if they were deleted in source.
3. **Conflict Check**:

   * For each file, compares modification times.
   * If both source and destination versions were modified within the last 24 hours and differ:

     * A conflict is logged.
     * The destination version is preserved as `file.syncconflict`.
4. **Sync Direction 2**: Repeats same process from `folder2` → `folder1`.

---

## 📜 Log File

* All operations are logged to `sync_folders.log` in the current working directory.
* Entries include timestamps and details about sync actions and conflicts.

---

## 📌 Requirements

* Bash shell
* `rsync` utility
* `stat` and `find` (standard on most Linux/Unix systems)

---

## ⚠️ Notes

* Conflict detection assumes conflicts if **both files are modified within the last 24 hours**.
* You can customize the conflict threshold (default: 24h) within the script.
* Files ending with `.syncconflict` are safe copies for manual review and resolution.

---

## 🔧 Project Structure

```
sync_folders/
├── sync_folders.sh
├── sync_folders.log
└── README.md
```

---

## 🚀 Sample Output

```
[2025-05-15 10:00:00] Starting two-way sync: /src <-> /dest
[2025-05-15 10:00:00] Syncing /src -> /dest
[2025-05-15 10:00:01] ⚠️ Conflict detected on file: notes.txt
[2025-05-15 10:00:01] Copied conflict file as /dest/notes.txt.syncconflict
[2025-05-15 10:00:02] Syncing /dest -> /src
[2025-05-15 10:00:03] Two-way sync completed.
```

