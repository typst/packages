#import "languages.typ": *
#import "apa-figure.typ": *

// For supplement: either "Appendix", "Annex" or "Addendum"
#let appendix(
  heading-numbering: "A",
  supplement: "Appendix",
  // Applies numbering also for headings of level 2 and 3
  numbering-for-all: false,
  body,
) = context {
  show heading: set heading(supplement: get-terms(text.lang).at(supplement))
  let multiple-level-1 = query(heading.where(level: 1, supplement: [#get-terms(text.lang).at(supplement)])).len() > 1
  let multiple-figures-on-level-1 = query(figure).len() > 1
  show heading.where(level: 1): set heading(numbering: heading-numbering) if multiple-level-1
  show heading.where(level: 2): set heading(numbering: heading-numbering) if numbering-for-all
  show heading.where(level: 3): set heading(numbering: heading-numbering) if numbering-for-all
  set figure(
    placement: none,
    numbering: n => apa-figure-numbering(n),
  )

  counter(heading).update(0)

  show heading.where(level: 1): it => align(center)[
    #pagebreak()
    #counter(figure.where(kind: image)).update(0)
    #counter(figure.where(kind: table)).update(0)
    #counter(figure.where(kind: math.equation)).update(0)
    #counter(figure.where(kind: raw)).update(0)
    #it.supplement
    #if (multiple-level-1) {
      numbering(it.numbering, ..counter(heading).at(it.location()))
    }
    #it
  ]

  show heading.where(level: 2): it => par(first-line-indent: 0in)[
    #if (numbering-for-all) [
      #numbering(it.numbering, ..counter(heading).at(it.location()))
    ]
    #it.body
  ]

  show heading.where(level: 3): it => par(
    first-line-indent: 0in,
    emph[
      #if numbering-for-all [
        #numbering(it.numbering, ..counter(heading).at(it.location()))
      ]
      #it.body
    ],
  )

  body
}

#let appendix-outline(
  depth: none,
  indent: auto,
  heading-supplement: "Appendix",
  title: auto,
) = context [
  #outline(
    title: title,
    depth: depth,
    indent: indent,
    target: heading.where(supplement: [#get-terms(text.lang).at(heading-supplement)]),
  )
]
