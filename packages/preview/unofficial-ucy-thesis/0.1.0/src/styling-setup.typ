#import "./utils.typ": primary-t, tl, ucy-lang

#import "@preview/headcount:0.1.1": dependent-numbering

/// UCY ADE page geometry: 16 cm text block on A4.
#let ucy-margins = (
  left: 2.5cm,
  right: 2.5cm,
  top: 1.5cm,
  bottom: 2.5cm,
)

#let ucy-page-setup(with-page-numbers: false, body) = {
  set page(
    paper: "a4",
    margin: ucy-margins,
    footer: if with-page-numbers {
      context align(right)[#text(size: 10pt, counter(page).display())]
    } else {
      none
    },
    header: none,
  )
  set text(
    font: ("Times New Roman", "New Computer Modern"),
    size: 12pt,
  )
  set par(justify: true, first-line-indent: 0pt)

  show link: it => if type(it.dest) == str {
    underline(text(fill: blue.darken(20%), it))
  } else {
    it
  }

  body
}

#let apply-body-typography(style, body) = {
  set text(tracking: style.tracking)
  set par(
    leading: style.leading,
    spacing: style.par-spacing,
  )
  set list(
    indent: 1.2em,
    body-indent: 0.6em,
    spacing: style.list-spacing,
  )
  set enum(
    indent: 1.2em,
    body-indent: 0.6em,
    spacing: style.list-spacing,
  )
  body
}

#let global-setup(body) = {
  show heading: set text(tracking: 0pt)
  show heading.where(level: 1): set text(size: 14pt, weight: "bold")
  show heading.where(level: 2): set text(size: 12pt, weight: "bold")

  show heading.where(level: 1): it => {
    v(1.5em)
    block(below: 1em, upper(it.body))
  }

  show heading.where(level: 2): it => {
    v(0.9em)
    block(below: 0.6em, it.body)
  }

  body
}

#let styled-body(style, body) = {
  apply-body-typography(style, {
    set heading(numbering: "1.1.")

    show heading: set text(size: 12pt)
    show heading.where(level: 1): set text(size: 17pt, weight: "bold")
    show heading.where(level: 2): set text(size: 12pt, weight: "bold")
    show heading.where(level: 3): set text(size: 12pt, weight: "bold")

    show figure: set figure(supplement: primary-t("figure"))
    show figure.where(kind: table): set figure(supplement: primary-t("table"))
    set figure(numbering: dependent-numbering("1.1"))

    show heading.where(level: 1): it => {
      pagebreak(weak: true)

      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)

      block(below: 2em, breakable: false)[
        #text(size: 17pt, weight: "bold")[
          #counter(heading).display("1")
          #h(1em)
          #it.body
        ]
      ]
    }

    show heading.where(level: 2): it => {
      v(1.2em, weak: true)
      block(below: 0.9em)[
        #text(weight: "bold")[
          #counter(heading).display("1.1")
          #h(1em)
          #it.body
        ]
      ]
    }

    show heading.where(level: 3): it => {
      v(1em, weak: true)
      block(below: 0.7em)[
        #text(weight: "bold")[
          #counter(heading).display("1.1.1")
          #h(1em)
          #it.body
        ]
      ]
    }

    body
  })
}

#let setup-appendices(body) = {
  counter(heading).update(0)
  let appendix-num = counter("ucy-appendix")
  set heading(numbering: none)

  show heading.where(level: 1): it => context {
    pagebreak(weak: true)
    appendix-num.step()
    let letter = numbering("A", appendix-num.get().first())
    let lang = ucy-lang.get()
    block(below: 2em)[
      #text(size: 17pt, weight: "bold", upper(tl("appendix", lang)) + " " + letter)
      #v(1em)
      #text(size: 17pt, weight: "bold", it.body)
    ]
  }

  body
}

#let default-style = (
  tracking: 0.04em,
  leading: 0.85em,
  par-spacing: 0.55em,
  list-spacing: 0.45em,
)
