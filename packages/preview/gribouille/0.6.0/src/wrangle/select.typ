///! Column- and row-selection verbs for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). `select`/`rename`/
///! `relocate` reshape the columns; `drop-na`/`distinct` and
///! `slice-max`/`slice-min` filter or rank the rows. Each verb calls
///! `_normalise-data` on entry (column-store input is accepted) and returns a
///! row-store, feeding `#plot` directly. Native `.filter`/`.sorted`/`.map`
///! already cover row filtering, sorting, and rowwise mutation, so those are
///! left to Typst.

#import "../data.typ": _normalise-data, column-names
#import "../utils/types.typ": parse-number
#import "../utils/errors.typ": fail, fail-type, fail-unknown-column, quote-each
#import "summarise.typ": _bucket-groups, _normalise-by

// Reject named arguments on a verb whose sink takes positional column names.
#let _require-positional(scope, args, hint: none) = {
  if args.named().len() != 0 {
    fail(
      scope,
      "column names are positional; got named argument(s) "
        + quote-each(args.named().keys()),
      hint: hint,
    )
  }
}

// Validate that every entry of `cols` is a string column name, and (when
// `rows` is non-empty) that it exists. Empty data carries no column names to
// check against, so existence is skipped there, matching `summarise`.
#let _require-cols(scope, label, cols, rows) = {
  for col in cols {
    if type(col) != str {
      fail-type(scope, label, col, "a string column name")
    }
  }
  if rows.len() != 0 {
    let available = column-names(rows)
    for col in cols {
      if not available.contains(col) {
        fail-unknown-column(scope, label, col, available)
      }
    }
  }
}

// Attach the `_gribouille-factors` tag to `out`, keeping only the factor
// columns that survive in `cols`. Shared by every wrangle verb that rebuilds
// rows, so a selected/renamed/reshaped/joined `as-factor` column keeps its
// discrete interpretation. Omits the tag entirely when no factor column
// survives.
#let _carry-factors(out, factors, cols) = {
  let kept = factors.filter(f => cols.contains(f))
  if kept.len() != 0 { out.insert("_gribouille-factors", kept) }
  out
}

// Rebuild `row` keeping only `cols` (in order), carrying the factor tag
// filtered to the retained columns.
#let _keep-cols(row, cols) = {
  let out = (:)
  for col in cols { out.insert(col, row.at(col, default: none)) }
  _carry-factors(out, row.at("_gribouille-factors", default: ()), cols)
}

// Rebuild `row` in `order` (which holds every column), preserving the factor
// tag. Used by verbs that keep all columns and only reorder them.
#let _reorder-row(row, order) = {
  let out = (:)
  for col in order { out.insert(col, row.at(col, default: none)) }
  _carry-factors(out, row.at("_gribouille-factors", default: ()), order)
}

/// Keep only the named columns, in the given order.
///
/// Positional string columns select and reorder; other columns are dropped. A selected `as-factor` column keeps its discrete tag.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - names: Columns to keep, as positional strings.
///
/// Returns: A row-store array carrying only the named columns.
///
/// See also: `rename`, `relocate`.
///
/// Keep just the class and highway columns.
///
/// ```typst
/// #let trimmed = select(mpg, "class", "hwy")
/// ```
#let select(data, ..names) = {
  let rows = _normalise-data(data)
  _require-positional("select", names)
  let cols = names.pos()
  _require-cols("select", "selection", cols, rows)
  rows.map(row => _keep-cols(row, cols))
}

/// Rename columns, leaving every other column and the column order unchanged.
///
/// Each named argument maps a new name to the old column name it replaces (`rename(data, new: "old")`), mirroring the dplyr `rename(new = old)` order. A renamed `as-factor` column keeps its discrete tag under the new name.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - renames: Named `new: "old"` pairs.
///
/// Returns: A row-store array with the columns relabelled in place.
///
/// See also: `select`, `relocate`.
///
/// Rename `hwy` to `highway`.
///
/// ```typst
/// #let renamed = rename(mpg, highway: "hwy")
/// ```
#let rename(data, ..renames) = {
  let rows = _normalise-data(data)
  if renames.pos().len() != 0 {
    fail(
      "rename",
      "renames are named `new: \"old\"` pairs; got "
        + str(renames.pos().len())
        + " positional argument(s)",
    )
  }
  let old-to-new = (:)
  for (new, old) in renames.named() {
    if type(old) != str {
      fail-type(
        "rename",
        "target for \"" + new + "\"",
        old,
        "a string column name",
      )
    }
    old-to-new.insert(old, new)
  }
  if rows.len() != 0 {
    let available = column-names(rows)
    for old in old-to-new.keys() {
      if not available.contains(old) {
        fail-unknown-column("rename", "rename target", old, available)
      }
    }
    let seen = (:)
    for name in available.map(col => old-to-new.at(col, default: col)) {
      if name in seen {
        fail(
          "rename",
          "renaming produces the duplicate column " + repr(name),
          hint: "Each column must keep a unique name after renaming.",
        )
      }
      seen.insert(name, true)
    }
  }
  rows.map(row => {
    let out = (:)
    for (col, value) in row {
      if col == "_gribouille-factors" {
        out.insert(col, value.map(f => old-to-new.at(f, default: f)))
      } else {
        out.insert(old-to-new.at(col, default: col), value)
      }
    }
    out
  })
}

/// Move columns to a new position, keeping their values and every other column.
///
/// The positional columns move together, in the given order. By default they go to the front; `before:` / `after:` place them just before or after a target column instead. The two anchors are mutually exclusive.
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - cols: Columns to move, as positional strings.
/// - before: Target column to insert the moved columns before.
/// - after: Target column to insert the moved columns after.
///
/// Returns: A row-store array with the columns reordered.
///
/// See also: `select`, `rename`.
///
/// Bring `class` to the front.
///
/// ```typst
/// #let front = relocate(mpg, "class")
/// ```
#let relocate(data, ..cols, before: none, after: none) = {
  let rows = _normalise-data(data)
  _require-positional(
    "relocate",
    cols,
    hint: "Use `before:` or `after:` to anchor the move.",
  )
  if before != none and after != none {
    fail("relocate", "`before:` and `after:` are mutually exclusive")
  }
  let moving = cols.pos()
  _require-cols("relocate", "column", moving, rows)
  let anchor = if before != none { before } else { after }
  if anchor != none {
    if type(anchor) != str {
      fail-type("relocate", "anchor", anchor, "a string column name")
    }
    if moving.contains(anchor) {
      fail(
        "relocate",
        "the anchor column " + repr(anchor) + " cannot also move",
      )
    }
  }
  if rows.len() == 0 { return rows }
  let available = column-names(rows)
  if anchor != none and not available.contains(anchor) {
    fail-unknown-column("relocate", "anchor", anchor, available)
  }
  let rest = available.filter(col => not moving.contains(col))
  let order = if anchor == none {
    moving + rest
  } else {
    let idx = rest.position(col => col == anchor)
    let cut = if before != none { idx } else { idx + 1 }
    rest.slice(0, cut) + moving + rest.slice(cut)
  }
  rows.map(row => _reorder-row(row, order))
}

/// Drop rows carrying a missing value in the named columns.
///
/// With no columns, a row is dropped when any of its columns is missing; with positional columns, only those are inspected. A value is missing when it is `none` (an absent key reads as `none`).
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - cols: Columns to inspect, as positional strings; none inspects all.
///
/// Returns: A row-store array without the dropped rows.
///
/// See also: `distinct`.
///
/// Drop rows missing a highway figure.
///
/// ```typst
/// #let complete = drop-na(mpg, "hwy")
/// ```
#let drop-na(data, ..cols) = {
  let rows = _normalise-data(data)
  _require-positional("drop-na", cols)
  let requested = cols.pos()
  _require-cols("drop-na", "column", requested, rows)
  let inspect = requested
  if inspect.len() == 0 { inspect = column-names(rows) }
  rows.filter(row => inspect.all(col => row.at(col, default: none) != none))
}

/// Keep the first row of each distinct combination of the named columns.
///
/// Positional columns form the key; the first row seen for each key is kept, in first-appearance order, with every column retained. With no columns the whole row is the key (native `.dedup()`).
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - cols: Key columns, as positional strings; none keys on the whole row.
///
/// Returns: A row-store array with duplicate keys removed.
///
/// See also: `drop-na`.
///
/// One representative row per class.
///
/// ```typst
/// #let one-each = distinct(mpg, "class")
/// ```
#let distinct(data, ..cols) = {
  let rows = _normalise-data(data)
  _require-positional("distinct", cols)
  let key-cols = cols.pos()
  _require-cols("distinct", "column", key-cols, rows)
  if key-cols.len() == 0 { return rows.dedup() }
  _bucket-groups(rows, key-cols).map(group => group.rows.first())
}

// Shared top-/bottom-n ranking. `descending` picks `slice-max` vs `slice-min`.
// Rows whose `col` parses to a number rank by value; rows with a non-numeric or
// missing `col` sort last (never ahead of a numeric row) so they are only kept
// when `n` reaches them. The numeric sort is stable, so ties keep input order
// and there is no tie expansion.
#let _slice-extreme(scope, data, col, n, by, descending) = {
  let rows = _normalise-data(data)
  if type(n) != int or n < 0 {
    fail-type(scope, "n", n, "a non-negative integer")
  }
  _require-cols(scope, "col", (col,), rows)
  let by-cols = _normalise-by(by, scope: scope)
  _require-cols(scope, "by", by-cols, rows)
  let take = group => {
    let scored = group.map(row => (
      row: row,
      v: parse-number(row.at(col, default: none)),
    ))
    let numeric = scored
      .filter(entry => entry.v != none)
      .sorted(key: entry => if descending { -entry.v } else { entry.v })
    let missing = scored.filter(entry => entry.v == none)
    let ranked = (numeric + missing).map(entry => entry.row)
    ranked.slice(0, calc.min(n, ranked.len()))
  }
  if by-cols.len() == 0 { return take(rows) }
  let out = ()
  for group in _bucket-groups(rows, by-cols) { out += take(group.rows) }
  out
}

/// Keep the `n` rows with the largest value of `col`.
///
/// Numeric ordering: cell values are parsed as numbers. Rows whose `col` is non-numeric or missing sort last, so they are kept only when `n` exceeds the numeric rows. `by:` ranks within each group (`none` for the whole dataset). Up to `n` rows are kept per group, ties keeping input order (no tie expansion).
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - col: Column to rank by.
/// - n: Number of rows to keep per group.
/// - by: Grouping columns: `none`, a column name, or an array of names.
///
/// Returns: A row-store array of the top rows.
///
/// See also: `slice-min`.
///
/// The thirstiest car in each class.
///
/// ```typst
/// #let worst = slice-max(mpg, "hwy", by: "class")
/// ```
#let slice-max(data, col, n: 1, by: none) = {
  _slice-extreme("slice-max", data, col, n, by, true)
}

/// Keep the `n` rows with the smallest value of `col`.
///
/// The bottom-n counterpart of `slice-max`, with the same parsing, grouping, and no-tie-expansion rules (non-numeric or missing `col` sorts last).
///
/// *Experimental.*
///
/// - data: Row-store (array of dicts) or column-store (dict of arrays).
/// - col: Column to rank by.
/// - n: Number of rows to keep per group.
/// - by: Grouping columns: `none`, a column name, or an array of names.
///
/// Returns: A row-store array of the bottom rows.
///
/// See also: `slice-max`.
///
/// The most economical car in each class.
///
/// ```typst
/// #let best = slice-min(mpg, "hwy", by: "class")
/// ```
#let slice-min(data, col, n: 1, by: none) = {
  _slice-extreme("slice-min", data, col, n, by, false)
}
