///! Column spanners and their header rows.
///!
///! A spanner labels a run of adjacent columns. Adjacency is a property of the
///! final column order, so it is checked once on the folded spec: a
///! `columns-move` may legally be written after the spanner it rearranges.

#import "../utils/columns.typ": check-addressable
#import "../utils/errors.typ": check
#import "stub.typ": stub-column-names

// `level` 1 sits directly above the column labels; higher levels stack above,
// so a spanner can span other spanners.
#let table-spanner(label, columns, level: 1) = (
  kind: "spanner",
  label: label,
  columns: columns,
  level: level,
)

// Column name to its position in the final order, built once so neither
// validation nor rendering has to scan the column list per spanner column.
#let _index-of(columns) = {
  let index = (:)
  for (position, name) in columns.enumerate() { index.insert(name, position) }
  index
}

#let validate-spanners(spec) = {
  let index = _index-of(spec.columns)
  // One entry per level, naming the spanner that already claimed each column.
  let claimed = (:)

  for spanner in spec.spanners {
    // A level is a position among the header rows, and everything that reads it
    // does arithmetic on it: the rows are sorted by it, and a footnote mark is
    // ranked by it inverted. A level that is not a whole number rendered until
    // something counted with it, and then failed as a raw Typst error.
    check(
      type(spanner.level) == int,
      "table-spanner",
      "level must be a whole number",
      value: spanner.level,
      hint: "Level 1 sits directly above the column labels, and higher levels stack above it.",
    )

    check(
      spanner.columns.len() > 0,
      "table-spanner",
      "spanner covers no columns",
      hint: "Name at least one column for the spanner to span.",
    )

    for name in spanner.columns {
      check-addressable(
        name,
        "table-spanner",
        columns: spec.columns,
        hidden: spec.hidden,
        stub: stub-column-names(spec.stub),
        hidden-hint: "Drop the columns-hide, or drop the column from the spanner.",
        stub-hint: "A spanner labels the columns beside the stub; the stub is not one of them.",
      )

      let key = str(spanner.level) + ":" + name
      check(
        key not in claimed,
        "table-spanner",
        "column " + name + " is already covered at level " + str(spanner.level),
        hint: "Spanners on one level cannot overlap; raise the level to nest them.",
      )
      claimed.insert(key, spanner.label)
    }

    let positions = spanner.columns.map(name => index.at(name)).sorted()
    check(
      positions.last() - positions.first() == positions.len() - 1,
      "table-spanner",
      "columns " + spanner.columns.join(", ") + " are not adjacent",
      hint: "Reorder them with columns-move so the spanner covers a single run.",
    )
  }
  spec
}

// One row of cells per spanner level, highest level first, each row covering
// every column: a spanner cell for a covered run, an empty cell for a gap.
#let spanner-rows(spec) = {
  if spec.spanners.len() == 0 { return () }

  let levels = spec.spanners.map(spanner => spanner.level).dedup().sorted().rev()
  let width = spec.columns.len()

  levels.map(level => (level: level, cells: {
    // One dictionary per level rather than a scan per column: a column covered
    // by this level looks its spanner up directly.
    let covering = (:)
    for spanner in spec.spanners.filter(spanner => spanner.level == level) {
      for name in spanner.columns { covering.insert(name, spanner) }
    }

    let cells = ()
    let position = 0
    while position < width {
      let spanner = covering.at(spec.columns.at(position), default: none)
      if spanner == none {
        cells.push((label: none, span: 1))
        position += 1
      } else {
        cells.push((label: spanner.label, span: spanner.columns.len()))
        position += spanner.columns.len()
      }
    }
    cells
  }))
}
