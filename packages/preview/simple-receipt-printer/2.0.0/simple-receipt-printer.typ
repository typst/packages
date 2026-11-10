/// Page setup for specific printer models
#let page-config = (
  bixolon-srp350ii: (
    width: 80mm,
    height: auto,
    margin: (left: 1mm, right: 8mm, rest: 4mm)
  )
)

/// Default font-config.
/// "Noto Emoji" is the non-color variant
#let font = (
  font: ("Inter", "Noto Emoji"),
  size: 10pt,
  slashed-zero: true,
  // Some features for inter, just my preference
  features: ("cv05", "cv03", "cv04", "cv09", "ss07", "ss08"),
  weight: "medium"
)

#let receipt(
  printer: page-config.bixolon-srp350ii,
  font: font,
  doc
) = {
  set page(..printer)
  set text(..font)
  set par(justify: true)
  
  show table: set par(justify: false)
  show title: set par(justify: false)
  show title: set align(left)
  show title: set block(below: 1.2em)
  show title: set text(
    fill: white, size: 16pt, weight: "extrabold",
    hyphenate: auto, tracking: 1pt
  )
  show title: it => rect(radius: .3em, fill: black)[#it]
  show heading: set block(below: 1.2em)
  show heading: set text(fill: white, tracking: 1pt)
  show heading: it => rect(radius: .3em, fill: black)[#it]
  show heading.where(level: 1): set text(weight: "extrabold")

  doc
}

#let recipe(
  portions: [],
  ingredients: (),
  img: none,
  printer: page-config.bixolon-srp350ii,
  font: font,
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
