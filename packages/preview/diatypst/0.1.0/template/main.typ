#import "@preview/diatypst:0.1.0": *

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
  counter: true,
)

#outline()

= First Section

== First Slide

#lorem(20)

/ *Term*: Definition

