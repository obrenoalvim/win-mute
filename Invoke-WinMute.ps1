#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables Windows AI features, telemetry, unneeded services/tasks and bloatware apps.
    Works on Windows 10 or 11 - the version is auto-detected.
.PARAMETER Categories
    Only offer tweaks from these categories: AI, Telemetry, Services, ScheduledTasks, Bloatware, Privacy
.PARAMETER Ids
    Apply these specific tweak IDs directly, no picker (e.g. AI01,TEL02).
.PARAMETER All
    Apply every tweak (optionally filtered by -Categories) with no picker.
.PARAMETER Report
    Show applied/not-applied status for every tweak and exit.
.PARAMETER Undo
    Revert every tweak recorded in the log.
.PARAMETER SkipRestorePoint
    Do not create a System Restore point before applying changes.
.PARAMETER SafeOnly
    Only offer/apply tweaks tagged Risk = Safe.
.NOTES
    Windows 10 vs 11 is auto-detected; tweaks that only apply to one of them
    are filtered out automatically, no version to pick.
.EXAMPLE
    .\Invoke-WinMute.ps1
    Opens an interactive checklist (Out-GridView) to pick tweaks.
.EXAMPLE
    .\Invoke-WinMute.ps1 -Categories AI,Telemetry -All
    Applies every AI and Telemetry tweak with no prompts.
.EXAMPLE
    .\Invoke-WinMute.ps1 -Undo
    Reverts everything previously applied by this tool.
#>
[CmdletBinding()]
param(
    [ValidateSet('AI', 'Telemetry', 'Services', 'ScheduledTasks', 'Bloatware', 'Privacy')]
    [string[]]$Categories,
    [string[]]$Ids,
    [switch]$All,
    [switch]$Report,
    [switch]$Undo,
    [switch]$SkipRestorePoint,
    [switch]$SafeOnly
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$logPath = Join-Path $root 'logs\applied.json'

Get-ChildItem (Join-Path $root 'modules') -Filter '*.ps1' | ForEach-Object { . $_.FullName }

function Get-AllTweaks {
    Get-AITweaks
    Get-TelemetryTweaks
    Get-ServiceTweaks
    Get-ScheduledTaskTweaks
    Get-BloatwareTweaks
    Get-PrivacyTweaks
}

function Get-AppliedLog {
    # The leading comma stops PowerShell from unrolling a 1-element array back
    # into a bare object when the function's output crosses the return boundary
    # (classic gotcha: happens only via a function call, not a direct @() assign).
    if (Test-Path $logPath) { , @(Get-Content $logPath -Raw | ConvertFrom-Json) } else { , @() }
}

function Save-AppliedLog($entries) {
    $entries | ConvertTo-Json -Depth 3 | Set-Content -Path $logPath -Encoding UTF8
}

$currentOS = Get-WindowsMajor
Write-Host "Detected: $currentOS (build $(Get-WindowsBuildNumber))" -ForegroundColor DarkCyan

$tweaks = Get-CompatibleTweaks -Tweaks (Get-AllTweaks) -CurrentOS $currentOS
if ($Categories) { $tweaks = $tweaks | Where-Object { $_.Category -in $Categories } }
if ($SafeOnly) { $tweaks = $tweaks | Where-Object { $_.Risk -eq 'Safe' } }

if ($Report) {
    $tweaks | ForEach-Object {
        $applied = try { & $_.Test } catch { $false }
        [PSCustomObject]@{ Id = $_.Id; Category = $_.Category; OS = $_.OS; Risk = $_.Risk; Applied = [bool]$applied; Name = $_.Name }
    } | Format-Table -AutoSize
    return
}

if ($Undo) {
    $log = Get-AppliedLog
    if (-not $log -or $log.Count -eq 0) { Write-Host 'Nothing to undo, log is empty.' -ForegroundColor Yellow; return }
    $byId = @{}
    $tweaks | ForEach-Object { $byId[$_.Id] = $_ }
    foreach ($entry in $log) {
        $tweak = $byId[$entry.Id]
        if (-not $tweak) { continue }
        Write-Host "Reverting $($tweak.Id) - $($tweak.Name)" -ForegroundColor Cyan
        try { & $tweak.Revert } catch { Write-Warning "Revert failed for $($tweak.Id): $_" }
    }
    Remove-Item $logPath -ErrorAction SilentlyContinue
    Write-Host 'Undo complete.' -ForegroundColor Green
    return
}

$selected = $null
if ($Ids) {
    $selected = $tweaks | Where-Object { $_.Id -in $Ids }
}
elseif ($All) {
    $selected = $tweaks
}
else {
    $selected = $tweaks |
        Select-Object Id, Category, Risk, Name, Description |
        Out-GridView -Title "Select tweaks to apply for $currentOS (Ctrl+click for multiple), then click OK" -PassThru
    if (-not $selected) { Write-Host 'Nothing selected, exiting.' -ForegroundColor Yellow; return }
    $ids = $selected.Id
    $selected = $tweaks | Where-Object { $_.Id -in $ids }
}

if (-not $selected -or $selected.Count -eq 0) { Write-Host 'Nothing to apply.' -ForegroundColor Yellow; return }

if (-not $SkipRestorePoint) {
    Write-Host 'Creating a System Restore point...' -ForegroundColor Cyan
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description 'win-mute before changes' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
    }
    catch { Write-Warning "Could not create a restore point: $_" }
}

$log = Get-AppliedLog
$logIds = @($log | ForEach-Object { $_.Id })

foreach ($tweak in $selected) {
    Write-Host "Applying $($tweak.Id) - $($tweak.Name)" -ForegroundColor Cyan
    try {
        & $tweak.Apply
        if ($tweak.Id -notin $logIds) {
            $log += [PSCustomObject]@{ Id = $tweak.Id; Name = $tweak.Name; AppliedAt = (Get-Date).ToString('s') }
        }
    }
    catch { Write-Warning "Failed to apply $($tweak.Id): $_" }
}

Save-AppliedLog $log
Write-Host "Done. $($selected.Count) tweak(s) processed. Run with -Report to check status, or -Undo to revert." -ForegroundColor Green
