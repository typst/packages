// xwysyy.typ — facade re-exporting every core submodule.
// Users do `#import "xwysyy.typ": *` to pull in themes, slides, and note.
// Optional cetz / fletcher / theorion integrations live in `xwysyy-extras.typ`.

#import "@preview/physica:0.9.8": *
#import "@preview/touying:0.7.4": *

#import "src/themes.typ": *
#import "src/elements.typ": *
#import "src/note.typ": *
#import "src/slides.typ": *

#show: super-T-as-transpose
