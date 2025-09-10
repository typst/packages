#import "dependencies.typ": codly, codly-init, codly-languages
#import "common.typ": book-state, counter-chapter
#import "dependencies.typ": default-names

#let equation-numbering-style(x) = {
  show math.equation: it => {
    if it.has("label") {
      math.equation(
        block: true,
        numbering: if book-state.get() {
          let title-index = context counter-chapter.display("1")
          let eq-index = counter(selector(math.equation).before(here())).get().first()
          n => {
            "(" + title-index + "." + str(eq-index + 1) + ")"
          }
        } else {
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

#let ref-numbering-style(x, lang: "en", names: default-names) = {
  let el = x.element
  if el != none {
    let loc = el.location()
    if el.func() == math.equation {
      if book-state.get() {
        let title-index = context counter-chapter.get().first()
        let eq-index = counter(selector(math.equation).before(here())).get().first()
        (
          names.blocks.at(lang).equation
            + link(
              loc,
              numbering(
                n => {
                  "(" + title-index + "." + str(eq-index) + ")"
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
