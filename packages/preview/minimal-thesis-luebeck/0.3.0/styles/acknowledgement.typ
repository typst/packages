#let acknowledgement(
  body-font: "",
  sans-font: "",
  dark-color: black,
  body
) = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    number-align: center,
  )

  set text(
    font: body-font, 
    size: 11pt, 
    lang: "en"
  )

  set par(
    leading: 1em, 
    justify: true
  )

  // --- Acknowledgements ---
  align(left, text(font: sans-font, 2em, weight: 700,"Acknowledgements", fill: dark-color))
  v(15mm)

  body
}