#import "book-defaults.typ": *

// Table of contents
#let tableofcontents = {
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))
  outline(title: context states.localization.get().toc, indent: 1em)
}

// List of figures
#let listoffigures = {
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))
  outline(title: context states.localization.get().lof, target: figure.where(kind: image))
}

// List of tables
#let listoftables = {
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))
  outline(title: context states.localization.get().lot, target: figure.where(kind: table))
}