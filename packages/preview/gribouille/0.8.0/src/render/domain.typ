// Domain scanning and post-training domain fix-ups (bar-zero floor, geom
// extents, ribbon padding), plus the flip mapping swap. The coord steps that
// follow (limits, expansion, flip) live in each coord's `train`.

#import "../scale/train.typ": mapping-ref-col
#import "../utils/types.typ": parse-number
#import "common.typ": _track-min-max
#import "../geom/registry.typ": GEOMS
#import "../stat/apply.typ": stat-binned, stat-flush
#import "../utils/bin.typ": bin-x-extents

// Fold the ribbon y-range, so `ymin`/`ymax` extend the trained y domain.
#let _scan-rows(mapping, layer-data, acc) = {
  let ymin-col = if mapping == none { none } else {
    mapping.at("ymin", default: none)
  }
  let ymax-col = if mapping == none { none } else {
    mapping.at("ymax", default: none)
  }
  if ymin-col == none and ymax-col == none { return acc }
  for row in layer-data {
    for col in (ymin-col, ymax-col) {
      if col == none { continue }
      let v = parse-number(row.at(col, default: none))
      if v == none { continue }
      let (lo, hi) = _track-min-max(acc.ribbon-y-min, acc.ribbon-y-max, v)
      acc.ribbon-y-min = lo
      acc.ribbon-y-max = hi
    }
  }
  acc
}

// Single-pass classifier feeding `_post-train`. Only ribbon layers need a
// row scan; every other layer is classified from its name and parameters.
#let _post-train-scan(layers) = {
  let acc = (
    needs-y-zero: false,
    flush: false,
    any-fill: false,
    bar-half: 0,
    ribbon-y-min: none,
    ribbon-y-max: none,
  )
  for layer in layers {
    let geom = layer.at("name", default: "")
    let mapping = layer.at("mapping", default: none)

    if geom == "col" or geom == "area" { acc.needs-y-zero = true }
    if stat-flush(layer.at("stat-source", default: "identity")) {
      acc.flush = true
    }
    if geom == "col" and layer.at("position", default: "identity") == "fill" {
      acc.any-fill = true
    }
    // Band geoms and dodged marks reach half their width either side of the
    // category, so a discrete category axis keeps that much room past its
    // outer levels. The pad matters on the radius of `coord-radial(theta:
    // "y")`, where the inner level would otherwise sit at radius 0 and a mark
    // reaching past it would cross the centre.
    if geom in ("col", "boxplot", "crossbar", "errorbar") {
      let w = layer.at("params", default: (:)).at("width", default: 0.9)
      if type(w) != length { acc.bar-half = calc.max(acc.bar-half, w / 2) }
    }
    let pos = layer.at("position", default: "identity")
    if type(pos) == dictionary and pos.at("name", default: none) == "dodge" {
      let w = pos.at("params", default: (:)).at("width", default: 0.9)
      acc.bar-half = calc.max(acc.bar-half, w / 2)
    } else if pos == "dodge" {
      acc.bar-half = calc.max(acc.bar-half, 0.9 / 2)
    }
    acc = _scan-rows(mapping, layer.at("data", default: ()), acc)
  }
  acc
}

// Axis titles that a statistic fixes when the plot mapping cannot name them:
// the Q-Q statistics synthesise their own columns, so the mapped `sample`
// column names no axis. Applies only when every layer uses such a statistic.
#let _STAT-AXIS-NAMES = (
  qq: (x: "theoretical", y: "sample"),
  qq-line: (x: "theoretical", y: "sample"),
)

#let _stat-axis-names(layers) = {
  let names = layers.map(l => _STAT-AXIS-NAMES.at(
    l.at("stat-source", default: ""),
    default: none,
  ))
  if names.len() == 0 or names.any(n => n == none) { return (:) }
  names.first()
}

// Inject labels `x`/`y`/... names into trained scale specs so axis and legend
// titles follow labels() overrides. `auto` (the labels default) keeps the
// scale-derived name; `none` sets `spec.blank` to suppress the title and
// collapse its reserved space; a string overrides the name.
#let _apply-labels(trained, labels, layers) = {
  for (aes-name, name) in _stat-axis-names(layers).pairs() {
    let t = trained.at(aes-name, default: none)
    if t == none { continue }
    let spec = t.at("spec", default: none)
    let base = if spec == none { (aesthetic: aes-name) } else { spec }
    if base.at("name", default: none) != none { continue }
    let new-t = t
    new-t.insert("spec", base + (name: name))
    trained.insert(aes-name, new-t)
  }
  if labels == none { return trained }
  for (aes-name, label) in labels.axes.pairs() {
    if label == auto { continue }
    let t = trained.at(aes-name, default: none)
    if t == none { continue }
    let spec = t.at("spec", default: none)
    let base = if spec == none { (aesthetic: aes-name) } else { spec }
    let new-spec = if label == none {
      base + (blank: true)
    } else {
      base + (name: label)
    }
    let new-t = t
    new-t.insert("spec", new-spec)
    trained.insert(aes-name, new-t)
  }
  trained
}

// The positional aesthetics that move to the other axis with `coord-flip`, as
// `(x-side, y-side)` pairs. A geom reads these names against the swapped
// trained scales, so each pair listed here swaps with them. A channel left out
// stays in user space, so its geom draws correctly only if it branches on
// `ctx.flipped` itself.
#let _FLIP-PAIRS = (
  ("x", "y"),
  ("xend", "yend"),
  ("xmin", "ymin"),
  ("xmax", "ymax"),
)

// Swap each `_FLIP-PAIRS` entry of a layer mapping, keys and all: a key is
// present after the swap only if its partner was present before. A geom that
// reads `mapping.x` directly still finds the key `aes()` held as `none`, and a
// geom that reads an absent key with `default:` still gets its default.
#let _flip-mapping(mapping) = {
  if mapping == none { return none }
  let out = mapping
  for (x-side, y-side) in _FLIP-PAIRS {
    let has-x = x-side in mapping
    let has-y = y-side in mapping
    let x-col = out.remove(x-side, default: none)
    let y-col = out.remove(y-side, default: none)
    if has-y { out.insert(x-side, y-col) }
    if has-x { out.insert(y-side, x-col) }
  }
  out
}

// Rewrite a continuous trained-scale's domain via `fn((lo, hi)) -> (lo, hi)`.
// No-ops when the axis is missing or non-continuous.
#let _rewrite-continuous-domain(trained, axis, fn) = {
  let t = trained.at(axis, default: none)
  if t == none or t.type != "continuous" { return trained }
  let new = t
  new.insert("domain", fn(t.domain))
  trained.insert(axis, new)
  trained
}

// Widen a continuous axis to cover `(ext-lo, ext-hi)`. A missing axis is
// seeded as continuous with that range, for a geom such as ellipse that maps
// no `x`/`y` of its own; a discrete axis is left as is. A reversed domain
// keeps its direction and widens outward on each side.
#let _extend-domain(trained, axis, ext-lo, ext-hi) = {
  if trained.at(axis, default: none) == none {
    trained.insert(axis, (
      type: "continuous",
      domain: (ext-lo, ext-hi),
      spec: none,
      transform: "identity",
      typst-mark: false,
    ))
    return trained
  }
  _rewrite-continuous-domain(trained, axis, ((lo, hi)) => if lo <= hi {
    (calc.min(lo, ext-lo), calc.max(hi, ext-hi))
  } else {
    (calc.max(lo, ext-hi), calc.min(hi, ext-lo))
  })
}

// Widen each axis of `trained` to an `(x, y)` extents record, and keep the
// user limits of a widened continuous axis as its `oob-cutoff`.
#let _extend-axes(trained, ext, cutoffs) = {
  for axis in ("x", "y") {
    let range = ext.at(axis, default: none)
    if range == none { continue }
    let (ext-lo, ext-hi) = range
    trained = _extend-domain(trained, axis, ext-lo, ext-hi)
    let cutoff = cutoffs.at(axis)
    if cutoff != none and trained.at(axis).type == "continuous" {
      let t = trained.at(axis)
      t.insert("oob-cutoff", cutoff)
      trained.insert(axis, t)
    }
  }
  trained
}

// The user limits of a continuous axis, in domain order, with `none` on a
// side left at `auto`, or `none` when the axis has no limits. Read from the
// trained domain, so the values are in the space the layer rows use.
#let _limit-cutoff(trained, axis) = {
  let t = trained.at(axis, default: none)
  if t == none or t.type != "continuous" { return none }
  let spec = t.at("spec", default: none)
  let limits = if spec == none { none } else {
    spec.at("limits", default: none)
  }
  if limits == none { return none }
  let (lo, hi) = t.domain
  (
    if limits.at(0) == auto { none } else { lo },
    if limits.at(1) == auto { none } else { hi },
  )
}

// Whether `value` lies inside a `_limit-cutoff` span. A `none` side is open,
// and a value that is not a number is kept, for the hook to skip.
#let _within-cutoff(value, cutoff) = {
  let v = parse-number(value)
  if v == none { return true }
  let (c-lo, c-hi) = cutoff
  if c-lo != none and c-hi != none and c-lo > c-hi {
    (c-lo, c-hi) = (c-hi, c-lo)
  }
  (c-lo == none or v >= c-lo) and (c-hi == none or v <= c-hi)
}

// Apply post-training domain fix-ups (bar-zero floor, geom extents, bin
// edges of binned stats, ribbon ymin/ymax padding on unpinned sides, discrete bar padding).
// Called once globally and once per panel under free scales so each panel's
// domain reflects its own subset.
#let _post-train(trained, layers) = {
  let scan = _post-train-scan(layers)

  // Bars and areas anchor against y=0. The touching side is tagged so
  // `apply-expand` collapses its auto-expansion to zero, matching the
  // `expansion(mult = c(0, 0.05))` convention. `position: "fill"` anchors
  // both sides; mixed-sign data keeps symmetric expansion.
  if scan.needs-y-zero {
    let yt = trained.at("y", default: none)
    if yt != none and yt.type == "continuous" {
      let (lo, hi) = yt.domain
      let new-y = yt
      new-y.insert("domain", (calc.min(lo, 0.0), calc.max(hi, 0.0)))
      let anchor = if scan.any-fill {
        "both"
      } else if lo >= 0 {
        "lo"
      } else if hi <= 0 {
        "hi"
      } else { none }
      if anchor != none { new-y.insert("anchor-zero", anchor) }
      trained.insert("y", new-y)
    }
  }

  // Each geom with a `spec.extents` hook widens the continuous position
  // domains to the outer edges of its marks. On an axis with user `limits`,
  // only the rows whose centre lies inside the limits reach the hook, and the
  // axis becomes the union of the limits and those extents, so every kept
  // mark is drawn whole. The limits are recorded as `oob-cutoff`, so the
  // out-of-bounds pass still cuts at them once the domain is wider. The hook
  // runs once per layer on values in the trained-domain space; discrete axes
  // ignore it, and a missing axis is seeded from the extents. A layer whose
  // stat publishes bins also reaches the outer bin edges on `x`, whatever
  // its geom, as ggplot2 trains `x` on the `xmin` and `xmax` of each bin.
  let cutoffs = (x: _limit-cutoff(trained, "x"), y: _limit-cutoff(trained, "y"))
  for layer in layers {
    let spec = GEOMS
      .at(layer.at("name", default: ""), default: (spec: (extents: none)))
      .spec
    let mapping = layer.at("mapping", default: none)
    let binned = stat-binned(layer.at("stat-source", default: "identity"))
    if mapping == none or (spec.extents == none and not binned) { continue }
    let centre = spec.at("centre", default: (x: "x", y: "y"))
    let bounds = ()
    for axis in ("x", "y") {
      let cutoff = cutoffs.at(axis)
      if cutoff == none { continue }
      let col = mapping-ref-col(mapping.at(centre.at(axis), default: none))
      if col == none { continue }
      bounds.push((col: col, cutoff: cutoff))
    }
    let data = layer.at("data", default: ())
    if bounds.len() > 0 {
      data = data.filter(row => bounds.all(b => _within-cutoff(
        row.at(b.col, default: none),
        b.cutoff,
      )))
    }
    let exts = ()
    if spec.extents != none {
      exts.push((spec.extents)(layer.at("params", default: (:)), mapping, data))
    }
    if binned {
      let x-col = mapping-ref-col(mapping.at("x", default: none))
      exts.push((x: bin-x-extents(data, x-col), y: none))
    }
    for ext in exts { trained = _extend-axes(trained, ext, cutoffs) }
  }

  if scan.ribbon-y-min != none {
    let lo-extra = scan.ribbon-y-min
    let hi-extra = scan.ribbon-y-max
    let (pin-lo, pin-hi) = if cutoffs.y == none { (none, none) } else {
      cutoffs.y
    }
    trained = _rewrite-continuous-domain(trained, "y", ((lo, hi)) => {
      let ascending = lo <= hi
      let (low-side, high-side) = if ascending { (lo, hi) } else { (hi, lo) }
      let (pin-low, pin-high) = if ascending {
        (pin-lo, pin-hi)
      } else {
        (pin-hi, pin-lo)
      }
      let new-low = if pin-low == none { calc.min(low-side, lo-extra) } else {
        low-side
      }
      let new-high = if pin-high == none {
        calc.max(high-side, hi-extra)
      } else {
        high-side
      }
      if ascending { (new-low, new-high) } else { (new-high, new-low) }
    })
  }

  // Discrete category axes get `geom-min-pad` so `apply-expand` keeps outer
  // bars inside the panel; the continuous case is col's extents hook.
  if scan.bar-half > 0 {
    let xt = trained.at("x", default: none)
    if xt != none and xt.type == "discrete" {
      let new-x = xt
      new-x.insert("geom-min-pad", scan.bar-half)
      trained.insert("x", new-x)
    }
  }

  // A `flush` stat tags both position axes so `apply-expand` drops their
  // automatic expansion.
  if scan.flush {
    for axis in ("x", "y") {
      let t = trained.at(axis, default: none)
      if t == none { continue }
      t.insert("flush", true)
      trained.insert(axis, t)
    }
  }

  trained
}
