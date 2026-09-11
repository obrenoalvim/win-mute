function Get-BloatwareTweaks {
    $apps = @(
        @{ Id = 'APP01'; Pkg = 'Microsoft.BingWeather'; Name = 'Weather (Bing)' }
        @{ Id = 'APP02'; Pkg = 'Microsoft.BingNews'; Name = 'News (Bing / MSN)' }
        @{ Id = 'APP03'; Pkg = 'Microsoft.GetHelp'; Name = 'Get Help' }
        @{ Id = 'APP04'; Pkg = 'Microsoft.Getstarted'; Name = 'Tips' }
        @{ Id = 'APP05'; Pkg = 'Microsoft.MicrosoftOfficeHub'; Name = 'Office Hub (ads-driven)' }
        @{ Id = 'APP06'; Pkg = 'Microsoft.MicrosoftSolitaireCollection'; Name = 'Solitaire Collection' }
        @{ Id = 'APP07'; Pkg = 'Microsoft.WindowsFeedbackHub'; Name = 'Feedback Hub' }
        @{ Id = 'APP08'; Pkg = 'Microsoft.MixedReality.Portal'; Name = 'Mixed Reality Portal' }
        @{ Id = 'APP09'; Pkg = 'Microsoft.People'; Name = 'People' }
        @{ Id = 'APP10'; Pkg = 'Microsoft.SkypeApp'; Name = 'Skype' }
        @{ Id = 'APP11'; Pkg = 'Microsoft.Xbox.TCUI'; Name = 'Xbox TCUI' }
        @{ Id = 'APP12'; Pkg = 'Microsoft.XboxApp'; Name = 'Xbox Console Companion' }
        @{ Id = 'APP13'; Pkg = 'Microsoft.XboxGameOverlay'; Name = 'Xbox Game Bar Overlay' }
        @{ Id = 'APP14'; Pkg = 'Microsoft.XboxGamingOverlay'; Name = 'Xbox Gaming Overlay' }
        @{ Id = 'APP15'; Pkg = 'Microsoft.XboxIdentityProvider'; Name = 'Xbox Identity Provider' }
        @{ Id = 'APP16'; Pkg = 'Microsoft.YourPhone'; Name = 'Phone Link' }
        @{ Id = 'APP17'; Pkg = 'Microsoft.ZuneMusic'; Name = 'Media Player (Groove)' }
        @{ Id = 'APP18'; Pkg = 'Microsoft.ZuneVideo'; Name = 'Movies & TV' }
        @{ Id = 'APP19'; Pkg = 'MicrosoftTeams'; Name = 'Teams (consumer, inbox)' }
        @{ Id = 'APP20'; Pkg = 'Microsoft.549981C3F5F10'; Name = 'Cortana app' }
        @{ Id = 'APP21'; Pkg = 'Clipchamp.Clipchamp'; Name = 'Clipchamp' }
        @{ Id = 'APP22'; Pkg = 'Microsoft.PowerAutomateDesktop'; Name = 'Power Automate Desktop' }
        @{ Id = 'APP23'; Pkg = 'Microsoft.Todos'; Name = 'Microsoft To Do' }
        @{ Id = 'APP24'; Pkg = 'Microsoft.BingSearch'; Name = 'Bing Search app' }
        @{ Id = 'APP25'; Pkg = 'Microsoft.OutlookForWindows'; Name = 'Outlook (new, inbox)' }
    )

    $apps | ForEach-Object {
        $pkg = $_.Pkg
        [PSCustomObject]@{
            Id = $_.Id; Category = 'Bloatware'; Risk = 'Moderate'
            Name = "Remove $($_.Name)"
            Description = "Uninstalls the $($_.Name) app ($pkg) for all users and de-provisions it for new accounts."
            Apply = { Remove-Bloat $pkg }.GetNewClosure()
            Revert = { Write-Host "  Reinstall '$pkg' manually from the Microsoft Store if needed." -ForegroundColor Yellow }.GetNewClosure()
            Test = { -not (Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue) }.GetNewClosure()
        }
    }
}
