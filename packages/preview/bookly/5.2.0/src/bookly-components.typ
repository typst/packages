#import "bookly-deps.typ": *
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *
#import "bookly-themes.typ": *

// Chapter
#let chapter(title: none, abstract: none, toc: true, numbered: true, label: none, body) = context {
  // Unnumbered chapter: the numbering overrides must live at the function body
  // level (not inside an `if` block) so that they also apply to `body`.
  set heading(numbering: none) if not numbered
  set math.equation(numbering: "(1a)") if not numbered

  show: show-if(not numbered, it => {
    show figure.where(kind: image): set figure(
      supplement: fig-supplement,
      numbering: "1",
      gap: 1.5em,
    )
    show figure.where(kind: table): set figure(
      numbering: "1",
      gap: 1.5em,
    )
    it
  })

  if toc {
    set page(header: anchor())
    set align(horizon)
    [#heading(title)#label]

    if abstract != none {
      abstract
    }

    minitoc
    pagebreak()
  } else {
    [#heading(title)#label]
  }

  body
}

#let chapter-nonum(body) = {
  let numbering-heading = none
  let numbering-eq = "(1a)"
  let numbering-fig = "1"

  // Heading numbering
  set heading(numbering: numbering-heading)

  // Equation numbering
  set math.equation(numbering: numbering-eq)

  // Figure numbering
  show figure.where(kind: image): set figure(
    supplement: fig-supplement,
    numbering: numbering-fig,
    gap: 1.5em
  )

  // Table numbering
  show figure.where(kind: table): set figure(
    numbering: numbering-fig,
    gap: 1.5em
  )

  body
}
