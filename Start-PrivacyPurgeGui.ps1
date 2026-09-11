<#
.SYNOPSIS
    Friendly point-and-click window for win-privacy-purge. Double-click START-GUI.bat
    if you don't want to deal with PowerShell directly.
.NOTES
    Design: dark, calm "utility" look (Fluent-inspired, not a copy) with a single
    teal accent, toggle switches instead of raw checkboxes, and progressive
    disclosure - one big recommended action up front, the full checklist tucked
    behind "Personalizar/Customize" for people who want it. All strings are
    bilingual (English default, PT-BR toggle) - see $S below. CLI stays technical/English.
#>
[CmdletBinding()]
param()

# Re-launch elevated if not already admin - most people double-clicking this aren't.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    return
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$root = $PSScriptRoot
Get-ChildItem (Join-Path $root 'modules') -Filter '*.ps1' | ForEach-Object { . $_.FullName }
$logPath = Join-Path $root 'logs\applied.json'

function Get-AllTweaks {
    Get-AITweaks
    Get-TelemetryTweaks
    Get-ServiceTweaks
    Get-ScheduledTaskTweaks
    Get-BloatwareTweaks
    Get-PrivacyTweaks
}

function Get-AppliedLog {
    if (Test-Path $logPath) { @(Get-Content $logPath -Raw | ConvertFrom-Json) } else { @() }
}

function Save-AppliedLog($entries) {
    $entries | ConvertTo-Json -Depth 3 | Set-Content -Path $logPath -Encoding UTF8
}

$currentOS = Get-WindowsMajor
$buildNumber = (Get-CimInstance Win32_OperatingSystem).BuildNumber
$tweaks = Get-CompatibleTweaks -Tweaks (Get-AllTweaks) -CurrentOS $currentOS
$safeTweaks = $tweaks | Where-Object { $_.Risk -eq 'Safe' }
$osLabel = if ($currentOS -eq 'Win11') { 'Windows 11' } else { 'Windows 10' }

$riskColor = @{ Safe = '#3DDC97'; Moderate = '#F5A623'; Aggressive = '#F25C54' }
$categoryIcon = @{
    AI = [char]::ConvertFromUtf32(0x1F916); Telemetry = [char]::ConvertFromUtf32(0x1F4E1)
    Services = [char]::ConvertFromUtf32(0x2699); ScheduledTasks = [char]::ConvertFromUtf32(0x1F5D3)
    Bloatware = [char]::ConvertFromUtf32(0x1F9F9); Privacy = [char]::ConvertFromUtf32(0x1F512)
}

# All GUI-visible strings, PT-BR and EN. The CLI (Invoke-PrivacyPurge.ps1) stays
# technical/English on purpose - this dictionary only feeds the friendly GUI.
$S = @{
    pt = @{
        tagline = 'Desliga IA, coleta de dados e programas de fabrica do Windows, num clique.'
        hero_title = 'Protecao recomendada'
        hero_subtitle = '{0} ajustes sem efeito colateral, prontos pra {1}.'
        hero_button = 'Aplicar agora'
        advanced_label = 'Personalizar ajustes'
        btn_safe = 'Marcar seguros'; btn_all = 'Marcar tudo'; btn_clear = 'Limpar'
        btn_apply = 'Aplicar marcados'; btn_undo = 'Reverter tudo'
        remove_prefix = 'Remover '
        risk = @{ Safe = 'Seguro'; Moderate = 'Moderado'; Aggressive = 'Agressivo' }
        category = @{
            AI = 'Inteligencia Artificial'; Telemetry = 'Telemetria'; Services = 'Servicos'
            ScheduledTasks = 'Tarefas agendadas'; Bloatware = 'Programas de fabrica'; Privacy = 'Privacidade'
        }
        log = @{
            creating_restore = 'Criando ponto de restauracao...'
            restore_created = 'Ponto de restauracao criado.'
            restore_failed = 'Nao foi possivel criar o ponto de restauracao ({0})'
            applying = 'Aplicando {0} - {1}'
            apply_failed = '  Falhou: {0}'
            apply_done = 'Concluido. {0} ajuste(s) aplicado(s).'
            reverting = 'Revertendo {0} - {1}'
            revert_done = 'Reversao concluida.'
            nothing_selected = 'Nada selecionado.'
            nothing_to_undo = 'Nada para reverter.'
        }
        tweaks = @{
            AI01 = 'Copilot (assistente de IA)'; AI02 = 'Recall (fotos automaticas da tela)'
            AI03 = 'Click To Do (IA sobre a tela)'; AI04 = 'Cortana'
            AI05 = 'Resultado do Bing na busca do Iniciar'; AI06 = 'Botao do Copilot na barra de tarefas'
            AI07 = 'IA generativa no Paint e no Fotos'; AI08 = 'Destaques de busca (noticias na caixa de busca)'
            AI09 = 'Sugestao de IA ao copiar texto'; AI10 = 'Sugestao do Bing na caixa de busca'
            TEL01 = 'Nivel de dados de diagnostico (minimo)'; TEL02 = 'Servico de telemetria (DiagTrack)'
            TEL03 = 'Servico de notificacao WAP'; TEL04 = 'ID de publicidade'
            TEL05 = 'Historico de atividades (Timeline)'; TEL06 = 'Sugestao personalizada com seus dados'
            TEL07 = 'Pesquisa de feedback e coleta CEIP'; TEL08 = 'Envio de relatorio de erro do Windows'
            TEL09 = 'Coleta do que voce digita e escreve a mao'; TEL10 = 'Apps verem diagnostico de outros apps'
            SVC01 = 'Modo demonstracao de loja'; SVC02 = 'Download automatico de mapas offline'
            SVC03 = 'Servico de fax'; SVC04 = 'Indexacao da busca do Windows'
            SVC05 = 'Acesso remoto ao registro'; SVC06 = 'Servicos do Xbox'
            SVC07 = 'Servico de diagnostico automatico'
            TASK01 = 'Tarefa do programa de melhoria (CEIP)'; TASK02 = 'Tarefa de compatibilidade de apps'
            TASK03 = 'Notificacao pedindo avaliacao do Windows'; TASK04 = 'Telemetria da verificacao de disco'
            TASK05 = 'Fila de envio de relatorio de erro'; TASK06 = 'Monitoramento do Family Safety'
            PRIV01 = 'Anuncio no Iniciar e na tela de bloqueio'; PRIV02 = 'Painel de Widgets'
            PRIV03 = 'OneDrive abrindo sozinho e pedindo backup'; PRIV04 = 'Rastreamento de localizacao'
            PRIV05 = 'Apps rodando em segundo plano'; PRIV06 = 'Area de transferencia na nuvem'
            PRIV07 = 'Menu de clique direito classico'; PRIV08 = 'Secao "Recomendados" no Iniciar'
            PRIV09 = 'Icone de Chat/Teams na barra de tarefas'; PRIV10 = 'Instalacao automatica de app patrocinado'
            PRIV11 = 'Gravacao em segundo plano do Game Bar'; PRIV12 = 'Aviso insistente pra atualizar pro Windows 11'
            PRIV13 = 'Icone de Pessoas na barra de tarefas'; PRIV14 = 'Atalho do Edge voltando na area de trabalho'
        }
    }
    en = @{
        tagline = 'Turns off Windows AI, data collection, and factory bloatware, in one click.'
        hero_title = 'Recommended protection'
        hero_subtitle = '{0} tweaks with no downside, ready for {1}.'
        hero_button = 'Apply now'
        advanced_label = 'Customize'
        btn_safe = 'Check safe ones'; btn_all = 'Check all'; btn_clear = 'Clear'
        btn_apply = 'Apply checked'; btn_undo = 'Undo everything'
        remove_prefix = 'Remove '
        risk = @{ Safe = 'Safe'; Moderate = 'Moderate'; Aggressive = 'Aggressive' }
        category = @{
            AI = 'AI Features'; Telemetry = 'Telemetry'; Services = 'Services'
            ScheduledTasks = 'Scheduled Tasks'; Bloatware = 'Bloatware'; Privacy = 'Privacy'
        }
        log = @{
            creating_restore = 'Creating restore point...'
            restore_created = 'Restore point created.'
            restore_failed = 'Could not create a restore point ({0})'
            applying = 'Applying {0} - {1}'
            apply_failed = '  Failed: {0}'
            apply_done = 'Done. {0} tweak(s) applied.'
            reverting = 'Reverting {0} - {1}'
            revert_done = 'Undo complete.'
            nothing_selected = 'Nothing selected.'
            nothing_to_undo = 'Nothing to undo.'
        }
        tweaks = @{
            AI01 = 'Copilot (AI assistant)'; AI02 = 'Recall (automatic screen snapshots)'
            AI03 = 'Click To Do (AI screen overlay)'; AI04 = 'Cortana'
            AI05 = 'Bing results in Start search'; AI06 = 'Copilot button on the taskbar'
            AI07 = 'Generative AI in Paint and Photos'; AI08 = 'Search Highlights (news in the search box)'
            AI09 = 'AI suggestions when copying text'; AI10 = 'Bing suggestions in the search box'
            TEL01 = 'Diagnostic data level (minimum)'; TEL02 = 'Telemetry service (DiagTrack)'
            TEL03 = 'WAP push notification service'; TEL04 = 'Advertising ID'
            TEL05 = 'Activity history (Timeline)'; TEL06 = 'Tailored tips based on your data'
            TEL07 = 'Feedback surveys and CEIP collection'; TEL08 = 'Windows error report submission'
            TEL09 = 'Typing and handwriting data collection'; TEL10 = "Apps reading other apps' diagnostics"
            SVC01 = 'Retail demo mode'; SVC02 = 'Automatic offline map downloads'
            SVC03 = 'Fax service'; SVC04 = 'Windows Search indexing'
            SVC05 = 'Remote registry access'; SVC06 = 'Xbox services'
            SVC07 = 'Automatic diagnostics service'
            TASK01 = 'Customer Experience Improvement tasks'; TASK02 = 'App compatibility tracking tasks'
            TASK03 = '"Rate Windows" notification tasks'; TASK04 = 'Disk-check telemetry task'
            TASK05 = 'Error report queue task'; TASK06 = 'Family Safety monitoring task'
            PRIV01 = 'Ads in Start menu and lock screen'; PRIV02 = 'Widgets board'
            PRIV03 = 'OneDrive auto-launch and backup nags'; PRIV04 = 'Location tracking'
            PRIV05 = 'Apps running in the background'; PRIV06 = 'Cloud clipboard sync'
            PRIV07 = 'Classic right-click menu'; PRIV08 = '"Recommended" section in Start'
            PRIV09 = 'Chat/Teams icon on the taskbar'; PRIV10 = 'Automatic sponsored app installs'
            PRIV11 = 'Game Bar background recording'; PRIV12 = 'Persistent "upgrade to Windows 11" nag'
            PRIV13 = 'People icon on the taskbar'; PRIV14 = 'Edge desktop shortcut coming back'
        }
    }
}

function Get-FriendlyName($lang, $t) {
    $strings = $S[$lang]
    if ($strings.tweaks.ContainsKey($t.Id)) { return $strings.tweaks[$t.Id] }
    if ($t.Name -like 'Remove *') { return $strings.remove_prefix + $t.Name.Substring(7) }
    return $t.Name
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Win Privacy Purge" Height="780" Width="960" MinWidth="760" MinHeight="560"
        WindowStartupLocation="CenterScreen" Background="#14161A"
        FontFamily="Segoe UI Variable Text, Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="Accent" Color="#3DDC97"/>
        <SolidColorBrush x:Key="AccentDim" Color="#2B9E6E"/>
        <SolidColorBrush x:Key="Card" Color="#1D2025"/>
        <SolidColorBrush x:Key="CardAlt" Color="#22262C"/>
        <SolidColorBrush x:Key="TextMuted" Color="#9AA1AC"/>
        <SolidColorBrush x:Key="Danger" Color="#F25C54"/>

        <Style x:Key="TitleText" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI Variable Display, Segoe UI Semibold"/>
            <Setter Property="FontSize" Value="26"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
        <Style x:Key="SectionHeader" TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI Variable Display, Segoe UI Semibold"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="White"/>
        </Style>
        <Style x:Key="MutedText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
        </Style>

        <!-- Pill button base: rounded, flat, subtle hover -->
        <Style x:Key="PillButtonBase" TargetType="Button">
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bg" CornerRadius="8" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"
                                               Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bg" Property="Opacity" Value="0.85"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Bg" Property="Opacity" Value="0.65"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="GhostButton" TargetType="Button" BasedOn="{StaticResource PillButtonBase}">
            <Setter Property="Background" Value="#2A2E35"/>
            <Setter Property="Foreground" Value="#D6D9DE"/>
        </Style>
        <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource PillButtonBase}">
            <Setter Property="Background" Value="{StaticResource Accent}"/>
            <Setter Property="Foreground" Value="#0A1410"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>
        <Style x:Key="DangerButton" TargetType="Button" BasedOn="{StaticResource PillButtonBase}">
            <Setter Property="Background" Value="#2A2020"/>
            <Setter Property="Foreground" Value="{StaticResource Danger}"/>
        </Style>
        <Style x:Key="LangButton" TargetType="Button" BasedOn="{StaticResource PillButtonBase}">
            <Setter Property="Background" Value="#22262C"/>
            <Setter Property="Foreground" Value="{StaticResource Accent}"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
        </Style>

        <!-- Toggle switch skinned CheckBox -->
        <Style x:Key="ToggleSwitch" TargetType="CheckBox">
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Padding" Value="10,0,0,0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <StackPanel Orientation="Horizontal">
                            <Border x:Name="Track" Width="38" Height="20" CornerRadius="10" Background="#3A3F47">
                                <Ellipse x:Name="Thumb" Width="14" Height="14" Fill="#DDDDDD" HorizontalAlignment="Left" Margin="3,0,0,0"/>
                            </Border>
                            <ContentPresenter Margin="{TemplateBinding Padding}" VerticalAlignment="Center"/>
                        </StackPanel>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="Track" Property="Background" Value="{StaticResource Accent}"/>
                                <Setter TargetName="Thumb" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="Thumb" Property="Margin" Value="0,0,3,0"/>
                                <Setter TargetName="Thumb" Property="Fill" Value="#0A1410"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="CategoryExpander" TargetType="Expander">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
            <Setter Property="Background" Value="{StaticResource Card}"/>
            <Setter Property="Padding" Value="4"/>
        </Style>
    </Window.Resources>

    <Grid Margin="22">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="110"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Margin="0,0,0,16">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" Orientation="Horizontal">
                    <TextBlock Text="&#128737;" FontSize="26" Foreground="{StaticResource Accent}" Margin="0,0,10,0" VerticalAlignment="Center"/>
                    <TextBlock Text="Win Privacy Purge" Style="{StaticResource TitleText}" VerticalAlignment="Center"/>
                    <Border Background="#22262C" CornerRadius="12" Padding="10,4" Margin="12,0,0,0" VerticalAlignment="Center">
                        <TextBlock Name="OsBadge" Text="" FontSize="11.5" Foreground="{StaticResource Accent}"/>
                    </Border>
                </StackPanel>
                <Button Name="BtnLang" Grid.Column="1" Content="PT" Style="{StaticResource LangButton}" VerticalAlignment="Center"/>
            </Grid>
            <TextBlock Name="Tagline" Style="{StaticResource MutedText}" Margin="0,6,0,0"/>
        </StackPanel>

        <!-- Hero recommended action -->
        <Border Grid.Row="1" Background="{StaticResource Card}" CornerRadius="14" Padding="20" Margin="0,0,0,16">
            <Border.Effect>
                <DropShadowEffect Color="Black" BlurRadius="24" ShadowDepth="6" Opacity="0.35"/>
            </Border.Effect>
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Name="HeroTitle" Style="{StaticResource SectionHeader}" FontSize="17"/>
                    <TextBlock Name="HeroSubtitle" Style="{StaticResource MutedText}" Margin="0,4,0,0"/>
                </StackPanel>
                <Button Name="BtnHeroApply" Grid.Column="1" Style="{StaticResource PrimaryButton}"
                        Padding="22,12" FontSize="14" VerticalAlignment="Center"/>
            </Grid>
        </Border>

        <!-- Personalizar / Customize (advanced, collapsed by default) -->
        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto">
            <StackPanel>
                <Expander Name="CustomizeExpander" Foreground="White" IsExpanded="False" Margin="0,0,0,10">
                    <Expander.Header>
                        <TextBlock Name="AdvancedLabel" Style="{StaticResource SectionHeader}"/>
                    </Expander.Header>
                    <StackPanel Margin="0,12,0,0">
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                            <Button Name="BtnSafe" Style="{StaticResource GhostButton}" Margin="0,0,8,0"/>
                            <Button Name="BtnAll" Style="{StaticResource GhostButton}" Margin="0,0,8,0"/>
                            <Button Name="BtnNone" Style="{StaticResource GhostButton}" Margin="0,0,16,0"/>
                            <Button Name="BtnApply" Style="{StaticResource PrimaryButton}" Margin="0,0,8,0"/>
                            <Button Name="BtnUndo" Style="{StaticResource DangerButton}"/>
                        </StackPanel>
                        <StackPanel Name="TweaksPanel"/>
                    </StackPanel>
                </Expander>
            </StackPanel>
        </ScrollViewer>

        <!-- Log -->
        <Border Grid.Row="3" Background="#101214" CornerRadius="10" Margin="0,14,0,0" Padding="2">
            <TextBox Name="LogBox" Background="Transparent" Foreground="#9AA1AC" FontFamily="Cascadia Mono, Consolas"
                      FontSize="11.5" BorderThickness="0" Padding="10"
                      IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$osBadge = $window.FindName('OsBadge')
$tagline = $window.FindName('Tagline')
$heroTitle = $window.FindName('HeroTitle')
$heroSubtitle = $window.FindName('HeroSubtitle')
$btnHeroApply = $window.FindName('BtnHeroApply')
$advancedLabel = $window.FindName('AdvancedLabel')
$btnSafe = $window.FindName('BtnSafe')
$btnAll = $window.FindName('BtnAll')
$btnNone = $window.FindName('BtnNone')
$btnApply = $window.FindName('BtnApply')
$btnUndo = $window.FindName('BtnUndo')
$btnLang = $window.FindName('BtnLang')
$panel = $window.FindName('TweaksPanel')
$logBox = $window.FindName('LogBox')
$toggleStyle = $window.Resources['ToggleSwitch']

$script:lang = 'en'
$script:checkboxes = @()

function Write-Log($msg) {
    $logBox.AppendText("$msg`r`n")
    $logBox.ScrollToEnd()
}

function Build-TweaksPanel {
    $checkedIds = @($script:checkboxes | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag.Id })
    $panel.Children.Clear()
    $script:checkboxes = @()
    $strings = $S[$script:lang]

    foreach ($group in $tweaks | Group-Object Category) {
        $label = if ($strings.category.ContainsKey($group.Name)) { $strings.category[$group.Name] } else { $group.Name }
        $icon = if ($categoryIcon.ContainsKey($group.Name)) { $categoryIcon[$group.Name] } else { '' }

        $expander = New-Object System.Windows.Controls.Expander
        $expander.Style = $window.Resources['CategoryExpander']
        $header = New-Object System.Windows.Controls.TextBlock
        $header.Text = "$icon  $label  -  $($group.Count)"
        $header.FontSize = 13
        $expander.Header = $header

        $stack = New-Object System.Windows.Controls.StackPanel
        $stack.Margin = '24,8,4,10'

        foreach ($t in $group.Group) {
            $row = New-Object System.Windows.Controls.StackPanel
            $row.Orientation = 'Horizontal'
            $row.Margin = '0,5,0,5'

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Style = $toggleStyle
            $cb.Tag = $t
            $cb.VerticalAlignment = 'Center'
            $cb.ToolTip = $t.Description
            $cb.IsChecked = ($t.Id -in $checkedIds)

            $label2 = New-Object System.Windows.Controls.TextBlock
            $riskTxt = if ($strings.risk.ContainsKey($t.Risk)) { $strings.risk[$t.Risk] } else { $t.Risk }
            $label2.Text = Get-FriendlyName $script:lang $t
            $label2.Foreground = 'White'
            $label2.FontSize = 12.5
            $label2.VerticalAlignment = 'Center'
            $label2.Margin = '10,0,8,0'
            $label2.ToolTip = $t.Description

            $badge = New-Object System.Windows.Controls.Border
            $badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFrom('#22262C')
            $badge.CornerRadius = 8
            $badge.Padding = '8,2'
            $badgeText = New-Object System.Windows.Controls.TextBlock
            $badgeText.Text = $riskTxt
            $badgeText.FontSize = 10.5
            $badgeText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFrom($riskColor[$t.Risk])
            $badge.Child = $badgeText

            [void]$row.Children.Add($cb)
            [void]$row.Children.Add($label2)
            [void]$row.Children.Add($badge)
            [void]$stack.Children.Add($row)
            $script:checkboxes += $cb
        }

        $expander.Content = $stack
        [void]$panel.Children.Add($expander)
    }
}

function Set-Language($newLang) {
    $script:lang = $newLang
    $strings = $S[$newLang]
    $btnLang.Content = if ($newLang -eq 'pt') { 'EN' } else { 'PT' }
    $tagline.Text = $strings.tagline
    $heroTitle.Text = $strings.hero_title
    $heroSubtitle.Text = $strings.hero_subtitle -f $safeTweaks.Count, $osLabel
    $btnHeroApply.Content = $strings.hero_button
    $advancedLabel.Text = $strings.advanced_label
    $btnSafe.Content = $strings.btn_safe
    $btnAll.Content = $strings.btn_all
    $btnNone.Content = $strings.btn_clear
    $btnApply.Content = $strings.btn_apply
    $btnUndo.Content = $strings.btn_undo
    Build-TweaksPanel
}

function Invoke-Tweaks($selected) {
    $strings = $S[$script:lang]
    if (-not $selected -or @($selected).Count -eq 0) { Write-Log $strings.log.nothing_selected; return }

    Write-Log $strings.log.creating_restore
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description 'win-privacy-purge before changes' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Write-Log $strings.log.restore_created
    }
    catch { Write-Log ($strings.log.restore_failed -f $_) }

    $log = Get-AppliedLog
    $logIds = @($log | ForEach-Object { $_.Id })

    foreach ($t in $selected) {
        Write-Log ($strings.log.applying -f $t.Id, (Get-FriendlyName $script:lang $t))
        try {
            & $t.Apply
            if ($t.Id -notin $logIds) { $log += [PSCustomObject]@{ Id = $t.Id; Name = $t.Name; AppliedAt = (Get-Date).ToString('s') } }
        }
        catch { Write-Log ($strings.log.apply_failed -f $_) }
    }
    Save-AppliedLog $log
    Write-Log ($strings.log.apply_done -f @($selected).Count)
}

$osBadge.Text = "$osLabel * build $buildNumber"
Set-Language 'en'

$btnLang.Add_Click({ Set-Language $(if ($script:lang -eq 'pt') { 'en' } else { 'pt' }) })
$btnSafe.Add_Click({ $script:checkboxes | ForEach-Object { $_.IsChecked = ($_.Tag.Risk -eq 'Safe') } })
$btnAll.Add_Click({ $script:checkboxes | ForEach-Object { $_.IsChecked = $true } })
$btnNone.Add_Click({ $script:checkboxes | ForEach-Object { $_.IsChecked = $false } })

$btnHeroApply.Add_Click({
    $script:checkboxes | Where-Object { $_.Tag.Risk -eq 'Safe' } | ForEach-Object { $_.IsChecked = $true }
    Invoke-Tweaks $safeTweaks
})

$btnApply.Add_Click({
    $selected = $script:checkboxes | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }
    Invoke-Tweaks $selected
})

$btnUndo.Add_Click({
    $strings = $S[$script:lang]
    $log = Get-AppliedLog
    if (-not $log -or $log.Count -eq 0) { Write-Log $strings.log.nothing_to_undo; return }
    $byId = @{}
    $tweaks | ForEach-Object { $byId[$_.Id] = $_ }
    foreach ($entry in $log) {
        $t = $byId[$entry.Id]
        if (-not $t) { continue }
        Write-Log ($strings.log.reverting -f $t.Id, (Get-FriendlyName $script:lang $t))
        try { & $t.Revert } catch { Write-Log ($strings.log.apply_failed -f $_) }
    }
    Remove-Item $logPath -ErrorAction SilentlyContinue
    Write-Log $strings.log.revert_done
})

[void]$window.ShowDialog()
