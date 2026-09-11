# win-mute

![License: MIT](https://img.shields.io/badge/license-MIT-3DDC97) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1-5391FE) ![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6)

English | [Português](README.pt-BR.md)

PowerShell toolkit that turns off Windows AI (Copilot, Recall, Cortana),
telemetry, unneeded services/scheduled tasks, and bloatware on **Windows 10
or 11**. Same category of tool as O&O ShutUp10++, Sophia Script, or WPD, but
as a small script you can read start to finish instead of a closed-source
binary.

Two ways in:

- **GUI** (`Start-WinMuteGui.ps1`, or double-click `START-GUI.bat`). One
  big "Apply now" button, an optional detailed list, self-elevates to admin,
  switches between PT-BR and EN with one click. For people who don't want to
  touch PowerShell.
- **CLI** (`Invoke-WinMute.ps1`). Flags for no-prompt runs, or an
  `Out-GridView` picker if you run it with no arguments. For people already
  comfortable in a terminal.

Both share the same `modules/` tweak definitions and detect **Windows 10 vs
11 on their own** (by build number). Tweaks that only exist on one of them
(Copilot, Recall, Click To Do, the classic right-click menu fix, Widgets, the
taskbar Copilot button, clipboard Suggested Actions) disappear automatically
on the other. Nothing to pick by hand.

## How it works

Each tweak is a plain PowerShell object with `Apply`, `Revert`, and `Test`
script blocks, touching the same levers those tools use: Group Policy
registry keys under `HKLM:\SOFTWARE\Policies\Microsoft\...`, service startup
types, scheduled tasks, and Appx package removal. No black box: open
`modules/*.ps1` and read exactly what each one does before running it.

72 tweaks across 6 categories (64 apply on Windows 10, 70 on Windows 11,
auto-filtered):

| Category | What it covers |
|---|---|
| `AI` | Copilot, Recall, Click To Do, Cortana, Bing web search, generative fill, Search Highlights, clipboard Suggested Actions, Bing search-box suggestions |
| `Telemetry` | Diagnostic data level, DiagTrack/dmwappushservice, advertising ID, activity history, CEIP, error reporting |
| `Services` | Retail Demo, Maps broker, Fax, Windows Search indexing, Remote Registry, Xbox services |
| `ScheduledTasks` | CEIP, Application Experience, feedback prompts, autochk telemetry, WER queue |
| `Bloatware` | 25 inbox Appx apps (Xbox apps, Bing Weather/News, Solitaire, Skype, Teams consumer, etc.) |
| `Privacy` | Start/lock screen ads, Start "Recommended" section, classic right-click menu, taskbar Chat icon, People icon (Win10), Widgets board, OneDrive nags, sponsored app auto-install, location, background apps, clipboard cloud sync, Game DVR background recording, Windows 11 upgrade nag (Win10), recurring Edge desktop shortcut |

Added after two rounds of "what do people actually complain about" research
(Reddit and tech-press roundups, 2025-2026):

- **Windows 11 backlash**: the gutted right-click menu, Start menu ad badges,
  forced Recommended feed, taskbar Chat icon, silently auto-installed
  sponsored Store apps. Became `PRIV07` through `PRIV11` and `AI08`/`AI09`.
- **Windows 10-specific pain** (post end-of-support, Oct 2025): the recurring
  "Upgrade to Windows 11" nag on machines staying on 10 for ESU, Bing
  hijacking the taskbar search box, the People icon nobody asked for, and
  Edge re-planting its desktop shortcut after every update. Became `PRIV12`
  through `PRIV14` and `AI10`.

One thing deliberately left alone: forced Windows Update and auto-restart
behavior. Turning that off trades a UX annoyance for unpatched security
holes, and that trade isn't worth making even under `-All`.

## Usage

### GUI (non-technical users)

Double-click `START-GUI.bat` (or run `Start-WinMuteGui.ps1`). It asks
for elevation itself (a UAC prompt) if you didn't launch it as admin. It
shows the detected Windows version at the top, one big "Apply now" button
for the recommended safe tweaks, and a "Customize" section (collapsed by
default) with the full list grouped by category, colored by risk
(green/orange/red), plus a corner button to switch between PT and EN.

### CLI (experienced users)

Run PowerShell **as Administrator**.

```powershell
# Interactive checklist (Out-GridView), pick what you want, click OK
.\Invoke-WinMute.ps1

# Apply everything in one or more categories, no prompts
.\Invoke-WinMute.ps1 -Categories AI,Telemetry -All

# Apply only the tweaks with no functional downside
.\Invoke-WinMute.ps1 -All -SafeOnly

# Apply specific tweaks by id
.\Invoke-WinMute.ps1 -Ids AI01,AI02,TEL02

# Check what's currently applied vs not, per tweak
.\Invoke-WinMute.ps1 -Report

# Revert everything this tool has applied
.\Invoke-WinMute.ps1 -Undo

# Skip the automatic System Restore point (faster, less safe)
.\Invoke-WinMute.ps1 -All -SkipRestorePoint
```

A System Restore point is created by default before any change, unless you
pass `-SkipRestorePoint`. Applied tweak IDs get logged to
`logs/applied.json`, so `-Undo` knows what to roll back. That log tracks
*which* tweaks ran, not a full registry diff: each tweak's `Revert` uses a
hardcoded "back to Windows default" value, the same approach Sophia Script
and similar tools take.

## Will you lose anything?

Every tweak was re-checked for this. None of the 72 delete or touch personal
files: they flip registry values, service startup types, and scheduled task
states, or uninstall a Store app (which removes that app's own local
settings/cache, never your Documents, photos, or anything outside the app
itself). The restore point created before any run is a full safety net on
top of that: if something feels off, Windows' own System Restore rolls the
whole machine back.

- **Safe**: no functional downside for typical desktop use.
- **Moderate**: turns off something you might actually use (Windows Search
  indexing, Maps, Xbox services, Family Safety, background app refresh for
  mail/chat notifications).
- **Aggressive**: legacy or edge-case features (Fax).

`Bloatware` removals are real uninstalls: reverting just prints a reminder to
reinstall from the Microsoft Store, since Windows keeps no local copy of a
removed inbox app.

## FAQ

**How do I disable Windows Recall?**
Run the GUI or `.\Invoke-WinMute.ps1 -Ids AI02`. It sets the `DisableAIDataAnalysis` policy so Recall never takes or stores screen snapshots. Windows 11 only, filtered out automatically on Windows 10.

**How do I turn off Copilot on Windows 11?**
`.\Invoke-WinMute.ps1 -Ids AI01,AI06` disables the Copilot policy and hides the taskbar button. Both are Windows 11 only.

**How do I stop Windows 10 or 11 telemetry?**
`.\Invoke-WinMute.ps1 -Categories Telemetry -All` covers diagnostic data level, the DiagTrack service, CEIP, and error reporting in one pass. Note: on Home/Pro editions Microsoft doesn't allow telemetry to reach true zero, only Enterprise/Education can; this sets the strictest level either SKU accepts.

**Is there an open-source alternative to O&O ShutUp10++, Sophia Script, or WPD?**
That's what win-mute is: same category of tool, same registry/service/task levers, but a script you can read end to end instead of a closed binary. See [How it works](#how-it-works).

**How do I remove Windows bloatware apps like Xbox, Solitaire, or the Bing apps?**
`.\Invoke-WinMute.ps1 -Categories Bloatware -All` uninstalls all 25 tracked inbox apps. Each is a real Store uninstall, see [Will you lose anything?](#will-you-lose-anything) before running it.

**Does this work on both Windows 10 and Windows 11?**
Yes, auto-detected by build number. 64 of the 72 tweaks apply on Windows 10, 70 on Windows 11, no version to pick.

## Adding a tweak

Add a new `[PSCustomObject]` with `Id`, `Category`, `Risk`, `Name`,
`Description`, `Apply`, `Revert`, `Test` to the matching file in `modules/`.
`Invoke-WinMute.ps1` picks it up automatically, no registration step.
To show a translated label in the GUI, add the same `Id` to both
`$S.pt.tweaks` and `$S.en.tweaks` in `Start-WinMuteGui.ps1`.
