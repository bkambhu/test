# Toggle Windows desktop icons

This repository includes a PowerShell script that reproduces the Windows desktop right-click action:

- **View → Show desktop icons**

## File

- `toggle-desktop-icons.ps1`

## Usage

Open **PowerShell** and run:

```powershell
# Toggle current state
.\toggle-desktop-icons.ps1

# Explicitly hide icons
.\toggle-desktop-icons.ps1 -Mode Hide

# Explicitly show icons
.\toggle-desktop-icons.ps1 -Mode Show
```

## What it does

- Updates `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideIcons`
  - `0` = show icons
  - `1` = hide icons
- Restarts `explorer.exe` so the change is applied immediately.
