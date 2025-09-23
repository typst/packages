#import "@preview/hydra:0.6.2": hydra
// needs context
// heading generation, depends on if the page is even or odd
#let custom-header() = {
  if calc.even(counter(page).get().at(0)) {
    let entry = hydra(skip-starting: true, 1)
    if entry != none {
      entry = if entry.has("text") {
        entry.text
      } else {
        entry.children.first() + [. ] + entry.children.last()
      }
      align(left)[#smallcaps(entry)]
      line(length: 100%, stroke: (thickness: 0.1pt))
    }
  } else {
    let entry = hydra(2, skip-starting: false)
    if entry == none {
      entry = hydra(1)
    }
    if entry != none {
      entry = if entry.has("text") {
        entry.text
      } else {
        entry.children.first() + [. ] + entry.children.last()
      }
      align(right)[#smallcaps(entry)]
      line(length: 100%, stroke: (thickness: 0.1pt))
    }
  }
}

