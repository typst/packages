#import "constants.typ" as constants


#let style(
  space: (),
  font: (),
  weight: (),
  font-families: constants.font-families,
  lang: "en",
  highlight: constants.palette.red,
  body,
) = {
  // paragraphs
  set text(
    font: font-families,
    fill: constants.palette.grey.dark,
    size: font.base,
    lang: lang,
  )
  set par(
    leading: 0.8em,
    spacing: 1.2em
  )

  // headings
  show heading: set text(weight: "bold")
  show heading: set par(leading: 0.6em)
  
  show heading.where(level: 1): set text(size: font.xxl)
  show heading.where(level: 2): set text(size: font.xl)
  show heading.where(level: 2): set block(above: space.base, below: space.md)

  // listings
  set list(
    marker: text(fill: highlight, sym.bullet),
    spacing: 1em,
    indent: 0em,
    body-indent: .6em,
  )
  set enum(
    spacing: 1em,
    indent: 0em,
    body-indent: .6em,
  )

  // tables
  set table(
    inset: (x: font.base * .5, y: font.base * .625),
    stroke: (_, y) =>
      if y == 0 {
        (bottom: weight.base + constants.palette.grey.dark)
      } else {
        (bottom:weight.sm + constants.palette.grey.medium)
      }
    ,
  )
  show table.cell.where(y: 0): strong

  // figures
  show figure.caption: set text(size: font.sm, fill: constants.palette.grey.medium)
  set figure(gap: space.sm)

  // footnotes
  set footnote(numbering: "[1]")
  set footnote.entry(indent: 0pt, separator: none)

  show footnote: set text(fill: constants.palette.blue, weight: "bold")
  show footnote.entry: set text(size: font.sm)

  // links & bibliography
  show link: set text(fill: constants.palette.blue)
  show cite: set text(fill: constants.palette.blue)
  show bibliography: set heading(offset: 1)

  // content
  body
}
