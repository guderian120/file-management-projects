

# 📂 Bulk File Renamer

A Bash script that batch renames files in a target directory using a specified prefix and sends a log of changes to an admin email. Designed for automation and administrative use.

---

## 🚀 Features

* Renames all files in a directory by adding a prefix and counter (e.g., `Bulk_Renamer_0.txt`)
* Skips files that have already been renamed with the prefix
* Logs all renaming activity
* Sends the log file to an admin email using a shared logger and email utility

---

## 📦 Requirements

* Bash (Linux/macOS)
* Run with `sudo` (requires root permissions)
* Dependencies:

  * [`logger.sh`](../general_logger/logger.sh)
  * [`email_server.py`](../general_logger/email_server.py)

---

## 🛠️ Usage

```bash
sudo ./file_bulk_renamer.sh [target_directory] <admin_email@example.com> [optional_prefix]
```

### Parameters:

* `target_directory`: The directory containing the files to rename.
* `admin_email`: Email address to receive the renaming log.
* `optional_prefix`: (Optional) Prefix to use. Defaults to `Bulk_Renamer`.

### Example:

```bash
sudo ./file_bulk_renamer.sh /home/user/downloads admin@example.com ProjectX
```

---

## 📧 Logging & Email

* All renamed files are logged to `bulk_rename.log`.
* If at least one file is renamed, a log file is sent to the specified admin email.

---

## ⚠️ Notes

* Script **must** be run as `root` (use `sudo`).
* Validates email format before continuing.
* Avoids double-renaming files by checking if they already start with the given prefix.

---

## 📁 Project Structure

```
file_bulk_renamer/
├── file_bulk_renamer.sh
├── README.md
└── ../general_logger/
    ├── logger.sh
    └── email_server.py
```


