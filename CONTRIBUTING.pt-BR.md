# Como contribuir

Leia antes de abrir uma issue ou um PR, isso evita ida e volta desnecessária.

English: [CONTRIBUTING.md](CONTRIBUTING.md)

## Abrindo uma issue

Procure nas issues existentes antes de criar uma nova. Se não achar nada, abra com contexto suficiente pra alguém agir: o que aconteceu, o que você esperava, como reproduzir (bug) ou por que precisa existir (feature).

## Pegando uma issue

Comente pedindo pra ser designado antes de começar a trabalhar. Espere a confirmação. Só uma issue aberta por vez, termine ou solte antes de pegar outra.

## Enviando um PR

- Referencie a issue que fecha (`closes #123`)
- Nunca dê force-push na branch do PR, isso quebra o re-review. Suba commits novos, eles são squashados no merge.
- Rode `Invoke-Pester tests/` antes de abrir o PR. O Pester já vem com o Windows PowerShell 5.1, não precisa instalar nada.

## Reviews

Seja direto, não duro. Use comentários inline pra sugestões específicas. Se o feedback já foi dado, não repita, um joinha já confirma.
