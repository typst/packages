#import "./utils.typ": t, kth-blue

#import "@preview/headcount:0.1.0": dependent-numbering
#import "@preview/hydra:0.6.0": hydra

#let header() = context {
  let chapter = hydra(1, skip-starting: false, display: (ctx, h) => h.body)

  let number = counter(page).display(here().page-numbering())

  if calc.odd(here().page()) {
    align(right, [#chapter | #number])
  } else {
    align(left, [#number | #chapter])
  }
}

#let global-setup(body) = {
  set page(
    // I don't like these numbers, especially the bottom margin...
    margin: (top: 37mm, bottom: 50mm, inside: 45mm, outside: 35mm),
    header-ascent: 15mm + 6mm,
    footer-descent: 25mm,
    header: header(),
    footer: none,
  )

  set par(justify: true)

  // front matter only; essentially styles [h1 as h2] and [h2 as h3]
  show heading.where(level: 1): set text(size: 18pt)
  show heading.where(level: 2): set text(size: 14pt)

  show figure: set figure(supplement: t("figure"))
  show figure.where(kind: table): set figure(supplement: t("figure-table"))
  show figure.where(kind: raw): set figure(supplement: t("figure-code"))

  set figure(numbering: dependent-numbering("1.1"))

  body
}

#let styled-body(body) = {
  set heading(numbering: "1.1.", supplement: t("section"))

  show heading: set text(size: 12pt) // for level > 3
  show heading.where(level: 1): set text(size: 25pt)
  show heading.where(level: 2): set text(size: 18pt)
  show heading.where(level: 3): set text(size: 14pt)

  // cannot merge these rules or the first one won't work
  show heading.where(level: 1): set heading(supplement: t("chapter"))
  show heading.where(level: 1): it => {
    pagebreak(weak: true, to: "odd")

    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)

    if it.numbering == none {
      it.body
    } else {
      let numbering = it.numbering.slice(0, -1) // remove trailing .
      let number = counter(heading).display(numbering)

      [
        #it.supplement #number \
        #it.body
      ]

      v(1em)
    }
  }

  show link: it => if type(it.dest) == str {
    // only affect external links, not e.g. glossary refs
    underline(
      stroke: 1pt + kth-blue,
      text(fill: kth-blue, it),
    )
  } else {
    it
  }

  body
}

#let setup-appendices(body) = {
  set heading(numbering: "A.1.")
  counter(heading).update(0)
  show heading.where(level: 1): set heading(supplement: t("appendix"))

  body
}
