#import "bookly-deps.typ": *
#import "bookly-helper.typ": *

// Table of contents
#let tableofcontents = context {
  show outline.entry: it => context {
    set par(first-line-indent: 0em) if states.par-indent.get()
    if states.tufte.get() {
      wideblock(side: "both")[#it]
    } else {
      it
    }
  }
  let title = context {
    set par(first-line-indent: 0em) if states.par-indent.get()
    states.localization.get().toc
  }
  outline(title: title, indent: 1em)
}

// List of figures
#let listoffigures = context {
  show outline.entry: it => context {
    set par(first-line-indent: 0em) if states.par-indent.get()
    let entry = context {
      let prev-outline-state = states.in-outline.get()
      states.in-outline.update(true)
      it
      states.in-outline.update(prev-outline-state)
    }

    if states.tufte.get() {
      wideblock(side: "both")[#entry]
    } else {
      entry
    }
  }
  outline(title: context states.localization.get().lof, target: figure.where(kind: image))
}

// List of tables
#let listoftables = context {
  show outline.entry: it => context {
    set par(first-line-indent: 0em) if states.par-indent.get()
    let entry = context {
      let prev-outline-state = states.in-outline.get()
      states.in-outline.update(true)
      it
      states.in-outline.update(prev-outline-state)
    }

    if states.tufte.get() {
      wideblock(side: "both")[#entry]
    } else {
      entry
    }
  }
  outline(title: context states.localization.get().lot, target: figure.where(kind: table))
}