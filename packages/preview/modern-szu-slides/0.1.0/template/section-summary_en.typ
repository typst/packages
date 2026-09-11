// Example: Summary & Outlook section (English)

#let summary-section = [
  = Summary & Outlook

  == Summary

  #block(
    fill: rgb("#f1f8ff"),
    stroke: 0.5pt + rgb("#0366d6"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Contribution One: Framework Design*
    #v(4pt)
    Strategy: Designed an end-to-end scalable representation learning model.
    #v(4pt)
    Results: Achieved 94.8% accuracy on benchmark test suite.
  ]

  #v(8pt)

  #block(
    fill: rgb("#fff8f4"),
    stroke: 0.5pt + rgb("#d9730d"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Contribution Two: Efficiency Optimization*
    #v(4pt)
    Strategy: Developed lightweight pruning and quantization algorithms.
    #v(4pt)
    Results: Reduced parameter count by 42% with negligible accuracy drop.
  ]

  == Future Work

  + Exploring cross-domain generalization in zero-shot transfer scenarios
  + Extending the methodology to real-time embedded and mobile edge devices
  + Integrating multimodal foundation models for broader downstream tasks
]
