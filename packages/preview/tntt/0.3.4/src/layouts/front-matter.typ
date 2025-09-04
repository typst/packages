/// Front Matter Layout
///
/// - twoside (bool): Whether to use two-sided layout.
/// - page-start (int): The page number to start from.
/// - page-numbering (str): The numbering format for the page.
/// - it (content): The content to be displayed in the front matter.
/// -> content
#let front-matter(
  // from entry
  twoside: false,
  // options
  page-start: 0,
  page-numbering: "I",
  // self
  it,
) = {
  // Page break
  if twoside { pagebreak() + " " }

  // Reset the counter
  counter(page).update(page-start)
  set page(numbering: page-numbering)

  it
}
