#import "@preview/hydra:0.6.2": hydra
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *

// Chapter
#let chapter(title: none, abstract: none, toc: true, numbered: true, body) = context {
    // Is the chapter numbered?
    if not numbered {
      numbering-heading = none
      numbering-eq = "(1a)"
      numbering-fig = "1"

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
    }

    let toc-header = states.localization.get().toc
    if toc {
      set page(header: none)
      set align(horizon)
      heading(title)

      if abstract != none {
        abstract
      }

      minitoc
      pagebreak()
    } else {
      heading(title)
    }

    body
  }
}

#let chapter-nonum(body) = {
  let numbering-heading = none
  let numbering-eq = "(1a)"
  let numbering-fig = "1"

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