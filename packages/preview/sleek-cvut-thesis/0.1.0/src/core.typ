#let ctu-layout(
  title: "",
  author: "",
  lang: "cs",
  gutter: false, // vázání
  body,
) = {
  set document(title: title, author: author)
  set page(
    margin: if gutter {
      (top: 25mm, bottom: 25mm, inside: 35mm, outside: 20mm)
    } else {
      (x: 25mm, y: 25mm)
    },
  )
  set text(lang: lang, region: "cz", size: 11pt, font: "libertinus serif")

  set heading(numbering: "1.")
  show heading: set block(below: 0.8em)
  set par(justify: true, first-line-indent: 2em)

  // slightly larger space behind an image/figure
  show figure: it => {
    it
    v(8pt)
  }

  // prettier code block
  show raw.where(block: true): it => align(
    block(
      stroke: rgb("#d5d5d5"),
      fill: rgb("#ffffff"),
      inset: 10pt,
      radius: 4pt,
      it,
    ),
    center,
  )

  body
}
