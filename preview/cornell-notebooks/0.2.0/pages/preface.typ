// preface.typ
// 前言

#let preface-content(
  content: none,
  lang: "zh"
) = {
  if content != none {
    set page(
      margin: (
        top: 1.5cm,
        bottom: 2cm,
        right: 2cm,
        left: 2cm,
      ),
    )
    align(center)[
      #set text(font: ("Times New Roman", "NSimSun"), size: 20pt)
      *#if lang == "en" [Preface] else [序]*
    ]
    [
      #set text(font: ("Times New Roman", "NSimSun"), size: 12pt)
      #content
    ]
  }
}
