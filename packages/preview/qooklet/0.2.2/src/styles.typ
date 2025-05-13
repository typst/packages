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
  )

  set outline.entry(fill: repeat(".", gap: 0.2em))
  show outline.entry: x => {
    if x.element.func() == figure {
      // parts
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
      // level 1 headings
      link(
        x.element.location(),
        {
          strong({
            let prefix = x.prefix()
            if prefix != none {
              box(width: indent-base, prefix)
            }
            x.body()
          })
          h(1fr)
          strong(x.page())
        },
      )
      v(0em)
    } else {
      x
    }
  }
  body
}

#let header-footer-style(header-cap, footer-cap) = {
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
}

#let heading-styles(x, book: false) = {
  if x.level == 1 {
    // set page(header: none)
    if book == true {
      pagebreak(to: "odd")
    }
    let bottom-pad = 10%

    grid(
      columns: (20fr, 2fr, 5fr),
      rows: (1fr, 12fr),
      align: (right + bottom, center, left + bottom),
      pad(
        text(25pt, x.body),
        bottom: bottom-pad,
      ),
      line(angle: 90deg, length: 100%),
      pad(
        text(50pt, counter(heading).display(heading.numbering)),
        bottom: bottom-pad,
      ),
    )
    v(1em)
  } else if x.level == 2 {
    v(1em, weak: true)
    set text(14pt)
    x
    v(1em, weak: true)
  } else if x.level == 3 {
    v(1em, weak: true)
    set text(12pt)
    x
    v(1em, weak: true)
  } else if x.level == 4 {
    v(1em, weak: true)
    set text(10.5pt)
    x
    v(1em, weak: true)
  } else {
    x
  }
}

#let figure-style(x) = {
  show figure.caption.where(kind: figure): it => [
    #if it.supplement == none {
      linguify("figure")
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.caption.where(kind: table): it => [
    #if it.supplement == none {
      linguify("table")
    } else {
      it.supplement
    }
    #context it.counter.display(it.numbering)
    #it.body
  ]
  show figure.where(kind: table): set figure.caption(position: top)
  x
}

#let equation-style(x) = {
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  show math.equation: it => {
    let count = counter(heading).get()
    let h1 = count.first()
    let h2 = count.at(1, default: 0)
    if it.has("label") {
      math.equation(
        block: true,
        numbering: n => {
          numbering("(1.1)", h1, n)
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
      let h1 = counter(heading).at(loc).first()
      let index = counter(math.equation).at(loc).first()

      link(loc, numbering("(1.1)", h1, index + 1))
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

#let body-style(body, header-cap: "", footer-cap: "", lang: "en") = {
  show: common-style
  // heading style
  // show heading: heading-styles
  // heading numbering
  set heading(
    numbering: numbly(
      "{1}",
      "{1}.{2}",
    ),
  )
  show: header-footer-style(header-cap, footer-cap)

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

  set ref(
    supplement: it => {
      if it.func() == heading {
        linguify("chapter")
      } else if it.func() == table {
        it.caption
      } else if it.func() == image {
        it.caption
      } else if it.func() == figure {
        it.supplement
      } else if it.func() == math.equation {
        linguify("eq")
      } else { }
    },
  )

  show ref: ref-style
  show figure: figure-style
  show: equation-style
  show: code-block-style
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

  body
}
