/// letterloom Core Module
///
/// This module provides the main interface and layout logic for generating
/// professional letters using the letterloom package. It orchestrates
/// input validation, document structure, and formatting, and exposes the main
/// `letterloom` function for end users and templates.
#import "validate-inputs.typ": validate-inputs
#import "construct-outputs.typ": *

/// Generates a formatted letter according to the letterloom specification.
#let letterloom(
  from: none,
  to: none,
  date: none,
  salutation: none,
  subject: none,
  closing: none,
  signatures: none,
  attn-line: none,
  cc: none,
  enclosures: none,
  footer: none,
  paper-size: "a4",
  margins: auto,
  par-leading: 0.8em,
  par-spacing: 1.8em,
  number-pages: false,
  main-font: "Libertinus Serif",
  main-font-size: 11pt,
  footer-font: "DejaVu Sans Mono",
  footer-font-size: 9pt,
  footnote-font: "Libertinus Serif",
  footnote-font-size: 7pt,
  from-alignment: right,
  footnote-alignment: left,
  link-color: blue,
  doc
) = {
  // Validate all inputs
  validate-inputs(
    from: from,
    to: to,
    date: date,
    salutation: salutation,
    subject: subject,
    closing: closing,
    signatures: signatures,
    attn-line: attn-line,
    cc: cc,
    enclosures: enclosures,
    footer: footer,
    par-leading: par-leading,
    par-spacing: par-spacing,
    number-pages: number-pages,
    main-font-size: main-font-size,
    footer-font-size: footer-font-size,
    footnote-font-size: footnote-font-size,
    from-alignment: from-alignment,
    footnote-alignment: footnote-alignment,
    link-color: link-color,
  )

  // Construct the custom footer (optional)
  let custom-footer = construct-custom-footer(
    footer: footer,
    footer-font: footer-font,
    footer-font-size:
    footer-font-size,
    link-color: link-color
  )

  // Construct the page numbering (optional)
  let page-numbering = construct-page-numbering(number-pages: number-pages)

  // Set the page settings
  set page(
    paper: paper-size,
    margin: margins,
    footer: align(center, custom-footer + page-numbering)
  )

  // Set the text settings
  set text(
    font: main-font,
    size: main-font-size
  )

  // Set the paragraph spacing
  set par(
    leading: par-leading, // Space between adjacent lines in a paragraph
    spacing: par-spacing  // Space between paragraphs
  )

  // Color links to the desired color
  show link: set text(fill: link-color)

  // Set the footnote separator
  set footnote.entry(separator: align(footnote-alignment, line(length: 30% + 0pt, stroke: 0.5pt)))

  // Set the footnote alignment and text settings
  show footnote.entry: it => {
    set align(footnote-alignment)
    set text(font: footnote-font, size: footnote-font-size)
    it
  }

  // Sender's name, address, and date block
  align(from-alignment, block[
    #set align(left)
    #from.name
    #linebreak()
    #from.address
    #linebreak()
    #v(2pt)
    #date
  ])

  // Construct the attention line (optional)
  let attn = none
  let attn-position = none
  if attn-line not in (none, ()) {
    attn = attn-line.at("label", default: "Attn:") + " " + attn-line.at("name")
    attn-position = attn-line.at("position", default: "above")
  }

  // Receiver's name, address and optional attention line
  block[
    #v(5pt)
    #set align(left)
    #if attn-position == "above" {
      text(attn)
      linebreak()
    }
    #to.name
    #linebreak()
    #to.address
    #linebreak()
    #if attn-position == "below" {
      text(attn)
      linebreak()
    }
  ]

  v(5pt)

  // Salutation
  text(salutation)

  linebreak()
  v(5pt)

  // Subject
  text(subject)

  // Body of letter
  doc

  linebreak()
  v(5pt)

  // Closing
  text(closing)

  // Construct and display the signatures
  construct-signatures(signatures: signatures)

  v(10pt)

  // Construct and display the cc (optional)
  construct-cc(cc: cc)

  // Construct and display the enclosures (optional)
  construct-enclosures(enclosures: enclosures)
}
