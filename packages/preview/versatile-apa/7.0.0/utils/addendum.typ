#import "languages.typ": *

// for supplement: either "Appendix" or "Annex"
#let addendum(
  heading-numbering: "A.1.",
  supplement: "Appendix",
  body,
) = (
  context {
    show heading: set heading(
      supplement: get-terms(text.lang).at(supplement),
      numbering: heading-numbering,
    )

    counter(heading).update(0)

    show heading.where(level: 1): it => align(center)[
      #pagebreak()
      #it.supplement
      #numbering(it.numbering, ..counter(heading).at(it.location()))
      #it.body
    ]

    show heading.where(level: 2): it => par(first-line-indent: 0in)[
      #numbering(it.numbering, ..counter(heading).at(it.location()))
      #it.body
    ]

    show heading.where(level: 3): it => par(
      first-line-indent: 0in,
      emph[
        #numbering(it.numbering, ..counter(heading).at(it.location()))
        #it.body
      ],
    )

    body
  }
)