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

$targetValue = if ($targetHidden) { 1 } else { 0 }

if ([int]$currentValue -ne $targetValue) {
    Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $targetValue

    # Refresh desktop by restarting Explorer so the icon visibility change is applied.
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

$updatedValue = (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue).$registryName
if ($null -eq $updatedValue) {
    $updatedValue = $targetValue
}

if ([int]$updatedValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
