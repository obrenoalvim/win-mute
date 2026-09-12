<#
.SYNOPSIS
    Coverage for the registry-touching helpers in modules/Helpers.ps1 that
    every tweak's Apply/Revert/Test calls into. Runs against a disposable
    HKCU:\Software\WinMuteTests key so it needs no admin rights and touches
    nothing a real tweak would.
.EXAMPLE
    Invoke-Pester (Join-Path $PSScriptRoot 'Helpers.Tests.ps1')
#>

$root = Split-Path -Parent $PSScriptRoot
Get-ChildItem (Join-Path $root 'modules') -Filter '*.ps1' | ForEach-Object { . $_.FullName }

$testRoot = 'HKCU:\Software\WinMuteTests'

Describe 'Set-Reg / Remove-Reg / Test-RegValue' {
    BeforeEach {
        Remove-Item -Path $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    AfterAll {
        Remove-Item -Path $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'Set-Reg creates the key path and value when neither exists' {
        Set-Reg "$testRoot\Sub" 'TestValue' 1
        (Get-ItemProperty -Path "$testRoot\Sub" -Name 'TestValue').TestValue | Should Be 1
    }

    It 'Set-Reg overwrites an existing value' {
        Set-Reg "$testRoot\Sub" 'TestValue' 1
        Set-Reg "$testRoot\Sub" 'TestValue' 2
        (Get-ItemProperty -Path "$testRoot\Sub" -Name 'TestValue').TestValue | Should Be 2
    }

    It 'Test-RegValue reflects what Set-Reg wrote' {
        Set-Reg "$testRoot\Sub" 'TestValue' 5
        Test-RegValue "$testRoot\Sub" 'TestValue' 5 | Should Be $true
        Test-RegValue "$testRoot\Sub" 'TestValue' 6 | Should Be $false
    }

    It 'Remove-Reg deletes the value but leaves the key' {
        Set-Reg "$testRoot\Sub" 'TestValue' 1
        Remove-Reg "$testRoot\Sub" 'TestValue'
        Test-RegValue "$testRoot\Sub" 'TestValue' 1 | Should Be $false
        Test-Path "$testRoot\Sub" | Should Be $true
    }

    It 'Remove-Reg on a path that does not exist does not throw' {
        { Remove-Reg "$testRoot\DoesNotExist" 'X' } | Should Not Throw
    }
}
