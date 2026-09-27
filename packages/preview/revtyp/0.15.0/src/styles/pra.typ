
#import "aps.typ"

#let var = (
  ..aps.var,
  // Layout
  title-descent: 0.38in,
  first-header-dy: 0.02in,
  rule-dy: 0.06in,
  first-rule-dy: 0.08in,
  // Colors
  text-color: rgb("#000000"),
  link-color: rgb("#0000FF"),
  // Font sizes
  abstract-font-size: 9pt,
  doi-font-size: 9pt,
  header-font-size: 9pt,
  footer-font-size: 9pt,
  footnote-font-size: 9pt,
  // Spacings
  affiliation-spacing: 9pt,
  date-spacing: 9pt,
  abstract-spacing: 10pt,
  abstract-leading: 5.5pt,
  frontmatter-spacing: 22pt,
)

#let layout(
  var: var,
  content,
) = {
  show: aps.layout.with(var: var)

  set page(
    width: 8.44in,
    height: 11.25in,
    margin: (
      left: 0.68in,
      right: 0.7in,
      top: 0.98in,
      bottom: 0.79in,
    ),
    header-ascent: 0.265in,
    footer-descent: 0.25in,
  )

  set text(size: 10pt)
  show heading: set text(size: 9pt)
  show figure.caption: set text(size: 9pt)

  show cite: set text(fill: var.text-color)

  content
}
