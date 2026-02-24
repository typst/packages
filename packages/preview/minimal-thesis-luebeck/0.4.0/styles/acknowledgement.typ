#let acknowledgement(
  dark-color: black,
  body
) = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    number-align: center,
  )

  set par(
    leading: 1em, 
    justify: true
  )

  // --- Acknowledgements ---
  context {
    let lang = text.lang
    if lang == "de" {
      heading("Danksagung", outlined: false)
    } else {
      heading("Acknowledgements", outlined: false)
    }
  }

  body
}