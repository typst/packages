#import "@preview/touying:0.6.2": *
#import "@preview/touying-greyc-ambrosia:0.1.0": *

#show: greyc-theme.with(
  // legacy | simple | cambridge | darmstadt | dewdrop | stargazer
  flavor: "legacy",
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
    institution: [Institution],
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

#tblock(title: [Example Block], fill: blue)[
  Block content.
]

#framed-tblock(title: [Example Framed Block], fill: red)[
  Block content.
]

#ending-slide(title: "The End")[
  Thanks for your attention!
]

#show: appendix

== Backup Slide

A slide with #alert[extra information].
