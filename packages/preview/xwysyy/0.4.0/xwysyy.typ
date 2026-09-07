// xwysyy.typ — facade re-exporting every core submodule.
// Users do `#import "xwysyy.typ": *` to pull in themes, slides, and note.
// Optional cetz / fletcher / theorion integrations load through `xwysyy-extras()`.

#import "@preview/physica:0.9.8": *
#import "@preview/touying:0.7.4": *

#import "src/themes.typ": *
#import "src/elements.typ": *
#import "src/note.typ": *
#import "src/slides.typ": *
#import "src/layout.typ": *

#let xwysyy-extras() = {
  import "xwysyy-extras.typ" as extras
  extras
}

#show: super-T-as-transpose
