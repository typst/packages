/// Main Matter Layout
///
/// - twoside (bool, str): Whether to use two-sided layout.
/// - page-numbering (str): The numbering format for the page.
/// - heading-numbering (dictorary): The numbering format for headings.
/// - figure-numbering (str, auto): The numbering format for figures.
/// - subfig-numbering (str, auto): The numbering format for subfigures.
/// - equation-numbering (str, auto): The numbering format for equations.
/// - subfig-numbering-extended (bool): Whether to extend the subfigure numbering with the figure numbering.
/// - it (content): The content to be displayed in the main matter.
/// -> content
#let main-matter(
  // from entry
  twoside: false,
  // options
  page-numbering: "1",
  heading-numbering: (formats: ("第1章", "1.1"), depth: 4, supplyment: " "),
  figure-numbering: auto,
  subfig-numbering: auto,
  equation-numbering: auto,
  subfig-numbering-extended: false,
  // self
  it,
) = {
  import "../utils/font.typ": use-size
  import "../utils/util.typ": array-at, multi-numbering, show-grid-figure, twoside-pagebreak

  if figure-numbering == auto { figure-numbering = heading-numbering.formats.last() }
  if subfig-numbering == auto { subfig-numbering = "(a)" }
  if equation-numbering == auto { equation-numbering = "(" + heading-numbering.formats.last() + ")" }

  let fold-numbering = (format, ..nums) => numbering(format, counter(heading).get().first(), ..nums)

  if type(figure-numbering) == str {
    if type(subfig-numbering) == str and subfig-numbering-extended {
      subfig-numbering = (..p, n) => fold-numbering(figure-numbering + subfig-numbering, ..p, n)
    }
    figure-numbering = n => fold-numbering(figure-numbering, n)
  }
  if type(equation-numbering) == str { equation-numbering = n => fold-numbering(equation-numbering, n) }

  // Page break
  twoside-pagebreak(twoside)

  set heading(numbering: multi-numbering.with(..heading-numbering))

  set math.equation(numbering: equation-numbering)

  counter(page).update(1)

  set page(numbering: page-numbering)

  show-grid-figure(figure-numbering, subfig-numbering, subfig-numbering-extended, it)
}
