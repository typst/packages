#let page-margins = (
  top: 20mm,
  bottom: 20mm,
  left: 30mm,
  right: 15mm,
)

#let page-settings = (
  paper: "a4",
  margin: page-margins,
  numbering: "1",
  number-align: center,
)

#let font-size = 14pt
#let line-spacing = 1.5

#let text-settings = (
  size: font-size,
  lang: "ru",
  fill: black,
  leading: 1em,
  spacing: 1.5em,
)

#let heading-settings = (
  level-1-numbering: "1",
  level-2-numbering: "1.1",
)

#let par-settings = (
  first-line-indent: (amount: 1.5cm, all: true),
)

#set text(
  size: text-settings.size,
  lang: text-settings.lang,
)

#set page(
  paper: page-settings.paper,
  margin: page-settings.margin,
)
