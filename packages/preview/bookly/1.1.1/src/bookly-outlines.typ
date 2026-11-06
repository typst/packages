#import "bookly-helper.typ": *

// Table of contents
#let tableofcontents = {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.tufte.get() {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    fullwidth(dx: dxr, it)
  }
  outline(title: context states.localization.get().toc, indent: 1em)
}

// List of figures
#let listoffigures = {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.tufte.get() {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    fullwidth(dx: dxr, it)
  }
  outline(title: context states.localization.get().lof, target: figure.where(kind: image))
}

// List of tables
#let listoftables = {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.tufte.get() {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    fullwidth(dx: dxr, it)
  }
  outline(title: context states.localization.get().lot, target: figure.where(kind: table))
}