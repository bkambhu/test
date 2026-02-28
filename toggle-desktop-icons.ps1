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

$currentValue = (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue).$registryName
if ($null -eq $currentValue) {
    $currentValue = 0
}

$currentHidden = [int]$currentValue -eq 1

switch ($Mode) {
    'Hide'   { $targetHidden = $true }
    'Show'   { $targetHidden = $false }
    'Toggle' { $targetHidden = -not $currentHidden }
}

if ($currentHidden -ne $targetHidden) {
    if (-not ('DesktopIconToggle' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class DesktopIconToggle {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
'@
    }

    $progman = [DesktopIconToggle]::FindWindow('Progman', $null)
    if ($progman -eq [IntPtr]::Zero) {
        throw 'Unable to find Progman window. Cannot toggle desktop icons.'
    }

    $WM_COMMAND = 0x0111
    $TOGGLE_DESKTOP_ICONS_COMMAND = 0x7402
    [void][DesktopIconToggle]::SendMessage($progman, $WM_COMMAND, [IntPtr]$TOGGLE_DESKTOP_ICONS_COMMAND, [IntPtr]::Zero)

    Start-Sleep -Milliseconds 200
}

$updatedValue = (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue).$registryName
if ($null -eq $updatedValue) {
    $updatedValue = if ($targetHidden) { 1 } else { 0 }
}

if ([int]$updatedValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
