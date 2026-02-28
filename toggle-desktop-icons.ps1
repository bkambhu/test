[CmdletBinding()]
param(
    [ValidateSet('Toggle', 'Show', 'Hide')]
    [string]$Mode = 'Toggle',

    [switch]$RestartExplorer
)

$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$registryName = 'HideIcons'
$policyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$policyName = 'NoDesktop'

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

function Get-HideIconsValue {
    $value = (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue).$registryName
    if ($null -eq $value) {
        return 0
    }

    return [int]$value
}

function Set-HideIconsValue([int]$Value) {
    Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $Value
}

function Refresh-DesktopWithoutExplorerRestart {
    # Ask Windows shell to refresh desktop settings/icons without killing Explorer.
    & "$env:WINDIR\System32\ie4uinit.exe" -show | Out-Null
}

$currentValue = Get-HideIconsValue
$currentHidden = $currentValue -eq 1

switch ($Mode) {
    'Hide'   { $targetHidden = $true }
    'Show'   { $targetHidden = $false }
    'Toggle' { $targetHidden = -not $currentHidden }
}

$targetValue = if ($targetHidden) { 1 } else { 0 }

# Always apply target state to recover out-of-sync visual/registry states.
Set-HideIconsValue -Value $targetValue

# If policy key already exists, try to ensure it does not force-hide icons.
# Do not create this key (can be blocked by policy on managed devices).
if (-not $targetHidden -and (Test-Path $policyPath)) {
    try {
        Set-ItemProperty -Path $policyPath -Name $policyName -Type DWord -Value 0 -ErrorAction Stop
    }
    catch {
        Write-Verbose "Could not update $policyPath\\$policyName (policy-managed or access denied)."
    }
}

if ($RestartExplorer) {
    # Optional hard refresh. May open a File Explorer window on some systems.
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 700
    Start-Process explorer.exe
    Start-Sleep -Seconds 1

    if ((Get-HideIconsValue) -ne $targetValue) {
        Set-HideIconsValue -Value $targetValue
    }
}
else {
    Refresh-DesktopWithoutExplorerRestart
}

$finalValue = Get-HideIconsValue
if ($finalValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
