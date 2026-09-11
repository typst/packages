// Example: Main Content section (English)

#import "slide-functions.typ": card, conclusion-card, small-title

#let placeholder = "assets/szu-logo-gold.svg"

#let work-section = [
  = Main Work

  == Topic One

  Describe your first contribution or proposed architecture here.

  #align(center)[
    #image(placeholder, width: 40%)
    #text(size: 12pt)[Figure 1: Replace this placeholder with your architecture diagram.]
  ]

  #pagebreak()

  == Topic Two

  #card(
    [Key Methodology Components],
    [
      + Component A: Dynamic feature alignment module
      + Component B: Multi-scale attention aggregation mechanism
      + Component C: Contrastive regularization objective
    ],
    fill: rgb("#fff8f4"),
  )

  #pagebreak()

  == Experimental Results

  #small-title[Performance Evaluation]

  #conclusion-card(
    [Conclusion],
    [The proposed approach achieves state-of-the-art results with 15% lower latency and 4.2% higher accuracy on standard benchmarks.],
  )
]
