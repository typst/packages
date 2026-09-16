// Example: Summary & Future Work (English)
#import "@preview/modern-szu-slides:0.1.0": *

#let summary-section = [
  = Summary

  == Key Contributions

  #block(
    fill: rgb("#f1f8ff"),
    stroke: 0.5pt + rgb("#0366d6"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Contribution 1: Framework Architecture*
    #v(4pt)
    Proposed an end-to-end adaptive representation learning pipeline.
    #v(4pt)
    Achieved 95.6% benchmark accuracy, setting a new competitive result.
  ]

  #v(8pt)

  #block(
    fill: rgb("#fff8f4"),
    stroke: 0.5pt + rgb("#d9730d"),
    inset: 15pt,
    radius: 6pt,
  )[
    *Contribution 2: Efficiency Optimization*
    #v(4pt)
    Designed dynamic compression and distillation, reducing size by 62%.
    #v(4pt)
    Delivered real-time performance at 45 FPS on edge platforms.
  ]
]
