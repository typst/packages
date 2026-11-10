///! Row-store normalisation, column extraction, and grouping.
///!
///! The canonical shape is a row store: an array of dictionaries, one per row.
///! A column store, a dictionary of equal-length arrays, is accepted and
///! converted. Every normalised row carries the reserved `_index` key, holding
///! its position in the input data, so predicates can read position without a
///! second parameter.

#import "utils/errors.typ": check, fail-type

#let _from-columns(data) = {
  let names = data.keys()
  if names.len() == 0 { return () }
  // Type before length: reading `.len()` off a non-array raises a Typst error
  // rather than one of ours.
  for name in names {
    check(
      type(data.at(name)) == array,
      "data",
      "column " + name + " is not an array",
      value: data.at(name),
      hint: "A column store maps each name to an array of values.",
    )
  }
  let size = data.at(names.first()).len()
  for name in names {
    check(
      data.at(name).len() == size,
      "data",
      "column " + name + " has " + str(data.at(name).len()) + " values, expected " + str(size),
      hint: "Every column must have the same length.",
    )
  }
  range(size).map(index => {
    let row = (:)
    for name in names { row.insert(name, data.at(name).at(index)) }
    row
  })
}

#let normalise(data) = {
  let rows = if type(data) == dictionary { _from-columns(data) } else { data }
  if type(rows) != array {
    fail-type(
      "data",
      "data",
      data,
      "an array of rows or a dictionary of columns",
      hint: "Write an array of row dictionaries, or a dictionary of column arrays.",
    )
  }
  rows
    .enumerate()
    .map(((index, row)) => {
      if type(row) != dictionary {
        fail-type(
          "data",
          "row " + str(index),
          row,
          "a dictionary",
          hint: "A row maps each column name to its value: (units: 1, price: 2.5).",
        )
      }
      check(
        "_index" not in row,
        "data",
        "_index is reserved",
        hint: "Rename the column; keisen uses _index for the row position.",
      )
      row + (_index: index)
    })
}

// Names of the data columns, excluding the reserved key. Every row is read, in
// first-appearance order, so a sparse row store keeps the columns that only
// later rows carry rather than silently dropping them.
#let column-names(rows) = {
  let names = ()
  for row in rows {
    for name in row.keys() {
      if name != "_index" and name not in names { names.push(name) }
    }
  }
  names
}

// A column as an array, with `none` wherever a row lacks the key.
#let column(rows, name) = rows.map(row => row.at(name, default: none))

// Rows bucketed by `key(row)`, preserving input order inside each bucket and
// first-appearance order between them. The push goes through the access chain
// rather than rebuilding the bucket, which would cost a copy per row.
#let group-by(rows, key) = {
  let buckets = (:)
  for row in rows {
    let label = str(key(row))
    if label not in buckets { buckets.insert(label, ()) }
    buckets.at(label).push(row)
  }
  buckets
}

// Groups of row positions, in first-appearance order, for the column that
// carries the group labels. `none` means the table is one nameless block.
#let group-rows(rows, name) = {
  if name == none { return () }
  for row in rows {
    let value = row.at(name, default: none)
    check(
      type(value) in (str, int, float, decimal),
      "table-stub",
      "group value in row " + str(row._index) + " cannot be a label",
      value: value,
      hint: "A group column holds strings or numbers.",
    )
  }
  group-by(rows, row => row.at(name, default: none))
    .pairs()
    .map(((label, members)) => (label: label, rows: members.map(row => row._index)))
}
