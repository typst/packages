#import "@preview/ultraw:0.0.1": themes, uraw

#let format-doc(doc) = {
  set page(width: 21cm + 6pt, height: auto, margin: 3pt)
  set par(spacing: 3mm)

  doc
}

#let source(code, ..args) = uraw(
  ..themes.note,
  lang-tag-name: "source",
  ..args,
  code,
)
