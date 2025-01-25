#let acknowledgement(body) = {

  set text(
    size: 12pt, 
    lang: "en"
  )

  set par(leading: 1em)

  
  // --- Acknowledgements ---
  align(left, text(2em, weight: 700,"Acknowledgements"))
  body
  v(15mm)

  pagebreak()
}