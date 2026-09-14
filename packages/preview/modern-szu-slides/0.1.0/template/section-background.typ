// Example: Research Background section
// Replace with your own content or delete this file.

#import "slide-functions.typ": small-title, card, conclusion-card

#let background-section = [
  = Section Title

  == Subsection One

  Your content here. You can use *bold*, _italic_, $x + y = z$, and more.

  #card(
    [Card Title],
    [Card body text.  Cards are useful for highlighting key points.],
  )

  #pagebreak()

  == Subsection Two

  #small-title[A Highlighted Point]

  - Item one
  - Item two
  - Item three

  #conclusion-card(
    [Key Insight],
    [Summarize your main finding or argument here.],
  )
]
