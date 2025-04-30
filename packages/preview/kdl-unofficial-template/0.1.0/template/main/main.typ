#import "@preview/kdl-unofficial-template:0.1.0" as kdl
// NOTE: before compiling follow the README.md and install the fonts used in this template
//
// if you use direnv you can compile with
// typst compile main.typ
//
// otherwise
// typst compile main.typ --root $PWD --font-path ./assets/fonts

#show: kdl.template

#kdl.pages.title.with(
  title: "A tall tale",
  author: "Baron von Münchhausen",
  size: 64pt // optional
)()

#kdl.pages.blank
#kdl.pages.blank

#include("./chapters/01-intro.typ")
#kdl.pages.toc
#include("./chapters/02-pre-gen.typ")

#bibliography("./assets/bibliography.bib", full: true, style: "pensoft")
