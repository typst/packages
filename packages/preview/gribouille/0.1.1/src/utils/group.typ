// Canonical grouping utilities shared across geoms, stats, and positions.
//
// Groups are determined by discrete aesthetics (non-numeric values or those
// forced discrete via as-factor()), following the compute-group pattern.
// The explicit "group" aesthetic always contributes regardless of value
// type.

#import "../utils/types.typ": is-numeric-value
#import "../scale/train.typ": mapping-ref-col, mapping-ref-type

/// Canonical set of aesthetics that may create groups, in priority order.
///
/// \@internal
#let group-aesthetics = ("group", "colour", "fill", "linetype", "shape")

/// Compute a canonical group key for a row.
///
/// Two modes:
///
/// `trained: none` (data-type mode, used by stats and positions before scale
/// training): includes an aesthetic when its cell value is non-numeric, or
/// when a `mapping-ref` annotation forces it discrete via `as-factor()`.
/// The `"group"` aesthetic is always included.
///
/// `trained: dict` (scale-aware mode, used by geoms which have `ctx.trained`):
/// includes an aesthetic only when its trained scale type is `"discrete"`.
/// The `"group"` aesthetic is always included.
///
/// Returns `"_all"` when no aesthetics qualify.
/// \@param row Row dictionary providing aesthetic cell values.
///
/// \@param mapping Aesthetic mapping (column names or `mapping-ref` dicts).
///
/// \@param trained Trained scales dict for scale-aware mode, or `none` for data-type mode.
/// \@returns Group key string joining the qualifying discrete cell values, or `"_all"` when no aesthetic qualifies.
/// \@internal
#let group-key(row, mapping, trained: none) = {
  let keys = ()
  let x-col = mapping-ref-col(mapping.at("x", default: none))
  let y-col = mapping-ref-col(mapping.at("y", default: none))

  for aes-name in group-aesthetics {
    let aes-val = mapping.at(aes-name, default: none)
    if aes-val == none { continue }
    let col-name = mapping-ref-col(aes-val)
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
/// Returns an array of `(key: str, data: array)` in first-appearance order.
/// `trained` is forwarded to `group-key`: pass `none` for data-type mode
/// (stats and positions) or `ctx.trained` for scale-aware mode (geoms).
/// \@param data Array of row dictionaries to partition.
///
/// \@param mapping Aesthetic mapping forwarded to `group-key`.
///
/// \@param trained Trained scales dict for scale-aware mode, or `none` for data-type mode.
/// \@returns Array of `(key: str, data: array)` pairs in first-appearance order.
/// \@internal
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
/// Used by the per-group stat framework to know which columns to re-inject
/// into stat output rows so group identity is preserved across the stat.
/// \@param mapping Aesthetic mapping (column names or `mapping-ref` dicts).
/// \@returns Array of grouping-aesthetic column names, excluding the x and y columns.
/// \@internal
#let group-cols(mapping) = {
  let out = ()
  let x-col = mapping-ref-col(mapping.at("x", default: none))
  let y-col = mapping-ref-col(mapping.at("y", default: none))
  for aes-name in group-aesthetics {
    let aes-val = mapping.at(aes-name, default: none)
    if aes-val == none { continue }
    let col-name = mapping-ref-col(aes-val)
    if col-name == x-col or col-name == y-col { continue }
    if not out.contains(col-name) { out.push(col-name) }
  }
  out
}
