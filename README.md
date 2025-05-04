# PowerShell Upgrade Utility

This project provides a Python script to automatically upgrade PowerShell (pwsh) on Windows systems. The script downloads the latest non-sandboxed PowerShell MSI, installs it, and can launch a new PowerShell window after the upgrade. It also provides a graphical progress window for user feedback.

## Features
- Downloads the latest non-sandboxed PowerShell MSI installer from GitHub
- Runs the installer silently
- Closes running PowerShell windows (if possible)
- Optionally launches a new PowerShell window after upgrade
- Displays a progress window using customtkinter
- Designed for use with PowerShell and Windows

## Requirements
- Windows OS
- Python 3.7 or newer (with tkinter support enabled)
- The following Python libraries:
  - requests
  - customtkinter
  - tkinter (part of the standard library, but must be enabled during Python installation)

## Installation
1. Ensure Python is installed and added to your PATH.
2. Make sure tkinter is available (install Python with the "tcl/tk and IDLE" option enabled).
3. Install required libraries:
   ```powershell
   pip install requests customtkinter
   ```

## Usage
1. Run the script from an elevated (Administrator) PowerShell window:
   ```powershell
   python upgrade_powershell.py
   ```
2. Follow the on-screen progress window. The script will download, install, and launch the new PowerShell version.
3. After upgrade, open a new PowerShell window to use the updated version.

## Notes
- The script will attempt to close running PowerShell windows. Save your work before running.
- If you encounter issues with tkinter, ensure your Python installation includes the "tcl/tk and IDLE" feature.
- For convenience, you can add a function or alias to your PowerShell profile to run the script easily.

