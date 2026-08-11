#let disclaimer(
  author,
  body
) = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: "i",
    number-align: center,
  )

  // --- Disclaimer ---  
  v(65%)

  body

  parbreak()
  v(10%)
  line(length: 35%)
  emph(author)
}
