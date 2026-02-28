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

switch ($Mode) {
    'Hide'   { $newValue = 1 }
    'Show'   { $newValue = 0 }
    'Toggle' {
        if ($currentValue -eq 0) {
            $newValue = 1
        }
        else {
            $newValue = 0
        }
    }
}

Set-ItemProperty -Path $registryPath -Name $registryName -Type DWord -Value $newValue

# Refresh desktop view by restarting Explorer.
Stop-Process -Name explorer -Force

if ($newValue -eq 1) {
    Write-Output 'Desktop icons are now hidden.'
}
else {
    Write-Output 'Desktop icons are now visible.'
}
