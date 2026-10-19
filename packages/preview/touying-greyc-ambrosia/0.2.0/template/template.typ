#import "@preview/touying-greyc-ambrosia:0.2.0": *

// Edit these defaults in your IDE preview; no command-line inputs are needed.
#let flavor = "legacy"
#let palette = "greyc-light"
#show: greyc-theme.with(
  // Geometry: legacy | simple | cambridge | darmstadt | dewdrop | stargazer | minimal | portico
  flavor: flavor,
  // Lab presets: greyc-light | greyc-ivory | greyc-nocturne | greyc-charcoal
  palette: palette,
  // block-style: "poster",     // plain | framed | poster | outlined | stripe
  // footcite-marker: "author-year",  // number | local | key also available
  // team: "safe",
  aspect-ratio: "16-9",
  config-info(
    title: [Research In Your Own Flavor],
    subtitle: [An Unofficial GREYC Presentation Theme],
    author: [Alex Researcher],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
    institution: [GREYC · Université de Caen Normandie · ENSICAEN · CNRS],
  ),
)

#title-slide()

#outline-slide()

= Example Section

== Example Slide 1

A slide with *important information*.

#focus-slide()[
  Wake up!
]

== Example Slide 2

=== Example Heading

// kind selects a palette-aware meaning: accent | info | success | warning | danger | neutral
#ambrosia-block(title: [Example Block], kind: "info")[
  Block content.
]

#ambrosia-block(style: "framed", title: [Example Framed Block], kind: "warning")[
  Block content.
]

#ending-slide(title: "The End")[
  Thanks for your attention!
]

#show: appendix

== Backup Slide

A slide with #alert[extra information].
