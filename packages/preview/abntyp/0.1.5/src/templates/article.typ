// Template para artigo científico conforme NBR 6022:2018

#import "../core/setup.typ": with-abnt-setup
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

  show: with-abnt-setup.with(fonte: fonte, level-1-pagebreak: false)

  // Paginação visível desde o início para artigos
  set page(
    numbering: "1",
    number-align: top + right,
  )

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
