#import "../utils/font.typ": use-size
#import "../utils/util.typ": array-at
#import "../utils/numbering.typ": custom-numbering

#import "../imports.typ": i-figured

#let main-matter(
  // from entry
  twoside: false,
  // options
  page-numbering: "1",
  heading-numbering: (first-level: "第1章", depth: 4, format: "1.1"),
  reset-footnote: true,
  // self
  it,
) = {
  set page(numbering: page-numbering)

  show heading: i-figured.reset-counters

  set heading(
    numbering: custom-numbering.with(
      first-level: heading-numbering.first-level,
      depth: heading-numbering.depth,
      heading-numbering.format,
    ),
  )

  show figure: i-figured.show-figure

  show math.equation.where(block: true): i-figured.show-equation

  set page(header: { if reset-footnote { counter(footnote).update(0) } })

  context {
    if calc.even(here().page()) {
      set page(numbering: "I", header: none)
      pagebreak() + " "
    }
  }

  counter(page).update(1)

  it
}
