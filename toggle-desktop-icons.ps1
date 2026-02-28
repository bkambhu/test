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
    if ($null -eq $value) {
        return 0
    }

    return [int]$value
}

function Set-HideIconsValue([int]$Value) {
    Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $Value

    # Verify and retry once if Explorer rewrites the value during restart.
    $applied = Get-HideIconsValue
    if ($applied -ne $Value) {
        Start-Sleep -Milliseconds 200
        Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $Value
    }
}

$currentValue = Get-HideIconsValue
$currentHidden = $currentValue -eq 1

switch ($Mode) {
    'Hide'   { $targetHidden = $true }
    'Show'   { $targetHidden = $false }
    'Toggle' { $targetHidden = -not $currentHidden }
}

$targetValue = if ($targetHidden) { 1 } else { 0 }

if ($currentValue -ne $targetValue) {
    Set-HideIconsValue -Value $targetValue

    # Restart Explorer deterministically: stop all instances and start it again.
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer.exe
    Start-Sleep -Seconds 1

    # Ensure final state remains what the user requested after Explorer is back.
    if ((Get-HideIconsValue) -ne $targetValue) {
        Set-HideIconsValue -Value $targetValue
    }
}

$finalValue = Get-HideIconsValue
if ($finalValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
