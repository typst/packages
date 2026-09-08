///! Column extraction and explicit coercion for tidy-row data.
///!
///! Data is an array of dictionaries (one per row). `as-numeric` and
///! `as-factor` are dual-arity helpers: call them with `(data, col)` to rewrite
///! a column, or with just `(col)` to tag an aesthetic mapping so the scale
///! picks the right (continuous vs. discrete) interpretation without mutating
///! the data.

#import "utils/types.typ": parse-number
#import "utils/errors.typ": fail

#let column(data, name) = {
  data.map(row => row.at(name, default: none))
}

// Partition `rows` into buckets keyed by `str(key-fn(row))`.
// Preserves input order within each bucket.
#let group-by(rows, key-fn) = {
  let out = (:)
  for row in rows {
    let k = str(key-fn(row))
    let bucket = out.at(k, default: ())
    bucket.push(row)
    out.insert(k, bucket)
  }
  out
}

// Coerce a `data` argument into the canonical row-store shape.
//
// Accepts either:
//   - row-store: an array of dictionaries (one per row), or
//   - column-store: a dictionary of equal-length arrays (one per column).
//
// `none` passes through unchanged so optional per-layer overrides keep their
// "inherit plot data" semantics. Idempotent on already-normalised input.
#let _normalise-data(data) = {
  if data == none { return none }
  if type(data) == array {
    for (i, row) in data.enumerate() {
      if type(row) != dictionary {
        fail(
          "data",
          "row-store array must contain dictionaries; got "
            + str(type(row))
            + " at index "
            + str(i),
        )
      }
    }
    return data
  }
  if type(data) == dictionary {
    let pairs = data.pairs()
    if pairs.len() == 0 { return () }
    let len = none
    for (k, vs) in pairs {
      if type(vs) != array {
        fail(
          "data",
          "column-store value for \""
            + k
            + "\" must be an array; got "
            + str(type(vs)),
        )
      }
      if len == none {
        len = vs.len()
      } else if vs.len() != len {
        let first-key = pairs.first().at(0)
        fail(
          "data",
          "column-store columns must share the same length; got \""
            + first-key
            + "\"="
            + str(len)
            + ", \""
            + k
            + "\"="
            + str(vs.len()),
        )
      }
    }
    return range(len).map(i => {
      let row = (:)
      for (k, vs) in pairs { row.insert(k, vs.at(i)) }
      row
    })
  }
  fail(
    "data",
    "must be an array of dicts or a dict of arrays; got " + str(type(data)),
  )
}

#let _mapping-ref(col, type) = (
  kind: "mapping-ref",
  var: col,
  type: type,
)

/// Coerce a column to numeric, or tag an aesthetic as continuous.
///
/// Two call forms: when given `(data, col)` it returns a new dataset with `col` parsed as a number in every row; when given `(col)` alone it returns a mapping-ref annotation that `aes` accepts in place of a column name, forcing the scale system to treat that channel as continuous.
///
/// - args: Either `(data, col)` or `(col)`. See arities.
///
/// Call forms:
/// - `as-numeric(data, col)`: Return a new dataset with `col` converted to numbers via `parse-number`.
/// - `as-numeric(col)`: Return a `mapping-ref` dict tagging `col` as continuous for `aes`.
///
/// Returns: New dataset (2-arg) or mapping-ref dict (1-arg).
///
/// See also: `as-factor`, `aes`.
///
/// Two-arg form rewrites a column with parsed numbers; useful when the data arrived as strings.
///
/// ```typst
/// #let raw = (
///   (x: "1", y: 2.0),
///   (x: "2", y: 4.0),
///   (x: "3", y: 9.0),
/// )
/// #let d = as-numeric(raw, "x")
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// One-arg form tags the column inside `aes` so the scale picks continuous semantics without rewriting the dataset.
///
/// ```typst
/// #let raw = (
///   (x: 1, y: 2.0),
///   (x: 2, y: 4.0),
///   (x: 3, y: 9.0),
/// )
/// #plot(
///   data: raw,
///   mapping: aes(x: as-numeric("x"), y: "y"),
///   layers: (geom-point(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let as-numeric(..args) = {
  let pos = args.pos()
  if pos.len() == 1 {
    return _mapping-ref(pos.at(0), "continuous")
  }
  let (data, col) = pos
  data.map(row => {
    let v = row.at(col, default: none)
    let new-row = row
    new-row.insert(col, parse-number(v))
    new-row
  })
}

/// Coerce a column to string factors, or tag an aesthetic as discrete.
///
/// Two call forms: when given `(data, col)` it returns a new dataset with `col` stringified in every row; when given `(col)` alone it returns a mapping-ref annotation that `aes` accepts in place of a column name, forcing the scale system to treat that channel as discrete.
///
/// - args: Either `(data, col)` or `(col)`. See arities.
///
/// Call forms:
/// - `as-factor(data, col)`: Return a new dataset with `col` coerced to strings (preserving `none`).
/// - `as-factor(col)`: Return a `mapping-ref` dict tagging `col` as discrete for `aes`.
///
/// Returns: New dataset (2-arg) or mapping-ref dict (1-arg).
///
/// See also: `as-numeric`, `aes`.
///
/// One-arg form tags the column as discrete inline in `aes`, useful when a numeric column should be treated as categorical without rewriting the dataset.
///
/// ```typst
/// #let iris = (
///   (sl: 5.1, sp: 1),
///   (sl: 7.0, sp: 2),
///   (sl: 6.3, sp: 3),
/// )
/// #plot(
///   data: iris,
///   mapping: aes(x: as-factor("sp"), y: "sl", fill: as-factor("sp")),
///   layers: (geom-col(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Two-arg form rewrites the column to strings, useful as a one-shot pre-processing step.
///
/// ```typst
/// #let raw = (
///   (sp: 1, y: 5.1),
///   (sp: 2, y: 7.0),
///   (sp: 3, y: 6.3),
/// )
/// #let d = as-factor(raw, "sp")
/// #plot(
///   data: d,
///   mapping: aes(x: "sp", y: "y"),
///   layers: (geom-col(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let as-factor(..args) = {
  let pos = args.pos()
  if pos.len() == 1 {
    return _mapping-ref(pos.at(0), "discrete")
  }
  let (data, col) = pos
  data.map(row => {
    let v = row.at(col, default: none)
    let new-row = row
    new-row.insert(col, if v == none { none } else { str(v) })
    let factors = new-row.at("_gribouille-factors", default: ())
    if not factors.contains(col) { factors.push(col) }
    new-row.insert("_gribouille-factors", factors)
    new-row
  })
}
