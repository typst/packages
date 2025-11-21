#let front-matter(
  // from entry
  twoside: false,
  // options
  page-start: 0,
  page-numbering: "I",
  // self
  it,
) = {
  // Reset the counter
  counter(page).update(page-start)
  set page(numbering: page-numbering)

  it
}
