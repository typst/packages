#import "@local/typst2anki:0.1.0": *
#import "@preview/alchemist:0.1.3": *
#import "@preview/curryst:0.3.0": rule, proof-tree

#let conf(
  doc,
) = {

  set raw(theme: "assets/halcyon.tmTheme")
  show raw: it => block(
    fill: rgb("#1d2433"),
    inset: 10pt,
    radius: 0pt,
    width: auto,
    text(fill: rgb("#a2aabc"), it)

  )
  doc
}
