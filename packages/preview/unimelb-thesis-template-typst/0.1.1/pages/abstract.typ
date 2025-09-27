// =================================
// Abstract Page
// =================================

#let abstract-page(abstract, keywords: ()) = {
  heading("Abstract", numbering: none, outlined: false)
  v(1em)
  abstract
  pagebreak()

  // Keywords
  if keywords.len() > 0 {
    heading("Keywords", numbering: none, outlined: false)
    v(0.5em)
    keywords.join(", ")
    pagebreak()
  }
}
