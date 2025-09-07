# hydra
Hydra is a Typst package allowing you to easily display the heading like elements anywhere in your
document. It's primary focus is to provide the reader with a reminder of where they currently are in
your document only when it is needed.

## Example
```typst
#import "@preview/hydra:0.5.2": hydra

#set page(paper: "a7", margin: (y: 4em), numbering: "1", header: context {
  if calc.odd(here().page()) {
    align(right, emph(hydra(1)))
  } else {
    align(left, emph(hydra(2)))
  }
  line(length: 100%)
})
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it

= Introduction
#lorem(50)

= Content
== First Section
#lorem(50)
== Second Section
#lorem(100)
```
![ex]

## Documentation
For a more in-depth description of hydra's functionality and the reference read its [manual].

## Contribution
For contributing, please take a look [CONTRIBUTING][contrib].

## Etymology
The package name hydra /ˈhaɪdrə/ is a word play headings and headers, inspired by the monster in
greek and roman mythology resembling a serpent with many heads.

[ex]: examples/example.png
[manual]: doc/manual.pdf
[contrib]: CONTRIBUTING.md
