#import "dependencies.typ": default-names, codly, codly-init, codly-languages
#import "common.typ": book-state, counter-chapter, counter-appendix

#let equation-numbering-style(x, prefix: "chapter") = {
  show math.equation: it => {
    let loc = it.location()
    if it.has("label") {
      math.equation(
        block: true,
        numbering: if book-state.get() {
          let title-index = if prefix == "chapter" { counter-chapter.get().first() } else if prefix == "appendix" {
            "ABCDE".at(counter-appendix.get().first() - 1)
          }
          let eq-index = counter(math.equation).at(loc).first()
          n => {
            "(" + str(title-index) + "." + str(eq-index + 1) + ")"
          }
        } else {
          let h1 = counter(heading).get().first()
          let num-style = if prefix == "chapter" { "(1.1)" } else if prefix == "appendix" { "(a.1)" }
          n => {
            numbering(num-style, h1, n)
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

#let ref-numbering-style(x, lang: "en", names: default-names, prefix: "chapter") = {
  let el = x.element
  if el != none {
    let loc = el.location()
    if el.func() == math.equation {
      if book-state.get() {
        let title-index = if prefix == "chapter" { counter-chapter.get().first() } else if prefix == "appendix" {
          "abcde".at(counter-appendix.get().first() - 1)
        }
        let eq-index = counter(math.equation).at(loc).first()
        (
          names.blocks.at(lang).equation
            + link(
              loc,
              numbering(
                n => {
                  "(" + str(title-index) + "." + str(eq-index + 1) + ")"
                },
                eq-index + 1,
              ),
            )
        )
      } else {
        let h1 = counter(heading).at(loc).first()
        let index = counter(math.equation).at(loc).first()

        names.blocks.at(lang).equation + link(loc, numbering("(1.1)", h1, index + 1))
      }
    }
    if el.func() == figure {
      if book-state.get() { }
    }
  } else {
    x
  }
}

#let figure-supplement-style(x, names: default-names) = {
  show figure.caption.where(kind: figure): it => [
    #if it.supplement == none {
      names.blocks.at(lang).figure
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.caption.where(kind: table): it => [
    #if it.supplement == none {
      names.blocks.at(lang).table
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.caption.where(kind: "chapter"): none
  x
}

#let ref-supplement-style(x, lang: "en", names: default-names) = {
  set ref(
    supplement: it => {
      if it.func() == heading {
        names.sections.at(lang).chapter
      } else if it.func() == table {
        it.caption
      } else if it.func() == image {
        it.caption
      } else if it.func() == figure {
        it.supplement
      } else if it.func() == math.equation {
        names.blocks.at(lang).equation
      } else { }
    },
  )
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
