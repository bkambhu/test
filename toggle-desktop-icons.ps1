[CmdletBinding()]
param(
    [ValidateSet('Toggle', 'Show', 'Hide')]
    [string]$Mode = 'Toggle'
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

$currentValue = Get-HideIconsValue
$currentHidden = $currentValue -eq 1

switch ($Mode) {
    'Hide'   { $targetHidden = $true }
    'Show'   { $targetHidden = $false }
    'Toggle' { $targetHidden = -not $currentHidden }
}

$targetValue = if ($targetHidden) { 1 } else { 0 }

# Always apply the requested state to handle cases where visual state and registry value are out of sync.
Set-HideIconsValue -Value $targetValue

# On some systems a policy value can keep icons hidden even when HideIcons is 0.
if (-not $targetHidden) {
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
    }

    Set-ItemProperty -Path $policyPath -Name $policyName -Type DWord -Value 0
}

# Restart Explorer deterministically: stop all instances and start it again.
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 700
Start-Process explorer.exe
Start-Sleep -Seconds 1

# Re-apply once after Explorer starts in case startup rewrites the value.
if ((Get-HideIconsValue) -ne $targetValue) {
    Set-HideIconsValue -Value $targetValue
}

$finalValue = Get-HideIconsValue
if ($finalValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
