#import "./utils.typ": maybe-sans-serif, ntnu-blue, t

#import "@preview/headcount:0.1.1": dependent-numbering
#import "@preview/hydra:0.6.3": hydra

#let header(style) = context {
  set text(font: maybe-sans-serif(style))

  let chapter = hydra(1, skip-starting: false)

  let alignment = if calc.odd(here().page()) {
    right
  } else {
    left
  }

  align(alignment, emph[#chapter])
  line(length: 100%)
}

#let footer(style) = context {
  set text(font: maybe-sans-serif(style))

  let number = counter(page).display(here().page-numbering())

  line(length: 100%)
  align(center, number)
}

#let global-setup(style, alternating-margins, body) = context {
  let margins = if alternating-margins {
    (
      inside: 35mm,
      outside: 25mm,
    )
  } else {
    (
      inside: 30mm,
      outside: 30mm,
    )
  }

  set page(
    // I don't like these numbers, especially the bottom margin...
    margin: (top: 30mm, bottom: 30mm, inside: margins.inside, outside: margins.outside),
    header-ascent: 10mm,
    footer-descent: 10mm,
    header: header(style),
    footer: footer(style),
  )

  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)

  set par(justify: true)

  show heading: set text(font: maybe-sans-serif(style))

  // front matter only; essentially styles [h1 as h2] and [h2 as h3]
  show heading.where(level: 1): set text(size: 18pt)
  show heading.where(level: 2): set text(size: 14pt)

  show figure: set figure(supplement: t("figure"))
  show figure.where(kind: table): set figure(supplement: t("figure-table"))
  show figure.where(kind: raw): set figure(supplement: t("figure-code"))

  set figure(numbering: dependent-numbering("1.1"))

  body
}

#let styled-body(style, body) = {
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

      if style.fancy-chapters {
        [
          #set align(end)

          #text(fill: rgb("#444"), [
            #upper(it.supplement) #box(rect(
              fill: rgb("#444"),
              outset: 2pt,
              text(
                size: 60pt,
                fill: white,
                align(center, number),
              ),
            ))
          ]) \
          #text(size: 36pt, strong(it.body))
        ]
      } else {
        [
          #it.supplement #number \
          #it.body
        ]
      }

      v(1em)
    }
  }

  show link: it => if type(it.dest) == str {
    // only affect external links, not e.g. glossary refs
    underline(
      stroke: 1pt + ntnu-blue,
      text(fill: ntnu-blue, it),
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
