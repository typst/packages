///! Join and bind verbs for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). The mutating joins
///! (`left-join`/`inner-join`/`full-join`) match two datasets on shared key
///! columns and combine their columns; the filtering joins (`semi-join`/
///! `anti-join`) keep rows of the first dataset by key presence. `bind-rows`
///! stacks datasets (column union, `none`-filling gaps); `bind-cols` glues them
///! side by side. Every verb calls `_normalise-data` on entry (column-store
///! input is accepted) and returns a row-store, feeding `#plot` directly.
///!
///! Keys are matched on the stringified compound value (`str(value)` joined with
///! the Unit Separator, like `_bucket-groups`), so key equality is by string
///! form: a native `1` and the string `"1"` match. The `_gribouille-factors`
///! tag is carried through, filtered to the surviving columns.

#import "../data.typ": _normalise-data, column-names, group-by
#import "../utils/errors.typ": fail, fail-type, fail-unknown-column, quote-each
#import "summarise.typ": _normalise-by
#import "select.typ": _carry-factors

// Normalise a join input, rejecting `none` (a join needs a real dataset).
#let _require-frame(scope, label, data) = {
  let rows = _normalise-data(data)
  if rows == none {
    fail-type(scope, label, data, "an array of dicts or a dict of arrays")
  }
  rows
}

// Resolve the key columns: `by: none` is a natural join on the columns common
// to both (in `x` order); a string or array names them explicitly. Validates
// that every key exists in both inputs (skipped for an empty input, which
// carries no column names).
#let _join-keys(scope, x, y, by) = {
  let xc = column-names(x)
  let yc = column-names(y)
  let keys = if by == none {
    let common = xc.filter(col => yc.contains(col))
    if common.len() == 0 and x.len() > 0 and y.len() > 0 {
      fail(
        scope,
        "no common columns to join by",
        hint: "Pass `by:` with the shared key column name(s).",
      )
    }
    common
  } else {
    _normalise-by(by, scope: scope)
  }
  for key in keys {
    if x.len() > 0 and not xc.contains(key) {
      fail-unknown-column(scope, "by", key, xc)
    }
    if y.len() > 0 and not yc.contains(key) {
      fail-unknown-column(scope, "by", key, yc)
    }
  }
  keys
}

// Stringified compound key for `row` over `keys`, matching `group-by`'s keying.
#let _key-of(row, keys) = {
  str(keys.map(col => str(row.at(col, default: ""))).join("\u{1}"))
}

// Build one merged output row from an `x` row and/or a `y` row. `x-cols` are the
// full x columns (key columns come from x, or from y when x is absent); `y-extra`
// are y's non-key columns. Absent sides fill with `none`. Factor tags merge: x
// tags its columns, y tags its extras.
#let _join-row(x-cols, y-extra, keys, xrow, yrow) = {
  let out = (:)
  for col in x-cols {
    out.insert(col, if xrow != none {
      xrow.at(col, default: none)
    } else if keys.contains(col) {
      yrow.at(col, default: none)
    } else {
      none
    })
  }
  for col in y-extra {
    out.insert(col, if yrow != none { yrow.at(col, default: none) } else {
      none
    })
  }
  let xf = if xrow != none {
    xrow.at("_gribouille-factors", default: ()).filter(f => x-cols.contains(f))
  } else { () }
  let yf = if yrow != none {
    yrow.at("_gribouille-factors", default: ()).filter(f => y-extra.contains(f))
  } else { () }
  _carry-factors(out, xf + yf, x-cols + y-extra)
}

// Shared engine for the mutating joins. `keep-unmatched-x` keeps x rows without
// a match (left/full); `add-unmatched-y` appends y rows without a match (full).
#let _mutating-join(
  scope,
  xdata,
  ydata,
  by,
  keep-unmatched-x,
  add-unmatched-y,
) = {
  let x = _require-frame(scope, "x", xdata)
  let y = _require-frame(scope, "y", ydata)
  let keys = _join-keys(scope, x, y, by)
  let y-extra = column-names(y).filter(col => not keys.contains(col))
  let overlap = column-names(x)
    .filter(col => not keys.contains(col))
    .filter(col => y-extra.contains(col))
  if overlap.len() != 0 {
    fail(
      scope,
      "non-key column(s) " + quote-each(overlap) + " appear in both inputs",
      hint: "Rename or select before joining; there is no automatic suffixing.",
    )
  }
  let x-cols = column-names(x)
  for key in keys {
    if not x-cols.contains(key) { x-cols.push(key) }
  }
  let y-index = group-by(y, row => _key-of(row, keys))
  let out = ()
  for xrow in x {
    let matches = y-index.at(_key-of(xrow, keys), default: ())
    if matches.len() == 0 {
      if keep-unmatched-x {
        out.push(_join-row(x-cols, y-extra, keys, xrow, none))
      }
    } else {
      for yrow in matches {
        out.push(_join-row(x-cols, y-extra, keys, xrow, yrow))
      }
    }
  }
  if add-unmatched-y {
    let x-index = group-by(x, row => _key-of(row, keys))
    for yrow in y {
      if _key-of(yrow, keys) not in x-index {
        out.push(_join-row(x-cols, y-extra, keys, none, yrow))
      }
    }
  }
  out
}

// Shared engine for the filtering joins. `keep-matched` picks semi vs anti.
// Returns x rows unchanged (columns and factor tags intact).
#let _filtering-join(scope, xdata, ydata, by, keep-matched) = {
  let x = _require-frame(scope, "x", xdata)
  let y = _require-frame(scope, "y", ydata)
  let keys = _join-keys(scope, x, y, by)
  let y-index = group-by(y, row => _key-of(row, keys))
  x.filter(xrow => {
    let matched = _key-of(xrow, keys) in y-index
    if keep-matched { matched } else { not matched }
  })
}

/// Keep every row of `x`, adding the matching columns from `y`.
///
/// Rows match on the `by:` key columns (a natural join on the common columns when `by: none`); key values compare by their string form, so a native `1` matches the string `"1"`. Output columns are x's columns, then y's non-key columns. An x row with no match keeps `none` in the y columns; multiple y matches emit one output row each (x order then y match order). A non-key column present in both inputs is an error (no automatic suffixing).
///
/// *Experimental.*
///
/// - x: Left dataset (row-store or column-store).
/// - y: Right dataset (row-store or column-store).
/// - by: Key columns: `none` for the common columns, a name, or an array.
///
/// Returns: A row-store array of x augmented with y's columns.
///
/// See also: `inner-join`, `full-join`.
///
/// Attach each customer's city to their orders.
///
/// ```typst
/// #let joined = left-join(orders, customers, by: "customer")
/// ```
#let left-join(x, y, by: none) = {
  _mutating-join("left-join", x, y, by, true, false)
}

/// Keep only the rows of `x` and `y` that share a key.
///
/// Like `left-join` but drops x rows with no match; output columns are x's columns then y's non-key columns.
///
/// *Experimental.*
///
/// - x: Left dataset (row-store or column-store).
/// - y: Right dataset (row-store or column-store).
/// - by: Key columns: `none` for the common columns, a name, or an array.
///
/// Returns: A row-store array of matched rows.
///
/// See also: `left-join`, `full-join`.
#let inner-join(x, y, by: none) = {
  _mutating-join("inner-join", x, y, by, false, false)
}

/// Keep every row of both `x` and `y`, matching on the key columns.
///
/// Matched rows combine as in `left-join`; a y row with no match becomes a new output row with its key columns and `none` in x's non-key columns.
///
/// *Experimental.*
///
/// - x: Left dataset (row-store or column-store).
/// - y: Right dataset (row-store or column-store).
/// - by: Key columns: `none` for the common columns, a name, or an array.
///
/// Returns: A row-store array of every row from both inputs.
///
/// See also: `left-join`, `inner-join`.
#let full-join(x, y, by: none) = {
  _mutating-join("full-join", x, y, by, true, true)
}

/// Keep the rows of `x` that have a match in `y`, adding no columns.
///
/// A filtering join: the output is a subset of `x` (columns unchanged), restricted to rows whose key appears in `y`. Keys compare by their string form, as in `left-join`.
///
/// *Experimental.*
///
/// - x: Dataset to filter (row-store or column-store).
/// - y: Dataset whose keys gate `x` (row-store or column-store).
/// - by: Key columns: `none` for the common columns, a name, or an array.
///
/// Returns: The rows of `x` with a match in `y`.
///
/// See also: `anti-join`.
#let semi-join(x, y, by: none) = {
  _filtering-join("semi-join", x, y, by, true)
}

/// Keep the rows of `x` that have no match in `y`, adding no columns.
///
/// The complement of `semi-join`: the rows of `x` whose key is absent from `y`.
///
/// *Experimental.*
///
/// - x: Dataset to filter (row-store or column-store).
/// - y: Dataset whose keys exclude rows of `x` (row-store or column-store).
/// - by: Key columns: `none` for the common columns, a name, or an array.
///
/// Returns: The rows of `x` with no match in `y`.
///
/// See also: `semi-join`.
#let anti-join(x, y, by: none) = {
  _filtering-join("anti-join", x, y, by, false)
}

/// Stack datasets on top of each other (row union).
///
/// The output columns are the union of every input's columns, in first- appearance order; a row missing a column fills it with `none`. Factor tags are unioned across the inputs. Passing no datasets returns `()`, and a `none` dataset is skipped.
///
/// *Experimental.*
///
/// - datasets: Datasets to stack, as positional row/column stores.
///
/// Returns: A single row-store array of every input row.
///
/// See also: `bind-cols`.
///
/// Combine two batches of rows with aligned columns.
///
/// ```typst
/// #let all = bind-rows(january, february)
/// ```
#let bind-rows(..datasets) = {
  if datasets.named().len() != 0 {
    fail(
      "bind-rows",
      "datasets are positional; got named argument(s) "
        + quote-each(datasets.named().keys()),
    )
  }
  let sets = datasets.pos().map(_normalise-data).filter(d => d != none)
  let all-cols = ()
  for d in sets {
    for col in column-names(d) {
      if not all-cols.contains(col) { all-cols.push(col) }
    }
  }
  let factor-cols = ()
  for d in sets {
    if d.len() > 0 {
      for f in d.first().at("_gribouille-factors", default: ()) {
        if not factor-cols.contains(f) { factor-cols.push(f) }
      }
    }
  }
  let out = ()
  for d in sets {
    for row in d {
      let new = (:)
      for col in all-cols { new.insert(col, row.at(col, default: none)) }
      out.push(_carry-factors(new, factor-cols, all-cols))
    }
  }
  out
}

/// Glue datasets side by side (column bind).
///
/// The inputs are matched by row position, so every input must have the same number of rows; output row `i` merges the `i`th row of each. Column names must be unique across the inputs. Factor tags merge. Passing no datasets returns `()`, and a `none` dataset is skipped.
///
/// *Experimental.*
///
/// - datasets: Datasets to glue, as positional row/column stores.
///
/// Returns: A single row-store array with every input's columns.
///
/// See also: `bind-rows`.
///
/// Attach a computed column block to a dataset.
///
/// ```typst
/// #let wide = bind-cols(base, extra-columns)
/// ```
#let bind-cols(..datasets) = {
  if datasets.named().len() != 0 {
    fail(
      "bind-cols",
      "datasets are positional; got named argument(s) "
        + quote-each(datasets.named().keys()),
    )
  }
  let sets = datasets.pos().map(_normalise-data).filter(d => d != none)
  if sets.len() == 0 { return () }
  let n = sets.first().len()
  for (i, d) in sets.enumerate() {
    if d.len() != n {
      fail(
        "bind-cols",
        "all inputs must have the same number of rows; input 1 has "
          + str(n)
          + ", input "
          + str(i + 1)
          + " has "
          + str(d.len()),
      )
    }
  }
  let set-cols = sets.map(column-names)
  let all-cols = ()
  for cols in set-cols {
    for col in cols {
      if all-cols.contains(col) {
        fail(
          "bind-cols",
          "duplicate column " + repr(col) + " across inputs",
          hint: "Rename before binding; columns must be unique.",
        )
      }
      all-cols.push(col)
    }
  }
  range(n).map(i => {
    let out = (:)
    let factors = ()
    for (d, cols) in sets.zip(set-cols) {
      let row = d.at(i)
      for col in cols { out.insert(col, row.at(col, default: none)) }
      for f in row.at("_gribouille-factors", default: ()) {
        if not factors.contains(f) { factors.push(f) }
      }
    }
    _carry-factors(out, factors, all-cols)
  })
}
