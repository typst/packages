#import "@preview/not-fraunhofer-iaf:0.1.0": *

#show: slides.with(
  title: "Diatypst", // Required
  subtitle: "easy slides in typst",
  date: "01.07.2024",
  authors: ("Author Name"),

  // Optional Styling (for more and explanation of options take a look at the typst universe)
  ratio: 16/9,
  layout: "medium",
  title-color: blue.darken(60%),
  toc: true,
)

#show: slides.with(
  title: "IAF Template",
  subtitle: "A template for the IAF",
  date: datetime.today().display("[day]. [month repr:long] [year]"),
  authors: ("Max Mustermann"),
  footer-clearance: "Public"
)

= First Section

== First Slide
#lorem(20)