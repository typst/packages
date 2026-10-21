///! Footnote marks and the order they are assigned in.
///!
///! Marks are local content, not Typst `footnote` elements, so they never
///! renumber the page footnotes a document may already have.

#import "../locations.typ": PARTS, expand
#import "../render/plan.typ": build-plan
#import "../theme/options.typ": option
#import "notes.typ": MARK-ORDER, numbering-of

// Where each body, stub, group, and note row actually appears, so "reading
// order" means the order a reader meets the cells rather than the order the
// data happened to arrive in. Grouping reorders rows, and marks must follow.
#let _display-order(spec) = {
  let order = (:)
  for (position, entry) in build-plan(spec).rows.enumerate() {
    if entry.source == none { continue }
    // Keyed by `repr` rather than `str`, because a summary row is identified by
    // the pair `(group, row)` and would otherwise have no place in the order.
    // The two vocabularies meet here. What is tested is a row-plan part, which
    // names what a row is; what is produced is PARTS, which names what a
    // location can address. A body row answers to two addresses, its cells and
    // its row name.
    let parts = if entry.part == "body" { (PARTS.body, PARTS.stub) } else if entry.part == "group" {
      (PARTS.row-groups,)
    } else if entry.part == "summary" { (PARTS.summary,) } else if entry.part == "grand-summary" {
      (PARTS.grand-summary,)
    } else if entry.part == "source-note" { (PARTS.source-notes,) } else { () }
    for part in parts { order.insert(part + "|" + repr(entry.source), position) }
  }
  order
}

// Where a spanner sits on the page, as the row and column a cell address would
// carry. A spanner address holds its level where a row goes and its label where
// a column name goes, so neither reads as a position: levels render highest
// first at `spanner-rows`, so the level had the order upside down, and the label
// is never in the column list, so every spanner ranked alike and the order the
// directives were written in decided between them.
#let _spanner-position(address, spec, columns) = {
  let spanner = spec.spanners.find(spanner => (
    spanner.level == address.row and spanner.label == address.column
  ))
  if spanner == none { return (-address.row, -1) }
  let covered = spanner.columns.map(name => columns.position(candidate => candidate == name))
  let known = covered.filter(position => position != none)
  (-address.row, if known.len() == 0 { -1 } else { calc.min(..known) })
}

#let _rank(address, spec, display, columns) = {
  let part = MARK-ORDER.position(name => name == address.part)
  let part-rank = if part == none { MARK-ORDER.len() } else { part }

  if address.part == PARTS.column-spanners {
    let (level, column) = _spanner-position(address, spec, columns)
    return (part-rank, level, column)
  }

  // Within a part, follow the rendered row, then the column left to right.
  let row = display.at(
    address.part + "|" + repr(address.row),
    default: if type(address.row) == int { address.row } else { -1 },
  )

  let column = columns.position(name => name == address.column)
  (part-rank, row, if column == none { -1 } else { column })
}

// One entry per footnote: its note, its mark, and the addresses it marks.
// Notes are numbered in reading order of their first address, and two notes
// with the same content share a mark.
#let assign-marks(spec) = {
  let display = _display-order(spec)
  let columns = spec.columns

  let resolved = spec.footnotes.map(directive => {
    let addresses = if directive.locations == none { () } else {
      expand(directive.locations, spec)
    }
    let ranks = addresses.map(address => _rank(address, spec, display, columns))
    (
      note: directive.note,
      mark: directive.mark,
      addresses: addresses,
      rank: if ranks.len() == 0 { (MARK-ORDER.len(), -1, -1) } else { ranks.sorted().first() },
    )
  })

  let order = resolved.enumerate().sorted(key: ((index, entry)) => (entry.rank, index))

  let marks = (:)
  let numbered = ()
  let next = 1
  let style = numbering-of(option(spec.options, "footnote-marks"))

  for (position, (index, entry)) in order.enumerate() {
    if entry.addresses.len() == 0 {
      numbered.push((index: index, position: position, mark: none, entry: entry))
      continue
    }
    // Keyed by the note and the mark asked for: two notes reading the same but
    // marked differently are two marks, and the caller's choice is not lost.
    let key = repr(entry.note) + "|" + repr(entry.mark)
    if key not in marks {
      marks.insert(key, if entry.mark == auto { style(next) } else { entry.mark })
      if entry.mark == auto { next += 1 }
    }
    numbered.push((index: index, position: position, mark: marks.at(key), entry: entry))
  }

  // Returned in the order the directives were written, since that is what every
  // caller but the footer wants; `position` carries the reading order the marks
  // were numbered in, which is the order the footer prints them in.
  numbered.sorted(key: entry => entry.index).map(entry => (
    note: entry.entry.note,
    mark: entry.mark,
    position: entry.position,
    addresses: entry.entry.addresses,
  ))
}

// The footer, in the order it prints: the marked notes behind their marks, then
// the unmarked ones, which explain the table rather than a cell.
//
// Marked notes follow their marks rather than the order they were written in. A
// note marking a row further down is numbered later, so printing the footer in
// directive order would list mark 2 above mark 1, and cells-footnotes would
// address rows a reader counting marks could not predict.
// One row per mark, not one per directive. Two cells carrying the same caveat
// share a mark, and the footer printed that mark twice, the second time out of
// mark order.
//
// Keyed by the note and the mark as printed, which is what a reader counts. The
// mark assignment above keys on the mark the caller asked for, `auto` included,
// so two entries that resolve to the same mark under the same note are two
// entries there and one row here. Two notes reading the same under two marks
// the caller wrote resolve differently and stay two rows.
//
// Unmarked notes explain the table rather than a cell and have no mark to
// share, so each one written is a row printed.
#let footer-notes(footnotes) = {
  let seen = (:)
  let marked = ()
  for footnote in footnotes.filter(footnote => footnote.mark != none).sorted(key: footnote => (
    footnote.position
  )) {
    let key = repr(footnote.note) + "|" + repr(footnote.mark)
    if key in seen { continue }
    seen.insert(key, true)
    marked.push(footnote)
  }
  marked + footnotes.filter(footnote => footnote.mark == none)
}

// Marks that belong on one cell, in the order they were numbered.
#let marks-for(footnotes, part, row, column) = {
  footnotes
    .filter(footnote => footnote.mark != none)
    .filter(footnote => footnote.addresses.any(address => (
      address.part == part and address.row == row and address.column == column
    )))
    .map(footnote => footnote.mark)
}
