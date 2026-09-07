#import "deps.typ": *
#import "common.typ": appendix-number, book-state, counter-appendix, counter-chapter

#let equation-prefix-at(loc, prefix) = {
  if prefix == "chapter" {
    counter-chapter.at(loc).first()
  } else if prefix == "appendix" {
    appendix-number(counter-appendix.at(loc).first())
  }
}

#let note-equation-format(prefix) = {
  if prefix == "appendix" { "(a.1)" } else { "(1.1)" }
}

#let equation-number-at(loc, index, prefix: "chapter") = {
  if book-state.get() {
    let title-index = equation-prefix-at(loc, prefix)
    numbering(n => "(" + str(title-index) + "." + str(n) + ")", index)
  } else {
    let h1 = counter(heading).at(loc).first()
    numbering(note-equation-format(prefix), h1, index)
  }
}

#let equation-numbering(prefix: "chapter") = {
  n => equation-number-at(here(), n, prefix: prefix)
}

#let heading-numbering-at(loc) = {
  let nums = counter(heading).at(loc)
  if book-state.get() {
    let append-index = counter-appendix.at(loc).first()
    let title-index = if append-index > 0 {
      appendix-number(append-index)
    } else {
      str(counter-chapter.at(loc).first())
    }
    title-index + "." + numbering("1.", ..nums)
  } else {
    numbering("1.", ..nums)
  }
}

#let equation-numbering-style(x, prefix: "chapter") = {
  show math.equation: it => {
    if it.has("label") {
      let loc = it.location()
      math.equation(
        block: true,
        numbering: n => equation-number-at(loc, n, prefix: prefix),
        it,
      )
    } else {
      it
    }
  }
  x
}

#let ref-style(x, lang: "en", names: default-names, prefix: "chapter") = {
  let targets = query(selector(x.target))
  let el = if targets.len() > 0 {
    targets.first()
  } else if x.has("element") {
    x.element
  } else {
    none
  }
  if el == none { return x }
  let loc = el.location()
  if el.func() == math.equation {
    let eq-index = counter(math.equation).at(loc).first()
    (
      names.blocks.at(lang).equation
        + link(loc, equation-number-at(loc, eq-index + 1, prefix: prefix))
    )
  } else if el.func() == heading {
    link(loc, el.supplement + [ ] + heading-numbering-at(loc))
  } else if el.func() == figure {
    link(loc, el.supplement + [ ] + context el.counter.display(el.numbering))
  } else {
    link(loc, str(x.target))
  }
}

#let figure-supplement-style(x, lang: "en", names: default-names) = {
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
