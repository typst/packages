#let colors = (
  pfgreen: rgb("#002a16"),
  pfred: rgb("#4e1b0e"),
  pfmaroon: rgb("#5d0000"),
  lightgreen: rgb("#015d4e"),
  pfwhite: rgb("#ede3c7"),
  pfnavy: rgb("#002b6f"),
  otherRow: rgb("#f4eee0"),
  pfyellow: rgb("#dac285"),
  pfbrown: rgb("#644117"),
)

#let pf-stylization(doc) = {
  // General page layout
  set page(
    paper: "a4",
    columns: 2,
    margin: (left: 15mm, right: 15mm, top: 15mm, bottom: 15mm),
  )
  set text(
    font: ("Roboto", "Liberation Sans"), // General font family
    size: 10pt,
    stretch: 80%,
  )
  set par(
    spacing: .6em,
    justify: true,
    first-line-indent: 1em,
  )
  show <s>: set par(first-line-indent: 0em)

  /// Headers
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0em)
    text(
      font: ("Taroca", "Liberation Sans"), // Staple Pathfinder font
      size: 1.6em,
      fill: colors.pfgreen,
      weight: "extrabold",
      it.body
    )
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0em)
    text(
      size: 1.4em,
      fill: colors.pfred,
      weight: "bold",
      it.body
    )
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0em)
    text(
      size: 1.3em,
      fill: colors.lightgreen,
      weight: "bold",
      it.body
    )
  }
  show heading.where(level: 4): it => block(
    width: 100%, 
    rect(
      width: 100%, 
      radius: (
        top-left: 10pt,
        top-right: 5pt,
      ),
      fill: colors.pfnavy,
      stroke: none,
      inset: 6pt,
      align(left, text(
        fill: white,
        weight: "bold",
        size: 1.3em,
        it.body
      )+ v(-9pt) + line(length: 100%, stroke: (white + 0.5pt)))
    )
  ) 
  show heading.where(level: 5): it => {
    text(
      size: 1.3em,
      weight: "bold",
      it.body
    )
  }

  // Struggled to get this. Work around found here -> https://github.com/typst/typst/issues/3640
  show table.cell.where(y: 0): it => (
    text(fill: white, weight: "bold")[#it]
  )
  doc
}
