# Toggle Windows desktop icons

This repository includes a PowerShell script that reproduces the Windows desktop right-click action:

- **View → Show desktop icons**

## File

- `toggle-desktop-icons.ps1`

## How to run this code (Windows)

1. Open **PowerShell** (Windows PowerShell 5.1 or PowerShell 7+) as your normal user.
2. Go to the folder containing the script:

```powershell
cd "C:\path\to\folder"
```

3. (Optional, first time only) allow local scripts in this PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

4. Run one of the commands below:

```powershell
# Toggle current state
.\toggle-desktop-icons.ps1

# Explicitly hide icons
.\toggle-desktop-icons.ps1 -Mode Hide

# Explicitly show icons
.\toggle-desktop-icons.ps1 -Mode Show
```

> Note: The script restarts `explorer.exe` to refresh the desktop, so your taskbar/desktop may briefly disappear and come back.

## Parameters

- `-Mode Toggle` (default): switches to the opposite of the current state.
- `-Mode Hide`: hides desktop icons.
- `-Mode Show`: shows desktop icons.

## What it does

- Updates `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideIcons`
  - `0` = show icons
  - `1` = hide icons
- Restarts `explorer.exe` so the change is applied immediately.
