#import "../utils/numbering.typ": custom-numbering

#import "../imports.typ": i-figured

#let back-matter(
  // from entry
  twoside: false,
  // options
  heading-numbering: (
    first-level: "附录A ",
    depth: 4,
    format: "1.1 ",
  ),
  reset-counter: false,
  figure-numbering: "A.1",
  equation-numbering: "(A.1)",
  // self
  it,
) = {
  /// Render the back matter page
  pagebreak(weak: true, to: if twoside { "odd" })

  set heading(
    numbering: custom-numbering(
      first-level: heading-numbering.first-level,
      depth: heading-numbering.depth,
      heading-numbering.format,
    ),
  )

  if reset-counter { counter(heading).update(0) }

  show figure: i-figured.show-figure.with(numbering: figure-numbering)

  show math.equation: i-figured.show-equation.with(numbering: equation-numbering)

  it
}
