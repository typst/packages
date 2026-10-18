// Canonical grouping utilities shared across geoms, stats, and positions.
//
// Groups are determined by discrete aesthetics (non-numeric values or those
// forced discrete via as-factor()), following the compute-group pattern.
// The explicit "group" aesthetic always contributes regardless of value
// type.

#import "../utils/types.typ": is-numeric-value
#import "../scale/train.typ": mapping-ref-col, mapping-ref-type
#import "../utils/late-binding.typ": after-scale-source

/// Canonical set of aesthetics that may create groups, in priority order.
#let group-aesthetics = ("group", "colour", "fill", "linetype", "shape")

// Grouping column for a mapping value: unwrap an `after-scale` marker to its
// source column (a stage's `start`) and a mapping-ref/typst-markup to its
// column. Returns `none` for a source-less marker (a pure `after-scale`
// closure), which callers skip since it carries no grouping variable.
#let _group-col(value) = mapping-ref-col(after-scale-source(value))

/// Compute a canonical group key for a row.
///
/// Two modes:
///
/// `trained: none` (data-type mode, used by stats and positions before scale training): includes an aesthetic when its cell value is non-numeric, or when a `mapping-ref` annotation forces it discrete via `as-factor()`. The `"group"` aesthetic is always included.
///
/// `trained: dict` (scale-aware mode, used by geoms which have `ctx.trained`): includes an aesthetic only when its trained scale type is `"discrete"`. The `"group"` aesthetic is always included.
///
/// Returns `"_all"` when no aesthetics qualify.
///
/// - row: Row dictionary providing aesthetic cell values.
/// - mapping: Aesthetic mapping (column names or `mapping-ref` dicts).
/// - trained: Trained scales dict for scale-aware mode, or `none` for data-type mode.
///
/// Returns: Group key string joining the qualifying discrete cell values, or `"_all"` when no aesthetic qualifies.
#let group-key(row, mapping, trained: none) = {
  let keys = ()
  let x-col = _group-col(mapping.at("x", default: none))
  let y-col = _group-col(mapping.at("y", default: none))

  for aes-name in group-aesthetics {
    let aes-val = mapping.at(aes-name, default: none)
    if aes-val == none { continue }
    let col-name = _group-col(aes-val)
    if col-name == none { continue }
    if col-name == x-col or col-name == y-col { continue }

    if trained != none and aes-name != "group" {
      let t = trained.at(aes-name, default: none)
      if t == none or t.type != "discrete" { continue }
    } else if aes-name != "group" {
      let val = row.at(col-name, default: none)
      let forced = mapping-ref-type(aes-val) == "discrete"
      if not forced and is-numeric-value(val) { continue }
    }

    keys.push(str(row.at(col-name, default: "")))
  }

  if keys.len() == 0 { "_all" } else { keys.join("\u{1}") }
}

/// Partition data into groups by the canonical group key.
///
/// Returns an array of `(key: str, data: array)` in first-appearance order. `trained` is forwarded to `group-key`: pass `none` for data-type mode (stats and positions) or `ctx.trained` for scale-aware mode (geoms).
///
/// - data: Array of row dictionaries to partition.
/// - mapping: Aesthetic mapping forwarded to `group-key`.
/// - trained: Trained scales dict for scale-aware mode, or `none` for data-type mode.
///
/// Returns: Array of `(key: str, data: array)` pairs in first-appearance order.
#let partition-by-group(data, mapping, trained: none) = {
  let groups = (:)
  let order = ()
  let seen = (:)
  for row in data {
    let key = group-key(row, mapping, trained: trained)
    let bucket = groups.at(key, default: ())
    bucket.push(row)
    groups.insert(key, bucket)
    if not seen.at(key, default: false) {
      seen.insert(key, true)
      order.push(key)
    }
  }
  order.map(k => (key: k, data: groups.at(k)))
}

/// Return the column names for all grouping aesthetics (not x or y).
///
/// Used by the per-group stat framework to know which columns to re-inject into stat output rows so group identity is preserved across the stat.
///
/// - mapping: Aesthetic mapping (column names or `mapping-ref` dicts).
///
/// Returns: Array of grouping-aesthetic column names, excluding the x and y columns.
#let group-cols(mapping) = {
  let out = ()
  let x-col = _group-col(mapping.at("x", default: none))
  let y-col = _group-col(mapping.at("y", default: none))
  for aes-name in group-aesthetics {
    let aes-val = mapping.at(aes-name, default: none)
    if aes-val == none { continue }
    let col-name = _group-col(aes-val)
    if col-name == none { continue }
    if col-name == x-col or col-name == y-col { continue }
    if not out.contains(col-name) { out.push(col-name) }
  }
  out
}

/// Copy each positional aesthetic's value into a column named after its source when a grouping aesthetic reuses that same column.
///
/// `group-cols` cannot re-inject a column equal to x or y, so after an aggregating stat renames the positional column to a generic key (`"x"` / `"y"`), a `fill`/`colour`/... mapped to that same column would find no value and resolve to the default ink with an empty guide. This exposes the stat's positional value under the source column name so the (already re-attached) grouping mapping resolves. The mapping is left untouched, and the work runs only for the same-column reuse case.
///
/// - data: Stat output rows (after compute-group recombination).
/// - input-mapping: The layer's pre-stat mapping carrying the source columns.
/// - output-mapping: The stat's output mapping naming the positional columns.
///
/// Returns: `data` with the source column added wherever a positional aesthetic is reused.
#let expose-shared-positional(data, input-mapping, output-mapping) = {
  if input-mapping == none { return data }
  let new-data = data
  for axis in ("x", "y") {
    let src = _group-col(input-mapping.at(axis, default: none))
    if src == none { continue }
    let out-col = output-mapping.at(axis, default: none)
    if out-col == none or out-col == src { continue }
    let reused = group-aesthetics.any(a => (
      _group-col(input-mapping.at(a, default: none)) == src
    ))
    if not reused { continue }
    new-data = new-data.map(row => {
      let v = row.at(out-col, default: none)
      if v == none or row.at(src, default: none) != none { return row }
      let r = row
      r.insert(src, v)
      r
    })
  }
  new-data
}
