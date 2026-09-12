// Starter presentation using the Matcha theme.
// Build with: typst compile main.typ

#import "@preview/touying-matcha:0.1.0": *

#show: matcha-theme.with(
  aspect-ratio: "16-9",
  footer: none,
)

#title-slide(
  title: "My Presentation",
  author: "Your Name",
  date: datetime.today(),
)

= Section

== Slide Title

#slide[
  Content goes here...
]

#focus-slide[
  Key takeaway
]
