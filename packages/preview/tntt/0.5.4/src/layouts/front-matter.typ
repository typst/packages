/// Front Matter Layout
///
/// - twoside (bool, str): Whether to use two-sided layout.
/// - page-numbering (str): The numbering format for the page.
/// - it (content): The content to be displayed in the front matter.
/// -> content
#let front-matter(
  // from entry
  twoside: false,
  // options
  page-numbering: "I",
  // self
  it,
) = {
  import "../utils/util.typ": twoside-pagebreak

  twoside-pagebreak(twoside)

  // Reset the counter of pages
  counter(page).update(1)

  set page(numbering: page-numbering)

  it
}
