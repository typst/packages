// Example: Core Methodology & Work (English)
#import "@preview/modern-szu-slides:0.1.0": *

#let work-section = [
  = Methodology

  == System Architecture

  Present the proposed architecture and data flow in detail.

  #align(center)[
    #rect(
      width: 70%,
      height: 100pt,
      fill: rgb("#fcf7f8"),
      stroke: 1pt + rgb("#a20040").lighten(60%),
      radius: 6pt,
    )[
      #align(center + horizon)[
        #text(size: 13pt, fill: rgb("#a20040"))[📊 Architecture Diagram (Placeholder)]
      ]
    ]
    #v(0.3em)
    #text(size: 11pt, fill: gray.darken(20%))[Figure 1: Overall system pipeline architecture]
  ]

  #pagebreak()

  == Experimental Results & Benchmarks

  Quantitative evaluation against state-of-the-art baselines:

  #align(center)[
    #table(
      columns: (1.5fr, 1fr, 1fr, 1.2fr),
      align: center + horizon,
      stroke: (x, y) => if y == 0 { (bottom: 1.2pt + rgb("#a20040")) } else { (bottom: 0.5pt + luma(220)) },
      fill: (x, y) => if y == 0 { rgb("#fbf7f8") } else { none },
      table.header([*Method*], [*Accuracy (%)*], [*F1-Score*], [*Latency (ms)*]),
      [Baseline A], [88.4], [0.86], [45.2],
      [Baseline B], [91.2], [0.89], [38.7],
      [*Ours (Proposed)*], [*95.6*], [*0.94*], [*22.1*],
    )
  ]
]
