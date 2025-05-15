
# 📦 Disk Space Analyzer

A simple and interactive Bash script to analyze disk space usage within a specified directory. It helps identify the **largest files and directories** to manage disk space effectively.

---

## 🔧 Features

* Analyze disk usage of a given directory and its subdirectories
* Interactive prompts for:

  * Number of top items to display
  * Sorting method (by size, name, or file type)
* Human-readable output
* Lightweight and beginner-friendly

---

## 🚀 Usage

```bash
./disk_space_analyzer.sh [path_to_directory]
```

**Example:**

```bash
./disk_space_analyzer.sh /home/user
```

You’ll be prompted to:

* Enter how many top items you want (default: 20)
* Choose a sorting option:

  1. Largest files/directories (default)
  2. By name (alphabetical)
  3. By file type

---

## ⚠️ Warning

This script may be **slow or inefficient** on directories containing a **very large number of files**, especially when using file type sorting (`Option 3`). Use with caution on massive datasets like `/var`, `/usr`, or external drives with many files.

---

## 📄 Output

Example output:

```
📦 Analyzing disk usage in: /home/user
------------------Please Wait--------------------------------
20M     /home/user/videos/movie.mp4
15M     /home/user/backups/backup.tar.gz
...
```

---

## ✅ Requirements

* Bash shell
* `du`, `sort`, `head`, `file`, `find` (common on most Unix/Linux systems)

---

## 📬 Feedback

Feel free to improve or adapt this script for your specific use case. Contributions and suggestions are welcome!

---
