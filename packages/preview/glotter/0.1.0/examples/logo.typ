#set page(width: auto, height: auto, margin: 10mm)

#let title-text = [glotter]
#let subtitle-text = [language-aware typesetting]

#let title-font = "Hiragino Kaku Gothic Pro"
#let title-size = 150pt
#let title-fill = rgb(42, 55, 67)

#let subtitle-font = "Hiragino Kaku Gothic Pro"
#let subtitle-base-size = 35pt
#let subtitle-fill = rgb("#22B3C6")

#context {
  let title-width = measure(
    text(
      size: title-size,
      font: title-font,
      weight: 800,
      fill: title-fill,
    )[#title-text]
  ).width

  let subtitle-base-width = measure(
    text(
      size: subtitle-base-size,
      font: subtitle-font,
      weight: 800,
      fill: subtitle-fill,
    )[#subtitle-text]
  ).width

  let subtitle-size = subtitle-base-size * (title-width / subtitle-base-width)

  grid(
    columns: 2,
    column-gutter: 10mm,
    align: center + horizon,
    image("logo.svg"),
    grid(
      rows: 2,
      row-gutter: 15mm,
      align: center + horizon,
      text(
        size: title-size,
        font: title-font,
        weight: 800,
        fill: title-fill,
      )[#title-text],
      text(
        size: subtitle-size,
        font: subtitle-font,
        weight: 800,
        fill: subtitle-fill,
      )[#subtitle-text],
    ),
  )
}