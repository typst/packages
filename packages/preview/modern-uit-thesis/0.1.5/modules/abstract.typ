#let abstract-page(body) = {
  pagebreak(weak: true, to: "even")
  // --- Abstract ---
  align(left)[
    = Abstract
    #v(1em)
    #body
  ]
}
