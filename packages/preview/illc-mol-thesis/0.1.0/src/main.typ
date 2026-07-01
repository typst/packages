#import "@preview/great-theorems:0.1.1": *
#import "@preview/rich-counters:0.2.1": *

// A show rule for the template.
#let mol-thesis(body) = [
  // LaTeX-like look from https://typst.app/docs/guides/guide-for-latex-users
  #set page(margin: 1.2in, footer-descent: 20%)
  #set par(leading: .85em, first-line-indent: 1.8em, justify: true)
  #set text(font: "New Computer Modern", size: 9.75pt)
  // New computer Moderno Mono is not shipped with Typst, and it would be
  // excessive to only ship it with the package for raw text, as it requires its
  // own CLi flag
  // #show raw: set text(font: "New Computer Modern Mono")
  #show heading: set block(above: 1.4em, below: 1em)

  // MoL thesis look from https://codeberg.org/m4lvin/illc-mol-thesis-template
  #set page(numbering: "1")
  #set heading(numbering: "1.1.1.1")
  #set outline(fill: repeat(". "), indent: true)
  #set cite(style: "alphanumeric")
  #set bibliography(style: "elsevier-vancouver")
  #show: great-theorems-init

  #body
]

// A parametric, non-numbered thesis titlepage that follows the
// recommendations of the Master of Logic.
#let mol-titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defence-date: "August 28, 2005",
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
) = align(alignment.center)[
  // Size of the thesis's title
  #let title-size = 17pt
  // Size of frontpage elements that should be smaller of the thesis's title
  // alone
  #let subtitle-size = 12pt

  #set page(numbering: none)

  #v(30pt)

  #text(smallcaps(title), size: title-size, weight: 100)

  #v(40pt)

  #text([*MSc Thesis* _(Afstudeerscriptie)_], size: subtitle-size)

  written by

  *#author*

    under the supervision of #supervisors.map(x => [*#x*]).join(", ", last:
    " and "), and submitted to the

    Examinations Board in partial fullfillment of the requirements for the
    degree of

  #text([*#degree*], size: subtitle-size)

  at the _Universiteit van Amsterdam_.

  #v(50pt)

  #box(width: 75%,
    par(spacing: 6pt, 
      columns(2, gutter: -10%,
        align(alignment.left,
          par(first-line-indent: 0em)[
            *Date of the public defence:*

            _#defence-date _

            #colbreak()

            *Members of the Thesis Committee:*

            #committee.join("\n")
          ]
        )
      )
    )
  )

  #align(bottom, image("../img/illclogo.svg", alt: "ILLC Logo. A 3-by-3 jigsaw puzzle. The
      center piece is white, while the surrounding pieces are black. The text
      below the puzzle reads 'Institute for Logic, Language, and Computation'",
      width: 65%))

  #pagebreak()
]

// A non-numbered page dedicated to the thesis abstract.
#let mol-abstract(body) = [
  #set page(numbering: none)
  #align(center+horizon, heading("Abstract", numbering: none, outlined: false))
  #body
  #pagebreak()
  #counter(page).update(1)
]

// A first-level heading dedicated to thesis chapters.
#let mol-chapter(body) = [
  #pagebreak()
  #hide(
    heading(body,
      hanging-indent: 0pt,
      level: 1,
      supplement: [Chapter])
  )
  #text(size: 28pt, weight: "bold")[
    #set par(first-line-indent: 0pt)
    #text(size: 24pt, [Chapter #context counter(heading).display()])

    #body]
]

// A counter for mathematical blocks
#let mathcounter = rich-counter(
  identifier: "mathblocks",
  inherited_levels: 1
)

// A block for mathematical definitions
#let definition = mathblock(
  blocktitle: "Definition",
  counter: mathcounter,
)

// A block for mathematical theorems
#let theorem = mathblock(
  blocktitle: "Theorem",
  counter: mathcounter,
)

// A block for mathematical lemmas
#let lemma = mathblock(
  blocktitle: "Lemma",
  counter: mathcounter,
)

// A block for mathematical corollaries
#let corollary = mathblock(
  blocktitle: "Corollary",
  counter: mathcounter,
)

// A block for mathematical remarks
#let remark = mathblock(
  blocktitle: "Remark",
  prefix: [_Remark._],
)

// A block for mathematical proofs
#let proof = proofblock()
