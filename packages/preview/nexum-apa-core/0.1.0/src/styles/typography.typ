// Independent typographic systems: regular text, mathematics and raw code.
#let with-typography(
  body,
  font: "New Computer Modern",
  font-size: 10pt,
  math-font: "New Computer Modern Math",
  math-size: none,
  code-font: "DejaVu Sans Mono",
  code-inline-size: 0.85em,
  code-block-size: 9pt,
  language: "es",
  justify: false,
  leading: 1em,
  paragraph-spacing: 1em,
  first-line-indent: 0.5in,
  top-edge: 0.8em,
  bottom-edge: -0.2em,
) = {
  set text(
    font: font,
    size: font-size,
    lang: language,
    top-edge: top-edge,
    bottom-edge: bottom-edge,
  )

  show math.equation: set text(font: math-font)
  if math-size != none {
    show math.equation: set text(size: math-size)
  }

  show raw.where(block: false): set text(
    font: code-font,
    size: code-inline-size,
  )
  show raw.where(block: true): set text(
    font: code-font,
    size: code-block-size,
  )

  set par(
    justify: justify,
    leading: leading,
    spacing: paragraph-spacing,
    first-line-indent: (amount: first-line-indent, all: true),
  )
  set block(spacing: paragraph-spacing)
  set list(tight: true)
  set enum(tight: true)
  body
}
