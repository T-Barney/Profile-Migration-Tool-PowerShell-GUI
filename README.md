# Profile Migration Tool (PowerShell GUI)

A lightweight, GUI-based utility designed to streamline the migration of user profile data between Windows workstations. This tool acts as a wrapper for **Robocopy**, providing a user-friendly interface for IT technicians to perform data transfers without needing to memorize complex command-line arguments.

## 🚀 Features

* **GUI Interface:** Built using PowerShell and Windows Forms for ease of use.
* **Auto-Elevation:** Automatically detects if the script is running as Administrator and prompts for elevation if necessary.
* **Robocopy Optimization:**
    * Multi-threaded transfer (`/MT:32`) for speed.
    * Restartable mode (`/ZB`) for resilience against network interruptions.
    * Preserves file attributes and timestamps (`/COPY:DAT`).
* **Smart Exclusions:** Automatically excludes system heavy/locked folders (e.g., `AppData`, `OneDrive` cache) to prevent profile corruption on the destination machine.
* **Logging:** Generates detailed transfer logs on the technician's desktop for verification.

## 📋 Prerequisites

To use this tool effectively in a domain or workgroup environment:

1.  **Permissions:** The user running the script must have **Local Administrator** privileges on both the Source and Destination machines.
2.  **Network Access:** Both computers must be online and reachable.
3.  **Admin Shares:** Windows Administrative Shares (C$) must be enabled on the target machines.

## 🛠️ Usage
![PMT](https://github.com/user-attachments/assets/c4050888-f3e3-4e11-af17-4fdbb34e6588)


1.  Run the script:
    ```powershell
    .\profile-migration-tool.ps1
    ```
2.  **Username:** Enter the Active Directory or Local username of the profile to copy.
3.  **Source/Destination:** Enter the Computer Name (or Service Tag/IP Address) for the source and destination machines.
4.  Click **Start Migration**.
5.  A command window will open to display the real-time progress of Robocopy. Once finished, check the log file created on your desktop.

## ⚙️ How It Works

The script constructs a dynamic Robocopy command based on the inputs:

```powershell
robocopy "\\Source\c$\Users\User" "\\Dest\c$\Users\User" /E /ZB /COPY:DAT /MT:32 ...
