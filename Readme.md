
# 📁 File Management Projects

This repository is a collection of Bash-based tools to automate and manage files efficiently. It contains seven modular scripts—each solving a real-world file management problem. A shared logging system and email notification utility are included for reuse across all projects.

---

## 🔧 General Utilities

* **[`general_logger/`](./general_logger)**
  Contains reusable modules:

  * `logger.sh`: Logs activities and errors across all scripts.
  * `email_server.py`: Sends email notifications for critical events.

---

## 📂 Projects Overview

### 1. [Automatic File Sorter](./sorter)

Organizes files by extension into categorized folders (Documents, Images, Videos, etc.).
**Skills:** File handling, conditional logic, directory management
📖 See [`README`](./sorter/Readme.md)

---

### 2. [Bulk File Renamer](./bulk_renamer)

Renames multiple files using user-defined patterns, prefixes, suffixes, and counters.
**Skills:** Regular expressions, loops, command-line input
📖 See [`README`](./bulk_renamer/README.md)

---

### 3. [Duplicate File Finder](./duplicate_finder)

Identifies duplicate files based on size and hash comparison, with options to delete or move them.
**Skills:** File hashing, user interaction, arrays
📖 See [`README`](./duplicate_finder/README.md)

---

### 4. [File Backup System](./backup)

Backs up selected files or directories with options for full or incremental backups, compression, and scheduling.
**Skills:** Archiving, scheduling (cron), file operations
📖 See [`README`](./backup/README.md)

---

### 5. [Disk Space Analyzer](./disk_space_check)

Displays the top space-consuming files and directories, with basic sort and filter options.
**Skills:** Sorting, disk usage reporting, output formatting
📖 See [`README`](./disk_space_check/README.md)

---

### 6. [File Encryption Tool](./file_encryption)

Encrypts and decrypts files using AES-256-CBC with secure password input.
**Skills:** OpenSSL, secure input/output, encryption handling
📖 See [`README`](./file_encryption/README.md)

---

### 7. [File Sync Utility](./file_sync)

Keeps two directories in sync with two-way synchronization and basic conflict resolution.
**Skills:** Rsync, logging, conflict detection
📖 See [`README`](./file_sync/README.md)

---

## 🧩 How to Use

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/file-management-projects.git
   cd file-management-projects
   ```

2. Navigate to any project directory and follow its instructions.

3. Shared tools in `general_logger/` can be sourced or imported where needed.

---

## ⚠️ Disclaimer

These tools are designed for **educational and personal use**. Please test in safe environments before applying them to sensitive or production filesystems.

