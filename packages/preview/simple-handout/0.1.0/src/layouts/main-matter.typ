#import "../utils/numbering.typ": custom-numbering

#import "../imports.typ": i-figured

#let main-matter(
  // from entry
  twoside: false,
  // options
  page-start: 1,
  page-numbering: "1",
  heading-numbering: (
    first-level: "第一章 ",
    depth: 4,
    format: "1.1 ",
  ),
  // self
  it,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  // reset the counter
  counter(page).update(page-start)
  set page(numbering: page-numbering)

  show heading: i-figured.reset-counters

  set heading(
    numbering: custom-numbering.with(
      first-level: heading-numbering.first-level,
      depth: heading-numbering.depth,
      heading-numbering.format,
    ),
  )

  show math.equation.where(block: true): i-figured.show-equation

  show figure: i-figured.show-figure

  it
}
