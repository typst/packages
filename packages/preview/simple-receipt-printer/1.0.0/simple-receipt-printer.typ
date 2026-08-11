// Page setup for specific printer models
#let page-config = (
  bixolon-srp350ii: (
    width: 80mm,
    height: auto,
    margin: (left: 1mm, right: 8mm, rest: 4mm)
  )
)

// Noto Emoji" is the non-color variant
#let fonts = (
  "Cascadia Code",
  "Noto Emoji",
)

#let receipt(
  printer: page-config.bixolon-srp350ii,
  doc
) = {
  set page(..printer)
  set text(font: fonts, size: 10pt)
  set par(justify: true)
  
  show table: set par(justify: false)
  show title: set par(justify: false)
  show title: set align(left)
  show title: set block(below: 1.2em)
  show title: set text(fill: white, size: 16pt, hyphenate: auto)
  show title: it => rect(radius: .3em, fill: black)[#it]
  show heading: set block(below: 1.2em)
  show heading: set text(fill: white)
  show heading: it => rect(radius: .3em, fill: black)[#it]

  doc
}

#let recipe(
  portions: [],
  ingredients: (),
  img: none,
  printer: page-config.bixolon-srp350ii,
  doc
) = {
  set table(
    columns: (auto, 1fr),
    align: (right, left),
    stroke: none,
  )
  show: receipt

  title()

  if img != none {
    img
  }

  context (
    if text.lang == "de" {
      [Rezept für #portions #if portions > 1 [Portionen] else [Portion]]
    } else {
      [Recipe for #portions  #if portions > 1 [portions] else [portion]]
    }
  )

  table(..ingredients)

  show regex("\d+ (.?C|.?F|Grad)"): it => box()[#emoji.fire *#it*]

  doc
}
