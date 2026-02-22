// Template para tese/dissertação/TCC conforme NBR 14724:2024

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../text/headings.typ": *
#import "../elements/cover.typ": *
#import "../elements/title-page.typ": *
#import "../elements/abstract.typ": *
#import "../elements/toc.typ": *
#import "../references/bibliography.typ": *

/// Template principal para trabalhos acadêmicos (tese, dissertação, TCC)
///
/// Parâmetros:
/// - titulo: título do trabalho
/// - subtitulo: subtítulo (opcional)
/// - autor: nome do autor
/// - instituicao: nome da instituição
/// - faculdade: faculdade/unidade
/// - programa: programa de pós-graduação
/// - local: cidade
/// - ano: ano de depósito
/// - natureza: natureza do trabalho
/// - objetivo: objetivo (ex: "Dissertação apresentada ao Programa...")
/// - area: área de concentração
/// - orientador: orientador
/// - coorientador: coorientador (opcional)
/// - palavras-chave: palavras-chave em português
/// - palavras-chave-en: keywords em inglês
/// - fonte: fonte a usar ("Times New Roman" ou "Arial")
/// - arquivo-bibliografia: caminho para arquivo .bib (opcional)
/// - titulo-bibliografia: título da seção de referências (padrão: "REFERÊNCIAS")
#let abntcc(
  titulo: "",
  subtitulo: none,
  autor: "",
  instituicao: "",
  faculdade: none,
  programa: none,
  local: "",
  ano: datetime.today().year(),
  natureza: none,
  objetivo: none,
  area: none,
  orientador: none,
  coorientador: none,
  palavras-chave: (),
  palavras-chave-en: (),
  fonte: "Times New Roman",
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  body,
) = {
  // Configuração do documento
  set document(
    title: titulo,
    author: autor,
  )

  // Configuração de página
  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 2cm,
      left: 3cm,
      right: 2cm,
    ),
  )

  // Configuração de fonte
  set text(
    font: fonte,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )

  // Configuração de parágrafo
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)
  set terms(indent: 0em, hanging-indent: 2em, separator: [: ])

  // Configuração de headings
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1.5em)
  }

  show heading.where(level: 3): it => {
    v(1.5em)
    text(weight: "bold", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 4): it => {
    v(1.5em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  show heading.where(level: 5): it => {
    v(1.5em)
    text(weight: "regular", style: "italic", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
    ]
    v(1.5em)
  }

  // Excluir indentação de containers que não devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Configuração de notas de rodapé
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
  )

  // Conteúdo
  body

  // Bibliografia automática (se arquivo .bib fornecido)
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }
}

/// Marca início da parte pré-textual (sem numeração visível)
#let pretextual() = {
  counter(page).update(1)
  set page(numbering: none)
}

/// Marca início da parte textual (numeração arábica)
#let textual() = {
  counter(page).update(1)
  set page(
    numbering: "1",
    number-align: top + right,
  )
}

/// Marca início da parte pós-textual
#let postextual() = {
  // Continua numeração
}

/// Página de dedicatória
#let dedicatoria(conteudo) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #conteudo
    ]
  ]
  pagebreak()
}

/// Página de agradecimentos
#let agradecimentos(conteudo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "AGRADECIMENTOS")
  ]
  v(1.5em)
  conteudo
  pagebreak()
}

/// Epígrafe
#let epigrafe(quote, autor) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      "#quote" \
      [(#autor)]
    ]
  ]
  pagebreak()
}
