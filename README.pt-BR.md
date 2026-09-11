# win-mute

![License: MIT](https://img.shields.io/badge/license-MIT-3DDC97) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1-5391FE) ![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6)

[English](README.md) | Português

Kit PowerShell que desliga IA do Windows (Copilot, Recall, Cortana), telemetria,
servicos/tarefas desnecessarias e programas de fabrica em **Windows 10 ou 11**.
Mesma categoria do O&O ShutUp10++, Sophia Script ou WPD, so que aberto: da pra
ler o script inteiro do inicio ao fim antes de rodar, em vez de confiar num
binario fechado.

Duas portas de entrada:

- **GUI** (`Start-WinMuteGui.ps1`, ou clique duplo em `START-GUI.bat`).
  Janela com botao unico "Aplicar agora", lista detalhada opcional, pede
  elevacao de admin sozinha (prompt de UAC), troca entre PT-BR e EN num
  clique. Pra quem nao manja de PowerShell.
- **CLI** (`Invoke-WinMute.ps1`). Flags pra rodar sem prompt, ou um
  seletor `Out-GridView` se rodar sem argumento nenhum. Pra quem ja usa
  terminal no dia a dia.

As duas usam as mesmas definicoes em `modules/` e detectam **Windows 10 ou 11
sozinhas** (pelo numero de build). Ajustes que so existem numa das duas
versoes (Copilot, Recall, Click To Do, o menu de clique direito classico,
Widgets, o botao do Copilot na barra de tarefas, Suggested Actions do
clipboard) somem automaticamente na outra. Nada pra escolher na mao.

## Como funciona

Cada ajuste e um objeto PowerShell simples com blocos `Apply`, `Revert` e
`Test`, mexendo exatamente nos mesmos pontos que essas ferramentas mexem:
chaves de registro de Group Policy em `HKLM:\SOFTWARE\Policies\Microsoft\...`,
tipo de inicializacao de servico, tarefas agendadas e remocao de pacote Appx.
Nada de caixa preta: abra `modules/*.ps1` e leia exatamente o que cada um faz
antes de rodar.

72 ajustes em 6 categorias (64 valem no Windows 10, 70 no Windows 11, filtro
automatico):

| Categoria | O que cobre |
|---|---|
| `AI` | Copilot, Recall, Click To Do, Cortana, busca do Bing, IA generativa, Destaques de busca, Suggested Actions do clipboard, sugestao do Bing na busca |
| `Telemetry` | Nivel de dado de diagnostico, DiagTrack/dmwappushservice, ID de publicidade, historico de atividades, CEIP, relatorio de erro |
| `Services` | Retail Demo, Maps broker, Fax, indexacao da busca, Remote Registry, servicos do Xbox |
| `ScheduledTasks` | CEIP, Application Experience, prompt de feedback, telemetria do autochk, fila do WER |
| `Bloatware` | 25 apps de fabrica (apps do Xbox, Bing Weather/News, Solitaire, Skype, Teams consumer, etc) |
| `Privacy` | Anuncio no Iniciar/tela de bloqueio, secao "Recomendados", menu de clique direito classico, icone de Chat na taskbar, icone de Pessoas (Win10), Widgets, nag do OneDrive, instalacao automatica de app patrocinado, localizacao, apps em segundo plano, sync de clipboard na nuvem, gravacao do Game Bar, nag de upgrade pro Win11 (Win10), atalho do Edge voltando |

Adicionado depois de duas rodadas de pesquisa sobre o que usuario realmente
reclama do Windows (Reddit e imprensa tech, 2025-2026):

- **Revolta contra o Windows 11**: menu de clique direito capado, anuncio no
  Menu Iniciar, feed "Recomendados" forcado, icone de Chat na taskbar, app
  patrocinado se instalando sozinho. Virou `PRIV07` a `PRIV11` e `AI08`/`AI09`.
- **Dor especifica do Windows 10** (pos fim de suporte, out/2025): nag
  insistente de upgrade pro Windows 11 em quem fica no 10 pra usar ESU, Bing
  sequestrando a caixa de busca da taskbar, icone de Pessoas que ninguem
  pediu, e o Edge recriando atalho na area de trabalho toda hora. Virou
  `PRIV12` a `PRIV14` e `AI10`.

Uma coisa que **nao** mexemos de proposito: reinicio forcado e atualizacao
automatica do Windows. Desligar isso troca um incomodo de interface por PC
sem patch de seguranca, e essa troca nao vale a pena nem no `-All`.

## Uso

### GUI (usuario nao tecnico)

Clique duplo em `START-GUI.bat` (ou rode `Start-WinMuteGui.ps1`). Ela
pede elevacao sozinha (prompt de UAC) se voce nao abriu como admin. Mostra a
versao do Windows detectada no topo, um botao grande "Aplicar agora" com os
ajustes seguros recomendados, e uma secao "Personalizar ajustes" (fechada por
padrao) com a lista completa agrupada por categoria, cor por risco
(verde/laranja/vermelho) e um botao no canto pra trocar entre PT e EN.

### CLI (usuario avancado)

Rode o PowerShell **como Administrador**.

```powershell
# Lista interativa (Out-GridView), escolhe o que quiser e clica OK
.\Invoke-WinMute.ps1

# Aplica tudo de uma ou mais categorias, sem prompt
.\Invoke-WinMute.ps1 -Categories AI,Telemetry -All

# Aplica so o que nao tem nenhum efeito colateral
.\Invoke-WinMute.ps1 -All -SafeOnly

# Aplica ajustes especificos por id
.\Invoke-WinMute.ps1 -Ids AI01,AI02,TEL02

# Mostra o que ja esta aplicado ou nao, ajuste por ajuste
.\Invoke-WinMute.ps1 -Report

# Reverte tudo que essa ferramenta ja aplicou
.\Invoke-WinMute.ps1 -Undo

# Pula o ponto de restauracao automatico (mais rapido, menos seguro)
.\Invoke-WinMute.ps1 -All -SkipRestorePoint
```

Por padrao a ferramenta cria um ponto de restauracao antes de qualquer
mudanca (a nao ser que voce passe `-SkipRestorePoint`). Os ids aplicados
ficam registrados em `logs/applied.json`, pra `-Undo` saber o que desfazer.
E um log de *quais* ajustes rodaram, nao um diff completo do registro: o
`Revert` de cada ajuste usa um valor fixo de "volta pro padrao do Windows",
o mesmo jeito que Sophia Script e ferramentas parecidas fazem.

## Voce vai perder alguma coisa?

Reconferi cada um dos 72 ajustes pensando nisso. Nenhum apaga ou toca em
arquivo pessoal: eles mexem em valor de registro, tipo de inicializacao de
servico, estado de tarefa agendada, ou desinstalam um app da Store (o que
remove so a configuracao/cache daquele app, nunca seus Documentos, fotos ou
qualquer coisa fora do app). O ponto de restauracao criado antes de rodar e
uma rede de seguranca a mais: se algo parecer errado, o proprio System
Restore do Windows volta a maquina inteira pro estado anterior.

- **Seguro**: nenhum efeito colateral pra um uso normal de desktop.
- **Moderado**: desliga algo que voce pode realmente usar (indexacao da
  busca, Maps, servicos do Xbox, Family Safety, atualizacao em segundo plano
  de notificacao de email/chat).
- **Agressivo**: recurso legado ou caso de borda (Fax).

Remocao de `Bloatware` e desinstalacao de verdade: reverter so mostra um
lembrete pra reinstalar pela Microsoft Store, porque o Windows nao guarda
copia local de um app de fabrica removido.

## Perguntas frequentes

**Como desligo o Windows Recall?**
Rode a GUI ou `.\Invoke-WinMute.ps1 -Ids AI02`. Ele ativa a politica `DisableAIDataAnalysis`, o Recall para de tirar e guardar foto da tela. So Windows 11, some sozinho no Windows 10.

**Como desligo o Copilot no Windows 11?**
`.\Invoke-WinMute.ps1 -Ids AI01,AI06` desliga a politica do Copilot e esconde o botao da taskbar. Os dois so existem no Windows 11.

**Como paro a telemetria do Windows 10 ou 11?**
`.\Invoke-WinMute.ps1 -Categories Telemetry -All` cobre nivel de dado de diagnostico, servico DiagTrack, CEIP e relatorio de erro de uma vez. Nota: no Windows Home/Pro a Microsoft nao deixa a telemetria chegar em zero de verdade, so Enterprise/Education consegue, isso aplica o nivel mais baixo que qualquer edicao aceita.

**Tem alternativa open source pro O&O ShutUp10++, Sophia Script ou WPD?**
E exatamente isso que o win-mute e: mesma categoria de ferramenta, mesmas alavancas de registro/servico/tarefa, mas um script que da pra ler do inicio ao fim em vez de um binario fechado. Ver [Como funciona](#como-funciona).

**Como removo programa de fabrica tipo Xbox, Solitaire ou os apps do Bing?**
`.\Invoke-WinMute.ps1 -Categories Bloatware -All` desinstala os 25 apps de fabrica rastreados. Cada um e uma desinstalacao de verdade da Store, ver [Voce vai perder alguma coisa?](#voce-vai-perder-alguma-coisa) antes de rodar.

**Funciona no Windows 10 e no Windows 11?**
Sim, detectado sozinho pelo numero de build. 64 dos 72 ajustes valem no Windows 10, 70 no Windows 11, sem escolher versao.

## Adicionando um ajuste

Cria um `[PSCustomObject]` novo com `Id`, `Category`, `Risk`, `Name`,
`Description`, `Apply`, `Revert`, `Test` no arquivo certo dentro de
`modules/`. O `Invoke-WinMute.ps1` pega automatico, sem passo de
cadastro. Pra aparecer traduzido na GUI, adiciona o mesmo `Id` no dicionario
`$S.pt.tweaks` e `$S.en.tweaks` dentro de `Start-WinMuteGui.ps1`.
