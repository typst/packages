#import "@preview/hydra:0.6.2": hydra, anchor
#import "/src/utils.typ": line-height
#import "/src/elements/colors.typ": colors
#import "/src/elements/note-figure.typ": note-figure-helper

#let break-h1 = state("break-h1", true)

#let inline-heading-1(doc) = {
  break-h1.update(false)
  heading(level: 1, doc)
  break-h1.update(true)
}

// settings derived from guideline of vstl:
// https://tu-dresden.de/bu/verkehr/ila/vkstrl/ressourcen/dateien/studium/Richtlinien-Vorlagen/hinweise_wiss_arbeiten.pdf

#let opinionated(doc, target: none) = {
  // Heading spacing
  // p. 22
  show heading: set block(
    above: line-height(1.5em * 2),
    below: line-height(1.5em * 1.25)
  )

  // Lists
  // p. 22f
  set list(marker: ([–], [•], [‣]))
  set enum(full: true, numbering: (..nums) => {
    let levels = nums.pos()
    
    if calc.rem(levels.len(), 2) == 0 {
      numbering("a)", levels.at(levels.len() - 1))
    } else {
      numbering("1.", levels.at(levels.len() - 1))
    }
  })

  // Numbered math equations
  // p 26
  set math.equation(numbering: "(1)")

  set page(
    header: {
      context [
        #set text(font: "Noto Sans", size: 9pt)
        #let headers = hydra(1, book: target == "print-alternating")

        // When in book mode skip every second page
        #if target == "print-alternating" and headers != none and calc.odd(here().page()) {
          headers = []
        }
        
        #if headers != none {
          place(
            top,
            dy: 9mm, // (18mm / 2)
            grid(
              columns: (1fr, auto),
              align: left,
              gutter: .5em,
              inset: (bottom: .5em),
              headers,
              grid.hline(stroke: 1pt),
            )
          )
        }
      ]
    },
    footer: [
      #set text(font: "Noto Sans")
      #if target == "print-alternating" {
        context {
          if calc.odd(here().page()) {
            place(
              bottom + right,
              dy: -9mm,
              counter(page).display()
            )
          } else {
            place(
              bottom + left,
              dy: -9mm,
              counter(page).display()
            )
          }
        }
      } else if (target == "print") {
        place(
          bottom + right,
          dy: -9mm,
          context counter(page).display()
        )
      }  else {
        place(
          bottom + center,
          dy: -9mm,
          context counter(page).display()
        )
      }
    ],
  )

  // Pagebreak before H1
  // p. 22
  show heading.where(level: 1, outlined: true): it => {
    if break-h1.get() {
      pagebreak(weak: true) + it
    } else {
      it
    }
  }

  set highlight(fill: none, extent: 0.2em)
  show highlight: it => {

    let it-1 = [
      #set text(
        top-edge: "ascender",
      )
      #it
    ]

    let it-2 = [
      #set text(
        top-edge: "ascender",
        bottom-edge: "descender"
      )
      #it
    ]
    
    context {
      let size-1 = measure(it-1)
      let size-2 = measure(it-2)

      box(
        outset: (left: 0.2em, right: 0.2em),
        height: size-2.height,
        width: size-2.width,
        fill: state("color-tertiary").get(),
        baseline: (size-2.height -  size-1.height),
        it-2
      )
    }
  }

  show: note-figure-helper

  show outline.entry.where(level: 1): set text(size: 12pt)
  
  set bibliography(style: "/src/iso690-author-date-de.csl")

  doc
}