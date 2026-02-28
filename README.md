# Toggle Windows desktop icons

This repository includes a PowerShell script that reproduces the Windows desktop right-click action:

- **View → Show desktop icons**

## File

- `toggle-desktop-icons.ps1`

## How to run this code (Windows)

```powershell
.\toggle-desktop-icons.ps1
```

Explicit modes:

```powershell
.\toggle-desktop-icons.ps1 -Mode Hide
.\toggle-desktop-icons.ps1 -Mode Show
```

## Fix for "cannot unhide" and Explorer window popping

This version does **not** restart Explorer by default.

- It force-writes `HideIcons` every run (`1` hide / `0` show).
- For `Show`, if `Policies\Explorer` already exists, it tries to set `NoDesktop=0`.
- It refreshes desktop settings without killing Explorer, so it avoids the “home folder/File Explorer pops up” issue.

If you still need a hard refresh, use:

```powershell
.\toggle-desktop-icons.ps1 -Mode Show -RestartExplorer
```

> Note: `-RestartExplorer` may open a File Explorer window on some systems.

## If policy key access is denied

On managed/corporate machines, `HKCU\...\Policies\Explorer` can be locked.
The script now skips creating that key and continues with `HideIcons` changes.

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
- `-RestartExplorer`: optional hard refresh (can pop File Explorer window).

## If your script file contains git diff text

If the file starts with lines like these, it is broken content (diff), not script:

```text
--- a/toggle-desktop-icons.ps1
+++ b/toggle-desktop-icons.ps1
@@ ...
```

Replace the file with the actual script content from this repository.
