// xwysyy.typ - facade re-exporting the package modules.
// Users do `#import "xwysyy.typ": *` to pull in themes, slides, and note.
// cetz / fletcher / theorion integrations are also exposed from this entrypoint.

#import "@preview/physica:0.9.8": *
#import "@preview/touying:0.7.4": *

#import "src/themes.typ": *
#import "src/elements.typ": *
#import "src/note.typ": *
#import "src/slides.typ": *
#import "src/extras.typ": *

#show: super-T-as-transpose
