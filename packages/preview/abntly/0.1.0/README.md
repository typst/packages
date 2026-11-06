# abntly

<p align="center">
  <strong>Português</strong> · <a href="https://github.com/lucaslrodri/abntly/blob/v0.1.0/README.en.md">English</a>
</p>

<p align="center">
  <a href="https://typst.app/universe/package/abntly"><img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flucaslrodri%2Fabntly%2Fmain%2Ftypst.toml&amp;query=%24.package.version&amp;label=Typst%20Universe&amp;logo=typst&amp;color=239dad" alt="Versão no Typst Universe"></a>
  <a href="https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/manual-pt.pdf"><img src="https://img.shields.io/badge/manual-portugu%C3%AAs-orange" alt="Manual em português (PDF)"></a>
  <a href="https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/manual-en.pdf"><img src="https://img.shields.io/badge/manual-English-orange" alt="Manual em inglês (PDF)"></a>
  <a href="https://typst.app/"><img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flucaslrodri%2Fabntly%2Fmain%2Ftypst.toml&amp;query=%24.package.compiler&amp;prefix=%E2%89%A5%20&amp;label=Typst&amp;logo=typst&amp;color=239dad" alt="Versão mínima do Typst"></a>
  <a href="https://github.com/lucaslrodri/abntly/blob/v0.1.0/LICENSE"><img src="https://img.shields.io/badge/licen%C3%A7a-MIT-green" alt="Licença: MIT"></a>
</p>

<p align="center">
  <em><a href="https://typst.app/">Typst</a> template for academic works (final course works, dissertations and
  theses) that follow the standards of the Brazilian Association of Technical Standards (ABNT), especially
  ABNT NBR 14724:2024.</em>
</p>

<p align="center">
  <em>Template do <a href="https://typst.app/">Typst</a> para trabalhos acadêmicos (trabalhos de conclusão de curso,
  dissertações e teses) condizentes com as normas da Associação Brasileira de Normas Técnicas (ABNT), especialmente
  a ABNT NBR 14724:2024.</em>
</p>

## O que é o pacote

O **abntly** formata um trabalho acadêmico escrito em Typst de acordo com as normas da ABNT. A função principal,
`trabalho-academico`, é chamada uma vez no início do arquivo e aplica a formatação a todo o documento. Cada elemento
da estrutura do trabalho tem a sua função.

- **Regras gerais:** página A4 e margens, fonte, espaçamento, paginação, numeração das seções, alíneas e notas de
  rodapé.
- **Estrutura:** capa, folha de rosto, ficha catalográfica, errata, folha de aprovação, dedicatória, agradecimentos,
  epígrafe, resumos, listas, sumário, glossário, apêndices, anexos e índice.
- **Elementos do texto:** ilustrações com fonte, legenda e notas, quadros, tabelas no padrão do IBGE, equações e
  remissões.
- **Citações e referências:** sistemas autor-data e numérico, citação de citação e lista de referências, a partir
  de um arquivo `.bib`.
- **Dois idiomas:** todas as funções têm um nome em português e um em inglês (`capa` e `cover`), e o trabalho pode
  ser escrito em português ou em inglês.

O pacote trata apenas de trabalhos acadêmicos. Artigos, relatórios técnicos e projetos de pesquisa ficam fora do
escopo (veja [ABNTyp](#veja-também)).

## Uso

Para criar um trabalho novo a partir do [modelo](https://github.com/lucaslrodri/abntly/blob/v0.1.0/template/main.typ), em que cada elemento está comentado como
obrigatório ou opcional:

```sh
typst init @preview/abntly:0.1.0 meu-trabalho
```

Para usar o pacote em um arquivo que já existe, importe-o no início:

```typst
#import "@preview/abntly:0.1.0": *
```

As fontes *New Computer Modern Sans*, *Mono* e *08* precisam estar instaladas (veja [Dependências](#dependências)).

## Exemplo básico

O exemplo a seguir tem só os elementos obrigatórios da NBR 14724:2024, na ordem da norma. O arquivo
[`refs.bib`](https://github.com/lucaslrodri/abntly/blob/v0.1.0/examples/pt/refs.bib) contém as obras citadas no texto.

<!-- basic:begin (gerado de examples/pt/basico.typ por scripts/readme.sh: não edite à mão) -->
```typst
// Trabalho acadêmico mínimo: só os elementos obrigatórios da ABNT NBR 14724:2024, na ordem da norma.
#import "@preview/abntly:0.1.0": *

#show: trabalho-academico.with(
  dados: config-dados(
    titulo: [Título do trabalho],
    autor: "Nome do Autor",
    orientador: "Prof. Dr. Nome do Orientador",
    instituicao: [Universidade do Brasil],
    local: [Rio Branco],
    ano: 2026,
  ),
)

// Elementos pré-textuais
#capa()
#folha-de-rosto[
  Dissertação apresentada à Universidade do Brasil, como requisito parcial para a obtenção do título de Mestre.
]
#ficha-catalografica()
#folha-de-aprovacao(
  (titulacao: [Prof. Dr.], nome: [Nome do Orientador], instituicao: [Universidade do Brasil]),
  (titulacao: [Profa. Dra.], nome: [Nome da Convidada], instituicao: [Outra Universidade]),
)
#resumo[
  Texto do resumo, em um único parágrafo.

  #palavras-chave[primeira][segunda][terceira]
]
#resumo(idioma: "en")[
  Abstract text, in a single paragraph.

  #palavras-chave[first][second][third]
]
#outline()

// Elementos textuais
= Introdução

Texto da introdução, com uma citação @luck2010.

= Desenvolvimento

Texto do desenvolvimento.

= Conclusão

Texto da conclusão.

// Elementos pós-textuais
#bibliography("refs.bib")
```

![As 11 páginas de examples/pt/basico.typ](https://raw.githubusercontent.com/lucaslrodri/abntly/v0.1.0/docs/readme/basico.png)
<!-- basic:end -->

## Exemplo completo

- [`examples/pt/main.typ`](https://github.com/lucaslrodri/abntly/blob/v0.1.0/examples/pt/main.typ) ([PDF](https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/example-pt.pdf)): um trabalho com
  todos os elementos da estrutura e os capítulos em arquivos separados, escrito com os nomes em português.
- [`examples/en/main.typ`](https://github.com/lucaslrodri/abntly/blob/v0.1.0/examples/en/main.typ) ([PDF](https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/example-en.pdf)): o mesmo trabalho
  em inglês, com os nomes em inglês.

## Documentação

O manual descreve cada função junto com o que a norma pede de cada elemento, com o código e o resultado. Ele serve
como guia do pacote e como referência rápida das normas.

- [Manual em português](https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/manual-pt.pdf) (PDF), com os nomes em português.
- [Manual em inglês](https://github.com/lucaslrodri/abntly/blob/v0.1.0/docs/manual-en.pdf) (PDF), com os nomes em inglês.

## Normas atendidas

| Norma | Assunto |
| ----- | ------- |
| ABNT NBR 14724:2024 | Trabalhos acadêmicos: estrutura e regras gerais de apresentação |
| ABNT NBR 6024:2012 | Numeração progressiva das seções, alíneas e subalíneas |
| ABNT NBR 6027:2012 | Sumário |
| ABNT NBR 6028:2021 | Resumo e palavras-chave |
| ABNT NBR 10520:2023 | Citações |
| ABNT NBR 6023:2025 | Referências |
| ABNT NBR 6034:2004 | Índice |
| ABNT NBR 6033:1989 | Ordem alfabética |
| IBGE (1993) | Normas de apresentação tabular |

## Dependências

| Dependência | Versão | Uso |
| ----------- | ------ | --- |
| [Typst](https://typst.app/) | ≥ 0.15.0 | compilador |
| [equate](https://typst.app/universe/package/equate) | 0.3.3 | numeração das equações |
| [glossarium](https://typst.app/universe/package/glossarium) | 0.5.10 | siglas, símbolos e glossário citados no texto |
| [linguify](https://typst.app/universe/package/linguify) | 0.5.0 | termos do pacote no idioma do trabalho |
| [subpar](https://typst.app/universe/package/subpar) | 0.2.2 | subfiguras |
| *New Computer Modern* | | fontes do texto, dos títulos, do código e das equações |

O Typst baixa os pacotes automaticamente. As fontes não: a *New Computer Modern* e a *New Computer Modern Math*
acompanham o Typst, mas a *Sans* (títulos), a *Mono* (código) e a *08* (sobrescritos) precisam ser instaladas. Elas
fazem parte da família [New Computer Modern](https://ctan.org/pkg/newcomputermodern): baixe o arquivo do CTAN e
instale, da pasta `otf`, os arquivos `NewCM10-*`, `NewCM08-*`, `NewCMSans10-*`, `NewCMSans08-*`, `NewCMMono10-*` e
`NewCMMath-*` (os que têm `Book` no nome não são usados). No [typst.app](https://typst.app/), envie esses arquivos
para o projeto.

## Veja também

O abntly se inspirou nestes projetos:

- [ABNTyp](https://typst.app/universe/package/abntyp): pacote do Typst para documentos nas normas da ABNT. Além de
  trabalhos acadêmicos, tem modelos para artigos, relatórios técnicos, projetos de pesquisa, livros, pôsteres e
  slides.
- [abnTeX2](https://www.abntex.net.br/): classes e pacotes do LaTeX para documentos nas normas da ABNT. O abntly
  segue o modelo de trabalho acadêmico do abnTeX2 nos pontos que as normas deixam em aberto.
- [csl-abnt](https://github.com/virgilinojuca/csl-abnt): estilo CSL nas normas ABNT NBR 6023 e NBR 10520 para o
  Zotero, de [@virgilinojuca](https://github.com/virgilinojuca) e [@AAguiarCAM](https://github.com/AAguiarCAM), em
  domínio público (CC0). O `src/csl/abnt-6023.csl` do abntly foi adaptado dele.

## Licença

O pacote é distribuído sob a [licença MIT](https://github.com/lucaslrodri/abntly/blob/v0.1.0/LICENSE).
