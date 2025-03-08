#import "languages.typ": *

// For supplement: either "Appendix", "Annex" or "Addendum"
#let appendix(
  heading-numbering: "A",
  supplement: "Appendix",
  // Applies numbering also for headings of level 2 and 3
  numbering-for-all: false,
  // Tries to keep the figure numbering "A1" joined instad of "A 1"
  // This creates inconsistency with the table of figures,
  // there will be shown "A 1" instead of "A1"
  joined-figure-numbering: true,
  body,
) = context {
  show heading: set heading(supplement: get-terms(text.lang).at(supplement))
  let multiple-level-1 = query(heading.where(level: 1, supplement: [#get-terms(text.lang).at(supplement)])).len() > 1
  let multiple-figures-on-level-1 = query(figure).len() > 1
  show heading.where(level: 1): set heading(numbering: heading-numbering) if multiple-level-1
  show heading.where(level: 2): set heading(numbering: heading-numbering) if numbering-for-all
  show heading.where(level: 3): set heading(numbering: heading-numbering) if numbering-for-all

  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: math.equation)).update(0)

  show figure.caption: it => {
    set par(first-line-indent: 0in)
    align(left)[
      #if (joined-figure-numbering) [
        *#it.supplement#context it.counter.display(it.numbering)*
      ] else [
        *#it.supplement #context it.counter.display(it.numbering)*
      ]

      #emph(it.body)
    ]
  }

  show heading.where(level: 1): it => align(center)[
    #pagebreak()
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

#let appendix-figure(
  body,
  caption: none,
  gap: 1.5em,
  kind: auto,
  numbering: "1",
  outlined: true,
  placement: none,
  scope: "column",
  supplement: "Figure",
  note: none,
  specific-note: none,
  probability-note: none,
  label: "",
  appendix-supplement: "Appendix",
  appendix-supplement-numbering: "A",
) = context [
  #let fig-supplement = supplement
  #let multiple-figures-on-level-1 = query(figure).len() > 1
  #let only-one-appendix = (
    query(heading.where(level: 1, supplement: [#get-terms(text.lang).at(appendix-supplement)])).len() == 1
  )
  #let figure-heading-numbering = counter(
    heading.where(level: 1, supplement: [#get-terms(text.lang).at(appendix-supplement)]),
  ).display("A")
  #if multiple-figures-on-level-1 and only-one-appendix {
    fig-supplement = [#fig-supplement #appendix-supplement-numbering]
  } else {
    fig-supplement = [#fig-supplement #figure-heading-numbering]
  }
  #figure(
    [
      #set par(first-line-indent: 0em)
      #body
      #set align(left)
      #if note != none [
        #emph(get-terms(text.lang).Note).
        #note
      ]
      #parbreak()
      #specific-note
      #parbreak()
      #probability-note
    ],
    caption: caption,
    gap: gap,
    kind: kind,
    numbering: numbering,
    outlined: outlined,
    placement: placement,
    scope: scope,
    supplement: fig-supplement,
  ) #std.label(label)
]
