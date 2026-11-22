// Capa tipográfica geométrica, integrada à paleta do documento.
#import "settings.typ": settings
#import "layout.typ": page-background, page-footer, paper-margin
#import "@preview/hydra:0.6.3": anchor

#let capa(
  titulo: "Caderno de estudos",
  subtitulo: none,
  concurso: none,
  orgao: none,
  autor: none,
  ano: none,
) = context {
  let s = settings.get()
  let tema = s.theme

  // Inicia a capa sem criar uma página vazia quando chamada no começo do arquivo.
  pagebreak(weak: true)
  set page(
    margin: 2.6cm,
    header: none,
    footer: none,
    background: {
      rect(width: 100%, height: 100%, fill: tema.page)
      place(
        top + left,
        dx: -2.6cm,
        rect(width: 0.7cm, height: 100%, fill: tema.strong),
      )
      place(
        top + right,
        dx: -2.6cm,
        dy: 2.6cm,
        rect(width: 1.3cm, height: 1.3cm, fill: tema.theorem.theorem),
      )
      place(
        top + right,
        dx: -1.05cm,
        dy: 2.6cm,
        rect(width: 0.32cm, height: 1.3cm, fill: tema.theorem.definition),
      )
      place(
        bottom + right,
        dx: -2.6cm,
        dy: -2.6cm,
        line(start: (0%, 0%), end: (100%, 0%), stroke: 1pt + tema.line),
      )
    },
  )

  set par(justify: false)
  set text(font: s.fonts.body, fill: tema.text)
  block(width: 100%)[
    #text(font: s.fonts.sans, size: 9pt, weight: "bold", fill: tema.strong)[CADERNO DE ESTUDOS]
    #v(4.0cm)
    #line(length: 3.2cm, stroke: 2pt + tema.strong)
    #v(0.65cm)
    #text(font: s.fonts.sans, size: 31pt, weight: "bold", fill: tema.text)[#titulo]
    #if subtitulo != none {
      v(0.55cm)
      text(font: s.fonts.sans, size: 15pt, fill: tema.muted)[#subtitulo]
    }
    #v(3.3cm)
    #if concurso != none {
      text(font: s.fonts.sans, size: 10pt, weight: "bold", fill: tema.strong)[CONCURSO]
      linebreak()
      text(font: s.fonts.body, size: 13pt)[#concurso]
      v(0.65cm)
    }
    #if orgao != none {
      text(font: s.fonts.sans, size: 10pt, weight: "bold", fill: tema.strong)[ÓRGÃO]
      linebreak()
      text(font: s.fonts.body, size: 13pt)[#orgao]
      v(0.65cm)
    }
    #if autor != none {
      text(font: s.fonts.sans, size: 10pt, weight: "bold", fill: tema.strong)[ESTUDANTE]
      linebreak()
      text(font: s.fonts.body, size: 13pt)[#autor]
    }
    #if ano != none {
      v(0.3cm)
      text(font: s.fonts.sans, size: 11pt, fill: tema.muted)[#ano]
    }
  ]

  // Fecha a capa e restaura o layout normal usado pelo restante do documento.
  pagebreak()
  set page(
    fill: tema.page,
    margin: paper-margin(s.margin, s.texts),
    background: page-background(s.paper, s.margin, s.side, s.fonts, tema),
    footer: page-footer(s.body, s.margin, s.side, s.fonts, tema),
    header: anchor(),
  )
}
