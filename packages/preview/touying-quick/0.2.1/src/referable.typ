#import "deps.typ": *

#let equation-numbering-style(x) = {
  show math.equation: it => {
    if it.has("label") {
      let loc = it.location()
      math.equation(
        block: true,
        numbering: {
          let h1 = counter(heading).get().first()
          n => {
            numbering("(1.1)", h1, n)
          }
        },
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
    let eq-index = counter(math.equation).at(loc).first()
    let h1 = counter(heading).at(loc).first()

    names.blocks.at(lang).equation + link(loc, numbering("(1.1)", h1, eq-index + 1))
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
    languages: codly-languages,
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
