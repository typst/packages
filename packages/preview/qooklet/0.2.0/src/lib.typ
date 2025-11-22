// multi-languages
#import "@preview/linguify:0.4.2": linguify, set-database
// header-footer
#import "@preview/hydra:0.6.1": hydra
// physics
#import "@preview/physica:0.9.5": *
// theorems
#import "@preview/ctheorems:1.1.3": thmbox, thmrules
// banners
#import "@preview/gentle-clues:1.2.0": *
// codes
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
// subfigures
#import "@preview/subpar:0.2.2": grid as sgrid
// diagram
#import "@preview/fletcher:0.5.7": diagram, node, edge
// excel
#import "@preview/rexllent:0.3.0": xlsx-parser
// wrap
#import "@preview/wrap-it:0.1.1": wrap-content
// annot
#import "@preview/pinit:0.2.2": pin, pinit-highlight, pinit-place

#let qooklet(
  title: none,
  author: (),
  header-cap: [],
  footer-cap: [],
  outline-on: false,
  par-leading: 1em,
  list-indent: 1.2em,
  block-above: 1em,
  block-below: 1em,
  figure-break: false,
  paper: "iso-b5",
  lang: "en",
  doc,
) = {
  let lang_data = toml("lang.toml")
  set-database(lang_data)

  set page(
    paper: paper,
    numbering: "1",
    header: context {
      set text(size: 8pt)
      if calc.odd(here().page()) {
        align(right, [#header-cap #h(6fr) #emph(hydra(1))])
      } else {
        align(left, [#emph(hydra(1)) #h(6fr) #header-cap])
      }
      line(length: 100%)
    },
    footer: context {
      set text(size: 8pt)
      let page_num = here().page()
      if calc.odd(page_num) {
        align(
          right,
          [#footer-cap #datetime.today().display("[year]-[month]-[day]") #h(6fr) #page_num],
        )
      } else {
        align(
          left,
          [#page_num #h(6fr) #footer-cap #datetime.today().display("[year]-[month]-[day]")],
        )
      }
    },
  )
  set heading(numbering: "1.1")

  set par(
    first-line-indent: (
      amount: 2em,
      all: true,
    ),
    justify: true,
    leading: 1em,
    spacing: 1em,
  )
  set block(above: block-above, below: block-below)
  set list(indent: list-indent)
  set enum(indent: list-indent)

  let fonts = toml("fonts.toml")
  set text(
    font: fonts.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )

  set ref(
    supplement: it => {
      if it.func() == heading {
        linguify("chapter")
      } else if it.func() == table {
        it.caption
      } else if it.func() == image {
        it.caption
      } else if it.func() == figure {
        it.supplement
      } else if it.func() == math.equation {
        linguify("eq")
      } else { }
    },
  )

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show math.equation: it => {
    let count = counter(heading).get()
    let h1 = count.first()
    let h2 = count.at(1, default: 0)
    if it.has("label") {
      math.equation(
        block: true,
        numbering: n => {
          numbering("(1.1)", h1, n)
        },
        it,
      )
    } else {
      it
    }
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let loc = el.location()
      let h1 = counter(heading).at(loc).first()
      let index = counter(math.equation).at(loc).first()

      link(loc, numbering("(1.1)", h1, index + 1))
    } else {
      it
    }
  }

  show figure.caption: it => [
    #it.supplement
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.where(kind: table): set figure.caption(position: top)

  codly(
    languages: codly-languages,
    display-name: false,
    fill: rgb("#F2F3F4"),
    zebra-fill: none,
    inset: (x: .3em, y: .3em),
    // stroke: -1pt + rgb("#000000"),
    radius: .5em,
  )
  show: codly-init.with()

  align(
    center,
    text(size: 20pt, font: fonts.at(lang).title)[
      *#title*
    ],
  )

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  if outline-on == true {
    outline(
      title: lang_data.lang.at(lang).content,
      indent: auto,
      depth: 2,
    )
    pagebreak()
  }

  show link: underline
  show: thmrules
  doc
}

// text
#let fonts = toml("fonts.toml")
#let ctext(body) = text(body, font: fonts.at("zh").math)

// table: three-line
#let three-line(stroke-color) = (
  (x, y) => (
    top: if y < 2 {
      stroke-color
    } else {
      0pt
    },
    bottom: stroke-color,
  )
)

// table: grid without left border and right border
#let no-left-right(stroke-color) = (
  (x, y) => (
    left: if x > 2 {
      stroke-color
    } else {
      0pt
    },
    top: stroke-color,
    bottom: stroke-color,
  )
)

// table: reading as three-line table
#let ktable(data, k, stroke: three-line(rgb("000")), inset: 0.3em) = table(
  columns: k,
  inset: inset,
  align: center + horizon,
  stroke: stroke,
  ..data.flatten(),
)

// codes: reading
#let code(text, lang: "python", breakable: true, width: 100%) = block(
  fill: rgb("#F3F3F3"),
  stroke: rgb("#DBDBDB"),
  inset: (x: 1em, y: 1em),
  outset: -.3em,
  radius: 5pt,
  spacing: 1em,
  breakable: breakable,
  width: width,
  raw(
    text,
    lang: lang,
    align: left,
    block: true,
  ),
)

// theorems
#let definition = thmbox(
  "definition",
  text(linguify("definition")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0em),
  fill: rgb("#FFFFFF"),
  // stroke: rgb("#000000"),
  inset: (left: 0em, right: 0.5em, top: 0.2em, bottom: 0.2em),
)

#let theorem = thmbox(
  "theorem",
  text(linguify("theorem")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0.2em),
  fill: rgb("#E5EEFC"),
  // stroke: rgb("#000000")
)

#let lemma = thmbox(
  "theorem",
  text(linguify("lemma")),
  separator: [#h(0.5em)],
  fill: rgb("#EFE6FF"),
  titlefmt: strong,
)

#let corollary = thmbox(
  "corollary",
  text(linguify("corollary")),
  // base: "theorem",
  separator: [#h(0.5em)],
  titlefmt: strong,
)

#let rule = thmbox(
  "",
  text(linguify("rule")),
  base_level: 1,
  separator: [#h(0.5em)],
  fill: rgb("#EEFFF1"),
  titlefmt: strong,
)

#let algo = thmbox(
  "",
  text(linguify("algorithm")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0.2em),
  fill: rgb("#FAF2FB"),
  titlefmt: strong,
)

#let tip(title: linguify("tip"), icon: emoji.bell, ..args) = clue(
  accent-color: rgb("#e5c525e9"),
  title: title,
  icon: icon,
  ..args,
)
