# hydra
Hydra is a Typst package allowing you to easily display the heading like elements anywhere in your
document. Its primary focus is to provide the reader with a reminder of where they currently are in
your document only when it is needed.

## Example
```typst
#import "@preview/hydra:0.6.3": hydra

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
![A Lorem Ipsum example document of four pages showing "1 Introduction" at the top of the first page, but no header. The second page shows "2 Content" followed by "2.1 First Section" at the top, again with no header. On the third page the header shows "2 Contet" on the right side despite "2.2 Second Section" at the top. The final page shows "2.2 Second Section" on the left side of the header. The example document shows of the starting page and book mode checks in action.][thumbnail]

## Documentation
For a more in-depth description of hydra's functionality and the reference read its [manual].

## Contribution
For contributing, please take a look [CONTRIBUTING][contrib].

## Etymology
The package name hydra /ˈhaɪdrə/ is a word play on headings and headers, inspired by the monster in
greek and roman mythology resembling a serpent with many heads.

[thumbnail]: assets/images/thumbnail.png
[manual]: assets/manual.pdf
[contrib]: CONTRIBUTING.md
