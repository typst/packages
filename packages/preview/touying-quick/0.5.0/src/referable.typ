#import "deps.typ": *

#let heading-size-style(
  x,
  lang: "en",
  styles: default-styles,
) = {
  show heading.where(level: 1): set text(
    size: styles.sizes.heading-1 * 1pt,
  )
  show heading.where(level: 2): set text(
    size: styles.sizes.heading-2 * 1pt,
  )
  show heading.where(level: 3): set text(
    size: styles.sizes.heading-3 * 1pt,
  )
  show heading.where(level: 4): set text(
    size: styles.sizes.heading-4 * 1pt,
  )
  x
}

#let section-equation-index(loc) = {
  let headings = query(selector(heading.where(level: 1)).before(loc))
  let section-start = if headings.len() == 0 {
    none
  } else {
    headings.last().location()
  }
  let previous-equations = if section-start == none {
    0
  } else {
    counter(math.equation).at(section-start).first()
  }
  counter(math.equation).at(loc).first() - previous-equations + 1
}

#let equation-numbering-style(x) = {
  show math.equation: it => {
    if it.has("label") {
      let loc = it.location()
      let h1 = counter(heading).at(loc).first()
      let eq-index = section-equation-index(loc)
      math.equation(
        block: true,
        numbering: _ => numbering("(1.1)", h1, eq-index),
        it,
      )
    } else {
      it
    }
  }
  x
}

#let ref-style(x, lang: "en", names: default-names) = {
  let el = x.element
  if el == none { return x }
  let loc = el.location()
  if el.func() == math.equation {
    let h1 = counter(heading).at(loc).first()
    let eq-index = section-equation-index(loc)

    names.blocks.at(lang).equation + link(loc, numbering("(1.1)", h1, eq-index))
  } else { x }
}

#let figure-supplement-style(x) = {
  show figure.caption.where(kind: figure): it => [
    #it.body
  ]
  show figure.caption.where(kind: table): it => [
    #it.body
  ]
  x
}

#let code-block-style(body) = {
  codly(
    display-name: false,
    fill: rgb("#F2F3F4"),
    zebra-fill: none,
    inset: (x: .3em, y: .3em),
    radius: .5em,
  )
  show: codly-init.with()
  body
}

#let bibx(bib, main: false) = {
  counter("bibs").step()

  context if main {
    [#bib <bib-main>]
  } else if query(<bib-main>) == () and counter("bibs").get().first() == 1 {
    bib
  }
}
