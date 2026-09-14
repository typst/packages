/// Back Matter Layout
///
/// - twoside (bool, str): Whether to use two-sided layout.
/// - heading-numbering (dictorary): The numbering format for headings.
/// - figure-outlined (bool): Whether to outline figure numbers in figures index page.
/// - figure-numbering (str, auto): The numbering format for figures.
/// - subfig-numbering (str, auto): The numbering format for subfigures.
/// - equation-numbering (str, auto): The numbering format for equations.
/// - subfig-numbering-extended (bool): Whether to extend the subfigure numbering with the figure numbering.
/// - subfig-outlined (bool): Whether to outline the subfigures.
/// - reset-counter (bool): Whether to reset the pages counter.
/// - it (content): The content of the back matter.
/// -> content
#let back-matter(
  // from entry
  twoside: false,
  // options
  heading-numbering: (formats: ("附录A", "A.1"), depth: 4, supplyment: " "),
  figure-outlined: false,
  figure-numbering: auto,
  subfig-numbering: auto,
  equation-numbering: auto,
  subfig-outlined: true,
  subfig-numbering-extended: false,
  reset-counter: false,
  // self
  it,
) = {
  import "../utils/util.typ": multi-numbering, show-grid-figure, twoside-pagebreak

  let __page-reset = state("__tntt:back-matter-page-reset", false)

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

  set figure(outlined: figure-outlined)

  // Reset the counter and numbering of headings
  counter(heading).update(0)

  set heading(numbering: multi-numbering.with(..heading-numbering), outlined: false)
  // Only level 1 headings of the appendices are shown in the outline
  show heading.where(level: 1): set heading(outlined: true)

  set math.equation(numbering: equation-numbering)

  // Reset the counter of pages at the first level 1 heading,
  // to avoid resetting on blank pages without headings when twoside is enabled.
  show heading.where(level: 1): it => {
    it
    if reset-counter and not __page-reset.get() {
      counter(page).update(1)
      __page-reset.update(true)
    }
  }

  show-grid-figure(figure-numbering, subfig-numbering, subfig-numbering-extended, subfig-outlined, it)
}
