#import "@preview/touying:0.6.0": *
#import themes.metropolis: *
// multi-languages
#import "@preview/linguify:0.4.2": linguify, set-database
// theorems
#import "@preview/ctheorems:1.1.3": thmbox, thmrules
// banners
#import "@preview/gentle-clues:1.2.0": *
// physics
#import "@preview/physica:0.9.5": dd, dv, pdv, dmat
// subfigures
#import "@preview/subpar:0.2.2": grid as sgrid
// diagram
#import "@preview/fletcher:0.5.7": diagram, node, edge
// codes
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
// annot
#import "@preview/pinit:0.2.2": pin, pinit-highlight, pinit-place
// excel
#import "@preview/rexllent:0.3.0": xlsx-parser

#let touying-quick(
  title: [],
  subtilte: none,
  author: [],
  author-size: 14pt,
  institute: [],
  background-img: "img/sky.png",
  footer: [],
  footer-size: 14pt,
  list-indent: 1.2em,
  lang: "en",
  doc,
) = {
  let lang_data = toml("lang.toml")
  set-database(lang_data)

  set par(
    first-line-indent: 2em,
    justify: true,
    leading: 1em,
    linebreaks: "optimized",
  )
  set block(above: 1em, below: 0.5em)
  set list(indent: list-indent)
  set enum(indent: list-indent)

  set page(background: image(background-img, width: 100%))

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
  show link: underline

  show: codly-init.with()
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: text(footer, size: footer-size, font: fonts.at(lang).footer),
    config-info(
      title: [#text(title, size: 40pt)],
      subtitle: [#subtilte],
      author: [#text(author, size: author-size, font: fonts.at(lang).author)],
      date: datetime.today(),
      institution: [#institute],
      logo: emoji.school,
    ),
    config-colors(
      primary-light: rgb("#fcbd00"),
      secondary: rgb("#3297df"),
      secondary-light: rgb("#ff0000"),
      neutral-lightest: rgb("#ffffff"),
      neutral-dark: rgb("#3297df"),
    ),
    config-common(
      preamble: {
        codly(
          languages: codly-languages,
          display-name: false,
          fill: rgb("#F2F3F4"),
          number-format: none,
          zebra-fill: none,
          inset: (x: .3em, y: .2em),
          radius: .5em,
        )
      },
    ),
  )

  show: thmrules.with(qed-symbol: $square$)

  title-slide()
  outline(title: linguify("outline"), indent: 2em, depth: 1)
  doc

  slide(align: center + horizon)[
    #text(linguify("ending"), font: fonts.at(lang).ending, size: 50pt)
  ]
}

// text
#let fonts = toml("fonts.toml")
#let ctext(body) = text(body, font: fonts.at("zh").math)

// tables
#let frame(stroke) = (
  (x, y) => (
    top: if y < 2 {
      stroke
    } else {
      0pt
    },
    bottom: stroke,
  )
)

// tables
#let frame2(stroke) = (
  (x, y) => (
    left: if x > 2 {
      stroke
    } else {
      0pt
    },
    top: stroke,
    bottom: stroke,
  )
)

#let ktable(data, k, inset: 0.3em) = table(
  columns: k,
  inset: inset,
  align: center + horizon,
  stroke: frame(rgb("000")),
  ..data.flatten(),
)

// codes
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
