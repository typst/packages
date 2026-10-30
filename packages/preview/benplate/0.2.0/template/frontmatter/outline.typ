#import "@preview/outrageous:0.4.1" as outrageous

#let default-outline() = {
  show outline.entry: outrageous.show-entry.with(
    font: (auto,),
    vspace: (15pt, none),
  )

  show outline: it => {
    set heading(outlined: true)
    it
  }

  // Show outline
  outline(depth: 3)
}
