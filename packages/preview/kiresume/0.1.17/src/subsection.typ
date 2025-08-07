#import "date.typ" : date, range

/// Creates a generic subsection, rendering only the provided fields.
/// 
/// -> content
#let subsection(
  /// -> str | none
  title: none,
  /// -> str | none
  subtitle: none,
  /// -> date | none
  from: none,
  /// -> date | none
  to: none,
  /// -> str | none
  location: none,
  /// -> str | none
  text: none,
  /// -> array | dictionary
  items: ()
) = {
  if (type(text) == str) {
    eval(text, mode: "markup")
  }

  let cells = ()

  if (title != none) {
    cells.push(
      // If we have a title and no date range, we allow the title to take the full width
      grid.cell(align: left, colspan: if from == none { 2 } else { 1 })[#strong(title)]
    )
  }

  if (from != none) {
    cells.push(
      grid.cell(align: right)[#range(from: date(..from), to: date(..to))]
    )
  }

  if (subtitle != none) {
    cells.push(
      // Similarly, if we have a subtitle and no location, we allow the subtitle to take the full width
      grid.cell(align: left, colspan: if location == none { 2 } else { 1 })[#emph(subtitle)]
    )
  }

  if (location != none) {
    cells.push(
      grid.cell(align: right)[#emph(location)]
    )
  }

  if (cells.len() != 0) {
    grid(columns: (1fr, 1fr), row-gutter: 4pt, ..cells)
  }

  if (type(items) == array) {
    for item in items {
      [- #item]
    }
  }

  if (type(items) == dictionary) {
    for (key, value) in items {
      [- *#key:* #value]
    }
  }
}
