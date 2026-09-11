function Get-TelemetryTweaks {
    @(
        [PSCustomObject]@{
            Id = 'TEL01'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Set diagnostic data to Security/Basic (lowest allowed)'
            Description = 'Lowers AllowTelemetry to the minimum level accepted by the SKU.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0 }
            Revert = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 3 }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0 }
        }
        [PSCustomObject]@{
            Id = 'TEL02'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable Connected User Experiences and Telemetry (DiagTrack)'
            Description = 'Stops and disables the DiagTrack service that uploads telemetry.'
            Apply = { Disable-Svc 'DiagTrack' }
            Revert = { Enable-Svc 'DiagTrack' 'Automatic' }
            Test = { (Get-Service DiagTrack -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TEL03'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable WAP Push Message Routing (dmwappushservice)'
            Description = 'Used for pushing telemetry/config over WAP; safe to disable on PCs.'
            Apply = { Disable-Svc 'dmwappushservice' }
            Revert = { Enable-Svc 'dmwappushservice' 'Manual' }
            Test = { (Get-Service dmwappushservice -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TEL04'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable Advertising ID'
            Description = 'Stops apps from using a per-user ID for targeted ads.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1 }
        }
        [PSCustomObject]@{
            Id = 'TEL05'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable Activity History / Timeline upload'
            Description = 'Stops Windows from publishing activity history to Microsoft.'
            Apply = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
            }
            Revert = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities'
            }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0 }
        }
        [PSCustomObject]@{
            Id = 'TEL06'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable tailored experiences with diagnostic data'
            Description = 'Stops Microsoft from using diagnostic data to personalize tips/ads.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 1 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0 }
        }
        [PSCustomObject]@{
            Id = 'TEL07'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable Feedback / Customer Experience Improvement prompts'
            Description = 'Stops feedback frequency notifications and CEIP data collection.'
            Apply = {
                Set-Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
            }
            Revert = {
                Remove-Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable'
            }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0 }
        }
        [PSCustomObject]@{
            Id = 'TEL08'; Category = 'Telemetry'; Risk = 'Moderate'
            Name = 'Disable Windows Error Reporting service (WerSvc)'
            Description = 'Stops crash reports from being sent to Microsoft.'
            Apply = { Disable-Svc 'WerSvc' }
            Revert = { Enable-Svc 'WerSvc' 'Manual' }
            Test = { (Get-Service WerSvc -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TEL09'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable inking/typing personalization data collection'
            Description = 'Stops Windows from collecting typing/inking data to improve suggestions.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1; Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 0; Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 0 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1 }
        }
        [PSCustomObject]@{
            Id = 'TEL10'; Category = 'Telemetry'; Risk = 'Safe'
            Name = 'Disable app diagnostics / usage access broadly'
            Description = 'Blocks apps from accessing diagnostic info about other apps.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsGetDiagnosticInfo' 2 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsGetDiagnosticInfo' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsGetDiagnosticInfo' 2 }
        }
    )
}
