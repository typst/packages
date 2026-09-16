///! Wide/long reshaping verbs for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). `pivot-longer` melts a set
///! of columns into a name/value pair of columns (one output row per melted
///! cell); `pivot-wider` spreads a name column and a value column back into one
///! column per distinct name. Both call `_normalise-data` on entry (column-
///! store input is accepted) and return a row-store, feeding `#plot` directly.
///! `pivot-longer` then `pivot-wider` round-trips the data, modulo column order.

#import "../data.typ": _normalise-data, column-names
#import "../utils/errors.typ": fail, fail-type
#import "summarise.typ": _bucket-groups
#import "select.typ": _carry-factors, _require-cols

/// Melt several columns into a single name/value column pair (wide to long).
///
/// `cols` (a column name or an array of names) are the columns to melt; every other column is kept as an identifier. Each input row becomes one output row per melted column: the kept columns, then `names-to` holding the melted column's name, then `values-to` holding its cell value.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - cols: Columns to melt, as a string or an array of strings.
/// - names-to: Name of the output column holding the melted column names.
/// - values-to: Name of the output column holding the melted cell values.
///
/// Returns: A long row-store array.
///
/// See also: `pivot-wider`.
///
/// Melt city and highway economy into one measurement column.
///
/// ```typst
/// #let long = pivot-longer(mpg, ("cty", "hwy"), names-to: "metric", values-to: "mpg")
/// ```
#let pivot-longer(data, cols, names-to: "name", values-to: "value") = {
  let rows = _normalise-data(data)
  let melt = if type(cols) == str { (cols,) } else { cols }
  if type(melt) != array {
    fail-type(
      "pivot-longer",
      "cols",
      cols,
      "a column name or an array of names",
    )
  }
  _require-cols("pivot-longer", "cols", melt, rows)
  for (label, value) in (("names-to", names-to), ("values-to", values-to)) {
    if type(value) != str {
      fail-type("pivot-longer", label, value, "a string column name")
    }
  }
  if names-to == values-to {
    fail("pivot-longer", "`names-to` and `values-to` must differ")
  }
  let id-cols = column-names(rows).filter(col => not melt.contains(col))
  for reserved in (names-to, values-to) {
    if id-cols.contains(reserved) {
      fail(
        "pivot-longer",
        "the output column " + repr(reserved) + " collides with a kept column",
        hint: "Choose a `names-to`/`values-to` name that is not a kept column.",
      )
    }
  }
  let out = ()
  for row in rows {
    let factors = row.at("_gribouille-factors", default: ())
    for col in melt {
      let new-row = (:)
      for id in id-cols { new-row.insert(id, row.at(id, default: none)) }
      new-row.insert(names-to, col)
      new-row.insert(values-to, row.at(col, default: none))
      out.push(_carry-factors(new-row, factors, id-cols))
    }
  }
  out
}

/// Spread a name column and a value column into one column per name (long to wide).
///
/// `names-from` holds the new column names, `values-from` their cell values; every other column identifies the output row. Rows sharing the identifier columns collapse into one, with a column per distinct `names-from` value (stringified, since dict keys are strings) in first-appearance order. Absent name/identifier combinations are filled with `none`; a repeated combination (the same `names-from` value twice within one identifier group) is an ambiguous spread and fails.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - names-from: Column whose values become the new column names.
/// - values-from: Column whose values fill the new columns.
///
/// Returns: A wide row-store array.
///
/// See also: `pivot-longer`.
///
/// Spread a key column into one column per key.
///
/// ```typst
/// #let wide = pivot-wider(long, names-from: "metric", values-from: "mpg")
/// ```
#let pivot-wider(data, names-from: none, values-from: none) = {
  let rows = _normalise-data(data)
  _require-cols("pivot-wider", "names-from", (names-from,), rows)
  _require-cols("pivot-wider", "values-from", (values-from,), rows)
  if names-from == values-from {
    fail("pivot-wider", "`names-from` and `values-from` must differ")
  }
  let id-cols = column-names(rows).filter(col => (
    col != names-from and col != values-from
  ))
  let new-cols = ()
  for row in rows {
    let name = str(row.at(names-from, default: none))
    if not new-cols.contains(name) { new-cols.push(name) }
  }
  for name in new-cols {
    if id-cols.contains(name) {
      fail(
        "pivot-wider",
        "the value "
          + repr(name)
          + " from `names-from` collides with a kept column",
        hint: "Rename or drop the clashing identifier column before widening.",
      )
    }
  }
  _bucket-groups(rows, id-cols).map(group => {
    let out = (:)
    for (col, value) in id-cols.zip(group.values) { out.insert(col, value) }
    for name in new-cols { out.insert(name, none) }
    let filled = (:)
    for row in group.rows {
      let name = str(row.at(names-from, default: none))
      if name in filled {
        let id-desc = id-cols
          .zip(group.values)
          .map(pair => pair.at(0) + "=" + repr(pair.at(1)))
          .join(", ")
        fail(
          "pivot-wider",
          "duplicate `names-from`="
            + repr(name)
            + (
              if id-desc == none { "" } else {
                " for identifier (" + id-desc + ")"
              }
            )
            + "; the spread is ambiguous",
          hint: "Summarise or de-duplicate the rows before widening.",
        )
      }
      filled.insert(name, true)
      out.insert(name, row.at(values-from, default: none))
    }
    _carry-factors(
      out,
      group.rows.first().at("_gribouille-factors", default: ()),
      id-cols,
    )
  })
}
