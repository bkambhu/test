# Toggle Windows desktop icons

This repository includes a PowerShell script that reproduces the Windows desktop right-click action:

- **View → Show desktop icons**

## File

- `toggle-desktop-icons.ps1`

## How to run this code (Windows)

1. Open **PowerShell** in the folder that contains `toggle-desktop-icons.ps1`.

2. Run the script with a **relative path** (important):

```powershell
.\toggle-desktop-icons.ps1
```

3. Optional modes:

```powershell
.\toggle-desktop-icons.ps1 -Mode Hide
.\toggle-desktop-icons.ps1 -Mode Show
```

## If you get “command not found”

PowerShell does **not** run scripts from the current folder unless you include `./` or `.\`.

- ❌ `toggle-desktop-icons.ps1`
- ✅ `.\toggle-desktop-icons.ps1`

Also make sure the filename is exactly `toggle-desktop-icons.ps1` (with `.ps1`).

## If you get “running scripts is disabled”

Run this in the same PowerShell window (temporary for current session only):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run:

```powershell
.\toggle-desktop-icons.ps1
```

## Parameters

- `-Mode Toggle` (default): switches to the opposite of the current state.
- `-Mode Hide`: hides desktop icons.
- `-Mode Show`: shows desktop icons.

## What it does

- Updates `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideIcons`
  - `0` = show icons
  - `1` = hide icons
- Restarts `explorer.exe` so the change is applied immediately.
- Your desktop/taskbar may briefly disappear and come back while Explorer restarts.
