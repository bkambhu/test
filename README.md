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


## If you get parse errors mentioning `--- a/` or `+++ b/`

Your `toggle-desktop-icons.ps1` file was likely replaced with a **git diff patch** instead of actual script content.
That is why PowerShell shows errors like:

- `Missing expression after unary operator '-'`
- `Unexpected token 'a/toggle-desktop-icons.ps1'`

### Quick fix

1. Open `toggle-desktop-icons.ps1` in Notepad.
2. Delete everything.
3. Paste the real script content from this repo (the file should start with `[CmdletBinding()]`).
4. Save and run:

```powershell
.\toggle-desktop-icons.ps1 -Mode Show
```

If the first lines in your script look like this, it is wrong (diff text):

```text
--- a/toggle-desktop-icons.ps1
+++ b/toggle-desktop-icons.ps1
@@ ...
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


## If icons still will not unhide

Run the explicit show command:

```powershell
.\toggle-desktop-icons.ps1 -Mode Show
```

This version writes `HideIcons = 0`, then performs a full Explorer restart (**stop + start**) and verifies the final value, which helps on systems where Explorer races and rewrites settings during startup.
