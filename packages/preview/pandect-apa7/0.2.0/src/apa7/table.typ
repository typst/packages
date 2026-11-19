/// Table module for APA 7th Edition.
///
/// Implements APA 7 table formatting rules (Chapter 7, Sections 7.4-7.21):
/// - Numbering above the title (e.g. "Table 1" in bold).
/// - Title in italic title case on a new line below the number.
/// - Border rules: single horizontal lines at top (1pt), under header (0.5pt),
///   and bottom of table (1pt). Vertical lines are strictly forbidden.
/// - Notes below the table starting with italicized "Note." or "Nota.".
/// - Accessibility: mandates semantic table.header() for PDF/UA-1 screen readers.

/// Helper to render APA table notes (General, Specific, Probability).
#let render-table-note(
  note,
  lang: "en",
) = {
  if note == none or note == "" {
    return none
  }

  let note-label = if lang == "es" {
    emph[Nota.]
  } else {
    emph[Note.]
  }

  align(left)[
    #set text(size: 10pt)
    #set par(first-line-indent: 0pt, leading: 0.6em, spacing: 0.6em)
    #note-label #note
  ]
}

/// Helper function to create an APA 7 compliant table.
///
/// Automatically applies:
/// - Semantic table.header() wrapping for screen reader accessibility.
/// - APA 7 three-rule horizontal borders (top, header-bottom, table-bottom).
/// - Zero vertical lines.
/// - Flush-left italicized notes block below the table.
///
/// Parameters:
/// - title: Table title (content or string). Displayed in italics below table number.
/// - columns: Column specification (e.g., 3, (1fr, auto, auto)).
/// - header: Array of header cells. Wrapped into table.header() for PDF/UA-1.
/// - note: Optional explanatory note placed at the bottom.
/// - lang: ISO 639-1 language code (default: "en").
/// - ..cells: Body data cells.
#let apa-table(
  title: [Untitled Table],
  columns: auto,
  header: (),
  note: none,
  lang: "en",
  ..cells,
) = {
  let table-supplement = if lang == "es" { [Tabla] } else { [Table] }

  figure(
    caption: title,
    kind: table,
    supplement: table-supplement,
    [
      #table(
        columns: columns,
        stroke: none,
        table.hline(stroke: 1pt),
        table.header(..header),
        table.hline(stroke: 0.5pt),
        ..cells,
        table.hline(stroke: 1pt),
      )
      #render-table-note(note, lang: lang)
    ]
  )
}

/// Applies APA 7 table caption styling across all tables in the document.
#let apply-tables(lang: "en", body) = {
  // APA 7: Table captions are placed ABOVE the table.
  show figure.where(kind: table): set figure.caption(position: top)

  // APA 7: Line 1 has bold table number; Line 2 has italicized title.
  show figure.where(kind: table): set figure(
    supplement: if lang == "es" [Tabla] else [Table]
  )

  show figure.caption.where(kind: table): it => align(left)[
    #strong[#it.supplement #context it.counter.display(it.numbering)] \
    #emph[#it.body]
  ]

  body
}
