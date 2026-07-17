// ==========================================
// PLANTILLA PRINCIPAL — FUNCIÓN tsiib()
// ==========================================

#import "links.typ": configurar-links

#let kinds-ref = ("teo", "prob", "ej", "def", "lema", "image", "table", "code")

#let tsiib(
  title: "Título del Documento",
  subtitle: none,
  author: none,
  affiliation: none,
  email: none,
  date: datetime.today().display("[day] de [month repr:long] de [year]"),
  abstract: none,
  keywords: none,
  bib: none,
  body
) = {
  {
    set document(title: title, author: author)
    if keywords != none {
      set document(keywords: keywords)
    }
  }

  set page(
    paper: "us-letter",
    margin: (x: 3cm, y: 3cm),
    header: context {
      if counter(page).get().at(0) > 1 {
        align(right)[#text(9pt, style: "italic", fill: luma(0))[#title]]
      }
    },
    footer: context {
      if counter(page).get().at(0) > 1 {
        align(center)[#text(9pt, fill: luma(0))[#counter(page).get().at(0)]]
      }
    },
  )

  set text(
    font: "New Computer Modern",
    size: 11pt,
    lang: "es",
  )

  show math.equation: set text(font: "New Computer Modern Math")

  set par(justify: true, leading: 0.65em, first-line-indent: 1.5em)

  set heading(numbering: "1.1")

  show heading: set par(first-line-indent: 0pt)
  show heading: it => block(above: 2.5em, below: 1.5em)[#it]

  show heading.where(level: 1): it => {
    counter(figure.where(kind: "teo")).update(0)
    counter(figure.where(kind: "prob")).update(0)
    counter(figure.where(kind: "ej")).update(0)
    counter(figure.where(kind: "def")).update(0)
    counter(figure.where(kind: "lema")).update(0)
    counter(figure.where(kind: "image")).update(0)
    counter(figure.where(kind: "table")).update(0)
    counter(figure.where(kind: "code")).update(0)
    counter(math.equation).update(0)
    text(size: 14pt, weight: "bold")[#it]
  }

  show heading.where(level: 2): it => {
    text(size: 12pt, weight: "bold")[#it]
  }

  show heading.where(level: 3): it => {
    text(size: 11pt, weight: "bold")[#it]
  }

  // Links azules (cites y links; el ref se maneja abajo)
  configurar-links()

  // Referencias con jerarquía completa de headings + color azul
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind in kinds-ref {
      let k = el.kind
      let sup = el.supplement
      text(fill: rgb("#2563eb"))[
        #link(el.location())[#sup #context {
          let h = counter(heading).at(el.location())
          let n = counter(figure.where(kind: k)).at(el.location()).first()
          if h.len() > 0 and h.at(0) > 0 {
            str(h.at(0)) + "." + str(n)
          } else {
            str(n)
          }
        }]
      ]
    } else {
      text(fill: rgb("#2563eb"))[#it]
    }
  }

  // Entornos: override centrado de figure
  let kinds = ("teo", "prob", "ej", "def", "lema")
  for k in kinds {
    show figure.where(kind: k): it => align(left, it.body)
  }

  // ── Portada ──
  align(center)[
    #v(3em)
    #block(text(weight: "bold", size: 2.2em)[#title])
    #if subtitle != none {
      v(1em)
      block(text(weight: "medium", size: 1.4em)[#subtitle])
    }
    #v(4em)
    #if author != none { block(text(size: 1.2em)[#author]) }
    #if affiliation != none {
      v(0.2em)
      block(text(size: 1.1em)[#affiliation])
    }
    #if email != none {
      v(0.2em)
      link("mailto:" + email)
    }
    #if date != none {
      v(2em)
      block(text(size: 1.1em)[#date])
    }
  ]

  v(4em)
  if abstract != none {
    align(center)[
      #block(width: 85%)[
        *Resumen* \
        #v(0.8em)
        #align(left)[#abstract]
      ]
    ]
    v(3em)
  }

  // Índice en azul
  set text(fill: rgb("#2563eb"))
  outline(
    title: [Índice],
    indent: auto,
    depth: 3,
  )
  set text(fill: black)

  pagebreak(weak: true)

  body

  // ── Bibliografía ──
  if bib != none {
    pagebreak(weak: true)
    set heading(numbering: none)
    bib
  }
}
