#let directory_writing_aids(language: "en", body) = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: none,
    number-align: center,
  )

  let body-font = "New Computer Modern"
  let sans-font = "New Computer Modern Sans"

  set text(
    font: body-font, 
    size: 12pt, 
    lang: "en"
  )

  set par(leading: 1em)

  // --- AI Usage ---
  let title = (en: "Directory of writing aids", de: "Verzeichnis der Schreibhilfsmittel")
  heading(title.at(language), numbering: none)
  v(12pt)

  body
}