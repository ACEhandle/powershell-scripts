import os
import sys
import tempfile
import requests
import subprocess
import shutil
import time
import threading
import customtkinter as ctk

# Constants
GITHUB_RELEASES_API = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
MSI_KEYWORD = "win-x64.msi"


def get_latest_msi_url():
    resp = requests.get(GITHUB_RELEASES_API)
    resp.raise_for_status()
    data = resp.json()
    for asset in data.get("assets", []):
        name = asset.get("name", "")
        if MSI_KEYWORD in name and "sandbox" not in name.lower():
            return asset["browser_download_url"], name
    raise Exception("Could not find latest non-sandboxed MSI.")


def download_file(url, dest):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(dest, 'wb') as f:
            shutil.copyfileobj(r.raw, f)


class UpgradeWindow(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("PowerShell Upgrade")
        self.geometry("400x150")
        self.resizable(False, False)
        self.label = ctk.CTkLabel(self, text="Starting upgrade...", font=("Segoe UI", 14))
        self.label.pack(pady=20)
        self.progress = ctk.CTkProgressBar(self, width=300)
        self.progress.pack(pady=10)
        self.progress.set(0)
        self.status = ctk.CTkLabel(self, text="", font=("Segoe UI", 10))
        self.status.pack(pady=5)
        self.protocol("WM_DELETE_WINDOW", self.on_close)
        self.closed = False

    def set_status(self, text, progress=None):
        self.label.configure(text=text)
        if progress is not None:
            self.progress.set(progress)
        self.update_idletasks()

    def set_detail(self, text):
        self.status.configure(text=text)
        self.update_idletasks()

    def on_close(self):
        self.closed = True
        self.destroy()


def threaded_upgrade(window):
    try:
        window.set_status("Checking for latest PowerShell release...", 0.1)
        url, name = get_latest_msi_url()
        window.set_status(f"Downloading {name}...", 0.3)
        temp_dir = tempfile.gettempdir()
        msi_path = os.path.join(temp_dir, name)
        download_file(url, msi_path)
        window.set_status("Download complete.", 0.6)
        window.set_detail(f"Saved to {msi_path}")
        window.set_status("Running installer...", 0.8)
        # Run installer and wait for it to finish
        proc = subprocess.Popen([
            "msiexec.exe", "/i", msi_path, "/qn", "/norestart"
        ])
        proc.wait()
        window.set_status("Upgrade complete. Launching new PowerShell...", 1.0)
        time.sleep(2)
        # Launch new PowerShell window
        subprocess.Popen(["start", "pwsh"], shell=True)
        window.set_detail("New PowerShell window launched.")
        window.after(1000, window.on_close)
        # Close PowerShell if running from it
        if "pwsh.exe" in os.environ.get("COMSPEC", "").lower() or "pwsh" in sys.executable.lower():
            subprocess.Popen(["taskkill", "/IM", "pwsh.exe", "/F"])
    except Exception as e:
        window.set_status("Upgrade failed.", 0)
        window.set_detail(str(e))


def main():
    try:
        # Show progress window
        ctk.set_appearance_mode("system")
        window = UpgradeWindow()
        t = threading.Thread(target=threaded_upgrade, args=(window,), daemon=True)
        t.start()
        window.mainloop()
    except Exception as e:
        print(f"[ERROR] {e}")
        print("Upgrade failed. Please check the error above and try again.")
        sys.exit(1)


if __name__ == "__main__":
    main()
