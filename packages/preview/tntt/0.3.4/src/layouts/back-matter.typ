#import "../utils/numbering.typ": custom-numbering

#import "../imports.typ": i-figured

/// Back Matter Layout
///
/// - twoside (bool): Whether to use two-sided layout.
/// - heading-numbering (str): The numbering format for headings.
/// - figure-numbering (str): The numbering format for figures.
/// - figure-outlined (bool): Whether to outline figure numbers in figures index page.
/// - equation-numbering (str): The numbering format for equations.
/// - reset-counter (bool): Whether to reset the heading counter.
/// - it (content): The content to be displayed in the back matter.
/// -> content
#let back-matter(
  // from entry
  twoside: false,
  // options
  heading-numbering: (first-level: "附录A", depth: 4, format: "A.1 "),
  figure-numbering: "A.1",
  figure-outlined: false,
  equation-numbering: "(A.1)",
  reset-counter: true,
  // self
  it,
) = {
  if reset-counter { counter(heading).update(0) }

  set heading(
    numbering: custom-numbering.with(
      first-level: heading-numbering.first-level,
      depth: heading-numbering.depth,
      heading-numbering.format,
    ),
    bookmarked: false,
    outlined: false,
  )

  show heading.where(level: 1): set heading(outlined: true)

  set figure(outlined: figure-outlined)

  show figure: i-figured.show-figure.with(numbering: figure-numbering)

  show math.equation.where(block: true): i-figured.show-equation.with(numbering: equation-numbering)

  it
}
