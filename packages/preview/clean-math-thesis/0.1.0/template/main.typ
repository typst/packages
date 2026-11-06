// global
#import "@preview/great-theorems:0.1.1": *
#import "@preview/hydra:0.5.1": hydra
#import "@preview/clean-math-thesis:0.1.0": template

//local 
#import "customization/colors.typ": *


#show: template.with(
  // personal/subject related stuff
  author: "Stuart Dent",
  title: "My Very Fancy and Good-Looking Thesis About Interesting Stuff",
  supervisor1: "Prof. Dr. Sue Persmart",
  supervisor2: "Prof. Dr. Ian Telligent",
  degree: "Example",
  program: "Example-Studies",
  university: "Example University",
  institute: "Example Institute",
  deadline: datetime.today().display(),
  city: "Example City",

  // file paths for logos etc.
  uni-logo: image("images/logo_placeholder.svg", width: 50%),
  institute-logo: image("images/logo_placeholder.svg", width: 50%),

  // formatting settings
  citation-style: "ieee",
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

  // chapters that need special placement
  abstract: include "chapter/abstract.typ",

  // colors
  colors: (cover-color: color1, heading-color: color2),
)

// ------------------- content -------------------
#include "chapter/introduction.typ"
#pagebreak()
#include "chapter/example_chapter.typ"
#pagebreak()
#include "chapter/conclusions_outlook.typ"
#pagebreak()
#include "chapter/appendix.typ"
#pagebreak()

// ------------------- bibliography -------------------
#bibliography("References.bib")
#pagebreak()

// ------------------- declaration -------------------
#include "chapter/declaration.typ"