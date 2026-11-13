/// Typography module for APA 7th Edition.
///
/// Implements typeface standards, double line spacing, first-line indentation,
/// ragged-right text alignment, hyphenation restrictions, and accessible language
/// tagging following APA 7 guidelines and Typst's Universal Access standards.

/// Returns the standard default font size recommended by APA 7 for a given font family.
#let default-font-size(font-name) = {
  let lower-name = lower(font-name)
  if lower-name.contains("georgia") or lower-name.contains("calibri") or lower-name.contains("arial") {
    11pt
  } else if lower-name.contains("lucida") {
    10pt
  } else {
    // Times New Roman, Computer Modern, and standard serif default
    12pt
  }
}

/// Applies APA 7 typography, line spacing, and language attributes to the document.
///
/// Parameters:
/// - font: Font family name (default: "Times New Roman").
///   Standard options: "Times New Roman", "Georgia", "Calibri", "Arial", "Lucida Sans Unicode".
/// - font-size: Font size length. If auto, selects the recommended APA size for the font.
/// - lang: ISO 639-1 language code (default: "en").
///   Crucial for PDF/UA-1 speech synthesis and screen readers.
/// - region: Optional ISO 3166-1 alpha-2 region code (e.g., "US", "GB", "ES").
/// - body: Document content.
#let apply-typography(
  font: "Times New Roman",
  font-size: auto,
  lang: "en",
  region: none,
  body,
) = {
  let effective-size = if font-size == auto {
    default-font-size(font)
  } else {
    font-size
  }

  // Language tagging for screen readers and accessibility
  set text(
    font: font,
    size: effective-size,
    fill: rgb(0, 0, 0), // 100% black on white for WCAG AAA contrast
    lang: lang,
    region: region,
    // APA 7 Section 2.18: Do not insert hyphens at the end of lines.
    // Also improves phonetic decoding in screen readers.
    hyphenate: false,
  )

  // APA 7 Section 2.21 & 2.24:
  // - Double-spacing throughout the entire paper (leading: 1em equals 100% of font size,
  //   yielding 200% baseline-to-baseline distance).
  // - No extra spacing above or below paragraphs (spacing: 1em matches leading).
  // - Left-aligned text with ragged right edge (justify: false). Full justification
  //   is prohibited as it creates uneven spacing hindering cognitive reading.
  // - First-line indent of 0.5 inches (1.27 cm) for body paragraphs.
  set par(
    leading: 1em,
    spacing: 1em,
    justify: false,
    first-line-indent: 0.5in,
  )

  // APA 7 Section 8.27: Block Quotations (40 words or more)
  // - Indented 0.5 inches from the left margin on the entire block.
  // - Double-spaced, no quotation marks.
  show quote.where(block: true): it => pad(left: 0.5in)[
    #set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
    #it.body
  ]

  // APA 7 Section 6.45: Display Equations
  // - Numbered consecutively with parentheses flush right: (1), (2).
  set math.equation(numbering: "(1)")

  // APA 7 Sections 6.49-6.52: Lists and Seriation
  // - Indented 0.5 inches matching standard paragraph indentation.
  set list(indent: 0.5in, spacing: 1em)
  set enum(indent: 0.5in, spacing: 1em)

  // APA 7 Section 2.28: Footnotes
  // - Numbered with superscripts (1, 2, 3), standard 10pt size at page bottom.
  show footnote.entry: set text(size: 10pt)
  set footnote.entry(separator: line(length: 2in, stroke: 0.5pt))

  body
}
