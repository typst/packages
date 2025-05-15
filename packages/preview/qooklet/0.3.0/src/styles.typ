#import "utils.typ": *

#let indent-base = 1.2em
#let book-state = state("book-state", false)
#let header-state = state("header-state", true)

#let cover-style(body, paper: "iso-b5", lang: "en") = {
  set page(
    paper: paper,
    margin: 10%,
  )
  body
  book-state.update(true)
}

#let common-style(body, list-indent: indent-base, paper: "iso-b5", lang: "en") = {
  set list(indent: list-indent)
  set enum(indent: list-indent)
  set page(paper: paper, margin: 10%)

  show link: set text(blue.lighten(10%))
  show link: underline
  body
}

#let front-matter-style(body, paper: "iso-b5", lang: "en") = {
  set page(paper: paper, margin: 10%)
  set par(justify: true)
  show heading.where(level: 1): it => {
    v(0.1em)
    set text(22pt)
    it
    v(0.5em)
  }
  text(body, size: 14pt)
}

#let contents-style(body, depth: 2, lang: "en", names: default-names, layout: default-layout) = {
  set page(paper: layout.paper.normal-size, margin: 10%)

  show link: set text(black)
  show heading.where(level: 1): it => {
    set text(22pt)
    it
    v(0.1em)
  }

  set outline(
    title: {
      heading(
        outlined: true,
        level: 1,
        names.sections.at(lang).content,
      )
    },
  )

  show outline.entry: x => {
    let loc = x.element.location()
    let chap-counter = state("chap-counter", 0)
    let chap-counter2 = state("chap-counter2", 0)
    let fill = box(width: 1fr, x.fill)

    let prefix = x.prefix()
    if (depth >= 0) and (x.element.func() == figure) {
      chap-counter.update(s => s + 1)
      link(
        loc,
        {
          (
            { context chap-counter.get() }
              + "."
              + h(.5em)
              + smallcaps(strong(x.body()))
              + fill
              + strong(x.page())
              + v(0em)
          )
        },
      )
    } else if (depth == 2) and (x.level == 1) and (prefix != none) {
      link(
        loc,
        {
          strong(
            if prefix.has("children") {
              if prefix.children.at(1).text == "1." {
                chap-counter2.update(s => s + 1)
              }
              context { h(1.2em) + str(chap-counter2.get()) } + "." + context { prefix.children.at(1) } + h(.5em)
            } else if prefix.has("text") {
              prefix + h(.5em)
            }
              + x.body(),
          )
          fill + strong(x.page())
        },
      )
      v(0em)
    } else if (depth < 0) or (depth > 2) { panic("depth can only be either 1 or 2") }
  }
  text(body, font: layout.fonts.at(lang).contents)
}

#let heading-style(x) = {
  if x.level == 1 {
    set text(16pt)
  } else if x.level == 2 {
    set text(14pt)
  } else if x.level == 3 {
    set text(12pt)
  } else {
    set text(10.5pt)
  }
  x
  v(1em, weak: true)
}

#let figure-style(x, names: default-names) = {
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
  show figure.caption.where(kind: "title"): none
  x
}

#let equation-style(x) = {
  show math.equation: it => {
    if it.has("label") {
      math.equation(
        block: true,
        numbering: if book-state.get() {
          let title-index = context counter(label-chapter).display("1")
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

#let ref-style(it) = {
  {
    let el = it.element
    if el != none and el.func() == math.equation {
      let loc = el.location()

      if book-state.get() {
        let title-index = context counter(label-chapter).get().first()
        let eq-index = counter(selector(math.equation).before(here())).get().first()

        link(
          loc,
          numbering(
            n => {
              "(" + title-index + "." + str(eq-index) + ")"
            },
            eq-index + 1,
          ),
        )
      } else {
        let h1 = counter(heading).at(loc).first()
        let index = counter(math.equation).at(loc).first()
        link(loc, numbering("(1.1)", h1, index + 1))
      }
    } else {
      it
    }
  }
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

#let body-style(
  body,
  title: "",
  paper: "",
  info: default-info,
  layout: default-layout,
  names: default-names,
  outline-on: false,
) = {
  show: common-style

  let header-cap = info.header-cap
  let footer-cap = info.footer-cap
  let lang = info.lang
  let paper = if paper == "" { layout.paper.normal-size } else { paper }

  set page(
    paper: paper,
    header: context {
      set text(size: 8pt)
      align-odd-even(header-cap, emph(hydra(1)))
      line(length: 100%)
    },
    footer: context {
      set text(size: 8pt)
      let page_num = here().page()
      align-odd-even(footer-cap, page_num)
    },
  )

  set par(
    first-line-indent: (
      amount: if lang == "zh" { 2em } else { 0em },
      all: if lang == "zh" { true } else { false },
    ),
    justify: true,
    leading: 1em,
    spacing: 1em,
  )

  set block(above: 1em, below: 1em, radius: 20%)
  set text(
    font: layout.fonts.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )
  context {
    if book-state.get() {
      align(center, chapter-title(title, book: true, lang: lang))
    } else {
      align(center, chapter-title(title, lang: lang))
    }
  }

  show heading: heading-style

  set heading(
    numbering: (..numbers) => {
      let title-index = if book-state.get() { context counter(label-chapter).display("1.") } else {
        none
      }
      let level = numbers.pos().len()
      if (level == 1) {
        title-index + numbering("1.", numbers.at(0))
      } else if (level == 2) {
        title-index + numbering("1.", numbers.at(0)) + numbering("1.", numbers.at(1))
      } else {
        h(-0.3em)
      }
    },
  )

  show pagebreak.where(weak: true): it => {
    counter(heading).update(0)
    it
  }

  if outline-on == true {
    outline(depth: 2)
    pagebreak()
  }

  show math.equation: equation-style

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

  context if not book-state.get() {
    set-inherited-levels(1)
  } else { set-inherited-levels(0) }

  show ref: ref-style
  show raw.where(block: true): code-block-style
  show figure: figure-style
  show figure.where(kind: table): set figure.caption(position: top)

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show: show-theorion
  body
}

#let appendix-style(body) = {
  show heading.where(level: 1): it => {
    pagebreak()
    it
  }

  set heading(numbering: "A.1")
  set-theorion-numbering("A.1")
  body
}
