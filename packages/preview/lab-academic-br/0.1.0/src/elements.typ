// ============================================================
// src/elements.typ
// Elementos pré-textuais e configurações de listas e rodapé
// ============================================================

#let capa(
  instituicao: "[FACULDADE] – [SIGLA, se houver]",
  curso: "CURSO DE X",
  autor: "NOME COMPLETO DO ESTUDANTE",
  titulo: "TÍTULO:",
  subtitulo: "",
  local: "Cidade - [SIGLA do estado]",
  ano: "2026",
) = page(numbering: none)[
  #align(center)[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em)
    #text(weight: "bold")[#instituicao] \
    #text(weight: "bold")[#curso]
    #v(4cm)
    #autor
    #v(1fr)
    #text(weight: "bold")[#titulo] \
    #text(weight: "regular")[#subtitulo]
    #v(1fr)
    #local \
    #ano
  ]
]

#let folha-de-rosto(
  instituicao: "[FACULDADE] – [SIGLA, se houver]",
  curso: "CURSO DE X",
  autor: "NOME COMPLETO DO ESTUDANTE",
  titulo: "TÍTULO:",
  subtitulo: "",
  natureza: "Projeto de pesquisa apresentado à disciplina Metodologia Científica, do curso de X da [FACULDADE}, como requisito parcial para obtenção de nota.",
  orientador: "Prof. Me. Silvio Santos",
  local: "Cidade - [SIGLA do estado]",
  ano: "2026",
) = page(numbering: none)[
  #align(center)[
    #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em)
    #text(weight: "bold")[#instituicao] \
    #text(weight: "bold")[#curso]
    #v(3cm)
    #autor
    #v(4cm)
    #text(weight: "bold")[#titulo] \
    #text(weight: "regular")[#subtitulo]
    #v(2cm)
    #grid(
      columns: (1fr, 8cm),
      [],
      [
        #set align(left)
        #set par(first-line-indent: (amount: 0pt, all: true), leading: 0.5em, justify: true)
        // Bloco de natureza: 10pt
        #text(size: 10pt)[
          #natureza
          #v(1em)
          Orientador: #orientador
        ]
      ],
    )
    #v(1fr)
    #local \
    #ano
  ]
]

#let sumario() = page(numbering: none)[
  #align(center)[#text(weight: "bold")[SUMÁRIO]]
  #v(2em)
  #set par(first-line-indent: (amount: 0pt, all: true))
  #outline(title: none, indent: auto)
]

// Usadas com #show: configurar-rodape / #show: configurar-alineas
#let configurar-rodape(corpo) = {
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(leading: 0.5em, first-line-indent: (amount: 0pt, all: true), justify: true)
  corpo
}

#let configurar-alineas(corpo) = {
  set enum(numbering: "a)", indent: 1.25cm, body-indent: 0.5cm)
  corpo
}
