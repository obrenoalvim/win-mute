# TODO IMPROVEMENTS

> Last updated: 2026-09-12

## Pending Changes

### GUI freezes while applying a batch of tweaks
- **Category:** Bug / UI-UX
- **Source:** Read-through of `Start-WinMuteGui.ps1` `Invoke-Tweaks` and the button click handlers.
- **What:** `Apply`/`Undo` run synchronously on the WPF UI thread. Applying a large batch (say `-All`, 70 tweaks, several of them service/scheduled-task operations that block for a moment each) freezes the window. Windows will likely show "Not Responding" during that stretch, even though the process is fine.
- **Where:** `Start-WinMuteGui.ps1`, the `Invoke-Tweaks` function (~line 285) and its two callers (`BtnHeroApply.Add_Click`, `BtnApply.Add_Click`).
- **Why:** A frozen window during a real operation reads as a crash to a non-technical user, exactly who this GUI is for.
- **Risk:** Needs a judgment call on approach (`Dispatcher.Invoke` with a background runspace vs. a `BackgroundWorker` vs. simple `$window.Dispatcher.DoEvents()`-style pumping between tweaks). Also needs the Apply/Undo buttons disabled for the duration to prevent a double-click re-entering `Invoke-Tweaks` mid-run.
- **Effort:** Medium.

### No `-WhatIf` / dry-run mode
- **Category:** Feature
- **Source:** PowerShell convention (`SupportsShouldProcess`/`-WhatIf`) is the idiomatic way scripts like this let people preview impact before running; came up while reading `Invoke-WinMute.ps1`'s param block.
- **What:** Add `[CmdletBinding(SupportsShouldProcess)]` and wrap each `& $tweak.Apply` call in `if ($PSCmdlet.ShouldProcess($tweak.Name, 'Apply'))`, so `-WhatIf` lists exactly what would run without touching the system.
- **Where:** `Invoke-WinMute.ps1`, the apply loop (~line 129). Optional: a parallel dry-run toggle in the GUI.
- **Why:** Standard, expected PowerShell idiom for a script that mutates system state; also gives cautious users a safe first look beyond just reading the code.
- **Risk:** Low technically, but changes the CLI's parameter surface (adds `-WhatIf`/`-Confirm` as implicit common params) — flagging as a product decision rather than applying silently.
- **Effort:** Low-Medium.

### No search/filter in the GUI's advanced tweak list
- **Category:** UI-UX
- **Source:** Read-through of the "Customize" panel in `Start-WinMuteGui.ps1` — 72 tweaks across 6 category expanders, no way to jump straight to one by name.
- **What:** A text box above the tweak list that filters visible rows (and auto-expands matching categories) as you type.
- **Where:** `Start-WinMuteGui.ps1`, XAML for the Customize section + `Build-TweaksPanel`.
- **Why:** Finding one specific tweak (say "Recall") currently means opening the AI category and scanning 10 rows; fine at this scale, would matter more if the tweak count keeps growing.
- **Risk:** None to existing behavior, but it's a new UI element and interaction, not a one-line fix.
- **Effort:** Low-Medium.

### Service/task/Appx helpers still have no test coverage
- **Category:** Test
- **Source:** `tests/Helpers.Tests.ps1` (added this cycle) now covers `Set-Reg`, `Remove-Reg`, and `Test-RegValue` against a disposable `HKCU:\Software\WinMuteTests\...` key. `Disable-Svc`, `Enable-Svc`, `Disable-Task`, `Enable-Task`, `Remove-Bloat` are still untested.
- **What:** These touch real services, scheduled tasks, and Appx packages, so they can't reuse the same "disposable registry key" trick safely. Needs a thin mockable wrapper (e.g. injecting `Get-Service`/`Get-ScheduledTask`/`Get-AppxPackage` as parameters, or a Pester mock) before they can be tested without real system side effects, or `-WhatIf`-style dry runs once the dry-run feature below exists.
- **Where:** `tests/Helpers.Tests.ps1` or a new file alongside it.
- **Why:** These are the functions every single Service/ScheduledTasks/Bloatware tweak calls; a regression here breaks everything silently.
- **Risk:** Needs a decision on how much to mock vs. accept real (harmless) system-state changes in CI; not a one-line addition.
- **Effort:** Medium.

### Undo silently drops the applied-tweak log entry for a revert that failed
- **Category:** Bug
- **Source:** Read-through of the `-Undo` path in `Invoke-WinMute.ps1` and `BtnUndo.Add_Click` in `Start-WinMuteGui.ps1`.
- **What:** Both loop over `logs/applied.json`, call `& $tweak.Revert` inside a try/catch that only warns/logs on failure, then unconditionally delete the whole log file once the loop finishes. If a `Revert` throws, that tweak was never actually rolled back, but its entry disappears from the log anyway — a later `-Undo` or `-Report` run has no record that it's still applied.
- **Where:** `Invoke-WinMute.ps1` (~line 86-99, the `$Undo` block); `Start-WinMuteGui.ps1` (~line 521-535, `BtnUndo.Add_Click`).
- **Why:** Defeats the one piece of state (`logs/applied.json`) this tool relies on to make Undo trustworthy — and only surfaces in exactly the case (a failing revert) where an accurate log matters most.
- **Risk:** Needs a decision on the right behavior (keep failed entries in the log vs. write them to a separate "needs manual revert" list) — not a one-line fix.
- **Effort:** Low-Medium.
