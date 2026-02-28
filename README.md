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

## How it works

- Reads `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideIcons`.
- Sends the same Windows shell command (`Progman` `WM_COMMAND` `0x7402`) used by the desktop context menu toggle.
- Prints the final state.
