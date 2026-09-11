function Set-Reg {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)]$Value, [string]$Type = 'DWord')
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Remove-Reg {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name)
    if (Test-Path $Path) { Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue }
}

function Test-RegValue {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name, $ExpectedValue)
    if (-not (Test-Path $Path)) { return $false }
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    return ($item.$Name -eq $ExpectedValue)
}

function Disable-Svc {
    param([Parameter(Mandatory)][string]$Name)
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($svc) {
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Enable-Svc {
    param([Parameter(Mandatory)][string]$Name, [string]$StartupType = 'Manual')
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($svc) {
        Set-Service -Name $Name -StartupType $StartupType -ErrorAction SilentlyContinue
        if ($StartupType -eq 'Automatic') { Start-Service -Name $Name -ErrorAction SilentlyContinue }
    }
}

function Disable-Task {
    param([Parameter(Mandatory)][string]$TaskPath, [Parameter(Mandatory)][string]$TaskName)
    Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
}

function Enable-Task {
    param([Parameter(Mandatory)][string]$TaskPath, [Parameter(Mandatory)][string]$TaskName)
    Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
}

function Remove-Bloat {
    param([Parameter(Mandatory)][string]$Name)
    Get-AppxPackage -Name $Name -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -eq $Name | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
}

function Get-WindowsMajor {
    $build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
    if ($build -ge 22000) { 'Win11' } else { 'Win10' }
}

function Get-CompatibleTweaks {
    param([Parameter(Mandatory)][array]$Tweaks, [Parameter(Mandatory)][string]$CurrentOS)
    $Tweaks | ForEach-Object {
        if (-not $_.PSObject.Properties.Match('OS').Count) { $_ | Add-Member -NotePropertyName OS -NotePropertyValue 'Both' -Force }
        $_
    } | Where-Object { $_.OS -eq 'Both' -or $_.OS -eq $CurrentOS }
}
