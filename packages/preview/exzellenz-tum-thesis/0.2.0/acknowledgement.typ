#let acknowledgement(body) = {
  set text(
    size: 12pt,
    lang: "en",
  )

  set par(leading: 1em)


  v(25mm)
  // --- Acknowledgements ---
  align(center, text(1.5em, weight: 700, "Acknowledgements"))
  body
  pagebreak()
}
