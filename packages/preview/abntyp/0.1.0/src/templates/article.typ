// Template para artigo científico conforme NBR 6022:2018

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../references/bibliography.typ": *

/// Template para artigo científico
///
/// Parâmetros:
/// - titulo: título do artigo
/// - subtitulo: subtítulo (opcional)
/// - autores: lista de autores com afiliação
/// - resumo: resumo em português
/// - resumo-en: abstract em inglês
/// - palavras-chave: palavras-chave
/// - palavras-chave-en: keywords
/// - fonte: fonte a usar
/// - colunas: número de colunas (1 ou 2)
/// - arquivo-bibliografia: caminho para arquivo .bib (opcional)
/// - titulo-bibliografia: título da seção de referências (padrão: "REFERÊNCIAS")
#let artigo(
  titulo: "",
  subtitulo: none,
  autores: (),
  resumo: none,
  resumo-en: none,
  palavras-chave: (),
  palavras-chave-en: (),
  fonte: "Times New Roman",
  colunas: 1,
  arquivo-bibliografia: none,
  titulo-bibliografia: "REFERÊNCIAS",
  body,
) = {
  // Configuração do documento
  set document(
    title: titulo,
    author: autores.map(a => a.name).join(", "),
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
    numbering: "1",
    number-align: top + right,
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

  // Configuração de headings (sem numeração para artigo)
  show heading.where(level: 1): it => {
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
    v(1em)
    text(weight: "regular", size: 12pt)[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #upper(it.body)
    ]
    v(1em)
  }

  // Excluir indentação de containers que não devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Título centralizado, maiúsculas, negrito
  align(center)[
    #text(weight: "bold", size: 14pt, upper(titulo))
    #if subtitulo != none {
      linebreak()
      text(size: 14pt, ": " + subtitulo)
    }
  ]

  v(1em)

  // Autores
  for autor in autores {
    align(center)[
      #text(size: 12pt, autor.name)
      #if "affiliation" in autor {
        footnote(autor.affiliation)
      }
    ]
  }

  v(2em)

  // Resumo
  if resumo != none {
    [*RESUMO*]
    linebreak()
    set par(first-line-indent: 0pt)
    resumo
    if palavras-chave.len() > 0 {
      linebreak()
      linebreak()
      [*Palavras-chave:* #palavras-chave.join(". ").]
    }
    v(2em)
  }

  // Abstract
  if resumo-en != none {
    [*ABSTRACT*]
    linebreak()
    set par(first-line-indent: 0pt)
    resumo-en
    if palavras-chave-en.len() > 0 {
      linebreak()
      linebreak()
      [*Keywords:* #palavras-chave-en.join(". ").]
    }
    v(2em)
  }

  // Corpo do artigo
  if colunas == 2 {
    columns(2, body)
  } else {
    body
  }

  // Bibliografia automática (se arquivo .bib fornecido)
  if arquivo-bibliografia != none {
    abnt-bibliography(arquivo-bibliografia, titulo: titulo-bibliografia)
  }
}

/// Seção de artigo (sem numeração)
#let article-section(titulo) = {
  heading(level: 1, numbering: none, titulo)
}

/// Subseção de artigo
#let article-subsection(titulo) = {
  heading(level: 2, numbering: none, titulo)
}
