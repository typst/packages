// --- DOCUMENT LAYOUT AND STYLING ---

/// This function initializes the global document properties.
/// - margin: Set to 10mm on all sides for a balanced professional look.
/// - font: Uses 'Inter', a clean sans-serif optimized for readability.
/// - leading: Controls the spacing between lines (set to 0.6em for a dense but clean feel).
#let project(body) = {
  set page(
    margin: (left: 10mm, right: 10mm, top: 10mm, bottom: 10mm),
  )
  set text(
    font: "Inter", 
    size: 10pt, 
    lang: "en"
  )
  set par(justify: true, leading: 0.6em)
  body
}

/// Creates a major category header (e.g., Work Experience).
/// Includes a signature burgundy horizontal line for visual separation.
#let section(title) = {
  v(1em, weak: true)
  block(width: 100%)[
    #set text(weight: "bold", size: 11pt)
    #stack(
      spacing: 0.35em,
      title,
      // Stroke color #802020 (Burgundy) provides a premium professional accent.
      line(length: 100%, stroke: 0.7pt + rgb("#802020"))
    )
  ]
}

/// A flexible component for Education, Work, and Organizations.
/// - title: The primary bold text (e.g., Job Title).
/// - sub_title: The secondary italicized text (e.g., Company/University).
/// - date: Automatically aligned to the top-right.
/// - location: Automatically aligned to the bottom-right.
#let entry(
  title: "",
  sub_title: "",
  date: "",
  location: "",
  description: []
) = {
  pad(bottom: 0.6em)[
    #grid(
      columns: (1fr, auto),
      row-gutter: 0.45em, // Space between title and sub-title
      [*#title*], [#text(weight: "regular")[#date]],
      [#emph(sub_title)], [#text(style: "italic", size: 9pt)[#location]]
    )
    #v(0.1em)
    #text(size: 9.5pt)[#description]
  ]
}

/// A specialized component for Projects where space efficiency is prioritized.
/// Uses negative vertical spacing (#v(-0.45em)) to keep titles and categories very close.
#let project_entry(
  title: "",
  category: "",
  description: []
) = {
  pad(bottom: 0.6em)[
    *#title* \
    #v(-0.45em) // Tightens the gap significantly for an ultra-clean look.
    #emph(text(size: 9pt)[#category]) \
    #v(-0.2em)  // Tightens gap between category and the bullet points.
    #text(size: 9.5pt)[#description]
  ]
}