# Toggle Windows desktop icons

This repository includes a PowerShell script that reproduces the Windows desktop right-click action:

- **View → Show desktop icons**

## File

- `toggle-desktop-icons.ps1`

## How to run this code (Windows)

1. Open **PowerShell** in the folder that contains `toggle-desktop-icons.ps1`.
2. Run with a relative path (important):

```powershell
.\toggle-desktop-icons.ps1
```

3. Optional explicit modes:

```powershell
.\toggle-desktop-icons.ps1 -Mode Hide
.\toggle-desktop-icons.ps1 -Mode Show
```

## Fix for "can hide but cannot unhide"

This script now uses a simple, reliable flow:

1. Read `HideIcons` from `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`.
2. Set the exact target value (`1` = hide, `0` = show).
3. Restart `explorer.exe` so Windows applies the change immediately.

This avoids the previous native API issues (`EnumWindows`, `SendMessageTimeout`, and `$Host` variable conflicts).

## If you get “command not found”

PowerShell does **not** run scripts from the current folder unless you include `./` or `.\`.

- ❌ `toggle-desktop-icons.ps1`
- ✅ `.\toggle-desktop-icons.ps1`

## If you get “running scripts is disabled”

Run this in the same PowerShell window (temporary for current session):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run again:

```powershell
.\toggle-desktop-icons.ps1
```

## Parameters

- `-Mode Toggle` (default): switches to the opposite state.
- `-Mode Hide`: force hide desktop icons.
- `-Mode Show`: force show desktop icons.
