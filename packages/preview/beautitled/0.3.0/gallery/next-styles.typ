// Gallery renders for the next-generation heading collection.
#import "@preview/beautitled:0.3.0": *

#set page(width: 16cm, height: 16cm, margin: 1.15cm)
#set text(font: "Libertinus Serif", size: 10pt)
#set par(leading: 0.62em)

#let sample(name, face: none) = [
  #reset-counters()
  #beautitled-setup(
    style: name,
    heading-font: face,
    primary-color: rgb("#17212b"),
    secondary-color: rgb("#6f7b86"),
    accent-color: rgb("#1877a8"),
    show-chapter-number: true,
    show-section-number: true,
    show-subsection-number: true,
    chapter-prefix: "Chapter",
    section-prefix: "Section",
  )

  #chapter[Designing with restraint]
  A clear hierarchy should guide the eye without competing with the content.

  #section[Rhythm and proportion]
  Good spacing makes structure legible before a single word is read.

  #subsection[Small details, quiet confidence]
  Fine rules, aligned numbers, and measured contrast create a calm page.

  #subsubsection[An additional level]
  The hierarchy remains visible even at its smallest scale.
]

#sample("folio", face: "Libertinus Serif")
#pagebreak()
#sample("terrace", face: "Linux Biolinum")
#pagebreak()
#sample("anchor", face: "Linux Biolinum")
