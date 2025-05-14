#import "utils.typ": *

#let paper-base = config-layouts.paper.base
#let indent-base = 1.2em

#let cover-style(body) = {
  set page(
    paper: paper-base,
    margin: 10%,
  )
  body
}

#let common-style(body, list-indent: indent-base) = {
  set list(indent: list-indent)
  set enum(indent: list-indent)
  set page(paper: paper-base, margin: 10%)

  show link: set text(blue.lighten(10%))
  show link: underline
  body
}

#let front-matter-style(body) = {
  set page(paper: paper-base, margin: 10%)
  set par(justify: true)
  show heading.where(level: 1): it => {
    v(0.1em)
    set text(24pt)
    it
    v(0.5em)
  }
  text(body, size: 14pt)
}

#let contents-style(body) = {
  set page(paper: paper-base, margin: 10%)
  show heading.where(level: 1): it => {
    v(0.1em)
    set text(24pt)
    it
    v(0.5em)
  }
  show link: set text(black)
  show underline: it => it.body

  set outline(
    indent: indent-base,
    title: {
      heading(
        outlined: true,
        level: 1,
        [
          Contents
        ],
      )
    },
    depth: 2,
  )

  set outline.entry(fill: repeat(".", gap: 0.2em))
  show outline.entry: x => {
    if x.element.func() == figure {
      link(
        x.element.location(),
        {
          v(.1em)
          smallcaps(strong(x.body()))
          h(1fr)
          strong(x.page())
          v(.1em)
        },
      )
    } else if x.level == 1 {
      link(
        x.element.location(),
        {
          strong({
            let prefix = x.prefix()
            if prefix != none {
              box(width: indent-base, prefix)
            }
            h(.8em) + x.body()
          })
          h(1fr)
          strong(x.page())
        },
      )
      v(0em)
    } else if x.level == 2 {
      x
    }
  }
  body
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
  v(1em, weak: true)
  x
  v(1em, weak: true)
}

#let figure-style(x) = {
  show figure.caption.where(kind: figure): it => [
    #if it.supplement == none {
      config-sections.block.at(lang).figure
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.caption.where(kind: table): it => [
    #if it.supplement == none {
      config-sections.block.at(lang).table
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.caption.where(kind: "title"): none
  x
}

#let equation-style(x, book: "") = {
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show math.equation: it => {
    if it.has("label") {
      math.equation(
        block: true,
        numbering: if book != "" {
          let title-index = if book != "" { context counter(label-title).display("1") } else { none }
          (..numbers) => {
            "(" + title-index + "." + numbering("1", numbers.at(0)) + ")"
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

#let ref-style(it, book: "") = {
  {
    let el = it.element
    if el != none and el.func() == math.equation {
      let loc = el.location()
      let index = counter(math.equation).at(loc).first()

      if book != "" {
        let title-index = if book != "" { context counter(label-title).display("1") } else { none }
        link(
          loc,
          numbering(
            (..numbers) => {
              "(" + title-index + "." + numbering("1", numbers.at(0)) + ")"
            },
            index + 1,
          ),
        )
      } else {
        let h1 = counter(heading).at(loc).first()
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
  info: info-default,
  outline-on: false,
  paper: "iso-b5",
) = {
  show: common-style
  let header-cap = info.header-cap
  let footer-cap = info.footer-cap
  let lang = info.lang

  set page(
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
    font: config-fonts.family.at(lang).context,
    size: 10.5pt,
    lang: lang,
  )

  align(center, chapter-title(title, book: info.book, lang: lang))

  show heading: heading-style

  set heading(
    numbering: (..numbers) => {
      let title-index = if info.book != "" { context counter(label-title).display("1.") } else { none }
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

  show math.equation: equation-style.with(book: info.book)

  set ref(
    supplement: it => {
      if it.func() == heading {
        config-sections.section.at(lang).chapter
      } else if it.func() == table {
        it.caption
      } else if it.func() == image {
        it.caption
      } else if it.func() == figure {
        it.supplement
      } else if it.func() == math.equation {
        config-sections.block.at(lang).equation
      } else { }
    },
  )

  show ref: ref-style.with(book: info.book)
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
  counter(heading).update(0)
  set heading(
    numbering: numbly(
      "{1:A}",
      "{1:A}.{2}",
    ),
  )

  show heading.where(level: 1): it => {
    pagebreak()
    it
  }
  body
}
