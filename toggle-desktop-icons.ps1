[CmdletBinding()]
param(
    [ValidateSet('Toggle', 'Show', 'Hide')]
    [string]$Mode = 'Toggle'
)

$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$registryName = 'HideIcons'

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

function Get-HideIconsValue {
    $value = (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue).$registryName
    if ($null -eq $value) { return 0 }
    return [int]$value
}

function Set-HideIconsValue([bool]$Hidden) {
    $newValue = if ($Hidden) { 1 } else { 0 }
    Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $newValue
}

function Ensure-NativeDesktopApi {
    if ('DesktopIconToggle' -as [type]) { return }

    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class DesktopIconToggle {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindowEx(IntPtr parentHandle, IntPtr childAfter, string className, string windowTitle);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
}
'@
}

function Get-DesktopCommandHost {
    Ensure-NativeDesktopApi

    $progman = [DesktopIconToggle]::FindWindow('Progman', $null)
    if ($progman -ne [IntPtr]::Zero) {
        return $progman
    }

    $foundHost = [IntPtr]::Zero
    $enumProc = [DesktopIconToggle+EnumWindowsProc]{
        param([IntPtr]$hWnd, [IntPtr]$lParam)

        $defView = [DesktopIconToggle]::FindWindowEx($hWnd, [IntPtr]::Zero, 'SHELLDLL_DefView', $null)
        if ($defView -ne [IntPtr]::Zero) {
            $script:foundHost = $hWnd
            return $false
        }

        return $true
    }

    [void][DesktopIconToggle]::EnumWindows($enumProc, [IntPtr]::Zero)
    return $foundHost
}

function Invoke-DesktopIconMenuToggle {
    $host = Get-DesktopCommandHost
    if ($host -eq [IntPtr]::Zero) {
        return $false
    }

    $WM_COMMAND = 0x0111
    $TOGGLE_DESKTOP_ICONS_COMMAND = 0x7402
    $SMTO_ABORTIFHUNG = 0x0002
    $result = [IntPtr]::Zero

    [void][DesktopIconToggle]::SendMessageTimeout(
        $host,
        $WM_COMMAND,
        [IntPtr]$TOGGLE_DESKTOP_ICONS_COMMAND,
        [IntPtr]::Zero,
        $SMTO_ABORTIFHUNG,
        1000,
        [ref]$result
    )

    Start-Sleep -Milliseconds 200
    return $true
}

$currentHidden = (Get-HideIconsValue) -eq 1
switch ($Mode) {
    'Hide'   { $targetHidden = $true }
    'Show'   { $targetHidden = $false }
    'Toggle' { $targetHidden = -not $currentHidden }
}

if ($currentHidden -ne $targetHidden) {
    $toggledViaShell = Invoke-DesktopIconMenuToggle

    $updatedHidden = (Get-HideIconsValue) -eq 1
    if ($updatedHidden -ne $targetHidden) {
        Set-HideIconsValue -Hidden $targetHidden
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    if (-not $toggledViaShell) {
        Write-Verbose 'Desktop host window not found; used registry + Explorer refresh fallback.'
    }
}

$finalHidden = (Get-HideIconsValue) -eq 1
if ($finalHidden) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
