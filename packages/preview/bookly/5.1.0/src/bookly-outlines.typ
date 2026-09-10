#import "bookly-deps.typ": *
#import "bookly-helper.typ": *

#let outline-entry(it) = {
  set par(first-line-indent: 0em) if states.par-indent.get()

  it
}

// Table of contents
#let tableofcontents = context {
  show metadata.where(label: <bookly-title>): it => it.value.short
  show outline.entry: outline-entry
  outline(title: states.localization.get().toc, indent: 1em)
}

// List of figures
#let listoffigures = context {
  show metadata.where(label: <bookly-title>): it => it.value.short
  show outline.entry: outline-entry

  outline(title: states.localization.get().lof, target: figure.where(kind: image))
}

// List of tables
#let listoftables = context {
  show metadata.where(label: <bookly-title>): it => it.value.short
  show outline.entry: outline-entry

  outline(title: states.localization.get().lot, target: figure.where(kind: table))
}