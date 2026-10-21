///! Footnotes with marks, and source notes.

#import "../locations.typ": PARTS

// A source note carries no mark; it explains the table as a whole.
#let table-source-note(note) = (
  kind: "source-note",
  note: note,
)

// A footnote carries a mark unless it has no location, in which case it is an
// unmarked note in the footer, like a source note with its own styling.
#let table-footnote(note, locations: none, mark: auto) = (
  kind: "footnote",
  note: note,
  locations: locations,
  mark: mark,
)

// Marks in reading order: header, then column labels and spanners, then the
// body in display order, then the footer. Identical notes share one mark, so
// repeating the same caveat does not renumber the table.
//
// Named from PARTS, so an order naming a part the vocabulary does not have is a
// compile error rather than a mark nothing ever reaches. `PARTS.footnotes` is
// the one part left out: the footer rows are added to the spec after the marks
// are assigned, so a footnote on a footnote has nothing to number.
#let MARK-ORDER = (
  PARTS.title,
  PARTS.column-spanners,
  PARTS.column-labels,
  PARTS.stubhead,
  PARTS.row-groups,
  PARTS.stub,
  PARTS.body,
  PARTS.summary,
  PARTS.grand-summary,
  PARTS.source-notes,
)

#let numbering-of(style) = {
  if style == "letters" { position => numbering("a", position) }
  else if style == "symbols" { position => numbering("*", position) }
  else { position => numbering("1", position) }
}
