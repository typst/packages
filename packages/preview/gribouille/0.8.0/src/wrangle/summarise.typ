///! Grouped aggregation verbs for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). `summarise` collapses each
///! group to a single row of named aggregations; `count` tallies the rows per
///! group. Grouping is per-call via `by:` (or the positional columns of
///! `count`); there is no persistent grouped state. Both accept column-store
///! input through `_normalise-data` and return a row-store, feeding `#plot`
///! directly.

#import "../data.typ": _require-cols, _require-frame, group-by
#import "../utils/errors.typ": fail, fail-type, quote-each
#import "../utils/types.typ": cell-key

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

// Stringified compound key for `row` over `cols`, joined with the Unit
// Separator. A `none` cell keys as its own group, apart from any string value,
// and an empty `cols` puts every row in one group.
#let _key-of(row, cols) = {
  cols
    .map(col => cell-key(row.at(col, default: none)))
    .join("\u{1}", default: "")
}

// Partition `rows` by the values of `cols`, returning `(values, rows)` records
// in first-appearance order. `values` holds each group's column values (from
// its first row); `rows` is the bucket. Reuses `group-by`, so within-group
// order is preserved.
#let _bucket-groups(rows, cols) = {
  group-by(rows, row => _key-of(row, cols))
    .values()
    .map(bucket => (
      values: cols.map(col => bucket.first().at(col, default: none)),
      rows: bucket,
    ))
}

// Engine behind `summarise` and `count`. `scope` names the verb the user
// called, `by-label` names its grouping argument in an unknown-column
// message, and `collision-hint` gives the fix for a name collision.
#let _summarise(
  scope,
  data,
  aggregations,
  by,
  by-label: "by",
  collision-hint: "Rename the aggregation or drop the column from `by`.",
) = {
  let rows = _require-frame(scope, "data", data)
  if aggregations.pos().len() != 0 {
    fail(
      scope,
      "aggregations must be named; got "
        + str(aggregations.pos().len())
        + " positional argument(s)",
      hint: "Pass each aggregation as `name: rows => value`.",
    )
  }
  let by-cols = _normalise-by(by, scope: scope)
  _require-cols(scope, by-label, by-cols, rows)
  let aggs = aggregations.named()
  for (name, fn) in aggs {
    if type(fn) != function {
      fail-type(
        scope,
        "aggregation \"" + name + "\"",
        fn,
        "a function `rows => value`",
      )
    }
    if by-cols.contains(name) {
      fail(
        scope,
        "aggregation \"" + name + "\" collides with a grouping column",
        hint: collision-hint,
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


/// Collapse each group of rows to a single row of named aggregations.
///
/// With `by: none` the whole dataset is one group, yielding exactly one row; with `by: ("col", ...)` (a single string is accepted too) there is one output row per group, in first-appearance order. A `none` cell in a grouping column forms its own group. Each output row carries the grouping columns first (in `by:` order) then one column per aggregation. Every aggregation is a closure receiving that group's rows (an array of dictionaries) and returning the cell value: `n: rows => rows.len()`, `mean-hwy: rows => mean(rows.map(row => float(row.hwy))).y`.
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
  _summarise("summarise", data, aggregations, by)
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
  let result = _summarise(
    "count",
    data,
    arguments(n: rows => rows.len()),
    group-cols,
    by-label: "column",
    collision-hint: "Rename the column `n` before counting.",
  )
  if sort { result = result.sorted(key: row => -row.n) }
  result
}
