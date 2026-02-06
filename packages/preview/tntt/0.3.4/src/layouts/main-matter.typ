#import "../utils/font.typ": use-size
#import "../utils/util.typ": array-at
#import "../utils/numbering.typ": custom-numbering

#import "../imports.typ": i-figured

/// Main Matter Layout
///
/// - twoside (bool): Whether to use two-sided layout.
/// - page-numbering (str): The numbering format for the page.
/// - heading-numbering (str): The numbering format for headings.
/// - reset-footnote (bool): Whether to reset the footnote counter.
/// - it (content): The content to be displayed in the main matter.
/// -> content
#let main-matter(
  // from entry
  twoside: false,
  // options
  page-numbering: "1",
  heading-numbering: (first-level: "第1章", depth: 4, format: "1.1"),
  equation-numbering: "(1-1)",
  reset-footnote: true,
  // self
  it,
) = {
  set page(numbering: page-numbering)

  show heading: i-figured.reset-counters

  set heading(numbering: custom-numbering.with(
    first-level: heading-numbering.first-level,
    depth: heading-numbering.depth,
    heading-numbering.format,
  ))

  /// Below code fix bookmarking issue with headings in PDF, applied to main matter and back matter.
  /// Inherit from https://forum.typst.app/t/how-to-display-chapter-numbers-in-pdf-bookmarks/4912/4?u=y.d.x

  // Remove original headings from bookmarks. We will add new ones later.
  set heading(bookmarked: false)

  show heading: it => if it.numbering == none {
    // This heading has been processed. Keep it untouched.
    it
  } else {
    let (numbering, body, ..args) = it.fields()
    let _ = args.remove("label", default: none)

    // Render the numbering manually
    let numbered-body = block({
      counter(heading).display(numbering)
      [ ] // space in the bookmark
      body
    })

    // regular heading
    it

    // Add our bookmarked, hidden heading
    show heading: none
    heading(..args, outlined: false, bookmarked: true, numbering: none, numbered-body)
  }

  show figure: i-figured.show-figure

  show math.equation.where(block: true): i-figured.show-equation.with(numbering: equation-numbering)

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
