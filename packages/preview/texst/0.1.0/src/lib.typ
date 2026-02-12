#import "@preview/ctheorems:1.1.3": *
#import "@preview/cetz:0.4.1"

// =============================================================================
// BASIC SETTINGS (edit here)
// =============================================================================
#let page_margin = (x: 1.2in, y: 1.2in)
#let page_numbering = "1"

#let body_font = "New Computer Modern"
#let body_size = 11pt
#let body_top_edge = 0.7em
#let body_bottom_edge = -0.3em

#let par_leading = 1em
#let par_first_indent = 1.8em

#let heading_numbering = "1."
#let heading_size = 1em
#let heading_weight = "bold"
#let heading_level1_size = 0.9em

#let table_text_size = 0.8em
#let table_leading = 0.65em
#let table_top_edge = 0.35em
#let table_bottom_edge = -0.3em

#let block_above = 1.5em
#let block_below = 1.5em

#let footnote_numbering = "[1]"

#let cmain = rgb(0,0,100)
#let csub = rgb("#8b0000")

// =============================================================================
// UTILITIES
// =============================================================================
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
#let proof = thmproof(
  "proof", "Proof"
)
#let prop = thmbox(
 "prop",
 "Proposition",
 inset: (x:2em, y:.5em),
 base_level: 0,
 base: "prop",
 titlefmt: smallcaps,
 bodyfmt: body => [
   #body
 ]
).with(numbering: "1")
#let lem = thmbox(
 "lem",
 "Lemma",
 inset: (x:2em, y:.5em),
 base_level: 0,
 base: "lem",
 titlefmt: smallcaps,
 bodyfmt: body => [
   #body
 ]
).with(numbering: "1")
#let rem = thmbox(
 "rem",
 "Remark",
 inset: (x:2em, y:.5em),
 base_level: 0,
 base: "rem",
 titlefmt: smallcaps,
 bodyfmt: body => [
   #body
 ]
).with(numbering: "1")
#let ass = thmbox(
 "ass",
 "Assumption",
 inset: (x:2em, y:.5em),
 base_level: 0,
 base: "ass",
 titlefmt: smallcaps,
 bodyfmt: body => [
   #body
 ]
).with(numbering: "1")

#let paper(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  abstract: none,
  doc,
) = {
  set page(
    margin: page_margin,
    numbering: page_numbering
  )
  
  set par(
    leading: par_leading,
    first-line-indent: par_first_indent,
    justify: true
  )
  
  set text(
    font: body_font,
    size: body_size,
    top-edge: body_top_edge,
    bottom-edge: body_bottom_edge
  )

  set math.equation(numbering: "(1)")
  set table(align: (x, _) => if x == 0 { left } else { center })
  set figure(numbering: "1")
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
    } else {
      // Other references as usual.
      it
    }
  }
  
  set bibliography(style: "american-political-science-association")
  show bibliography: set par(first-line-indent: 0em)

  set quote(block: true)

  set heading(numbering: heading_numbering)
  show heading: set block(above: 2em, below: 1em)
  show heading: set par(leading: 0.3em)
  show heading: set text(size: heading_size, weight: heading_weight)
  //show heading: set text(font: "PT Sans", weight: "bold")
  // Center first level headings only
  show heading: it => {
    if it.level == 1 {
      smallcaps(align(center, text(size: heading_level1_size, it)))
    } else {
      it
    }
  }

  set enum(indent: 1.8em)
  show enum: set block(above: 1em, below: 1em)

  show table: set text(size: table_text_size)
  show table: set par(leading: table_leading)
  show table: set text(top-edge: table_top_edge, bottom-edge: table_bottom_edge)
  show figure: set block(below: 0em)
  set block(above: block_above, below: block_below)
  show figure: set align(center)
  // Set all tables to be centered
  show table: set align(center)
  // Also center table captions
  show figure.where(kind: table): set align(center)
  // Center figures with tables inside them
  show figure.where(body: it => {
    if it.func() == table { true } else { false }
  }): set align(center)
  
  //show figure.caption: set text(font: "PT Sans", weight: "regular")
  set figure(placement: auto)

  show link: set text(rgb(0,0,100))
  show ref: set text(rgb(0,0,100))
  show cite: set text(rgb(0,0,100))
  show footnote: set text(rgb(0,0,100))
  show footnote: set text(weight:"bold")
  //show footnote.entry: set par(leading: 1em)
  //set footnote.entry(gap: 1em)
  set footnote(numbering: footnote_numbering)

  v(4em)
  set align(center)
  par(leading: .5em)[#text(1.2em)[#title]\ #text(1em)[#subtitle]]

  let count = authors.len()
  let ncols = calc.min(count, 3)
  grid(
    columns: (1fr,) * ncols,
    row-gutter: 24pt,
    ..authors.map(author => [
      #text(author.name) \
      //#text(0.8em, author.affiliation) \
      //#text(0.8em, link("mailto:" + author.email))
    ]),
  )

  text(date)

  set align(left)
  if abstract != none {
  pad(x: 3em,
  par(leading: 0.4em, 
  text(0.9em,
    [#smallcaps("Abstract.") #abstract]
  )))
  }
    
  doc
}
