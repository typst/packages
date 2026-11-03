// Out-of-range pre-pass.
//
// Walks each prepared layer once after training and removes rows whose value
// for any user-limited aesthetic falls outside the trained domain. When the
// scale's `oob` is `"squish"` the row stays and the cell is clamped to the
// nearest limit so downstream resolvers see an in-range value. Discrete
// scales censor only — squish has no geometric meaning on levels.

#import "../utils/types.typ": parse-number
#import "../utils/late-binding.typ": is-late-binding
#import "train.typ": mapping-ref-col

// Returns one of:
//   ("in",     value)   — unchanged
//   ("squish", clamped) — kept, value rewritten
//   ("drop",   value)   — caller drops the row
#let _check(trained, raw) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return ("in", raw) }
  if spec.at("limits", default: none) == none { return ("in", raw) }
  let oob = spec.at("oob", default: "drop")
  if trained.type == "continuous" {
    let v = parse-number(raw)
    if v == none { return ("in", raw) }
    let (lo, hi) = trained.domain
    if v >= lo and v <= hi { return ("in", raw) }
    if oob == "squish" {
      return ("squish", if v < lo { lo } else { hi })
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
  for (aes, t) in trained.pairs() {
    let spec = t.at("spec", default: none)
    if spec == none { continue }
    if spec.at("limits", default: none) == none { continue }
    active.push(aes)
  }
  if active.len() == 0 { return (layers: layers, counts: (:)) }

  let counts = (:)
  let new-layers = ()
  for layer in layers {
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
        let (action, value) = _check(t, cell)
        if action == "in" { continue }
        if action == "squish" {
          new-row.insert(col, value)
          continue
        }
        if strict {
          panic(
            "scale `"
              + aes
              + "`: row "
              + str(row-idx)
              + " value "
              + repr(cell)
              + " outside limits "
              + repr(t.spec.at("limits"))
              + ". Set `oob: \"squish\"` to clamp, widen `limits`, "
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
