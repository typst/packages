# Obelisk Estudos

Obelisk Estudos is a Portuguese-language adaptation of the Obelisk template, extended with reusable notes and personal-reflection tools for subjects beyond STEM, including law, public administration, and the humanities. It is aimed at Portuguese-speaking students, especially those preparing for public exams.

Caderno de estudos em português baseado no Obelisk/Obelisk Lite. Além de manter recursos úteis para matérias de exatas, esta adaptação acrescenta ambientes reutilizáveis para disciplinas não exatas — como Direito e Administração Pública — e reflexão pessoal. O público-alvo são estudantes falantes de português, especialmente quem se prepara para concursos. Organize capítulos e subtópicos com grade tipográfica, notas laterais e capa geométrica.

## Usar como modelo

No Typst Web App, selecione **Start from template** e procure `obelisk-estudos` depois que a submissão for aprovada e publicada. No Typst CLI, crie um projeto com:

```sh
typst init @preview/obelisk-estudos:0.1.0 meus-estudos
```

O projeto criado inclui `main.typ`, com capa, sumário e um exemplo de anotações para concurso. Edite os títulos, textos e respostas para adaptar o documento à sua prova.

## Usar os componentes em outro documento

Importe a versão completa do pacote no seu arquivo Typst:

```typst
#import "@preview/obelisk-estudos:0.1.0": *
#show: init.with(theme: "flexoki-light")

#capa(
  titulo: [Caderno de Estudos],
  subtitulo: [Preparação para o concurso],
  concurso: [Tribunal de Contas do Estado],
  orgao: [TCE],
  autor: [Seu nome],
  ano: [2026],
)

#outline()

= Direito Administrativo
== Atos administrativos

#conceito[Motivo][Pressuposto de fato e de direito que fundamenta a prática do ato.]

#reflexao(
  entendi: [Escreva a ideia principal com suas próprias palavras.],
  duvidas: [Anote o que ainda ficou confuso.],
  conexoes: [Relacione o assunto a outras matérias ou exemplos.],
  proxima-revisao: [Defina uma próxima ação de estudo.],
)
```

## Componentes

`init` configura o layout. `capa` cria uma página de abertura com título, subtítulo, concurso, órgão, estudante e ano. `blank-page`, `sidenote` e `v-step` oferecem recursos de layout. `reflexao` destaca quatro registros pós-estudo: `entendi`, `duvidas`, `conexoes` e `proxima-revisao`. Cada resposta é conteúdo Typst escrito entre colchetes; não são campos de formulário interativos no PDF.

Para anotações gerais, use `conceito`, `norma`, `jurisprudencia`, `questao`, `caso_pratico` e `dica`. Cada ambiente aceita `[conteúdo]` ou `[título][conteúdo]`. Para matérias quantitativas, continuam disponíveis `theorem`, `proposition`, `corollary`, `lemma`, `definition`, `example`, `remark` e `proof`, além dos nomes em português `teorema`, `proposicao`, `corolario`, `lema`, `definicao`, `exemplo`, `observacao` e `prova`.

O argumento `theme` de `init.with(...)` aceita as paletas `default`, `monochrome`, `flexoki-light`, `flexoki-dark`, `solarized-light`, `github-light`, `one-light`, `everforest-light`, `catppuccin-latte`, `rose-pine-dawn`, `rose-pine-moon` e `rose-pine`. Outras opções de página, margens, fontes e grade estão definidas em `settings.typ` e podem ser passadas a `init.with(...)`.

## Origem e licença

Esta é uma adaptação em português do projeto Obelisk/Obelisk Lite, de atzlt. O código-base é identificado como MIT no [Typst Universe](https://typst.app/universe/package/obelisk/) e no manifesto do [repositório de origem](https://github.com/atzlt/obelisk-lite). Este pacote mantém os avisos de licença e atribuição. A adaptação não é uma publicação oficial do autor original.
