#import "@preview/touying:0.6.2": *
#import "@preview/touying-htwk-stripes:1.0.0": *

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
  logo-institution: image("htwk.png"),
  logo-faculty: image("fim.png"),
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
