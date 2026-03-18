#let epigraph_page(body) = {
  // --- Epigraphs ---
  page(
    numbering: none,
    align(right + bottom)[
      #body
    ],
  )
}
