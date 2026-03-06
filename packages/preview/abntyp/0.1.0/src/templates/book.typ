// Template para livros e folhetos conforme NBR 6029:2023
// Informacao e documentacao - Livros e folhetos - Apresentacao

#import "../core/page.typ": *
#import "../core/fonts.typ": *
#import "../core/spacing.typ": *
#import "../core/dates.typ": *

/// Template principal para livro ou folheto
/// Conforme NBR 6029:2023
///
/// Parametros:
/// - titulo: titulo da obra
/// - subtitulo: subtitulo (opcional)
/// - autor: nome do autor
/// - editora: nome da editora
/// - local: cidade de publicacao
/// - ano: ano de publicacao
/// - edicao: numero da edicao (a partir da 2a)
/// - volume: numero do volume (se houver)
/// - isbn: numero ISBN
/// - fonte: fonte a usar
/// - cabecalho: titulo corrente (opcional)
#let livro(
  titulo: "",
  subtitulo: none,
  autor: "",
  editora: "",
  local: "",
  ano: datetime.today().year(),
  edicao: none,
  volume: none,
  isbn: none,
  fonte: "Times New Roman",
  cabecalho: none,
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: autor,
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
    // Titulo corrente no alto da mancha
    header: context {
      if cabecalho != none {
        let page-num = counter(page).get().first()
        // Paginas pares: autor/titulo a esquerda
        // Paginas impares: capitulo a direita
        if calc.rem(page-num, 2) == 0 {
          // Pagina par
          text(size: 10pt, cabecalho)
        } else {
          // Pagina impar
          align(right)[
            #text(size: 10pt, cabecalho)
          ]
        }
      }
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

  // Configuracao de headings com numeracao progressiva
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    text(weight: "bold", size: 14pt)[
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
    v(1em)
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
    v(1em)
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
    v(1em)
  }

  // Excluir indentacao de containers que nao devem ser indentados
  show heading: set par(first-line-indent: 0pt)
  show figure: set par(first-line-indent: 0pt)
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show outline: set par(first-line-indent: 0pt)
  show terms: set par(first-line-indent: 0pt)

  // Notas de rodape
  set footnote.entry(
    separator: line(length: 5cm, stroke: 0.5pt),
  )

  body
}

/// Primeira capa do livro
/// Conforme NBR 6029:2023 - deve conter:
/// - Nome do autor
/// - Titulo e subtitulo por extenso
/// - Nome da editora e/ou logomarca
/// - Recomenda-se: edicao, local e ano
///
/// Parametros:
/// - autor: nome do autor
/// - titulo: titulo da obra
/// - subtitulo: subtitulo (opcional)
/// - editora: nome da editora
/// - logo-editora: logomarca da editora (opcional)
/// - edicao: numero da edicao (opcional)
/// - local: cidade (opcional)
/// - ano: ano (opcional)
#let book-cover(
  autor: "",
  titulo: "",
  subtitulo: none,
  editora: "",
  logo-editora: none,
  edicao: none,
  local: none,
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  v(2cm)

  // Autor
  text(size: 14pt, upper(autor))

  v(1fr)

  // Titulo
  text(weight: "bold", size: 18pt, upper(titulo))

  // Subtitulo
  if subtitulo != none {
    linebreak()
    text(size: 14pt, ": " + subtitulo)
  }

  v(1fr)

  // Edicao
  if edicao != none {
    text(size: 12pt)[#edicao. edicao]
    v(0.5em)
  }

  // Editora
  if logo-editora != none {
    logo-editora
    v(0.5em)
  }
  text(size: 12pt, editora)

  v(1em)

  // Local e ano
  if local != none {
    text(size: 12pt, local)
    linebreak()
  }
  if ano != none {
    text(size: 12pt, str(ano))
  }

  v(2cm)
  pagebreak()
}

/// Quarta capa (contracapa)
/// Conforme NBR 6029:2023 - deve conter:
/// - ISBN (obrigatorio)
/// - Codigo de barras (se houver)
/// - Pode conter: resumo e endereco da editora
///
/// Parametros:
/// - isbn: numero ISBN
/// - codigo-barras: codigo de barras (imagem, opcional)
/// - resumo: resumo do conteudo (opcional)
/// - endereco-editora: endereco da editora (opcional)
#let book-back-cover(
  isbn: "",
  codigo-barras: none,
  resumo: none,
  endereco-editora: none,
) = {
  set page(numbering: none)

  v(1fr)

  // Resumo
  if resumo != none {
    set par(first-line-indent: 0pt)
    resumo
    v(2em)
  }

  // Endereco da editora
  if endereco-editora != none {
    set text(size: 10pt)
    endereco-editora
    v(2em)
  }

  v(1fr)

  // ISBN e codigo de barras
  align(left)[
    #text(size: 10pt)[ISBN #isbn]
  ]

  if codigo-barras != none {
    v(0.5em)
    codigo-barras
  }

  pagebreak()
}

/// Falsa folha de rosto (opcional)
/// Apenas o titulo da obra
#let half-title-page(titulo: "") = {
  set page(numbering: none)
  set align(center)

  v(1fr)
  text(size: 14pt, titulo)
  v(1fr)

  pagebreak()
}

/// Folha de rosto - anverso
/// Conforme NBR 6029:2023 - elementos na ordem:
/// a) Autor
/// b) Titulo e subtitulo
/// c) Outros colaboradores
/// d) Indicacao de edicao (a partir da 2a)
/// e) Numeracao do volume
/// f) Editora
/// g) Local de publicacao
/// h) Ano de publicacao
///
/// Parametros:
/// - autor: nome do autor
/// - titulo: titulo
/// - subtitulo: subtitulo (opcional)
/// - colaboradores: outros colaboradores (tradutor, ilustrador, etc.)
/// - edicao: numero da edicao (a partir da 2a)
/// - volume: numero do volume (se houver)
/// - editora: editora
/// - local: cidade
/// - ano: ano
#let book-title-page(
  autor: "",
  titulo: "",
  subtitulo: none,
  colaboradores: none,
  edicao: none,
  volume: none,
  editora: "",
  local: "",
  ano: none,
) = {
  set page(numbering: none)
  set align(center)

  // Autor
  text(size: 12pt, upper(autor))

  v(1fr)

  // Titulo
  text(weight: "bold", size: 16pt, upper(titulo))

  // Subtitulo (diferenciado tipograficamente)
  if subtitulo != none {
    linebreak()
    text(size: 14pt, ": " + subtitulo)
  }

  v(1em)

  // Colaboradores
  if colaboradores != none {
    set text(size: 11pt)
    colaboradores
  }

  v(1em)

  // Edicao
  if edicao != none {
    text(size: 11pt)[#edicao. edicao]
    v(0.5em)
  }

  // Volume
  if volume != none {
    text(size: 11pt)[Volume #volume]
  }

  v(1fr)

  // Editora
  text(size: 12pt, editora)

  v(0.5em)

  // Local
  text(size: 12pt, local)

  // Ano
  if ano != none {
    linebreak()
    text(size: 12pt, str(ano))
  }

  pagebreak()
}

/// Folha de rosto - verso
/// Conforme NBR 6029:2023 - deve conter:
/// a) Direito autoral
/// b) Direito de reproducao
/// c) Titulo original (se traducao)
/// d) Outros suportes disponiveis
/// e) Creditos
/// f) Ficha catalografica + nome e CRB do bibliotecario
/// g) Dados da editora
///
/// Parametros:
/// - ano-copyright: ano do copyright
/// - detentor-copyright: detentor dos direitos
/// - titulo-original: titulo original (se traducao)
/// - direitos-reproducao: texto sobre direito de reproducao
/// - outros-formatos: outros suportes disponiveis
/// - creditos: creditos diversos
/// - ficha-catalografica: conteudo da ficha catalografica
/// - bibliotecario: nome e CRB do bibliotecario
/// - dados-editora: dados da editora
#let book-title-page-verso(
  ano-copyright: none,
  detentor-copyright: none,
  titulo-original: none,
  direitos-reproducao: none,
  outros-formatos: none,
  creditos: none,
  ficha-catalografica: none,
  bibliotecario: none,
  dados-editora: none,
) = {
  set page(numbering: none)
  set text(size: 10pt)
  set par(first-line-indent: 0pt, leading: 1em * 0.65)

  // Copyright
  if ano-copyright != none and detentor-copyright != none {
    [(c) #ano-copyright #detentor-copyright]
    v(1em)
  }

  // Direito de reproducao
  if direitos-reproducao != none {
    direitos-reproducao
    v(1em)
  }

  // Titulo original
  if titulo-original != none {
    [Titulo original: #emph[#titulo-original]]
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

  // Ficha catalografica (parte inferior)
  if ficha-catalografica != none {
    align(center)[
      #box(
        width: 12.5cm,
        height: auto,
        stroke: 0.5pt,
        inset: 0.5cm,
      )[
        #ficha-catalografica

        #if bibliotecario != none {
          v(0.5em)
          text(size: 9pt, bibliotecario)
        }
      ]
    ]
    v(1em)
  }

  // Dados da editora
  if dados-editora != none {
    align(center)[
      #text(size: 9pt, dados-editora)
    ]
  }

  pagebreak()
}

/// Dedicatoria
/// Conforme NBR 6029:2023 - pagina impar
#let book-dedication(conteudo) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #set text(size: 11pt)
      #conteudo
    ]
  ]
  pagebreak()
}

/// Agradecimentos
/// Conforme NBR 6029:2023 - pagina impar
#let book-acknowledgments(conteudo) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "AGRADECIMENTOS")
  ]
  v(1.5em)
  conteudo
  pagebreak()
}

/// Epigrafe
/// Conforme NBR 6029:2023 - pagina impar
#let book-epigraph(quote, autor) = {
  set page(numbering: none)
  v(1fr)
  align(right)[
    #box(width: 50%)[
      #set par(first-line-indent: 0pt)
      #set text(size: 11pt, style: "italic")
      "#quote"
      #linebreak()
      #set text(style: "normal")
      [(#autor)]
    ]
  ]
  pagebreak()
}

/// Lista de ilustracoes
/// Conforme NBR 6029:2023 - ordem de apresentacao
/// Formato: nome especifico + travessao + titulo + pagina
#let book-list-illustrations() = {
  align(center)[
    #text(weight: "bold", size: 12pt, "LISTA DE ILUSTRACOES")
  ]

  v(1.5em)

  outline(
    title: none,
    target: figure.where(kind: image),
  )

  pagebreak()
}

/// Lista de tabelas
#let book-list-tables() = {
  align(center)[
    #text(weight: "bold", size: 12pt, "LISTA DE TABELAS")
  ]

  v(1.5em)

  outline(
    title: none,
    target: figure.where(kind: table),
  )

  pagebreak()
}

/// Lista de abreviaturas e siglas
/// Conforme NBR 6029:2023 - ordem alfabetica
#let book-list-abbreviations(items) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "LISTA DE ABREVIATURAS E SIGLAS")
  ]

  v(1.5em)

  set par(first-line-indent: 0pt)

  // Ordenar alfabeticamente
  let sorted-keys = items.keys().sorted()
  for key in sorted-keys {
    [#key #h(1em) #items.at(key) \ ]
  }

  pagebreak()
}

/// Lista de simbolos
/// Conforme NBR 6029:2023 - ordem de apresentacao
#let book-list-symbols(items) = {
  align(center)[
    #text(weight: "bold", size: 12pt, "LISTA DE SIMBOLOS")
  ]

  v(1.5em)

  set par(first-line-indent: 0pt)

  for (symbol, meaning) in items {
    [#symbol #h(1em) #meaning \ ]
  }

  pagebreak()
}

/// Sumario do livro
/// Conforme NBR 6027
#let book-toc(
  titulo: "SUMARIO",
  profundidade: 3,
) = {
  align(center)[
    #text(weight: "bold", size: 12pt, titulo)
  ]

  v(1.5em)

  outline(
    title: none,
    depth: profundidade,
    indent: auto,
  )

  pagebreak()
}

/// Prefacio ou apresentacao
/// Conforme NBR 6029:2023 - pagina impar, sem indicativo de secao
/// Em novas edicoes: prefacio novo precede os anteriores
#let book-preface(titulo: "PREFACIO", conteudo) = {
  heading(level: 1, numbering: none, upper(titulo))
  conteudo
  pagebreak()
}

/// Apresentacao
#let book-presentation(conteudo) = {
  book-preface(titulo: "APRESENTACAO", conteudo)
}

/// Posfacio
/// Conforme NBR 6029:2023 - elemento pos-textual opcional
#let book-postface(conteudo) = {
  heading(level: 1, numbering: none, "POSFACIO")
  conteudo
  pagebreak()
}

/// Glossario
/// Conforme NBR 6029:2023 - elemento pos-textual opcional
/// - items: dicionario termo -> definicao
#let book-glossary(items) = {
  heading(level: 1, numbering: none, "GLOSSARIO")

  set par(first-line-indent: 0pt)

  let sorted-keys = items.keys().sorted()
  for key in sorted-keys {
    [*#key:* #items.at(key) \ ]
    v(0.5em)
  }

  pagebreak()
}

/// Apendice
/// Conforme NBR 6029:2023 - identificacao: termo + travessao + titulo
/// Multiplos: letras maiusculas consecutivas (A, B, C...)
#let book-appendix(letra: "A", titulo: "", body) = {
  heading(level: 1, numbering: none)[APENDICE #letra -- #titulo]
  body
  pagebreak()
}

/// Anexo
/// Conforme NBR 6029:2023 - identificacao: termo + travessao + titulo
/// Multiplos: letras maiusculas consecutivas (A, B, C...)
#let book-annex(letra: "A", titulo: "", body) = {
  heading(level: 1, numbering: none)[ANEXO #letra -- #titulo]
  body
  pagebreak()
}

/// Indice remissivo
/// Conforme NBR 6034 - no final da publicacao
#let book-index(titulo: "INDICE", entries) = {
  heading(level: 1, numbering: none, upper(titulo))

  set par(first-line-indent: 0pt)
  set text(size: 10pt)

  // Organizar por letra inicial
  let by-letter = (:)
  for (term, pages) in entries {
    let letter = upper(term.at(0))
    if letter not in by-letter {
      by-letter.insert(letter, ())
    }
    by-letter.at(letter).push((term, pages))
  }

  for letter in by-letter.keys().sorted() {
    text(weight: "bold", size: 11pt, letter)
    linebreak()
    for (term, pages) in by-letter.at(letter) {
      [#term #box(width: 1fr, repeat[.]) #pages \ ]
    }
    v(0.5em)
  }

  pagebreak()
}

/// Colofao
/// Conforme NBR 6029:2023 - ultima folha do miolo
/// Especificacoes graficas da publicacao
#let book-colophon(conteudo) = {
  v(1fr)
  set text(size: 10pt)
  set par(first-line-indent: 0pt)
  align(center)[
    #conteudo
  ]
}

/// Inicia numeracao das paginas (apos elementos pre-textuais)
/// Conforme NBR 6029:2023:
/// - Folhas iniciais ate o Sumario: contadas mas nao numeradas
/// - Algarismos arabicos
/// - Localizacao: fora da mancha, a criterio do projeto grafico
#let book-start-numbering() = {
  counter(page).update(1)
  set page(
    numbering: "1",
    number-align: bottom + center,
  )
}

/// Equacoes e formulas
/// Conforme NBR 6029:2023 - numeradas com algarismos arabicos entre parenteses
#let book-equation(body) = {
  set math.equation(numbering: "(1)")
  body
}
