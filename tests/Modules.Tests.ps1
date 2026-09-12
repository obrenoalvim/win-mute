<#
.SYNOPSIS
    Shape/regression tests for the tweak modules. Uses the classic Pester
    syntax (Describe/It/Should) that ships inline with Windows PowerShell
    5.1, no Install-Module needed.
.EXAMPLE
    Invoke-Pester (Join-Path $PSScriptRoot 'Modules.Tests.ps1')
#>

$root = Split-Path -Parent $PSScriptRoot
Get-ChildItem (Join-Path $root 'modules') -Filter '*.ps1' | ForEach-Object { . $_.FullName }

function Get-AllTweaksForTest {
    Get-AITweaks
    Get-TelemetryTweaks
    Get-ServiceTweaks
    Get-ScheduledTaskTweaks
    Get-BloatwareTweaks
    Get-PrivacyTweaks
}

Describe 'Tweak module shape' {
    $all = @(Get-AllTweaksForTest)

    It 'loads at least one tweak' {
        $all.Count | Should BeGreaterThan 0
    }

    It 'has no duplicate Ids' {
        $dupes = $all | Group-Object Id | Where-Object Count -gt 1
        $dupes.Count | Should Be 0
    }

    foreach ($category in 'AI', 'Telemetry', 'Services', 'ScheduledTasks', 'Bloatware', 'Privacy') {
        It "has at least one tweak in category '$category'" {
            ($all | Where-Object Category -eq $category).Count | Should BeGreaterThan 0
        }
    }

    It 'only uses known Risk values' {
        $badRisk = $all | Where-Object { $_.Risk -notin @('Safe', 'Moderate', 'Aggressive') }
        $badRisk.Count | Should Be 0
    }

    It 'every tweak has Id, Category, Risk, Name, Description, Apply, Revert, Test' {
        $incomplete = $all | Where-Object {
            -not $_.Id -or -not $_.Category -or -not $_.Risk -or -not $_.Name -or -not $_.Description `
                -or $_.Apply -isnot [scriptblock] -or $_.Revert -isnot [scriptblock] -or $_.Test -isnot [scriptblock]
        }
        $incomplete.Count | Should Be 0
    }

    It 'only uses known OS tags when present' {
        $badOS = $all | Where-Object { $_.PSObject.Properties.Match('OS').Count -and $_.OS -notin @('Win10', 'Win11', 'Both') }
        $badOS.Count | Should Be 0
    }
}

Describe 'Get-CompatibleTweaks' {
    $fake = @(
        [PSCustomObject]@{ Id = 'BOTH1'; OS = 'Both' }
        [PSCustomObject]@{ Id = 'WIN10ONLY'; OS = 'Win10' }
        [PSCustomObject]@{ Id = 'WIN11ONLY'; OS = 'Win11' }
        [PSCustomObject]@{ Id = 'UNTAGGED' }
    )

    It 'treats a tweak with no OS property as Both' {
        $result = Get-CompatibleTweaks -Tweaks $fake -CurrentOS 'Win10'
        @($result | Where-Object Id -eq 'UNTAGGED').Count | Should Be 1
    }

    It 'includes Both and Win10 tweaks, excludes Win11-only, for CurrentOS Win10' {
        $result = Get-CompatibleTweaks -Tweaks $fake -CurrentOS 'Win10'
        ($result.Id | Sort-Object) -join ',' | Should Be 'BOTH1,UNTAGGED,WIN10ONLY'
    }

    It 'includes Both and Win11 tweaks, excludes Win10-only, for CurrentOS Win11' {
        $result = Get-CompatibleTweaks -Tweaks $fake -CurrentOS 'Win11'
        ($result.Id | Sort-Object) -join ',' | Should Be 'BOTH1,UNTAGGED,WIN11ONLY'
    }
}

Describe 'Get-WindowsMajor / Get-WindowsBuildNumber' {
    It 'Get-WindowsBuildNumber returns a positive integer' {
        (Get-WindowsBuildNumber) | Should BeGreaterThan 0
    }

    It 'Get-WindowsMajor returns Win10 or Win11' {
        @('Win10', 'Win11') -contains (Get-WindowsMajor) | Should Be $true
    }
}

Describe 'Test-RegValue' {
    It 'returns false for a registry path that does not exist' {
        Test-RegValue -Path 'HKCU:\Software\WinMute\DoesNotExist12345' -Name 'X' -ExpectedValue 1 | Should Be $false
    }
}
