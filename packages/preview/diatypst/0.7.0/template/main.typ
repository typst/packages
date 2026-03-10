#import "@preview/diatypst:0.7.0": *

#show: slides.with(
  title: "Diatypst", // Required
  subtitle: "easy slides in typst",
  date: "01.07.2024",
  authors: ("Author Name"),

  // Optional Styling (for more / explanation see in the typst universe)
  ratio: 16/9,
  layout: "medium",
  title-color: blue.darken(60%),
  toc: true,
)

= First Section

== First Slide

#lorem(20)

/ *Term*: Definition
