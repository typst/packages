#import "languages.typ": *
#import "apa-figure.typ": *

// https://apastyle.apa.org/style-grammar-guidelines/paper-format/appendices
#let appendix(
  heading-numbering: "A",
  supplement: "Appendix",
  // Applies numbering also for headings of level 2 and 3
  numbering-for-all: false,
  body,
) = context {
  set heading(supplement: get-terms(text.lang, text.script).at(supplement))
  let multiple-level-1 = (
    query(heading.where(level: 1, supplement: [#get-terms(text.lang, text.script).at(supplement)])).len() > 1
  )
  let multiple-figures-on-level-1 = query(figure).len() > 1
  show heading.where(level: 1): set heading(numbering: heading-numbering) if multiple-level-1
  show heading.where(level: 2).or(heading.where(level: 3)): set heading(
    numbering: heading-numbering,
  ) if numbering-for-all
  set figure(
    placement: none,
    numbering: n => apa-figure-numbering(n),
  )

  counter(heading).update(0)
  show heading.where(level: 1): it => {
    pagebreak()
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)
    block[
      #it.supplement
      #if (multiple-level-1) {
        numbering(it.numbering, ..counter(heading).at(it.location()))
      }

      #it.body
    ]
  }

  show heading.where(level: 2): it => block[
    #if (numbering-for-all) [
      #numbering(it.numbering, ..counter(heading).at(it.location()))
    ]
    #it.body
  ]

  show heading.where(level: 3): it => block[
    #if numbering-for-all [
      #numbering(it.numbering, ..counter(heading).at(it.location()))
    ]
    #it.body
  ]

  body
}

#let appendix-outline(
  ..args,
) = context {
  let appendices = query(heading.where(level: 1))
  let appendix-supplement = appendices.last().supplement
  outline(
    ..args,
    target: heading.where(
      supplement: appendix-supplement,
    ),
  )
}
