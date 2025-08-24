#import "@preview/diatypst:0.2.0": *

#show: slides.with(
  title: "Diatypst", // Required
  subtitle: "easy slides in typst",
  date: "01.07.2024",
  authors: ("Author Name"),

  // Optional Styling
  ratio: 16/9,
  layout: "medium",
  title-color: green.darken(60%),
  footer: true,
  count: true,
  toc: true,
)

#outline()

= First Section

== First Slide

#lorem(20)

/ *Term*: Definition

