# classic-ppgsi

Modelo de dissertação/tese para o **PPgSI–EACH–USP** (Programa de Pós-Graduação em Sistemas de Informação, Universidade de São Paulo) em [Typst](https://typst.app) — um porte 1:1 da classe LaTeX `abntex2ppgsi`, em conformidade com a ABNT NBR 14724 e os ajustes específicos do programa. O texto gerado é em português; os **nomes dos parâmetros da API são em inglês**.

![Página de capa do modelo](thumbnail.png)

## Sumário

- [Instalação](#instalação)
- [Logotipo da USP](#logotipo-da-usp)
- [Configuração do documento](#configuração-do-documento)
- [Parâmetros do `thesis`](#parâmetros-do-thesis)
- [Corpo do texto](#corpo-do-texto)
- [Ilustrações](#ilustrações)
- [Citações longas](#citações-longas)
- [Citações e referências](#citações-e-referências)
- [Siglas e símbolos](#siglas-e-símbolos)
- [Pacotes integrados](#pacotes-integrados)
- [Apêndices e anexos](#apêndices-e-anexos)
- [Desenvolvimento](#desenvolvimento)
- [Licença](#licença)

## Instalação

```sh
typst init @preview/classic-ppgsi
```

Isso cria um projeto a partir de `template/main.typ`, já com o `referencias.bib` e os `assets/` de exemplo. Depois compile:

```sh
typst compile main.typ
```

O `template/main.typ` é, ao mesmo tempo, o esqueleto inicial e uma demonstração que exercita **todos** os recursos — vale usá-lo como referência viva.

## Logotipo da USP

O pacote **não** distribui o logotipo da USP — ele é marca registrada da Universidade e não cabe a nós redistribuí-lo. Por padrão, o parâmetro `logo` mostra um *placeholder* que você deve substituir. Baixe o logotipo e aponte para o seu arquivo:

- Portal oficial de identidade visual da USP: <https://scs.usp.br/identidadevisual/>
- SVG vetorial no Wikimedia Commons (domínio público no Brasil): <https://commons.wikimedia.org/wiki/File:Webysther_20160310_-_Logo_USP.svg>

```typ
#show: ppgsi.thesis.with(
  logo: image("assets/usp.svg"),
  // …
)
```

Como membro da comunidade USP, você pode usar o logotipo no seu próprio trabalho; o pacote apenas não pode embarcá-lo.

## Configuração do documento

Toda a formatação vem de uma única `show`-rule, `thesis`, que emite a pré-textualização na ordem da ABNT (capa → folha de rosto → ficha → errata → folha de aprovação → dedicatória → agradecimentos → epígrafe → resumo (pt) → abstract (en) → listas de ilustrações → siglas → símbolos → sumário) antes de entregar o controle ao seu texto. Cada seção só aparece se o parâmetro correspondente for preenchido.

```typ
#import "@preview/classic-ppgsi:0.1.0" as ppgsi

#show: ppgsi.thesis.with(
  title: "Título do trabalho: subtítulo do trabalho",
  title-en: "Work title: work subtitle",
  // partículas (de, da, dos) vão em `given` p/ a referência invertida sair "TAL, Fulano de"
  author: (given: "Fulano de", surname: "Tal"),
  advisor: [Orientador: Prof. Dr. Fulano de Tal],
  co-advisor: [Coorientador: Prof. Dr. Fulano de Tal],
  bibliography: read("referencias.bib"),
  // a ficha catalográfica é específica de cada trabalho — forneça a sua
  catalog-card: image("assets/ficha-1.png", width: 100%, height: 100%, fit: "contain"),
  preamble: [
    Dissertação apresentada ao Programa de Pós-Graduação em Sistemas de
    Informação da Escola de Artes, Ciências e Humanidades da Universidade de
    São Paulo para obtenção do título de Mestre em Ciências.
  ],
  abstract: (
    pt-br: (body: [Resumo…], keywords: ("palavra1", "palavra2")),
    en-us: (body: [Abstract…], keywords: ("keyword1", "keyword2")),
  ),
)

= Introdução
O corpo do texto começa aqui.
```

Na compilação, os elementos obrigatórios da ABNT (título, autor, orientador, resumo pt+en, bibliografia) são validados; desligue com `validate: false`.

## Parâmetros do `thesis`

**Identificação (obrigatórios)**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `title` | `str` | Título; se contiver `:`, a parte após os dois-pontos vira subtítulo. |
| `author` | `(given, surname)` | Nome do autor. Partículas ("de", "da") vão em `given`. |
| `advisor` | conteúdo | Linha do orientador. |
| `bibliography` | `read("*.bib")` | Conteúdo do arquivo `.bib`. |
| `abstract` | dicionário | Resumo/abstract (ver abaixo). |

**Autor e instituição**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `title-en` | `none` | Título em inglês (habilita o *Abstract*). |
| `institution` | USP/EACH/PPgSI | Bloco da capa/folha de rosto. |
| `location` | `"São Paulo"` | Cidade. |
| `date` | `"2015"` | Ano de depósito. |
| `defense-year` | `none` | Ano de defesa (cai para `date` se ausente). |
| `degree` / `degree-en` | Dissertação (Mestrado…) | Grau, usado na referência da própria obra. |
| `institution-ref` / `institution-ref-en` | EACH/USP | Instituição na referência da própria obra. |

**Pré-textuais opcionais** (cada um gera sua página quando `!= none`)

`preamble`, `co-advisor`, `catalog-card`, `errata`, `approval-text`, `committee`, `dedication`, `acknowledgments`, `epigraph`.

**Listas, siglas e símbolos**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `acronyms` | `none` | Siglas (ver [Siglas e símbolos](#siglas-e-símbolos)). |
| `symbols` | `none` | Símbolos. |
| `list-figures`, `list-tables`, `list-frames`, `list-algorithms`, `list-code` | `true` | Ligam/desligam cada lista de ilustrações. |

**Outros**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `logo` | *placeholder* | Logotipo da capa (ver [Logotipo da USP](#logotipo-da-usp)). |
| `self-source` | `auto` | Fonte usada por `source: auto` nas ilustrações. |
| `validate` | `true` | Valida os elementos obrigatórios da ABNT na compilação. |

O `abstract` é um dicionário por idioma. Cada idioma aceita `body`, `keywords` e, opcionalmente, `citation` — a referência ABNT da própria obra impressa no topo do resumo (`auto` a gera de autor/título/ano/nº de folhas/grau/instituição; passe conteúdo para sobrescrever, ou `none` para omitir):

```typ
abstract: (
  pt-br: (body: [Resumo…], keywords: ("k1", "k2"), citation: auto),
  en-us: (body: [Abstract…], keywords: ("k1", "k2")),
)
```

## Corpo do texto

O corpo usa os títulos nativos do Typst — `=` (capítulo), `==` (seção), `===` (subseção). A numeração, os cabeçalhos "Capítulo N. Título" e o sumário são montados automaticamente; a paginação começa no texto, não na capa.

## Ilustrações

`figure`, `table`, `frame` (quadro), `algorithm` e `code` seguem o padrão ABNT: legenda em cima, linha de fonte embaixo. A fonte (`source:`) tem três formas:

- `ppgsi.myself` → "Fonte – \<autor\>, \<ano\>" (autor/ano da `thesis`);
- `ppgsi.prose("chave")` → cita outro trabalho como fonte;
- `none` → sem linha de fonte.

```typ
// Figura: qualquer conteúdo (imagem, gráfico lilaq, desenho cetz…)
#ppgsi.figure(
  image("assets/figura.png", width: 8cm),
  caption: [Exemplo de figura],
  source: ppgsi.myself,
)

// Tabela: sem bordas verticais, com filetes ABNT (topo/base + separador de cabeçalho)
#ppgsi.table(
  caption: [Exemplo de tabela],
  source: ppgsi.myself,
  columns: (1in, 1in, 1in),
  header: ([Cabeçalho 1], [Cabeçalho 2], [Cabeçalho 3]),
  [a], [b], [c],
)

// Quadro (frame): mesma API da tabela, mas com todas as bordas
#ppgsi.frame(caption: [Exemplo de quadro], columns: (1in, 1in), header: ([A], [B]), [1], [2])

// Algoritmo: réguas acima/abaixo, linhas numeradas automaticamente
#ppgsi.algorithm(
  caption: [Exemplo de algoritmo],
  source: ppgsi.myself,
  [para cada item da lista],
  [  processe o item],
)

// Código: listagem estilizada pelo codly (números de linha etc.)
#ppgsi.code(caption: [Exemplo de código], ```py print("olá")```)
```

## Citações longas

Citação direta com mais de três linhas: recuo de 4 cm, corpo 10, sem aspas. `citation` é opcional ao final.

```typ
#ppgsi.quote(citation: ppgsi.prose("teste3"))[
  Texto da citação longa, recuado conforme a ABNT.
]
```

## Citações e referências

Motor de citação autor–data próprio (réplica do `abntex2-alf`), com backref ("Citado nas páginas…") e desambiguação a/b/c compartilhada entre as formas. As chaves vêm do `.bib` passado em `bibliography`.

- `#ppgsi.cite("chave1", "chave2")` — citação **no fim** da frase (entre parênteses);
- `#ppgsi.prose("chave")` — citação **narrativa**, no meio da frase;
- `#ppgsi.references()` — a lista de referências ordenada, ao fim do texto.

```typ
Tal coisa é melhor que a outra #ppgsi.cite("teste1", "teste2").

De acordo com #ppgsi.prose("teste3"), tal coisa é melhor que a outra.
```

> Nunca use `cite` para uma citação que faz parte da frase — para isso é `prose`. A resolução de a/b/c e das páginas do backref exige a compilação de múltiplos passes do Typst (automática).

## Siglas e símbolos

**Siglas** (`acronyms`): um dicionário `chave → (short, long)`. No texto, referencie com `@chave`; na primeira menção sai por extenso, nas seguintes só a sigla. A "Lista de abreviaturas e siglas" é gerada automaticamente.

```typ
acronyms: (
  "svm": (short: "SVM", long: "máquina de vetores de suporte"),
  "api": (short: "API", long: "interface de programação de aplicações"),
)
```
```typ
A @svm é uma técnica supervisionada; a @svm também serve para regressão.
```

**Símbolos** (`symbols`): uma lista de pares `(símbolo, descrição)`.

```typ
symbols: (
  ([$Gamma$], [Letra grega Gama]),
  ([$in$], [Pertence]),
)
```

## Pacotes integrados

Já vêm montados dentro do `thesis` (não funcionam fora dele):

- **[glossy](https://typst.app/universe/package/glossy)** — siglas (`@chave`), habilitado quando `acronyms != none`.
- **[codly](https://typst.app/universe/package/codly)** — realce de código, dentro de `ppgsi.code`.
- **[cheq](https://typst.app/universe/package/cheq)** — checklists com `- [ ]`, `- [x]`, `- [/]`.
- **[lilaq](https://typst.app/universe/package/lilaq)** — gráficos de dados, re-exportado como `ppgsi.lq`, para usar dentro de `ppgsi.figure`.
- **[cetz](https://typst.app/universe/package/cetz)** — desenhos/diagramas, re-exportado como `ppgsi.cetz`, idem.

## Apêndices e anexos

Solte o marcador `#ppgsi.appendix` (ou `#ppgsi.annex`) e, a partir dele, escreva o capítulo e as seções com títulos nativos (`=`, `==`, `===`). Cada capítulo ganha uma letra independente (Apêndice A, B, …); as seções internas são numeradas automaticamente ("1", "1.1") e ficam fora do sumário.

```typ
#ppgsi.appendix
= Primeiro apêndice
Conteúdo…

#ppgsi.annex
= Primeiro anexo
Conteúdo…
```

## Desenvolvimento

`build.sh` registra este repositório no cache local de pacotes do Typst (`@preview/classic-ppgsi`), compila `template/main.typ` e gera `build/main.pdf`, os PNGs por página e o `thumbnail.png`. Requer `typst` e `pdftoppm` (poppler) no `PATH`. Não há suíte de testes: a verificação é "compila e as páginas saem certas".

## Licença

[MIT](LICENSE).
