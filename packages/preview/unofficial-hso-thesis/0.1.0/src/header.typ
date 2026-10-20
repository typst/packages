// Header displaying the current Chapter and its name.
// 
// Kapitel 1 ____________ Einleitung
#let header-current-chapter-and-name(ctx) = context {
  let all-headings = query(heading.where(level: 1))
  let target-heading = all-headings.filter(h => h.location().page() <= here().page()).last(default: none)

  if target-heading != none {
    if target-heading.numbering != none and target-heading.numbering not in ("A.", "I.") {
      let num = counter(heading).at(target-heading.location())

      block(width: 100%, stroke: (bottom: 0.5pt + luma(50%)), inset: (bottom: 5pt))[
        #grid(
          columns: (1fr, 1fr),
          align: (left, right),
          [#ctx.strings.chapter #numbering(target-heading.numbering, ..num)], [#target-heading.body],
        )
      ]
    }
  }
}

// Header displaying the current Chapter and its name.
// 
// 1. Einleitung ____________________________
#let header-current-chapter(ctx) = context {
  let all-headings = query(heading.where(level: 1))
  let target-heading = all-headings.filter(h => h.location().page() <= here().page()).last(default: none)

  if target-heading != none {
    if target-heading.numbering != none and target-heading.numbering not in ("A.", "I.") {
      let num = counter(heading).at(target-heading.location())

      block(width: 100%, stroke: (bottom: 0.5pt + luma(50%)), inset: (bottom: 5pt))[
        #grid(
          columns: (1fr),
          align: (left),
          [#numbering(target-heading.numbering, ..num) #target-heading.body],
        )
      ]
    }
  }
}