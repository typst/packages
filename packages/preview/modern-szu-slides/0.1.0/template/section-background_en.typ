// Example: Research Background section (English)
// Replace with your own content or delete this file.

#import "slide-functions.typ": small-title, card, conclusion-card

#let background-section = [
  = Research Background

  == Background & Motivation

  Your content here. You can use *bold*, _italic_, $x + y = z$, and more.

  #card(
    [Research Objective],
    [Describe the problem context and core motivation here. Cards are useful for highlighting key points.],
  )

  #pagebreak()

  == Key Challenges

  #small-title[Problem Formulation]

  - Challenge one: High computational complexity in large-scale datasets
  - Challenge two: Limited generalizability across heterogeneous domains
  - Challenge three: Robustness under noisy environmental conditions

  #conclusion-card(
    [Key Insight],
    [Summarize your main finding, core hypothesis, or key takeaway here.],
  )
]
