#import "dependencies.typ": codly, codly-init, codly-languages, default-names
#import "common.typ": book-state, counter-appendix, counter-chapter

#let equation-prefix(prefix) = {
  if prefix == "chapter" {
    counter-chapter.get().first()
  } else if prefix == "appendix" {
    "ABCDE".at(counter-appendix.get().first() - 1)
  }
}

#let equation-numbering-style(x, prefix: "chapter") = {
  show math.equation: it => {
    if it.has("label") {
      let loc = it.location()
      math.equation(
        block: true,
        numbering: if book-state.get() {
          let title-index = equation-prefix(prefix)
          n => {
            "(" + str(title-index) + "." + str(n) + ")"
          }
        } else {
          let h1 = counter(heading).get().first()
          let num-style = if prefix == "chapter" { "(1.1)" } else if (
            prefix == "appendix"
          ) { "(a.1)" }
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

#let ref-style(x, lang: "en", names: default-names, prefix: "chapter") = {
  let el = x.element
  if el == none { return x }
  let loc = el.location()
  if el.func() == math.equation {
    let eq-index = counter(math.equation).at(loc).first()
    if book-state.get() {
      let title-index = equation-prefix(prefix)
      (
        names.blocks.at(lang).equation
          + link(
            loc,
            numbering(
              n => {
                "(" + str(title-index) + "." + str(n) + ")"
              },
              eq-index + 1,
            ),
          )
      )
    } else {
      let h1 = counter(heading).at(loc).first()
      let num-style = if prefix == "chapter" { "(1.1)" } else if (
        prefix == "appendix"
      ) { "(a.1)" }
      (
        names.blocks.at(lang).equation + link(loc, numbering(num-style, h1, eq-index + 1))
      )
    }
  } else { x }
}

#let figure-supplement-style(x, names: default-names) = {
  show figure.caption.where(kind: "chapter"): none

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
  x
}

#let bibx(bib, main: false) = {
  counter("bibs").step()

  context if main {
    [#bib <bib-main>]
  } else if query(<bib-main>) == () and counter("bibs").get().first() == 1 {
    bib
  }
}
