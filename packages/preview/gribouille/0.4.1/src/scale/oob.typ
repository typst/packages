// Out-of-range pre-pass.
//
// Walks each prepared layer once after training and removes rows whose value
// for any user-limited aesthetic falls outside the trained domain. When the
// scale's `oob` is `"squish"` the row stays and the cell is clamped to the
// nearest limit so downstream resolvers see an in-range value. Discrete
// scales censor only — squish has no geometric meaning on levels.

#import "../utils/types.typ": parse-number
#import "../utils/late-binding.typ": is-late-binding
#import "train.typ": _to-stat, mapping-ref-col, view-bounds-stat
#import "../utils/errors.typ": fail

// Returns one of:
//   ("in",     value)   — unchanged
//   ("squish", clamped) — kept, value rewritten
//   ("drop",   value)   — caller drops the row
//
// `bounds` is the expanded `(t-lo, t-hi)` view in stat space, precomputed once
// per aesthetic by `filter-oob`; `none` for discrete scales.
#let _check(trained, raw, bounds: none) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return ("in", raw) }
  if spec.at("limits", default: none) == none { return ("in", raw) }
  let oob = spec.at("oob", default: "drop")
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return ("in", raw) }
    // Test against the expanded view bounds (in stat space) rather than the raw
    // `limits`, so a value sitting in the expansion headroom -- which still maps
    // inside the visible panel -- survives instead of being dropped.
    let (t-lo, t-hi) = bounds
    let sv = _to-stat(trained, v)
    // `t-lo`/`t-hi` follow the domain order, which runs high-to-low when the
    // user supplies reversed `limits` to flip the axis; test against the sorted
    // span so the in-range check holds either way.
    if sv >= calc.min(t-lo, t-hi) and sv <= calc.max(t-lo, t-hi) {
      return ("in", raw)
    }
    if oob == "squish" {
      // Clamp to the nearest `limits` endpoint (the visible data edge), not the
      // expanded bound, matching the documented squish-to-limit semantics.
      // `t-lo` pairs with `lo` and `t-hi` with `hi` whatever the order.
      let (lo, hi) = trained.domain
      let to-lo = calc.abs(sv - t-lo) <= calc.abs(sv - t-hi)
      return ("squish", if to-lo { lo } else { hi })
    }
    return ("drop", raw)
  }
  if trained.type == "discrete" {
    if raw == none { return ("in", raw) }
    let s = str(raw)
    if trained.domain.contains(s) { return ("in", raw) }
    return ("drop", raw)
  }
  ("in", raw)
}

// Filter rows of every layer through the trained dict. Returns the rewritten
// layers and a per-aesthetic dropped-row count. `strict: true` converts the
// first drop into a `panic` instead.
#let filter-oob(layers, trained, strict: false) = {
  let active = ()
  // Expanded view bounds are constant per aesthetic; resolve them once here so
  // the per-row `_check` only warps the cell value.
  let bounds = (:)
  for (aes, t) in trained.pairs() {
    let spec = t.at("spec", default: none)
    if spec == none { continue }
    if spec.at("limits", default: none) == none { continue }
    active.push(aes)
    if t.type == "continuous" { bounds.insert(aes, view-bounds-stat(t)) }
  }
  if active.len() == 0 { return (layers: layers, counts: (:)) }

  let counts = (:)
  let new-layers = ()
  for layer in layers {
    // A `clip: false` layer (e.g. `annotate(clip: false)`) is meant to draw
    // beyond the limits, so it opts out of the drop pre-pass entirely; its rows
    // pass through verbatim. Mirror the unclipped-set predicate in `panel-draw`
    // (`not layer.clip`) so the two passes agree on which layers are unclipped.
    if not layer.at("clip", default: true) {
      new-layers.push(layer)
      continue
    }
    let mapping = layer.at("mapping", default: none)
    let data = layer.at("data", default: none)
    if mapping == none or type(data) != array {
      new-layers.push(layer)
      continue
    }
    let kept = ()
    for (row-idx, row) in data.enumerate() {
      let new-row = row
      let drop = false
      for aes in active {
        let raw = mapping.at(aes, default: none)
        if raw == none { continue }
        if is-late-binding(raw) { continue }
        let col = mapping-ref-col(raw)
        let cell = row.at(col, default: none)
        let t = trained.at(aes)
        let (action, value) = _check(t, cell, bounds: bounds.at(
          aes,
          default: none,
        ))
        if action == "in" { continue }
        if action == "squish" {
          new-row.insert(col, value)
          continue
        }
        if strict {
          fail(
            "scale `" + aes + "`",
            "row "
              + str(row-idx)
              + " value "
              + repr(cell)
              + " outside limits "
              + repr(t.spec.at("limits")),
            hint: "Set `oob: \"squish\"` to clamp, widen `limits`, "
              + "or remove `strict: true` to drop silently.",
          )
        }
        drop = true
        counts.insert(aes, counts.at(aes, default: 0) + 1)
        break
      }
      if not drop { kept.push(new-row) }
    }
    let new-layer = layer
    new-layer.data = kept
    new-layers.push(new-layer)
  }
  (layers: new-layers, counts: counts)
}
