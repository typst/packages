// =============================================================================
// src/styles.typ: Global document styles, typography, code blocks, and headings
// =============================================================================

/// Applies global typographical, code block, heading, and layout styling rules.
///
/// - font (str, array): Font family name or fallback list.
/// - lang (str): Document language code.
/// - code-bg (color): Background fill color for code blocks.
/// - body (content): Document content to style.
/// -> content
#let apply-base-styles(
  font: ("Lato", "Liberation Sans", "DejaVu Sans"),
  lang: "es",
  code-bg: rgb("#F1F3F4"),
  body,
) = {
  set text(
    font: font,
    lang: lang,
    size: 10pt,
  )

  // Code block styling
  show raw.where(block: true): it => block(
    fill: code-bg,
    width: 100%,
    inset: 1.2em,
    radius: 6pt,
    breakable: true,
    text(fill: rgb("#303030"), it),
  )

  show raw.where(block: false): box.with(
    fill: code-bg,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Figure styling
  show figure: set block(breakable: true)

  // Link styling
  show link: it => underline(text(fill: rgb("#0056b3"), style: "italic", it))

  // Heading styles according to official template
  set heading(numbering: "1.")
  show heading.where(level: 1): it => block(
    width: 100%,
    above: 1.2em,
    below: 1em,
  )[
    #set align(left)
    #set text(weight: "bold", size: 12pt)
    #smallcaps(it)
  ]
  show heading.where(level: 2): it => block(above: 1em, below: 0.8em)[
    #set align(left)
    #set text(weight: "bold", size: 11pt)
    #it
  ]
  show heading.where(level: 3): it => block(above: 1em, below: 0.8em)[
    #set align(left)
    #set text(weight: "bold", size: 10pt)
    #it
  ]

  // Paragraph justification
  set par(justify: true)

  body
}
