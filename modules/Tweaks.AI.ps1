function Get-AITweaks {
    @(
        [PSCustomObject]@{
            Id = 'AI01'; Category = 'AI'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Windows Copilot'
            Description = 'Removes the Copilot icon/entry point and blocks it via policy.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI02'; Category = 'AI'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Recall (snapshots)'
            Description = 'Blocks Windows Recall from taking and storing screen snapshots.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI03'; Category = 'AI'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Click To Do'
            Description = 'Disables the AI Click To Do overlay feature.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI04'; Category = 'AI'; Risk = 'Safe'
            Name = 'Disable Cortana'
            Description = 'Turns off Cortana assistant and its background access.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0 }
        }
        [PSCustomObject]@{
            Id = 'AI05'; Category = 'AI'; Risk = 'Safe'
            Name = 'Disable Bing/web results in Windows Search'
            Description = 'Stops Windows Search from sending queries to Bing.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI06'; Category = 'AI'; Risk = 'Moderate'; OS = 'Win11'
            Name = 'Disable Copilot key remap prompt / taskbar Copilot button'
            Description = 'Hides the Copilot button from the taskbar.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 1 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0 }
        }
        [PSCustomObject]@{
            Id = 'AI07'; Category = 'AI'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Generative Fill/AI in Paint & Photos'
            Description = 'Blocks cloud-based generative AI features in inbox apps.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableGenerativeFill' 1 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableGenerativeFill' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableGenerativeFill' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI08'; Category = 'AI'; Risk = 'Safe'
            Name = 'Disable Search Highlights'
            Description = 'Stops Windows Search from injecting web/trending-content cards into the Start search box.'
            Apply = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'EnableDynamicContentInWSB' 0 }
            Revert = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'EnableDynamicContentInWSB' }
            Test = { Test-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'EnableDynamicContentInWSB' 0 }
        }
        [PSCustomObject]@{
            Id = 'AI09'; Category = 'AI'; Risk = 'Safe'; OS = 'Win11'
            Name = 'Disable Suggested Actions on clipboard copy'
            Description = 'Stops the AI popup offering to open Maps/Calendar when you copy a date, phone number, or address.'
            Apply = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard' 'Disabled' 1 }
            Revert = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard' 'Disabled' 0 }
            Test = { Test-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard' 'Disabled' 1 }
        }
        [PSCustomObject]@{
            Id = 'AI10'; Category = 'AI'; Risk = 'Safe'
            Name = 'Disable Bing suggestions in the search box'
            Description = 'Stops the taskbar/Start search box from mixing in Bing web suggestions with local results.'
            Apply = { Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 }
            Revert = { Remove-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' }
            Test = { Test-RegValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 }
        }
    )
}
