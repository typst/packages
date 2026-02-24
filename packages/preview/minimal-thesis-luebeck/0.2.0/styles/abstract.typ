#let abstract(
  title: "Abstract",
  language: "en",
  body-font,
  body
) = {
  set text(
    font: body-font, 
    size: 12pt
  )
  set par(
    leading: 1em,
    justify: true
  )
  set text(lang: language)

  align(center, text(font: body-font, 1em, weight: "semibold", title))

  body
}
