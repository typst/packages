#import "@preview/touying-htwk-stripes:1.0.1": *

#show: htwk-stripes-theme.with(
  aspect-ratio: "4-3",
  title: [Title],
  subtitle: [Subtitle],
  authors: ("Author A",),
  authors-title-slide:
  [
    Author A
  ],
  date: datetime.today(),
  institution: [HTWK Leipzig],
  logo-institution: image("uoe.svg"),
  logo-faculty: image("foe.svg"),
)

#htwk-title-slide()

#htwk-outline()

= Example Section Title
== Example Slide
A slide with *important information*.

= Second Section
== First Slide
Hello

== Second Slide
World

#htwk-sources()[...]
