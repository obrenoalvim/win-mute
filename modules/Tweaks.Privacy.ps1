function Get-PrivacyTweaks {
    @(
        [PSCustomObject]@{
            Id = 'PRIV01'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Disable Start menu / lock screen suggestions and ads'
            Description = 'Turns off "Suggested" apps, tips, and spotlight ads across Start and lock screen.'
            Apply = {
                $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
                'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SilentInstalledAppsEnabled', 'SystemPaneSuggestionsEnabled', 'RotatingLockScreenOverlayEnabled', 'RotatingLockScreenEnabled' | ForEach-Object { Set-Reg $p $_ 0 }
            }
            Revert = {
                $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
                'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SilentInstalledAppsEnabled', 'SystemPaneSuggestionsEnabled', 'RotatingLockScreenOverlayEnabled', 'RotatingLockScreenEnabled' | ForEach-Object { Set-Reg $p $_ 1 }
            }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV02'; Category = 'Privacy'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Widgets board'
            Description = 'Removes the Widgets icon and background news feed process.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV03'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Disable OneDrive auto-start and backup nags'
            Description = 'Prevents OneDrive from launching at sign-in and nagging to back up folders.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' 1 }
        }
        [PSCustomObject]@{
            Id = 'PRIV04'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Disable location tracking service-wide'
            Description = 'Turns off the system location service for all apps.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' 1 }
        }
        [PSCustomObject]@{
            Id = 'PRIV05'; Category = 'Privacy'; Risk = 'Moderate'
            Name = 'Disable "Let apps run in the background" telemetry-heavy default'
            Description = 'Blocks background apps globally, cutting a common data-collection vector. Side effect: mail/chat apps that rely on background refresh may stop showing live notifications until opened.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsRunInBackground' 2 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsRunInBackground' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsRunInBackground' 2 }
        }
        [PSCustomObject]@{
            Id = 'PRIV06'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Disable clipboard cloud sync'
            Description = 'Stops clipboard history from syncing to a Microsoft account across devices.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' 0 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV07'; Category = 'Privacy'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Restore classic right-click context menu'
            Description = 'Undoes the Windows 11 "Show more options" menu that hides Print, 7-Zip, etc. behind a second click.'
            Apply = {
                $clsid = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
                New-Item -Path $clsid -Force | Out-Null
                Set-Item -Path $clsid -Value '' -Force
                Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            }
            Revert = {
                Remove-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force -ErrorAction SilentlyContinue
                Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            }
            Test = { Test-Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' }
        }
        [PSCustomObject]@{
            Id = 'PRIV08'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Disable Start menu "Recommended" section ads'
            Description = 'Hides the recently-used/suggested-app feed injected below the pinned apps grid.'
            Apply = { Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1; Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1 }
            Revert = { Remove-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection'; Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' }
            Test = { Test-RegValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1 }
        }
        [PSCustomObject]@{
            Id = 'PRIV09'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Hide taskbar Chat/Teams icon'
            Description = 'Removes the consumer Teams "Chat" button from the taskbar.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 1 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV10'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Stop auto-installing sponsored/suggested apps'
            Description = 'Blocks the "Consumer Experience" feature that silently installs Store apps like Candy Crush.'
            Apply = {
                $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
                'PreInstalledAppsEnabled', 'OemPreInstalledAppsEnabled', 'ContentDeliveryAllowed' | ForEach-Object { Set-Reg $p $_ 0 }
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
            }
            Revert = {
                $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
                'PreInstalledAppsEnabled', 'OemPreInstalledAppsEnabled', 'ContentDeliveryAllowed' | ForEach-Object { Set-Reg $p $_ 1 }
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures'
            }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1 }
        }
        [PSCustomObject]@{
            Id = 'PRIV11'; Category = 'Privacy'; Risk = 'Moderate'
            Name = 'Disable Game DVR / Game Bar background recording'
            Description = 'Stops Xbox Game Bar from recording game clips in the background (also helps performance).'
            Apply = { Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0; Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0 }
            Revert = { Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 1; Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 1 }
            Test = { Test-RegValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV12'; Category = 'Privacy'; Risk = 'Safe'; OS = 'Win10'
            Name = 'Block the "Upgrade to Windows 11" nag'
            Description = 'Stops Windows Update from offering/pushing the Windows 11 upgrade banner and notifications.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DisableOSUpgrade' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DisableOSUpgrade' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DisableOSUpgrade' 1 }
        }
        [PSCustomObject]@{
            Id = 'PRIV13'; Category = 'Privacy'; Risk = 'Safe'; OS = 'Win10'
            Name = 'Hide the People icon from the taskbar'
            Description = 'Removes the People (contacts) flyout button most people never use.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' 0 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' 1 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' 0 }
        }
        [PSCustomObject]@{
            Id = 'PRIV14'; Category = 'Privacy'; Risk = 'Safe'
            Name = 'Stop Edge from re-creating its desktop shortcut'
            Description = 'Blocks the recurring "Microsoft Edge" icon that update installs drop back onto the desktop.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'DisableEdgeDesktopShortcutCreation' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'DisableEdgeDesktopShortcutCreation' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'DisableEdgeDesktopShortcutCreation' 1 }
        }
    )
}
