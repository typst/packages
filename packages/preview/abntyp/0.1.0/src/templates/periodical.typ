// Template para publicacao periodica tecnica e/ou cientifica
// Conforme NBR 6021:2015

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/dates.typ": *
#import "../references/abbreviations.typ": *

/// Template principal para fasciculo de periodico
///
/// Parametros:
/// - titulo: titulo do periodico
/// - subtitulo: subtitulo (opcional)
/// - issn: numero ISSN
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - ano: ano de publicacao
/// - mes-inicio: mes inicial (1-12)
/// - mes-fim: mes final (1-12, opcional para periodo)
/// - local: cidade de publicacao
/// - editora: editora
/// - instituicao: instituicao responsavel
/// - doi: identificador DOI (opcional)
/// - fonte: fonte a usar
#let periodical(
  titulo: "",
  subtitulo: none,
  issn: none,
  volume: none,
  numero: none,
  ano: datetime.today().year(),
  mes-inicio: none,
  mes-fim: none,
  local: none,
  editora: none,
  instituicao: none,
  doi: none,
  fonte: "Times New Roman",
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
  )

  // Configuracao de pagina
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
    // Legenda bibliografica no rodape
    footer: context {
      let abbrev-title = abbreviate-title(titulo)
      let month-text = if mes-inicio != none {
        if mes-fim != none {
          format-month-range(mes-inicio, mes-fim)
        } else {
          get-month-abbrev(mes-inicio)
        }
      } else { "" }

      let page-num = counter(page).get().first()

      set text(size: 10pt)
      set align(left)
      [#abbrev-title, #local, v. #volume, n. #numero, p. #page-num, #month-text #ano.]
    },
  )

  // Configuracao de fonte
  set text(
    font: fonte,
    size: 12pt,
    lang: "pt",
    region: "BR",
  )

  // Configuracao de paragrafo
  set par(
    leading: 1.5em * 0.65,
    justify: true,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)
  set terms(indent: 0em, hanging-indent: 2em, separator: [: ])

  // Configuracao de headings
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

  // Excluir indentacao de containers que nao devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  body
}

/// Capa do fasciculo conforme NBR 6021:2015
/// Primeira capa com elementos obrigatorios
///
/// Parametros:
/// - titulo: titulo do periodico
/// - subtitulo: subtitulo (opcional)
/// - issn: numero ISSN (obrigatorio, canto superior direito)
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - ano: ano
/// - mes-inicio: mes inicial
/// - mes-fim: mes final (opcional)
/// - logo: logomarca (opcional)
/// - suplemento: indicacao de suplemento (opcional)
#let periodical-cover(
  titulo: "",
  subtitulo: none,
  issn: none,
  volume: none,
  numero: none,
  ano: none,
  mes-inicio: none,
  mes-fim: none,
  logo: none,
  suplemento: none,
) = {
  set page(numbering: none)

  // ISSN no canto superior direito
  if issn != none {
    place(top + right)[
      #text(size: 10pt)[ISSN #issn]
    ]
  }

  v(2cm)

  // Logomarca (se houver)
  if logo != none {
    align(center)[#logo]
    v(1cm)
  }

  // Titulo e subtitulo
  align(center)[
    #text(weight: "bold", size: 16pt, upper(titulo))
    #if subtitulo != none {
      linebreak()
      text(size: 14pt, subtitulo)
    }
  ]

  v(1fr)

  // Indicacao de suplemento
  if suplemento != none {
    align(center)[
      #text(size: 12pt, suplemento)
    ]
    v(1em)
  }

  // Volume, numero e data
  align(center)[
    #text(size: 12pt)[
      v. #volume
      #h(1em)
      n. #numero
      #h(1em)
      #if mes-inicio != none {
        if mes-fim != none {
          [#month-names.at(mes-inicio - 1)/#month-names.at(mes-fim - 1)]
        } else {
          month-names.at(mes-inicio - 1)
        }
      }
      #h(0.5em)
      #ano
    ]
  ]

  v(2cm)
  pagebreak()
}

/// Folha de rosto do fasciculo (anverso)
/// Conforme NBR 6021:2015 secao 4.3.1
///
/// Parametros:
/// - titulo: titulo do periodico
/// - issn: numero ISSN
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - paginas: intervalo de paginas (ex: "1-154")
/// - ano: ano
/// - mes-inicio: mes inicial
/// - mes-fim: mes final (opcional)
/// - local: cidade de publicacao
#let periodical-title-page(
  titulo: "",
  issn: none,
  volume: none,
  numero: none,
  paginas: none,
  ano: none,
  mes-inicio: none,
  mes-fim: none,
  local: none,
) = {
  set page(numbering: none)

  // Titulo com destaque
  align(center)[
    #text(weight: "bold", size: 14pt, upper(titulo))
  ]

  v(2cm)

  // ISSN acima da legenda bibliografica
  if issn != none {
    align(center)[
      #text(size: 10pt)[ISSN #issn]
    ]
  }

  v(1cm)

  // Legenda bibliografica completa
  let abbrev-title = abbreviate-title(titulo)
  let month-text = if mes-inicio != none {
    if mes-fim != none {
      format-month-range(mes-inicio, mes-fim)
    } else {
      get-month-abbrev(mes-inicio)
    }
  } else { "" }

  align(center)[
    #text(size: 10pt)[
      #abbrev-title, #local, v. #volume, n. #numero, p. #paginas, #month-text #ano.
    ]
  ]

  v(1fr)
  pagebreak()
}

/// Verso da folha de rosto
/// Conforme NBR 6021:2015 secao 4.3.1.2
///
/// Parametros:
/// - ano-copyright: ano do copyright
/// - detentor-copyright: detentor dos direitos
/// - direitos-reproducao: autorizacao de reproducao (opcional)
/// - outros-formatos: outros suportes disponiveis (opcional)
/// - catalogacao: dados de catalogacao na publicacao
/// - creditos: creditos e outras informacoes
#let periodical-title-page-verso(
  ano-copyright: none,
  detentor-copyright: none,
  direitos-reproducao: none,
  outros-formatos: none,
  catalogacao: none,
  creditos: none,
) = {
  set page(numbering: none)
  set text(size: 10pt)
  set par(first-line-indent: 0pt, leading: 1em * 0.65)

  // Copyright
  if ano-copyright != none and detentor-copyright != none {
    [(c) #ano-copyright #detentor-copyright]
    v(1em)
  }

  // Autorizacao de reproducao
  if direitos-reproducao != none {
    direitos-reproducao
    v(1em)
  }

  // Outros suportes
  if outros-formatos != none {
    outros-formatos
    v(1em)
  }

  // Creditos
  if creditos != none {
    creditos
    v(1em)
  }

  v(1fr)

  // Dados de catalogacao (parte inferior)
  if catalogacao != none {
    align(center)[
      #box(
        width: 12cm,
        stroke: 0.5pt,
        inset: 0.5cm,
      )[
        #catalogacao
      ]
    ]
  }

  pagebreak()
}

/// Sumario do fasciculo
/// Conforme NBR 6027
#let periodical-toc(
  titulo: "SUMARIO",
) = {
  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  outline(
    title: none,
    depth: 2,
    indent: auto,
  )

  pagebreak()
}

/// Editorial
/// Texto do editor apresentando o conteudo do fasciculo
#let editorial(conteudo) = {
  heading(level: 1, numbering: none, "EDITORIAL")
  conteudo
  pagebreak()
}

/// Legenda bibliografica completa
/// Para uso no rodape de cada pagina ou folha de rosto
///
/// Parametros:
/// - titulo: titulo do periodico (sera abreviado)
/// - local: cidade
/// - volume: numero do volume
/// - numero: numero do fasciculo
/// - paginas: paginas (ex: "1-154" para fasciculo, "9-21" para artigo)
/// - mes-inicio: mes inicial (1-12)
/// - mes-fim: mes final (1-12, opcional)
/// - ano: ano
#let bibliographic-legend(
  titulo: "",
  local: "",
  volume: none,
  numero: none,
  paginas: none,
  mes-inicio: none,
  mes-fim: none,
  ano: none,
) = {
  let abbrev-title = abbreviate-title(titulo)

  let month-text = if mes-inicio != none {
    if mes-fim != none {
      format-month-range(mes-inicio, mes-fim)
    } else {
      get-month-abbrev(mes-inicio)
    }
  } else { "" }

  text(size: 10pt)[
    #abbrev-title, #local, v. #volume, n. #numero, p. #paginas, #month-text #ano.
  ]
}

/// Artigo em periodico
/// Conforme NBR 6022:2018 (integrado com NBR 6021:2015)
///
/// Parametros:
/// - titulo: titulo do artigo
/// - autores: lista de autores com afiliacao
/// - resumo: resumo em portugues
/// - palavras-chave: palavras-chave
/// - resumo-en: abstract em ingles (opcional)
/// - palavras-chave-en: keywords (opcional)
#let periodical-article(
  titulo: "",
  autores: (),
  resumo: none,
  palavras-chave: (),
  resumo-en: none,
  palavras-chave-en: (),
  body,
) = {
  // Titulo do artigo
  align(center)[
    #text(weight: "bold", size: 12pt, upper(titulo))
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
    set par(first-line-indent: 0pt)
    [*RESUMO*]
    linebreak()
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
    set par(first-line-indent: 0pt)
    [*ABSTRACT*]
    linebreak()
    resumo-en
    if palavras-chave-en.len() > 0 {
      linebreak()
      linebreak()
      [*Keywords:* #palavras-chave-en.join(". ").]
    }
    v(2em)
  }

  // Corpo do artigo
  body
}

/// Instrucoes editoriais para autores
/// Conforme NBR 6021:2015 secao 4.5.2
#let author-guidelines(conteudo) = {
  heading(level: 1, numbering: none, "INSTRUCOES PARA AUTORES")
  set par(first-line-indent: 0pt)
  conteudo
}

/// Suplemento de periodico
/// Conforme NBR 6021:2015 secao 5.4
///
/// Parametros:
/// - titulo-principal: titulo do periodico principal
/// - titulo-suplemento: titulo do suplemento
/// - volume: volume do periodico principal
/// - ano: ano
/// - issn: ISSN do periodico principal
#let supplement-info(
  titulo-principal: "",
  titulo-suplemento: "",
  volume: none,
  ano: none,
  issn: none,
) = {
  text(size: 10pt)[
    Suplemento de: #titulo-principal, v. #volume, #ano.
    #titulo-suplemento
    #if issn != none { [ISSN #issn] }
  ]
}
