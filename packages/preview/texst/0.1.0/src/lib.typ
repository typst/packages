#import "@preview/ctheorems:1.1.3": *

#let default_style = (
  page_margin: (x: 1.2in, y: 1.2in),
  page_numbering: "1",
  body_font: "New Computer Modern",
  body_size: 11pt,
  body_top_edge: 0.7em,
  body_bottom_edge: -0.3em,
  paragraph_leading: 1em,
  paragraph_indent: 1.8em,
  heading_numbering: "1.",
  heading_size: 1em,
  heading_weight: "bold",
  heading_level1_size: 0.9em,
  table_text_size: 0.8em,
  table_leading: 0.65em,
  table_top_edge: 0.35em,
  table_bottom_edge: -0.3em,
  block_above: 1.5em,
  block_below: 1.5em,
  footnote_numbering: "[1]",
  accent_main: rgb(0, 0, 100),
)

#let nneq(eq) = math.equation(block: true, numbering: none, eq)

#let caption_note(body) = align(left)[
  #pad(x: 2em, y: 0em)[
    #par(leading: 0.2em)[
      #text(size: 0.9em)[*Note:* #body]
    ]
  ]
]

#let caption_with_note(title, note) = [#title #caption_note(note)]

#let table_note(body) = align(left)[
  #text(size: 0.9em)[#emph(body)]
]

#show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem")
#let proof = thmproof("proof", "Proof")
#let prop = thmbox(
  "prop",
  "Proposition",
  inset: (x: 2em, y: .5em),
  base_level: 0,
  base: "prop",
  titlefmt: smallcaps,
  bodyfmt: body => [#body],
).with(numbering: "1")

#let lem = thmbox(
  "lem",
  "Lemma",
  inset: (x: 2em, y: .5em),
  base_level: 0,
  base: "lem",
  titlefmt: smallcaps,
  bodyfmt: body => [#body],
).with(numbering: "1")

#let rem = thmbox(
  "rem",
  "Remark",
  inset: (x: 2em, y: .5em),
  base_level: 0,
  base: "rem",
  titlefmt: smallcaps,
  bodyfmt: body => [#body],
).with(numbering: "1")

#let asp = thmbox(
  "asp",
  "Assumption",
  inset: (x: 2em, y: .5em),
  base_level: 0,
  base: "asp",
  titlefmt: smallcaps,
  bodyfmt: body => [#body],
).with(numbering: "1")

#let paper(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  abstract: none,
  style: none,
  doc,
) = {
  let s = if style == none {
    default_style
  } else {
    default_style + style
  }

  set page(margin: s.page_margin, numbering: s.page_numbering)
  set par(
    leading: s.paragraph_leading,
    first-line-indent: s.paragraph_indent,
    justify: true,
  )
  set text(
    font: s.body_font,
    size: s.body_size,
    top-edge: s.body_top_edge,
    bottom-edge: s.body_bottom_edge,
  )

  set math.equation(numbering: "(1)")
  set table(align: (x, _) => if x == 0 { left } else { center })
  set figure(numbering: "1", placement: auto)

  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      numbering(el.numbering, ..counter(eq).at(el.location()))
    } else {
      it
    }
  }

  set quote(block: true)

  set heading(numbering: s.heading_numbering)
  show heading: set block(above: 2em, below: 1em)
  show heading: set par(leading: 0.3em)
  show heading: set text(size: s.heading_size, weight: s.heading_weight)
  show heading: it => {
    if it.level == 1 {
      smallcaps(align(center, text(size: s.heading_level1_size, it)))
    } else {
      it
    }
  }

  set enum(indent: 1.8em)
  show enum: set block(above: 1em, below: 1em)

  show table: set text(size: s.table_text_size)
  show table: set par(leading: s.table_leading)
  show table: set text(top-edge: s.table_top_edge, bottom-edge: s.table_bottom_edge)
  show figure: set block(below: 0em)
  set block(above: s.block_above, below: s.block_below)
  show figure: set align(center)
  show table: set align(center)
  show figure.where(kind: table): set align(center)
  show figure.where(body: it => if it.func() == table { true } else { false }): set align(center)

  show link: set text(s.accent_main)
  show ref: set text(s.accent_main)
  show cite: set text(s.accent_main)
  show footnote: set text(s.accent_main)
  show footnote: set text(weight: "bold")
  set footnote(numbering: s.footnote_numbering)

  v(4em)
  set align(center)
  par(leading: .5em)[
    #text(1.2em)[#title]\\
    #if subtitle != none { text(1em)[#subtitle] }
  ]

  let count = authors.len()
  if count > 0 {
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 24pt,
      ..authors.map(author => [#text(author.name)]),
    )
  }

  if date != none {
    text(date)
  }

  set align(left)
  if abstract != none {
    pad(
      x: 3em,
      par(
        leading: 0.4em,
        text(0.9em, [#smallcaps("Abstract.") #abstract]),
      ),
    )
  }

  doc
}
