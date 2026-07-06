/// Front Matter Layout
///
/// - page-numbering (str): The numbering format for the page.
/// - it (content): The content to be displayed in the front matter.
/// -> content
#let front-matter(
  // options
  page-numbering: "I",
  // self
  it,
) = {
  // Reset the counter of pages
  counter(page).update(1)

  set page(numbering: page-numbering)

  it
}
