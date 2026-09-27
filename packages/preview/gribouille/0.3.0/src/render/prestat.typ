// Pre-stat data preparation: continuous pre-transforms applied before stats
// run, raw facet-level collection, and discrete-column factor rewriting.

#import "../scale/train.typ": (
  _SYNTHETIC-FEEDERS, _find-user-scale, _resolve-forced-type, mapping-ref-col,
  transform-fwd,
)
#import "../utils/types.typ": parse-number
#import "../utils/aes-resolve.typ": merge-mapping
#import "common.typ": _resolve-data

// Collect unique levels of a column from the raw (pre-stat) data across all
// layers. Used by faceting to decide panel identity before any statistical
// transformation strips or synthesises rows.
#let _raw-levels-for(spec, var) = {
  let seen = ()
  let seen-set = (:)
  for layer in spec.layers {
    let d = _resolve-data(layer, spec.data)
    for row in d {
      let v = row.at(var, default: none)
      if v == none { continue }
      let s = str(v)
      if seen-set.at(s, default: false) { continue }
      seen-set.insert(s, true)
      seen.push(s)
    }
  }
  seen
}

// Continuous transforms that warp data before stats run. `reverse` and
// `identity` stay as visual-only warps applied at mapping time.
#let _PRE-STAT-TRANSFORMS = ("log10", "sqrt")

#let _scale-pre-transforms(scales) = {
  let result = (:)
  for axis in ("x", "y") {
    let s = _find-user-scale(scales, axis)
    if s == none { continue }
    if s.at("type", default: none) != "continuous" { continue }
    let t = s.at("transform", default: "identity")
    if _PRE-STAT-TRANSFORMS.contains(t) { result.insert(axis, t) }
  }
  result
}

// (column, transform) pairs to rewrite on each row of a layer. Synthetic
// feeders share the axis's pre-stat transform.
#let _pre-transform-cols(mapping, pre) = {
  if mapping == none { return () }
  let pairs = ()
  for (axis, t) in pre.pairs() {
    let feeders = (axis,) + _SYNTHETIC-FEEDERS.filter(s => s.starts-with(axis))
    for f in feeders {
      let raw = mapping.at(f, default: none)
      if raw == none { continue }
      pairs.push((mapping-ref-col(raw), t))
    }
  }
  pairs
}

#let _pre-transform-row(row, col-trans) = {
  let new-row = row
  for (col, transform) in col-trans {
    let v = parse-number(row.at(col, default: none))
    if v == none { continue }
    new-row.insert(col, transform-fwd(transform, v))
  }
  new-row
}

#let _preprocess-data(spec) = {
  let pre = _scale-pre-transforms(spec.at("scales", default: ()))
  if pre.len() == 0 { return spec }
  let new-layers = spec.layers.map(layer => {
    let mapping = merge-mapping(layer, spec.mapping)
    let col-trans = _pre-transform-cols(mapping, pre)
    if col-trans.len() == 0 { return layer }
    let data = _resolve-data(layer, spec.data)
    let new = layer
    new.data = data.map(row => _pre-transform-row(row, col-trans))
    new.insert("data-trusted", true)
    new
  })
  let new-spec = spec
  new-spec.layers = new-layers
  new-spec
}

// Rewrite each discrete-marked positional column to its 1-indexed level
// position so position adjustments (`position-jitter`, ...) operate in
// numeric space. Without this, jitter would offset the raw level values
// directly and the discrete scale would train on the jittered floats.
// The level set is stashed on the layer so scale training can restore it
// as the discrete domain.
#let _rewrite-factor-cols(mapping, data) = {
  if mapping == none {
    return (data: data, factor-levels: (:))
  }
  let factor-levels = (:)
  let new-data = data
  for axis in ("x", "y") {
    let raw = mapping.at(axis, default: none)
    if raw == none { continue }
    let col = mapping-ref-col(raw)
    if _resolve-forced-type(raw, new-data, col) != "discrete" { continue }
    // Build levels and the level→index map in a single pass; Typst closures
    // capture variables read-only, so the value rewrite below still needs a
    // second `.map`.
    let levels = ()
    let level-map = (:)
    for row in new-data {
      let v = row.at(col, default: none)
      if v == none { continue }
      let s = str(v)
      if level-map.at(s, default: none) != none { continue }
      level-map.insert(s, levels.len() + 1)
      levels.push(s)
    }
    new-data = new-data.map(row => {
      let v = row.at(col, default: none)
      if v == none { return row }
      let r = row
      r.insert(col, level-map.at(str(v)))
      r
    })
    factor-levels.insert(col, levels)
  }
  (data: new-data, factor-levels: factor-levels)
}
