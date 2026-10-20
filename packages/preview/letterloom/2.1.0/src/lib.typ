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
  from-name: none,
  from-address: none,
  to-name: none,
  to-address: none,
  date: none,
  salutation: none,
  subject: none,
  closing: none,
  signatures: none,
  required-fields: ("from-name", "from-address", "to-name", "to-address", "date", "salutation", "subject", "closing", "signatures"),
  signature-alignment: left,
  attn-name: none,
  attn-label: "Attn:",
  attn-position: "above",
  cc: none,
  cc-label: "cc:",
  enclosures: none,
  enclosures-label: "encl:",
  letterhead: none,
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
  date-alignment: right,
  footnote-alignment: left,
  link-color: blue,
  doc
) = {
  // Validate all inputs
  validate-inputs(
    from-name: from-name,
    from-address: from-address,
    to-name: to-name,
    to-address: to-address,
    date: date,
    salutation: salutation,
    subject: subject,
    closing: closing,
    signatures: signatures,
    required-fields: required-fields,
    signature-alignment: signature-alignment,
    attn-name: attn-name,
    attn-label: attn-label,
    attn-position: attn-position,
    cc: cc,
    cc-label: cc-label,
    enclosures: enclosures,
    enclosures-label: enclosures-label,
    letterhead: letterhead,
    footer: footer,
    par-leading: par-leading,
    par-spacing: par-spacing,
    number-pages: number-pages,
    main-font-size: main-font-size,
    footer-font-size: footer-font-size,
    footnote-font-size: footnote-font-size,
    from-alignment: from-alignment,
    date-alignment: date-alignment,
    footnote-alignment: footnote-alignment,
    link-color: link-color,
  )

  // Shadow fields not in required-fields with none so rendering guards suppress them
  let opt(field, value) = if field in required-fields { value } else { none }

  let from-name = opt("from-name", from-name)
  let from-address = opt("from-address", from-address)
  let to-name = opt("to-name", to-name)
  let to-address = opt("to-address", to-address)
  let date = opt("date", date)
  let salutation = opt("salutation", salutation)
  let subject = opt("subject", subject)
  let closing = opt("closing", closing)
  let signatures = opt("signatures", signatures)

  // Construct the custom footer (optional)
  let custom-footer = construct-custom-footer(
    footer: footer,
    footer-font: footer-font,
    footer-font-size: footer-font-size,
    link-color: link-color,
  )

  // Construct the page numbering (optional)
  let page-numbering = construct-page-numbering(number-pages: number-pages)

  // Set the page settings
  set page(
    paper: paper-size,
    margin: margins,
    footer: align(center, custom-footer + page-numbering),
  )

  // Set the text settings
  set text(
    font: main-font,
    size: main-font-size,
  )

  // Set the paragraph spacing
  set par(
    leading: par-leading, // Space between adjacent lines in a paragraph
    spacing: par-spacing, // Space between paragraphs
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

  construct-letterhead(letterhead: letterhead)
  construct-sender(from-name: from-name, from-address: from-address, from-alignment: from-alignment)
  construct-date(date: date, date-alignment: date-alignment, from-alignment: from-alignment, from-name: from-name, from-address: from-address)
  construct-recipient(to-name: to-name, to-address: to-address, attn-name: attn-name, attn-label: attn-label, attn-position: attn-position)
  construct-salutation(salutation: salutation)
  construct-subject(subject: subject)

  doc

  construct-closing(closing: closing)
  if signatures != none {
    construct-signatures(signatures: signatures, signature-alignment: signature-alignment)
  }
  construct-cc(cc: cc, cc-label: cc-label)
  construct-enclosures(enclosures: enclosures, enclosures-label: enclosures-label)
}
