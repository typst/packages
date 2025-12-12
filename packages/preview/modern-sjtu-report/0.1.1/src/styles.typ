#let make_title(name: str) = align(center)[
  #text(size: 20pt, weight: "bold")[#name]
  #v(1em)
]

#let header_left(ident_color: str, header_logo: bool, experiment_name: str) = {
  grid(
    columns: (1fr, auto),
    text(size: 10pt, weight: "bold")[#experiment_name],
    if header_logo {
      if ident_color == "blue" {
        image("./assets/SJTU_header_blue.png", height: 0.5cm)
      } else if ident_color == "red" {
        image("./assets/SJTU_header_red.png", height: 0.5cm)
      }
    } else {
      []
    },
  )
}

#let header_right(ident_color: str, header_logo: bool) = {
  let headings = query(selector(heading.where(level: 1)).before(here())).last().body

  grid(
    columns: (auto, 1fr),
    if header_logo {
      if ident_color == "blue" {
        image("./assets/SJTU_header_blue.png", height: 0.5cm)
      } else if ident_color == "red" {
        image("./assets/SJTU_header_red.png", height: 0.5cm)
      }
    } else {
      []
    },
    align(right)[#text(size: 10pt, weight: "bold")[#headings]],
  )
}

#let general_layout(
  ident_color: str,
  header_logo: bool,
  experiment_name: str,
  article_fonts: array,
  code_fonts: array,
  content,
) = {
  counter(page).update(1)
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm),
    header: context {
      if calc.odd(counter(page).get().first()) {
        header_left(ident_color: ident_color, header_logo: header_logo, experiment_name: experiment_name)
      } else {
        header_right(ident_color: ident_color, header_logo: header_logo)
      }
      v(-0.25cm)
      line(length: 100%, stroke: 0.5pt + black)
    },
    footer: context align(center)[
      第 #counter(page).display() 共 #counter(page).final().last() 页
    ],
  )

  set text(font: article_fonts)

  set heading(numbering: "1.1")

  set par(first-line-indent: (amount: 2em, all: true))

  set table(stroke: (x, y) => (
    top: if y == 0 { 1pt } else if y == 1 { 0.5pt } else { 0pt },
    bottom: 1pt,
  ))

  show figure.where(kind: table): it => {
    align(center)[
      #if it.caption != none [
        #text(size: 9pt, weight: "bold")[
          表 #counter(figure.where(kind: table)).display(): #it.caption.body
        ]
      ]
      #v(-0.5em)
      #it.body
    ]
  }
  show figure.where(kind: image): it => {
    align(center)[
      #v(-0.5em)
      #it.body
      #if it.caption != none [
        #text(size: 9pt, weight: "bold")[
          图 #counter(figure.where(kind: image)).display(): #it.caption.body
        ]
      ]
    ]
  }
  show figure.where(kind: "pseudocode-list"): it => {
    align(left)[
      #line(length: 100%, stroke: 0.5pt + black)
      #v(-0.75em)
      #if it.caption != none [
        #text(size: 9pt, weight: "bold")[
          算法 #counter(figure.where(kind: "pseudocode-list")).display(): #it.caption.body
        ]
      ]
      #v(-0.75em)
      #line(length: 100%, stroke: 0.25pt + black)
      #v(-1.5em)
      #it.body
      #v(-1.5em)
      #line(length: 100%, stroke: 0.5pt + black)
    ]
  }

  show raw: it => {
    text(font: code_fonts)[#it]
  }
  show raw.where(block: true): it => {
    align(right)[#text(size: 8pt)[#it.lang]]
    v(-0.75em)
    line(length: 100%, stroke: 0.5pt + black)
    block(
      it,
    )
    line(length: 100%, stroke: 0.5pt + black)
  }

  content
}

