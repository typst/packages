///! Grouped aggregation verbs for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). `summarise` collapses each
///! group to a single row of named aggregations; `count` tallies the rows per
///! group. Grouping is per-call via `by:` (or the positional columns of
///! `count`); there is no persistent grouped state. Both accept column-store
///! input through `_normalise-data` and return a row-store, feeding `#plot`
///! directly.

#import "../data.typ": _normalise-data, column-names, group-by
#import "../utils/errors.typ": fail, fail-type, fail-unknown-column, quote-each

// Coerce a `by:` argument into an array of column-name strings. `none` means
// "no grouping" (the whole dataset); a bare string is a single column. `scope`
// names the calling verb so shared callers report their own error scope.
#let _normalise-by(by, scope: "summarise") = {
  if by == none { return () }
  if type(by) == str { return (by,) }
  if type(by) == array {
    for col in by {
      if type(col) != str {
        fail-type(scope, "by entry", col, "a string column name")
      }
    }
    return by
  }
  fail-type(
    scope,
    "by",
    by,
    "a column name, an array of names, or `none`",
  )
}

// Partition `rows` by the values of `cols`, returning `(values, rows)` records
// in first-appearance order. `values` holds each group's column values (from
// its first row); `rows` is the bucket. Reuses `group-by`, so within-group
// order is preserved and a compound key joins columns with the Unit Separator.
#let _bucket-groups(rows, cols) = {
  let key-fn = row => cols
    .map(col => str(row.at(col, default: "")))
    .join("\u{1}")
  group-by(rows, key-fn)
    .values()
    .map(bucket => (
      values: cols.map(col => bucket.first().at(col, default: none)),
      rows: bucket,
    ))
}

/// Collapse each group of rows to a single row of named aggregations.
///
/// With `by: none` the whole dataset is one group, yielding exactly one row; with `by: ("col", ...)` (a single string is accepted too) there is one output row per group, in first-appearance order. Each output row carries the grouping columns first (in `by:` order) then one column per aggregation. Every aggregation is a closure receiving that group's rows (an array of dictionaries) and returning the cell value: `n: rows => rows.len()`, `mean-hwy: rows => mean(rows.map(row => float(row.hwy))).y`.
///
/// column. Names must not collide with a grouping column.
///
/// or an array of names.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - aggregations: Named closures `name: rows => value`, one per output
/// - by: Grouping columns: `none` for the whole dataset, a column name,
///
/// Returns: A row-store array with one row per group.
///
/// See also: `count`.
///
/// Mean and count of `hwy` per drive train.
///
/// ```typst
/// #let by-drv = summarise(
///   mpg,
///   n: rows => rows.len(),
///   mean-hwy: rows => mean(rows.map(row => float(row.hwy))).y,
///   by: "drv",
/// )
/// ```
///
/// Whole-dataset summary (`by: none`) returns one row.
///
/// ```typst
/// #let overall = summarise(mpg, n: rows => rows.len())
/// ```
#let summarise(data, ..aggregations, by: none) = {
  let rows = _normalise-data(data)
  if rows == none {
    fail-type(
      "summarise",
      "data",
      data,
      "an array of dicts or a dict of arrays",
    )
  }
  if aggregations.pos().len() != 0 {
    fail(
      "summarise",
      "aggregations must be named; got "
        + str(aggregations.pos().len())
        + " positional argument(s)",
      hint: "Pass each aggregation as `name: rows => value`.",
    )
  }
  let by-cols = _normalise-by(by)
  let available = column-names(rows)
  if rows.len() != 0 {
    for col in by-cols {
      if not available.contains(col) {
        fail-unknown-column("summarise", "by", col, available)
      }
    }
  }
  let aggs = aggregations.named()
  for (name, fn) in aggs {
    if type(fn) != function {
      fail-type(
        "summarise",
        "aggregation \"" + name + "\"",
        fn,
        "a function `rows => value`",
      )
    }
    if by-cols.contains(name) {
      fail(
        "summarise",
        "aggregation \"" + name + "\" collides with a grouping column",
        hint: "Rename the aggregation or drop the column from `by`.",
      )
    }
  }
  let groups = if by-cols.len() == 0 {
    ((values: (), rows: rows),)
  } else {
    _bucket-groups(rows, by-cols)
  }
  groups.map(group => {
    let out = (:)
    for (col, value) in by-cols.zip(group.values) { out.insert(col, value) }
    for (name, fn) in aggs { out.insert(name, fn(group.rows)) }
    out
  })
}

/// Count the rows in each group, one output row per group.
///
/// The positional string columns are the grouping; with no columns the result is a single row holding the total. The tally lands in a plain `n` column. `sort: true` orders the rows by descending `n`, ties keeping their first-appearance order.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - cols: Grouping columns as positional strings; none for a grand total.
/// - sort: When `true`, order rows by descending `n`.
///
/// Returns: A row-store array with the grouping columns and an `n` column.
///
/// See also: `summarise`.
///
/// Rows per class, most frequent first.
///
/// ```typst
/// #let per-class = count(mpg, "class", sort: true)
/// ```
#let count(data, ..cols, sort: false) = {
  if cols.named().len() != 0 {
    fail(
      "count",
      "column names are positional; got named argument(s) "
        + quote-each(cols.named().keys()),
      hint: "Group by column names as positional strings; use `sort:` to order by `n`.",
    )
  }
  let group-cols = cols.pos()
  for col in group-cols {
    if type(col) != str {
      fail-type("count", "column", col, "a string column name")
    }
  }
  if type(sort) != bool {
    fail-type("count", "sort", sort, "a boolean")
  }
  let result = summarise(data, n: rows => rows.len(), by: group-cols)
  if sort { result = result.sorted(key: row => -row.n) }
  result
}
