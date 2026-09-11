function Get-ScheduledTaskTweaks {
    @(
        [PSCustomObject]@{
            Id = 'TASK01'; Category = 'ScheduledTasks'; Risk = 'Safe'
            Name = 'Disable Customer Experience Improvement Program tasks'
            Description = 'Stops the Consolidator/UsbCeip tasks that compile usage telemetry.'
            Apply = {
                Disable-Task '\Microsoft\Windows\Customer Experience Improvement Program\' 'Consolidator'
                Disable-Task '\Microsoft\Windows\Customer Experience Improvement Program\' 'UsbCeip'
            }
            Revert = {
                Enable-Task '\Microsoft\Windows\Customer Experience Improvement Program\' 'Consolidator'
                Enable-Task '\Microsoft\Windows\Customer Experience Improvement Program\' 'UsbCeip'
            }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -TaskName 'Consolidator' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TASK02'; Category = 'ScheduledTasks'; Risk = 'Safe'
            Name = 'Disable Application Experience telemetry tasks'
            Description = 'Stops Microsoft Compatibility Appraiser and PcaPatchDbTask from scanning app usage.'
            Apply = {
                Disable-Task '\Microsoft\Windows\Application Experience\' 'Microsoft Compatibility Appraiser'
                Disable-Task '\Microsoft\Windows\Application Experience\' 'PcaPatchDbTask'
                Disable-Task '\Microsoft\Windows\Application Experience\' 'ProgramDataUpdater'
            }
            Revert = {
                Enable-Task '\Microsoft\Windows\Application Experience\' 'Microsoft Compatibility Appraiser'
                Enable-Task '\Microsoft\Windows\Application Experience\' 'PcaPatchDbTask'
                Enable-Task '\Microsoft\Windows\Application Experience\' 'ProgramDataUpdater'
            }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Application Experience\' -TaskName 'Microsoft Compatibility Appraiser' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TASK03'; Category = 'ScheduledTasks'; Risk = 'Safe'
            Name = 'Disable Feedback notification tasks'
            Description = 'Stops periodic "Rate this device" style feedback prompts.'
            Apply = { Disable-Task '\Microsoft\Windows\Feedback\Siuf\' 'DmClient'; Disable-Task '\Microsoft\Windows\Feedback\Siuf\' 'DmClientOnScenarioDownload' }
            Revert = { Enable-Task '\Microsoft\Windows\Feedback\Siuf\' 'DmClient'; Enable-Task '\Microsoft\Windows\Feedback\Siuf\' 'DmClientOnScenarioDownload' }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Feedback\Siuf\' -TaskName 'DmClient' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TASK04'; Category = 'ScheduledTasks'; Risk = 'Safe'
            Name = 'Disable Autochk proxy telemetry task'
            Description = 'Disables disk-check telemetry reporting task.'
            Apply = { Disable-Task '\Microsoft\Windows\Autochk\' 'Proxy' }
            Revert = { Enable-Task '\Microsoft\Windows\Autochk\' 'Proxy' }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Autochk\' -TaskName 'Proxy' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TASK05'; Category = 'ScheduledTasks'; Risk = 'Safe'
            Name = 'Disable Windows Error Reporting queued tasks'
            Description = 'Stops queued error report uploads on top of disabling the WerSvc service.'
            Apply = { Disable-Task '\Microsoft\Windows\Windows Error Reporting\' 'QueueReporting' }
            Revert = { Enable-Task '\Microsoft\Windows\Windows Error Reporting\' 'QueueReporting' }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Error Reporting\' -TaskName 'QueueReporting' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
        [PSCustomObject]@{
            Id = 'TASK06'; Category = 'ScheduledTasks'; Risk = 'Moderate'
            Name = 'Disable Family Safety monitoring task'
            Description = 'Disables Family Safety usage upload if not using parental controls.'
            Apply = { Disable-Task '\Microsoft\Windows\Shell\' 'FamilySafetyMonitor' }
            Revert = { Enable-Task '\Microsoft\Windows\Shell\' 'FamilySafetyMonitor' }
            Test = { (Get-ScheduledTask -TaskPath '\Microsoft\Windows\Shell\' -TaskName 'FamilySafetyMonitor' -ErrorAction SilentlyContinue).State -eq 'Disabled' }
        }
    )
}
