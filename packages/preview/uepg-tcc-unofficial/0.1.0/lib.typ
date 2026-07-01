// monografia-uepg: Template para Monografias da UEPG - Normas ABNT
// Baseado no Guia ABNT da UEPG (NBR 14724)

// Função para citações longas ABNT (recuo 4cm, 10pt, espaçamento simples)
#let citacao-longa(body) = {
  v(0.5em)
  pad(left: 4cm)[
    #set text(size: 10pt)
    #set par(leading: 0.4em, first-line-indent: 0cm, justify: true)
    #body
  ]
  v(0.5em)
}

#let monografia(
  // Informações institucionais
  titulo: "",
  autor: "",
  orientadores: (),
  nota-apresentacao: "",
  curso: "",
  departamento: "",
  setor: "SETOR DE ENGENHARIAS, CIÊNCIAS AGRÁRIAS E TECNOLOGIA",
  local: "PONTA GROSSA",
  ano: "",

  // Resumo
  resumo: none,
  palavras-chave: (),

  // Abstract
  abstract: none,
  keywords: (),

  // Elementos pré-textuais opcionais
  dedicatoria: none,
  agradecimentos: none,
  epigrafe: none,
  lista-abreviaturas: none, // Array de (sigla, significado): (("ABNT", "Associação Brasileira de Normas Técnicas"), ...)

  // Controle de listas (auto = gera se existirem elementos, true = força, false = não gera)
  lista-ilustracoes: auto,
  lista-quadros: auto,
  lista-tabelas: auto,

  // Texto padrão da fonte em figuras/tabelas/quadros
  fonte-padrao: "O autor",

  // Conteúdo
  body
) = {

  // Configurações de página - Margens ABNT
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm, top: 3cm, bottom: 2cm),
    numbering: none,
  )

  set text(
    font: ("Times New Roman", "TeX Gyre Termes", "Liberation Serif"),
    size: 12pt,
    lang: "pt",
  )

  // Espaçamento entre linhas - 1.5
  set par(
    leading: 0.65em,
    justify: true,
    first-line-indent: 1.25cm,
  )

  // Configuração de títulos
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    set text(size: 12pt, weight: "bold")
    set block(above: 1.5em, below: 1em)
    upper(it)
  }

  show heading.where(level: 2): it => {
    set text(size: 12pt, weight: "regular")
    set block(above: 1.5em, below: 1em)
    it
  }

  show heading.where(level: 3): it => {
    set text(size: 12pt, weight: "regular")
    set block(above: 1.5em, below: 1em)
    it
  }

  // Notas de rodapé - 10pt, espaçamento simples
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(leading: 0.4em)

  // ==================== CAPA ====================
  {
    set align(center)
    set par(first-line-indent: 0cm)

    text(size: 14.5pt)[
      UNIVERSIDADE ESTADUAL DE PONTA GROSSA\
      #setor\
      #departamento\
      #curso
    ]

    v(4cm)

    text(size: 14.5pt, upper(autor))

    v(4cm)

    text(size: 14.5pt, upper(titulo))

    v(1fr)

    text(size: 14.5pt)[
      #local\
      #ano
    ]

    pagebreak()
  }

  // ==================== FOLHA DE ROSTO ====================
  // Contagem de páginas inicia na folha de rosto (ABNT), mas sem exibir
  counter(page).update(1)
  {
    set align(center)
    set par(first-line-indent: 0cm)

    v(3cm)

    text(size: 14.5pt, upper(autor))

    v(6cm)

    text(size: 14.5pt, upper(titulo))

    v(2cm)

    // Nota de apresentação alinhada à direita
    align(right)[
      #box(width: 8cm)[
        #set align(left)
        #set par(justify: true, first-line-indent: 0cm)
        #text(size: 14.5pt)[
          #nota-apresentacao
        ]

        #v(0.5cm)

        #for (i, orientador) in orientadores.enumerate() [
          #text(size: 14.5pt)[
            #if orientadores.len() == 1 [
              *Orientador:* #orientador
            ] else if i == 0 [
              *Orientador:* #orientador
            ] else [
              *Coorientador:* #orientador
            ]
          ]
          #if i < orientadores.len() - 1 [
            #v(0.3cm)
          ]
        ]
      ]
    ]

    v(1fr)

    text(size: 14.5pt)[
      #local\
      #ano
    ]

    pagebreak()
  }

  // ==================== DEDICATÓRIA ====================
  if dedicatoria != none {
    set par(first-line-indent: 0cm)

    v(1fr)

    align(right)[
      #box(width: 8cm)[
        #set align(left)
        #set par(justify: true, first-line-indent: 0cm)
        #set text(style: "italic")
        #dedicatoria
      ]
    ]

    pagebreak()
  }

  // ==================== AGRADECIMENTOS ====================
  if agradecimentos != none {
    set par(first-line-indent: 0cm)

    align(center)[
      #text(size: 16pt, weight: "bold")[AGRADECIMENTOS]
    ]

    v(1cm)

    set par(first-line-indent: 0cm, justify: true)

    agradecimentos

    pagebreak()
  }

  // ==================== EPÍGRAFE ====================
  if epigrafe != none {
    set par(first-line-indent: 0cm)

    v(1fr)

    align(right)[
      #box(width: 10cm)[
        #set align(left)
        #set par(justify: true, first-line-indent: 0cm)
        #set text(style: "italic")
        #epigrafe
      ]
    ]

    pagebreak()
  }

  // ==================== RESUMO ====================
  if resumo != none {
    set par(first-line-indent: 0cm)

    align(center)[
      #text(size: 16pt, weight: "bold")[RESUMO]
    ]

    v(1cm)

    set par(first-line-indent: 0cm, justify: true, leading: 0.4em)

    resumo

    v(1cm)

    text(weight: "bold")[Palavras-chave: ] + palavras-chave.join(". ") + "."

    pagebreak()
  }

  // ==================== ABSTRACT ====================
  if abstract != none {
    set par(first-line-indent: 0cm)

    align(center)[
      #text(size: 16pt, weight: "bold")[ABSTRACT]
    ]

    v(1cm)

    set par(first-line-indent: 0cm, justify: true, leading: 0.4em)

    abstract

    v(1cm)

    text(weight: "bold")[Keywords: ] + keywords.join(". ") + "."

    pagebreak()
  }

  // ==================== LISTA DE ABREVIATURAS E SIGLAS ====================
  if lista-abreviaturas != none {
    set par(first-line-indent: 0cm)

    align(center)[
      #text(size: 16pt, weight: "bold")[LISTA DE ABREVIATURAS E SIGLAS]
    ]

    v(1cm)

    for (sigla, significado) in lista-abreviaturas [
      #sigla #h(1em) -- #h(1em) #significado\
    ]

    pagebreak()
  }

  // ==================== LISTA DE ILUSTRAÇÕES ====================
  {
    let deve-gerar = lista-ilustracoes
    if lista-ilustracoes == auto {
      context {
        let figs = query(figure.where(kind: image))
        if figs.len() > 0 {
          align(center)[
            #text(size: 16pt, weight: "bold")[LISTA DE ILUSTRAÇÕES]
          ]

          v(1cm)

          outline(
            title: none,
            target: figure.where(kind: image),
          )

          pagebreak()
        }
      }
    } else if deve-gerar == true {
      align(center)[
        #text(size: 16pt, weight: "bold")[LISTA DE ILUSTRAÇÕES]
      ]

      v(1cm)

      outline(
        title: none,
        target: figure.where(kind: image),
      )

      pagebreak()
    }
  }

  // ==================== LISTA DE QUADROS ====================
  {
    let deve-gerar = lista-quadros
    if lista-quadros == auto {
      context {
        let quads = query(figure.where(kind: "quadro"))
        if quads.len() > 0 {
          align(center)[
            #text(size: 16pt, weight: "bold")[LISTA DE QUADROS]
          ]

          v(1cm)

          outline(
            title: none,
            target: figure.where(kind: "quadro"),
          )

          pagebreak()
        }
      }
    } else if deve-gerar == true {
      align(center)[
        #text(size: 16pt, weight: "bold")[LISTA DE QUADROS]
      ]

      v(1cm)

      outline(
        title: none,
        target: figure.where(kind: "quadro"),
      )

      pagebreak()
    }
  }

  // ==================== LISTA DE TABELAS ====================
  {
    let deve-gerar = lista-tabelas
    if lista-tabelas == auto {
      context {
        let tabs = query(figure.where(kind: table))
        if tabs.len() > 0 {
          align(center)[
            #text(size: 16pt, weight: "bold")[LISTA DE TABELAS]
          ]

          v(1cm)

          outline(
            title: none,
            target: figure.where(kind: table),
          )

          pagebreak()
        }
      }
    } else if deve-gerar == true {
      align(center)[
        #text(size: 16pt, weight: "bold")[LISTA DE TABELAS]
      ]

      v(1cm)

      outline(
        title: none,
        target: figure.where(kind: table),
      )

      pagebreak()
    }
  }

  // ==================== SUMÁRIO ====================
  {
    align(center)[
      #text(size: 16pt, weight: "bold")[SUMÁRIO]
    ]

    v(1cm)

    // Títulos de nível 1 em negrito no sumário
    show outline.entry.where(level: 1): it => {
      text(weight: "bold", it)
    }

    outline(
      title: none,
      depth: 3,
      indent: 1em,
    )

    pagebreak()
  }

  // ==================== CORPO DO DOCUMENTO ====================
  // Numeração visível a partir da primeira página textual
  set page(
    numbering: "1",
    number-align: right + top,
  )

  // ==================== CONFIGURAÇÃO DE FIGURAS, TABELAS E QUADROS (ABNT) ====================

  // Configuração para TABELAS (caption em cima, alinhado à esquerda, separator "---")
  // Tabelas ABNT: abertas nas laterais
  show figure.where(kind: table): set figure.caption(position: top, separator: [ --- ])

  show figure.where(kind: table): it => {
    set par(leading: 0.4em, first-line-indent: 0cm)
    set align(left)
    set text(size: 10pt)
    it
    v(0.3em, weak: true)
    text(size: 10pt)[Fonte: #fonte-padrao]
  }

  // Configuração para QUADROS (caption em cima, alinhado à esquerda, separator "---")
  // Quadros ABNT: fechados em todos os lados
  show figure.where(kind: "quadro"): set figure.caption(position: top, separator: [ --- ])

  show figure.where(kind: "quadro"): it => {
    set par(leading: 0.4em, first-line-indent: 0cm)
    set align(left)
    set text(size: 10pt)
    it
    v(0.3em, weak: true)
    text(size: 10pt)[Fonte: #fonte-padrao]
  }

  // Configuração para IMAGENS (caption em cima, alinhado à esquerda, separator "---")
  show figure.where(kind: image): set figure.caption(position: top, separator: [ --- ])

  show figure.where(kind: image): it => {
    set par(leading: 0.4em, first-line-indent: 0cm)
    set align(left)
    set text(size: 10pt)
    it
    v(0.3em, weak: true)
    text(size: 10pt)[Fonte: #fonte-padrao]
  }

  // Configuração para referências bibliográficas
  show bibliography: set text(size: 12pt)
  show bibliography: set par(leading: 0.4em, first-line-indent: 0cm)

  body
}
