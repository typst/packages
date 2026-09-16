// Example: Background & Motivation (English)
#import "@preview/modern-szu-slides:0.1.0": *

#let background-section = [
  = Background

  == Motivation & Problem Definition

  Describe the research motivation and background here. Typst natively supports *bold*, _italic_, inline formulas $x + y = z$, and more.

  #card(
    [Research Objective],
    [Formulate the core objective and primary research question clearly. Use card components to emphasize fundamental definitions and scope.],
  )

  #pagebreak()

  == Core Challenges

  Key limitations and unresolved challenges in existing state-of-the-art literature:

  #v(0.5em)

  #conclusion-card(
    title: [Key Technical Challenges],
    [
      - *Challenge 1: High-dimensional Representation* --- Sparse embedding space and complex multi-modal alignment.
      - *Challenge 2: Real-time Latency Constraints* --- High computational complexity under edge deployment scenarios.
    ],
  )
]
