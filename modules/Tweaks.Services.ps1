function Get-ServiceTweaks {
    @(
        [PSCustomObject]@{
            Id = 'SVC01'; Category = 'Services'; Risk = 'Moderate'
            Name = 'Disable Retail Demo service'
            Description = 'Used only for in-store demo mode; unused on personal PCs.'
            Apply = { Disable-Svc 'RetailDemo' }
            Revert = { Enable-Svc 'RetailDemo' 'Manual' }
            Test = { (Get-Service RetailDemo -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC02'; Category = 'Services'; Risk = 'Moderate'
            Name = 'Disable Maps download/update service'
            Description = 'Disables background download of offline map data.'
            Apply = { Disable-Svc 'MapsBroker' }
            Revert = { Enable-Svc 'MapsBroker' 'Automatic' }
            Test = { (Get-Service MapsBroker -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC03'; Category = 'Services'; Risk = 'Aggressive'
            Name = 'Disable Fax service'
            Description = 'Legacy fax support, unused on almost all modern PCs.'
            Apply = { Disable-Svc 'Fax' }
            Revert = { Enable-Svc 'Fax' 'Manual' }
            Test = { (Get-Service Fax -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC04'; Category = 'Services'; Risk = 'Moderate'
            Name = 'Disable Windows Search indexing (WSearch)'
            Description = 'Frees CPU/disk on low-end machines; Start menu search becomes slower.'
            Apply = { Disable-Svc 'WSearch' }
            Revert = { Enable-Svc 'WSearch' 'Automatic' }
            Test = { (Get-Service WSearch -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC05'; Category = 'Services'; Risk = 'Safe'
            Name = 'Disable Remote Registry service'
            Description = 'Allows remote editing of the registry; disabled by default good practice.'
            Apply = { Disable-Svc 'RemoteRegistry' }
            Revert = { Enable-Svc 'RemoteRegistry' 'Manual' }
            Test = { (Get-Service RemoteRegistry -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC06'; Category = 'Services'; Risk = 'Moderate'
            Name = 'Disable Xbox services (XblAuthManager, XblGameSave, XboxGipSvc, XboxNetApiSvc)'
            Description = 'Disables Xbox-related background services if you do not game with Xbox integration.'
            Apply = { 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc' | ForEach-Object { Disable-Svc $_ } }
            Revert = { 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc' | ForEach-Object { Enable-Svc $_ 'Manual' } }
            Test = { (Get-Service XblAuthManager -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'SVC07'; Category = 'Services'; Risk = 'Safe'
            Name = 'Disable diagnostic policy telemetry helper (diagsvc/WdiSystemHost telemetry hooks)'
            Description = 'Disables Diagnostic Execution Service used for auto-collecting problem reports.'
            Apply = { Disable-Svc 'diagsvc' }
            Revert = { Enable-Svc 'diagsvc' 'Manual' }
            Test = { (Get-Service diagsvc -ErrorAction SilentlyContinue).StartType -eq 'Disabled' }
        }
    )
}
