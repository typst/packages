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
#let listoffigures = context {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.tufte.get() {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    let entry = context {
      let prev-outline-state = states.in-outline.get()
      states.in-outline.update(true)
      it
      states.in-outline.update(prev-outline-state)
    }
    fullwidth(dx: dxr, entry)
  }
  outline(title: context states.localization.get().lof, target: figure.where(kind: image))
}

// List of tables
#let listoftables = context {
  show outline.entry: it => context {
    let dxl = 0%
    let dxr = 0%
    if states.tufte.get() {
      dxl = 8.17%
      dxr = -17%
    }
    show: move.with(dx: dxl)
    let entry = context {
      let prev-outline-state = states.in-outline.get()
      states.in-outline.update(true)
      it
      states.in-outline.update(prev-outline-state)
    }
    fullwidth(dx: dxr, entry)
  }
  outline(title: context states.localization.get().lot, target: figure.where(kind: table))
}