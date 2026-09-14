// Example: Summary & Outlook section

#let summary-section = [
  = Summary & Outlook

  == Summary

  #block(
    fill: rgb("#f1f8ff"),
    stroke: 0.5pt + rgb("#0366d6"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Work One*
    #v(4pt)
    Strategy: Brief description of your approach.
    #v(4pt)
    Results: Key metric = value
  ]

  #v(8pt)

  #block(
    fill: rgb("#fff8f4"),
    stroke: 0.5pt + rgb("#d9730d"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Work Two*
    #v(4pt)
    Strategy: Brief description of your approach.
    #v(4pt)
    Results: Key metric = value
  ]

  == Future Work

  + Direction one
  + Direction two
  + Direction three
]
