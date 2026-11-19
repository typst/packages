/* Package Entrypoint */
#import "@preview/booktabs:0.0.4": booktabs-default-table-style
#import "@preview/droplet:0.3.1"

#import "@preview/tudelft-tools-novanext:0.1.0": *
#import "edge-indices.typ": *
#import "@preview/elembic:1.1.1" as e
#import "@preview/nomos:0.1.0": print-nomenclature

#let subtitle = state("subtitle")
#let in-outline = state("in-outline", false)
#let outline-alt(long, short) = context if in-outline.get() { short } else { long }

#let chapter-heading(
  it,
  number-args: (),
  text-args: (),
) = {
  pagebreak(to: "odd", weak: true)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)

  if it.numbering != none {
    align(right, text(
      size: 10em,
      weight: 300,
      fill: thumb-index-color,
      ..number-args,
      counter(heading).display(it.numbering)
    ))
    v(-10em)
  }
  text(
    hyphenate: false,
    size: 2em,
    weight: 600,
    fill: tud-blue,
    ..text-args,
    it.body
  )
}

#let thesis(it) = {
  show math.integral: math.limits.with(inline: false)
  show: set-fonts
  show title: set par(justify: false)
  show title: set text(
    hyphenate: false)
  set heading(numbering: "1.1")
  show heading: set par(justify: false)
  show heading: set text(
    hyphenate: false,
    //fill: tud-blue,
    weight: 600,
  )
  show heading.where(level: 2): set text(
    font: "Roboto Slab",
    weight: 500,
  )
  show heading.where(level: 3): set text(
    weight: 600,
    1.12em
  )
  show heading.where(level: 1): chapter-heading.with(
    number-args: arguments(
      weight: "bold",
      font: "Roboto Slab",
      fill: tud-blue-50,
    ),
    text-args: arguments(
      font: "Roboto Slab",
      weight: 400,
    )
  )

  set outline(title: none)
  show outline: set heading(level: 2, numbering: none)
  show outline: x => {
    heading(level:1, "Contents")
    in-outline.update(true)
    box()
    context(v(-par.leading))
    x
    in-outline.update(false)
  }

  show figure.caption: it => context box(
    align(left)[#text(fill: tud-blue)[*#it.supplement~#it.counter.display()#it.separator*]#it.body
    ]
  )

  set math.equation(numbering: (..nums) =>
    numbering("(1.1)", counter(heading).get().first(), ..nums)
  )
  set figure(numbering: (..num) =>
    numbering("1.1", counter(heading).get().first(), num.pos().first())
  )
  show figure: set block(spacing: 2.0em)
  set figure(gap: 1.4em)
  show figure.where(kind: table): set figure.caption(position: top)
  show: booktabs-default-table-style

  set bibliography(title: "References")

  set page(
    height: 24cm,
    width: 17cm,
    header: thesis-header(),
    footer: thesis-footer(),
    background: thumb-index(height: 2cm),
  )

  it
}

#let standalone(preamble: it => it, 
  doc) = {
  context(if document.title == none {
    show: preamble
    doc
  } else {
    doc
  })
}

#let sub-document = standalone.with(preamble: doc => {
  set document(title: "")
  /* alternatively:
  show: thesis
  */
  set page(paper: "a4")
  set page(numbering: "1")
  set math.equation(numbering: "(1)")
  show heading.where(level: 1): set heading(outlined: false)   
  // since 'offset' must be >= 0, this cannot be used to 'upgrade' headings and we need to do this manually:
  let section-numbering = (
    (..nums) => nums
      .pos().slice(1)
      .map(str)
      .join(".") + "."
  )
  set heading(numbering: section-numbering)
  show heading.where(level: 1): h1 => {
    set document(
      title: h1.body,
    )
    title()
    outline(title: none)
    show heading.where(level: 1): h1 => {}
    print-nomenclature(depth:2, value: false, domain: false)
  }

  doc
})


#let dropcap = e.element.declare(
  "dropcap",
  prefix: "@preview/tudelft-thesis-novanext,v0.1.0",
  doc: "Formats a dropcap.",

  display: it => droplet.dropcap(
    height: 2,
    gap: .2em,
    fill: tud-blue,
    font: it.font,
    weight: 400
  )[#it.body],

  fields: (
    // Force this field to be specified.
    e.field("body", content, required: true),
    e.field("font", str, doc: "The text fill.", default: "Roboto Slab"),
  )
)

#let subtitle-font = e.element.declare(
  "subtitle-font",
  prefix: "@preview/tudelft-thesis-novanext,v0.1.0",
  doc: "Formats the subtitle.",

  display: it => text(
    font: it.font,
    size: it.size,
    weight: it.weight,
  )[#it.body],

  fields: (
    // Force this field to be specified.
    e.field("body", content, required: true),
    e.field("size", length, default: 14pt),
    e.field("weight", e.types.any, default: "semibold"),
    e.field("font", str, doc: "The font.", default: "Arial"),
  )
)

#let author-font = e.element.declare(
  "author-font",
  prefix: "@preview/tudelft-thesis-novanext,v0.1.0",
  doc: "Formats the author.",

  display: it => text(
    font: it.font,
    size: it.size,
    weight: it.weight,
  )[#it.body],

  fields: (
    // Force this field to be specified.
    e.field("body", content, required: true),
    e.field("size", length, default: 17pt),
    e.field("weight", e.types.any, default: "semibold"),
    e.field("font", str, doc: "The font.", default: "Roboto Slab"),
  )
)

#let thesis-classic = it => {
  show: thesis
  show: set-fonts-classic
  show heading: set text(
    font: "Libertinus Serif",
    features: ("smcp",)
  )
  show heading.where(level: 1): chapter-heading.with(
    number-args: arguments(font: "Libertinus Serif Display"),
  )
  show: e.set_(subtitle-font,
    font: "Libertinus Serif",
    size: 16pt,
  ) 
  show: e.set_(author-font,
    font: "Libertinus Serif",
  )
  show: e.set_(dropcap,
    font: "Libertinus Serif Display",
  )
  show: e.set_(if-classic-else,
    is-classic: true,
  )
  it
}
