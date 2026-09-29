// Template para Poster Tecnico e Cientifico conforme NBR 15437:2006
//
// Estrutura:
// - Titulo (obrigatorio) - parte superior
// - Subtitulo (opcional) - diferenciado tipograficamente ou separado por :
// - Autor (obrigatorio) - logo abaixo do titulo
// - Informacoes complementares (opcional) - instituicao, cidade, estado, pais, etc.
// - Resumo (opcional) - ate 100 palavras, seguido de palavras-chave
// - Conteudo (obrigatorio) - ideias centrais em texto/tabelas/ilustracoes
// - Referencias (opcional) - conforme NBR 6023
//
// Dimensoes recomendadas:
// - Largura: 0,60m a 0,90m
// - Altura: 0,90m a 1,20m
//
// O poster deve ser legivel a pelo menos 1 metro de distancia

/// Template principal para Poster Cientifico conforme NBR 15437:2006
///
/// Parametros:
/// - titulo: titulo do poster (obrigatorio)
/// - subtitulo: subtitulo (opcional)
/// - autores: lista de autores (nome e afiliacao)
/// - instituicao: instituicao principal
/// - contato: informacoes de contato (email, endereco)
/// - texto-resumo: resumo (ate 100 palavras)
/// - palavras-chave: palavras-chave
/// - num-colunas: numero de colunas para o conteudo (padrao: 3)
/// - largura: largura do poster (padrao: 90cm)
/// - altura: altura do poster (padrao: 120cm)
/// - fonte: fonte a usar
/// - tamanho-titulo: tamanho da fonte do titulo (padrao: 72pt)
/// - tamanho-corpo: tamanho da fonte do corpo (padrao: 24pt)
/// - fundo: cor de fundo (opcional)
/// - cor-destaque: cor de destaque (opcional)
#let poster(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  largura: 90cm,
  altura: 120cm,
  fonte: "Arial",
  tamanho-titulo: 72pt,
  tamanho-corpo: 24pt,
  fundo: white,
  cor-destaque: rgb("#003366"),
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: autores.map(a => if type(a) == dictionary { a.name } else { a }).join(", "),
  )

  // Configuracao de pagina para poster
  set page(
    width: largura,
    height: altura,
    margin: 2cm,
    fill: fundo,
  )

  // Configuracao de fonte
  set text(
    font: fonte,
    size: tamanho-corpo,
    lang: "pt",
    region: "BR",
  )

  // Configuracao de paragrafo
  set par(
    leading: 1.2em,
    justify: true,
    first-line-indent: 0pt,
  )

  // Configuracao de headings para poster
  show heading.where(level: 1): it => {
    v(0.5em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.5,
      fill: cor-destaque,
      upper(it.body),
    )
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    v(0.3em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.2,
      it.body,
    )
    v(0.3em)
  }

  // Cabecalho do poster (titulo, autores, instituicao)
  align(center)[
    // Titulo
    #text(
      weight: "bold",
      size: tamanho-titulo,
      fill: cor-destaque,
      upper(titulo),
    )

    // Subtitulo
    #if subtitulo != none {
      linebreak()
      text(
        size: tamanho-titulo * 0.6,
        ": " + subtitulo,
      )
    }

    #v(1cm)

    // Autores
    #if autores.len() > 0 {
      text(size: tamanho-corpo * 1.3)[
        #for (i, autor) in autores.enumerate() {
          if i > 0 { [, ] }
          if type(autor) == dictionary {
            text(weight: "bold", autor.name)
            if "affiliation" in autor {
              super(str(i + 1))
            }
          } else {
            text(weight: "bold", autor)
          }
        }
      ]
      linebreak()

      // Afiliacoes
      v(0.5cm)
      text(size: tamanho-corpo * 0.9)[
        #for (i, autor) in autores.enumerate() {
          if type(autor) == dictionary and "affiliation" in autor {
            super(str(i + 1))
            autor.affiliation
            linebreak()
          }
        }
      ]
    }

    // Instituicao principal
    #if instituicao != none {
      v(0.3cm)
      text(size: tamanho-corpo, instituicao)
    }

    // Contato
    #if contato != none {
      linebreak()
      text(size: tamanho-corpo * 0.8, contato)
    }
  ]

  v(1cm)

  // Linha divisoria
  line(length: 100%, stroke: 2pt + cor-destaque)

  v(1cm)

  // Resumo (se fornecido)
  if texto-resumo != none {
    box(
      width: 100%,
      inset: 1em,
      fill: cor-destaque.lighten(90%),
      radius: 5pt,
    )[
      #text(weight: "bold", size: tamanho-corpo * 1.1)[RESUMO]
      #linebreak()
      #v(0.3em)
      #texto-resumo
      #if palavras-chave.len() > 0 {
        v(0.5em)
        text(weight: "bold")[Palavras-chave: ]
        palavras-chave.join("; ")
      }
    ]
    v(1cm)
  }

  // Conteudo em colunas
  columns(num-colunas, gutter: 2em, body)
}

/// Secao de poster com caixa colorida
#let poster-section(
  titulo: none,
  cor-destaque: rgb("#003366"),
  body,
) = {
  box(
    width: 100%,
    inset: 1em,
    stroke: 2pt + cor-destaque,
    radius: 5pt,
  )[
    #if titulo != none {
      align(center)[
        #box(
          fill: cor-destaque,
          inset: 0.5em,
          radius: 3pt,
        )[
          #text(weight: "bold", fill: white, upper(titulo))
        ]
      ]
      v(0.5em)
    }
    #body
  ]
  v(1em)
}

/// Caixa de destaque para poster
#let poster-highlight(
  cor-destaque: rgb("#003366"),
  body,
) = {
  box(
    width: 100%,
    inset: 1em,
    fill: cor-destaque.lighten(90%),
    radius: 5pt,
  )[
    #body
  ]
  v(0.5em)
}

/// Figura para poster
/// Maior e com legenda mais visivel
#let poster-figure(
  body,
  legenda: none,
  origem: none,
) = {
  align(center)[
    #body
    #if legenda != none {
      v(0.3em)
      text(weight: "bold")[#legenda]
    }
    #if origem != none {
      linebreak()
      text(size: 0.8em)[Fonte: #origem]
    }
  ]
  v(0.5em)
}

/// Referencias para poster
/// Formato compacto, sem notas de rodape
#let poster-references(itens) = {
  text(weight: "bold", size: 1.2em)[REFERENCIAS]
  v(0.3em)

  set par(
    hanging-indent: 1em,
    first-line-indent: 0pt,
  )
  set text(size: 0.8em)

  for item in itens {
    item
    linebreak()
    v(0.2em)
  }
}

/// Template de poster academico (com orientador)
#let academic-poster(
  titulo: "",
  subtitulo: none,
  autores: (),
  orientador: none,
  instituicao: none,
  departamento: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  largura: 90cm,
  altura: 120cm,
  fonte: "Arial",
  tamanho-titulo: 72pt,
  tamanho-corpo: 24pt,
  fundo: white,
  cor-destaque: rgb("#003366"),
  logo: none,
  body,
) = {
  // Configuracao do documento
  set document(
    title: titulo,
    author: autores.map(a => if type(a) == dictionary { a.name } else { a }).join(", "),
  )

  // Configuracao de pagina
  set page(
    width: largura,
    height: altura,
    margin: 2cm,
    fill: fundo,
  )

  set text(
    font: fonte,
    size: tamanho-corpo,
    lang: "pt",
    region: "BR",
  )

  set par(
    leading: 1.2em,
    justify: true,
    first-line-indent: 0pt,
  )

  show heading.where(level: 1): it => {
    v(0.5em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.5,
      fill: cor-destaque,
      upper(it.body),
    )
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    v(0.3em)
    text(
      weight: "bold",
      size: tamanho-corpo * 1.2,
      it.body,
    )
    v(0.3em)
  }

  // Cabecalho com logo
  grid(
    columns: if logo != none { (auto, 1fr, auto) } else { (1fr,) },
    gutter: 1cm,
    align: horizon,

    // Logo esquerdo
    if logo != none { logo },

    // Titulo e informacoes
    align(center)[
      #text(
        weight: "bold",
        size: tamanho-titulo,
        fill: cor-destaque,
        upper(titulo),
      )

      #if subtitulo != none {
        linebreak()
        text(size: tamanho-titulo * 0.6, ": " + subtitulo)
      }

      #v(0.5cm)

      // Autores
      #text(size: tamanho-corpo * 1.2)[
        #for (i, autor) in autores.enumerate() {
          if i > 0 { [, ] }
          if type(autor) == dictionary {
            text(weight: "bold", autor.name)
          } else {
            text(weight: "bold", autor)
          }
        }
      ]

      // Orientador
      #if orientador != none {
        linebreak()
        text(size: tamanho-corpo)[Orientador: #orientador]
      }

      #v(0.3cm)

      // Instituicao
      #if instituicao != none {
        text(size: tamanho-corpo * 0.9, instituicao)
      }
      #if departamento != none {
        linebreak()
        text(size: tamanho-corpo * 0.8, departamento)
      }

      #if contato != none {
        linebreak()
        text(size: tamanho-corpo * 0.7, contato)
      }
    ],

    // Logo direito (mesmo que esquerdo para simetria)
    if logo != none { logo },
  )

  v(1cm)
  line(length: 100%, stroke: 2pt + cor-destaque)
  v(1cm)

  // Resumo
  if texto-resumo != none {
    box(
      width: 100%,
      inset: 1em,
      fill: cor-destaque.lighten(90%),
      radius: 5pt,
    )[
      #text(weight: "bold", size: tamanho-corpo * 1.1)[RESUMO]
      #linebreak()
      #v(0.3em)
      #texto-resumo
      #if palavras-chave.len() > 0 {
        v(0.5em)
        text(weight: "bold")[Palavras-chave: ]
        palavras-chave.join("; ")
      }
    ]
    v(1cm)
  }

  // Conteudo
  columns(num-colunas, gutter: 2em, body)
}

/// Cria um poster A0 (padrao para congressos)
#let poster-a0(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 3,
  fonte: "Arial",
  cor-destaque: rgb("#003366"),
  body,
) = {
  poster(
    titulo: titulo,
    subtitulo: subtitulo,
    autores: autores,
    instituicao: instituicao,
    contato: contato,
    texto-resumo: texto-resumo,
    palavras-chave: palavras-chave,
    num-colunas: num-colunas,
    largura: 84.1cm,   // A0 width
    altura: 118.9cm, // A0 height
    fonte: fonte,
    tamanho-titulo: 72pt,
    tamanho-corpo: 24pt,
    cor-destaque: cor-destaque,
    body,
  )
}

/// Cria um poster A1
#let poster-a1(
  titulo: "",
  subtitulo: none,
  autores: (),
  instituicao: none,
  contato: none,
  texto-resumo: none,
  palavras-chave: (),
  num-colunas: 2,
  fonte: "Arial",
  cor-destaque: rgb("#003366"),
  body,
) = {
  poster(
    titulo: titulo,
    subtitulo: subtitulo,
    autores: autores,
    instituicao: instituicao,
    contato: contato,
    texto-resumo: texto-resumo,
    palavras-chave: palavras-chave,
    num-colunas: num-colunas,
    largura: 59.4cm,  // A1 width
    altura: 84.1cm, // A1 height
    fonte: fonte,
    tamanho-titulo: 48pt,
    tamanho-corpo: 18pt,
    cor-destaque: cor-destaque,
    body,
  )
}
