// A4 note document mode — self-contained, no theme/touying dependency.

#let xwysyy-note(
  doc,
  title: none,
  subtitle: none,
  font: ("Times New Roman", "Noto Serif CJK SC"),
  code-font: "Maple Mono",
  base-size: 10pt,
  lang: "en",
) = [
  #set text(
    font: font,
    lang: lang,
    size: base-size,
    weight: "regular",
    style: "normal",
  )

  #set page(
    paper: "a4",
    columns: 1,
    margin: (x: 2cm, y: 2cm),
    numbering: "1 / 1",
  )
  #set par(justify: true, leading: 0.8em)
  #set heading(numbering: "1.1")

  // Title block
  #if title != none {
    align(center)[
      #v(1em)
      #text(size: 1.6em, weight: "bold", title)
      #if subtitle != none {
        v(0.3em)
        text(size: 0.9em, fill: luma(120), subtitle)
      }
      #v(1em)
    ]
  }

  // Quote decoration
  #show ">|": it => [
    #box(baseline: 0.4em, rect(width: 0.2em, height: 1.2em, fill: luma(200)))
    #h(0.5em)
  ]

  // Headings
  #show heading.where(level: 1): it => {
    v(0.5em)
    text(size: 1.25em, fill: luma(30), weight: "bold", it.body)
    v(-0.6em)
    line(length: 100%, stroke: 0.5pt + luma(200))
    v(0.3em)
  }
  #show heading.where(level: 2): it => {
    v(0.3em)
    text(size: 1.15em, fill: luma(50), weight: "bold", it.body)
    v(0.1em)
  }
  #show heading.where(level: 3): it => {
    v(0.2em)
    text(size: 1.05em, fill: luma(60), weight: "bold", it.body)
    v(0.1em)
  }
  #show heading.where(level: 4): it => text(
    fill: luma(70), size: 1em, weight: "bold", it.body,
  )

  // Bold
  #show strong: it => text(weight: "bold", it.body)

  // List markers
  #set list(marker: (text(fill: luma(120), [❖]), text(fill: luma(160), [⬦]), text(fill: luma(160), [–])), spacing: 1em, indent: 0.5em, body-indent: 0.8em)
  #set enum(spacing: 1em, indent: 0.5em)

  // Italic — CJK skew (guard for non-text content like links/math/code)
  #show emph: it => {
    if type(it.body) == content and it.body.has("text") {
      for c in it.body.text {
        box(skew(ax: -8deg, c))
      }
    } else {
      box(skew(ax: -8deg, it.body))
    }
  }

  // Figure captions
  #show figure.caption: it => {
    set text(size: 0.85em, fill: luma(100))
    v(0.3em)
    it
  }
  #show figure.where(kind: table): set figure.caption(position: top)

  // Code blocks
  #show raw.where(block: true): it => {
    set text(font: code-font, size: 0.9em)
    block(width: 100%, fill: luma(248), inset: 0.6em, radius: 0.3em, it)
  }
  #show raw.where(block: false): it => {
    set text(font: code-font)
    box(fill: luma(245), inset: (x: 0.3em, y: 0.15em), radius: 0.2em, baseline: 0.15em, it)
  }

  // Links
  #show link: underline
  #show link: it => { set text(fill: rgb("#4271ae")); it }

  // Arrow decorations
  #show "<==>": [$arrow.l.r.double.long$]
  #show "<=>": [$<=>$]
  #show "-->": [$-->$]
  #show "<--": [$<--$]
  #show "==>": [$==>$]
  #show "<==": [$arrow.l.double.long$]
  #show "->": [$->$]
  #show "<-": [$<-$]
  #show "=>": [$=>$]
  #show "<=": [$arrow.l.double$]
  #show "|->": [$|->$]

  // Tables
  #set table(
    stroke: 0.5pt + luma(200),
    gutter: 0em,
    align: center,
    fill: (x, y) => if y == 0 { luma(240) } else { none },
  )
  #show table.cell: it => {
    if it.y == 0 {
      set text(weight: "bold")
      it
    } else { it }
  }

  #doc
]
