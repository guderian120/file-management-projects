

## 📝 General Bash Logger Utility

This Bash script serves as a **reusable logging and alerting utility** that is sourced or imported into other Bash scripts across the application to maintain consistent, timestamped logs and optional email notifications.

---

### 📦 Features

* **Timestamped logging** with support for log levels:

  * `log_info`, `log_warn`, `log_error`, `log_debug`
* **Customizable log file path** (default: `/var/log/bash_logger.log`)
* **Email notification** capability using a Python helper script (`email_server.py`)
* **Basic email validation** with `is_email` function
* Plug-and-play: Simply source it into any Bash script for centralized logging

---

### ⚙️ Usage

**1. Import into your script:**

```bash
source /path/to/logger.sh
```

**2. Use logging functions:**

```bash
log_info "Script started"
log_error "Something went wrong"
```

**3. Send logs via email (optional):**

```bash
send_email_to_admin "admin@example.com" "/path/to/logfile.log" "Alert: Backup Failure"
```

---

### 📁 Structure

* `LOG_FILE`: Default log file path (can be overridden by parent script)
* `email_server.py`: A Python script (must be executable) to handle email sending
* `send_email_to_admin`: Wrapper to send log file to administrator

---

### 🛡 Requirements

* `bash`
* `python3`
* A working Python script `email_server.py` that handles email delivery

---

### 🧪 Example Output

```log
2025-05-15 14:00:00 [INFO] Backup started
2025-05-15 14:05:12 [WARNING] Disk space running low
2025-05-15 14:10:03 [ERROR] Failed to copy database
```

---
