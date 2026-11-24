// Pre-stat data preparation: continuous pre-transforms applied before stats
// run, raw facet-level collection, and discrete-column factor rewriting.

#import "../scale/train.typ": (
  _SYNTHETIC-FEEDERS, _find-user-scale, _resolve-forced-type, level-position,
  mapping-ref-col, scope-of, transform-fwd,
)
#import "../utils/types.typ": (
  MISSING-KEY, is-discrete-column, is-missing, level-key, parse-number,
)
#import "../utils/aes-resolve.typ": merge-mapping
#import "../utils/late-binding.typ": is-late-binding
#import "../scale/arguments.typ": check-transform-domain
#import "common.typ": _resolve-data

// Collect unique levels of a column from the raw (pre-stat) data across all
// layers. Used by faceting to decide panel identity before any statistical
// transformation strips or synthesises rows.
#let _raw-levels-for(spec, var) = {
  let seen = ()
  let seen-set = (:)
  let any-missing = false
  for layer in spec.layers {
    let d = _resolve-data(layer, spec.data)
    // A layer whose data lacks the column, such as an `annotate()`, adds no
    // level and no missing cell.
    if d.len() == 0 or var not in d.first() { continue }
    for row in d {
      let v = row.at(var, default: none)
      if is-missing(v) {
        any-missing = true
        continue
      }
      let s = str(v)
      if seen-set.at(s, default: false) { continue }
      seen-set.insert(s, true)
      seen.push(s)
    }
  }
  // Missing cells get a trailing missing panel, unless the variable holds nothing
  // else, which still lays out no panel.
  if any-missing and seen.len() > 0 { seen.push(MISSING-KEY) }
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
    if _PRE-STAT-TRANSFORMS.contains(t) {
      result.insert(axis, (transform: t, scope: scope-of(s)))
    }
  }
  result
}

// (column, transform, scope, aesthetic) records to rewrite on each row of a
// layer.
// Synthetic feeders share the axis's pre-stat transform.
#let _pre-transform-cols(mapping, pre) = {
  if mapping == none { return () }
  let pairs = ()
  for (axis, entry) in pre.pairs() {
    let feeders = (axis,) + _SYNTHETIC-FEEDERS.filter(s => s.starts-with(axis))
    for f in feeders {
      let raw = mapping.at(f, default: none)
      if raw == none { continue }
      pairs.push((col: mapping-ref-col(raw), aesthetic: f, ..entry))
    }
  }
  pairs
}

// A cell outside the domain of the transform fails here, where the cell the
// user wrote is still at hand, so the message prints it before parsing.
#let _pre-transform-row(row, col-trans) = {
  let new-row = row
  for entry in col-trans {
    let raw = row.at(entry.col, default: none)
    let v = parse-number(raw)
    if v == none { continue }
    check-transform-domain(
      entry.scope,
      entry.aesthetic,
      raw,
      v,
      entry.transform,
    )
    new-row.insert(entry.col, transform-fwd(entry.transform, v))
  }
  new-row
}

#let _preprocess-data(spec) = {
  let pre = _scale-pre-transforms(spec.at("scales", default: (:)))
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

// Reserved prefix for the per-axis numeric position column synthesised below.
#let _POS-COL-PREFIX = "_gribouille-pos-"

// Whether each positional axis of a layer is discrete: the forced type of its
// mapping (`as-factor`), else a user discrete scale on the aesthetic, else the
// cells of the whole layer. Decided once for the layer, so a stat that runs on
// one group, or on a forced-discrete numeric column, agrees with the scale.
#let layer-discrete(mapping, data, user-scales) = {
  let out = (x: false, y: false)
  if mapping == none { return out }
  for axis in ("x", "y") {
    let raw = mapping.at(axis, default: none)
    // An `after-stat` axis names a column the stat has not made yet.
    if raw == none or is-late-binding(raw) { continue }
    let col = mapping-ref-col(raw)
    let forced = _resolve-forced-type(raw, data, col)
    let user = _find-user-scale(user-scales, axis)
    out.insert(axis, if forced != none {
      forced == "discrete"
    } else if user != none and user.at("type", default: none) == "discrete" {
      true
    } else {
      is-discrete-column(data, col)
    })
  }
  out
}

// Rewrite each discrete positional column to its 1-indexed level position so
// position adjustments (`position-jitter`, `position-beeswarm`, ...) operate in
// numeric space. Without this, jitter would offset the raw level values
// directly and the discrete scale would train on the jittered floats.
//
// A column is treated as discrete when it is forced (`as-factor`/sentinel) or
// when its values infer as strings, mirroring `_scale-type-from-cache` so the
// numeric spine and the trained scale never disagree on discreteness. Numeric
// columns stay continuous and are left untouched.
//
// The indices are written to a *separate* synthetic column (never over the
// source column) so a non-positional aesthetic mapped to the same column
// (`aes(x: as-factor("g"), fill: "g")`) still reads the raw levels. Callers
// repoint the positional mapping entry to the synthetic column via `repoint`.
// The level set is stashed on the layer (keyed by the synthetic column) so
// scale training can restore it as the discrete domain.
#let _rewrite-factor-cols(mapping, data) = {
  if mapping == none {
    return (data: data, factor-levels: (:), repoint: (:))
  }
  let factor-levels = (:)
  let repoint = (:)
  let new-data = data
  for axis in ("x", "y") {
    let raw = mapping.at(axis, default: none)
    if raw == none { continue }
    let col = mapping-ref-col(raw)
    let forced = _resolve-forced-type(raw, new-data, col)
    let discrete = if forced != none {
      forced == "discrete"
    } else {
      is-discrete-column(new-data, col)
    }
    if not discrete { continue }
    let pos-col = _POS-COL-PREFIX + col
    // Number levels in sorted order to match the alphabetically sorted trained
    // domain (`_discrete-domain-from-cache`), so `map-discrete`'s numeric branch
    // (`idx = value - 1`) indexes the spine into the right slot for any input
    // order. Typst closures capture read-only, so the value rewrite needs a
    // second `.map`.
    // A missing cell takes the slot after the last level, which is where the
    // trained scale puts its missing level. The recorded levels end with `MISSING-KEY`
    // so that training knows the column holds one.
    let seen = (:)
    let levels = ()
    let any-missing = false
    for row in new-data {
      let v = row.at(col, default: none)
      if is-missing(v) {
        any-missing = true
        continue
      }
      let s = str(v)
      if seen.at(s, default: false) { continue }
      seen.insert(s, true)
      levels.push(s)
    }
    levels = levels.sorted()
    let level-map = (:)
    for (i, s) in levels.enumerate() { level-map.insert(s, i + 1) }
    new-data = new-data.map(row => {
      let v = row.at(col, default: none)
      let r = row
      r.insert(
        pos-col,
        if is-missing(v) { levels.len() + 1 } else { level-map.at(str(v)) },
      )
      r
    })
    factor-levels.insert(
      pos-col,
      if any-missing { levels + (MISSING-KEY,) } else { levels },
    )
    repoint.insert(axis, pos-col)
  }
  (data: new-data, factor-levels: factor-levels, repoint: repoint)
}

// Move each row of a rewritten layer from its spine slot to the slot its level
// holds on the trained scale of the panel. `_rewrite-factor-cols` numbers the
// levels in the layer's own sorted order, but `map-discrete` reads a number as
// a slot of the trained domain, which follows the scale `limits` and the
// levels of every other layer. The offset the position added is kept. A level
// the trained scale does not carry gets no slot, so its row is not drawn.
// Under `coord-flip` the layer's x is drawn on the trained y, and its y on x.
#let _rebase-level-spine(data, layer, trained, flipped: false) = {
  let factor-levels = layer.at("_factor-levels", default: (:))
  let mapping = layer.at("mapping", default: none)
  if factor-levels.len() == 0 or mapping == none { return data }
  let out = data
  // x and y mapped to one source column share one spine column; shift it once.
  let done = ()
  for (axis, drawn-on) in (("x", "y"), ("y", "x")) {
    let pos-col = mapping-ref-col(mapping.at(axis, default: none))
    if type(pos-col) != str or pos-col in done { continue }
    let levels = factor-levels.at(pos-col, default: none)
    if levels == none { continue }
    let axis-trained = trained.at(
      if flipped { drawn-on } else { axis },
      default: none,
    )
    if axis-trained == none or axis-trained.type != "discrete" { continue }
    done.push(pos-col)
    let src-col = pos-col.slice(_POS-COL-PREFIX.len())
    let shift = (:)
    for (i, level) in levels.enumerate() {
      let slot = level-position(axis-trained, level)
      shift.insert(level, if slot == none { none } else { slot - (i + 1) })
    }
    if shift.values().all(by => by == 0) { continue }
    out = out.map(row => {
      let v = row.at(src-col, default: none)
      let spine = row.at(pos-col, default: none)
      if spine == none { return row }
      let by = shift.at(level-key(v), default: none)
      let r = row
      r.insert(pos-col, if by == none { none } else { spine + by })
      r
    })
  }
  out
}
