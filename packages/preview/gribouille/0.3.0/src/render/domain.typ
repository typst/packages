// Domain scanning, coordinate-system application, and post-training domain
// fix-ups (bar-zero floor, bin/ribbon/ellipse padding, expansion, flip).

#import "../scale/train.typ": transform-fwd
#import "../scale/expansion.typ": DISCRETE-AUTO-DATA-PAD, normalise-expansion
#import "../utils/radial.typ": radial-axis-of
#import "../utils/types.typ": parse-number
#import "common.typ": _track-min-max

// Bounding box of every ellipse layer's data, accounting for rotation.
// Axis-aligned bbox of an ellipse with semi-axes (a, b) and major-axis
// rotation theta — using `max(|a|, |b|)` instead would inflate the box by
// an order of magnitude when units differ between axes (e.g., flipper-length
// in mm vs body-mass in g).
#let _scan-ellipse(layer, mapping, layer-data, acc) = {
  if mapping == none { return acc }
  let x0-col = mapping.at("x0", default: none)
  let y0-col = mapping.at("y0", default: none)
  if x0-col == none or y0-col == none { return acc }
  let a-col = mapping.at("a", default: none)
  let b-col = mapping.at("b", default: none)
  let angle-col = mapping.at("angle", default: none)
  let params = layer.at("params", default: (:))
  let a-fb = params.at("a", default: 1)
  let b-fb = params.at("b", default: 1)
  let angle-fb = params.at("angle", default: 0)
  let _read(row, col, fallback) = if col == none { fallback } else {
    let v = parse-number(row.at(col, default: none))
    if v == none { fallback } else { v }
  }
  for row in layer-data {
    let x0 = parse-number(row.at(x0-col, default: none))
    let y0 = parse-number(row.at(y0-col, default: none))
    if x0 == none or y0 == none { continue }
    let a = _read(row, a-col, a-fb)
    let b = _read(row, b-col, b-fb)
    let theta = _read(row, angle-col, angle-fb)
    let cos-t = calc.cos(theta)
    let sin-t = calc.sin(theta)
    let x-half = calc.sqrt(
      (a * cos-t) * (a * cos-t) + (b * sin-t) * (b * sin-t),
    )
    let y-half = calc.sqrt(
      (a * sin-t) * (a * sin-t) + (b * cos-t) * (b * cos-t),
    )
    let (xlo, xhi) = _track-min-max(acc.x-min, acc.x-max, x0 - x-half)
    acc.x-min = xlo
    acc.x-max = if acc.x-max == none { x0 + x-half } else {
      calc.max(acc.x-max, x0 + x-half)
    }
    let (ylo, yhi) = _track-min-max(acc.y-min, acc.y-max, y0 - y-half)
    acc.y-min = ylo
    acc.y-max = if acc.y-max == none { y0 + y-half } else {
      calc.max(acc.y-max, y0 + y-half)
    }
  }
  acc
}

// Project `geom-col` layer x values + bar-fraction into the panel-level
// `cols` accumulator.
#let _scan-col(layer, mapping, layer-data) = {
  let x-col = if mapping == none { none } else {
    mapping.at("x", default: none)
  }
  let xs = if x-col != none {
    layer-data
      .map(r => parse-number(r.at(x-col, default: none)))
      .filter(v => v != none)
  } else { () }
  (
    bar-frac: layer.at("params", default: (:)).at("width", default: 0.9),
    xs: xs,
  )
}

// Fold per-row width / ymin / ymax aggregates: the panel-level bin half-max
// (so outer bins stay inside the panel) and the ribbon y-range (so ymin/ymax
// extend the trained y domain).
#let _scan-rows(mapping, layer-data, acc) = {
  let ymin-col = if mapping == none { none } else {
    mapping.at("ymin", default: none)
  }
  let ymax-col = if mapping == none { none } else {
    mapping.at("ymax", default: none)
  }
  let scan-width = (
    layer-data.len() > 0
      and layer-data.first().at("width", default: none) != none
  )
  if not (scan-width or ymin-col != none or ymax-col != none) { return acc }
  for row in layer-data {
    if scan-width {
      let w = row.at("width", default: none)
      if w != none and (type(w) == int or type(w) == float) {
        acc.bin-half-max = calc.max(acc.bin-half-max, w / 2)
      }
    }
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

// Single-pass classifier feeding `_post-train`. Per layer it picks the
// minimal row scan needed (col layers project parsed x values; binned and
// ribbon layers fold per-row aggregates) so non-col, non-binned, non-ribbon
// layers skip the row loop entirely.
#let _post-train-scan(layers) = {
  let acc = (
    needs-y-zero: false,
    any-fill: false,
    cols: (),
    bin-half-max: 0.0,
    ribbon-y-min: none,
    ribbon-y-max: none,
    x-min: none,
    x-max: none,
    y-min: none,
    y-max: none,
  )
  for layer in layers {
    let geom = layer.at("geom", default: none)
    let mapping = layer.at("mapping", default: none)
    let layer-data = layer.at("data", default: ())

    if geom == "col" or geom == "area" { acc.needs-y-zero = true }
    if geom == "ellipse" {
      acc = _scan-ellipse(layer, mapping, layer-data, acc)
    }
    if geom == "col" {
      if layer.at("position", default: "identity") == "fill" {
        acc.any-fill = true
      }
      acc.cols.push(_scan-col(layer, mapping, layer-data))
    }
    acc = _scan-rows(mapping, layer-data, acc)
  }
  (
    needs-y-zero: acc.needs-y-zero,
    any-fill: acc.any-fill,
    cols: acc.cols,
    bin-half-max: acc.bin-half-max,
    ribbon-y-min: acc.ribbon-y-min,
    ribbon-y-max: acc.ribbon-y-max,
    ellipse-x-min: acc.x-min,
    ellipse-x-max: acc.x-max,
    ellipse-y-min: acc.y-min,
    ellipse-y-max: acc.y-max,
  )
}

// `geom-col` centres each bar on its category value and draws it from
// `centre ± min-gap * bar-frac / 2`. On a continuous category axis the
// trained domain is `(min, max)` of the raw values, so the outer bars hang
// off the panel by half a bar width. Mirror the geom's minimum-gap heuristic
// to compute the half-width in domain units and pad the trained domain on
// both sides. The renderer applies coord-flip after `_post-train`, so
// padding pre-flip x covers both orientations.
#let _col-half-width-x(cols) = {
  let max-half = 0.0
  for layer in cols {
    let sorted = layer.xs.dedup().sorted()
    if sorted.len() < 2 { continue }
    let gaps = range(sorted.len() - 1).map(i => (
      sorted.at(i + 1) - sorted.at(i)
    ))
    let min-gap = calc.min(..gaps)
    let half = min-gap * layer.bar-frac / 2
    if half > max-half { max-half = half }
  }
  max-half
}

// Inject labs `x`/`y`/... names into trained scale specs so axis and legend
// titles follow labs() overrides. `auto` (the labs default) keeps the
// scale-derived name; `none` sets `spec.blank` to suppress the title and
// collapse its reserved space; a string overrides the name.
#let _apply-labs(trained, labs) = {
  if labs == none { return trained }
  for (aes-name, label) in labs.axes.pairs() {
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

// coord-transform warps the view at mapping time. Skips axes whose scale
// already pre-transformed the data: pre- and post-stat warps don't compose.
#let _apply-coord-transform(trained, coord) = {
  if coord == none or coord.at("coord", default: none) != "transform" {
    return trained
  }
  for axis in ("x", "y") {
    let t = coord.at(axis, default: "identity")
    if t == "identity" { continue }
    let entry = trained.at(axis, default: none)
    if entry == none or entry.type != "continuous" { continue }
    if entry.at("pre-transformed", default: false) { continue }
    let new-entry = entry
    new-entry.insert("transform", t)
    trained.insert(axis, new-entry)
  }
  trained
}

// xlim/ylim arrive in data space; pre-transformed domains live in stat space.
#let _coord-limits-to-domain(entry, lim) = {
  if not entry.at("pre-transformed", default: false) { return lim }
  let t = entry.at("transform", default: "identity")
  let (lo, hi) = lim
  (transform-fwd(t, lo), transform-fwd(t, hi))
}

// coord-cartesian xlim/ylim overrides take precedence over scale training,
// so re-apply them after any per-panel retraining.
#let _apply-coord(trained, coord) = {
  if coord == none { return trained }
  if coord.coord != "cartesian" { return trained }
  let xlim = coord.at("xlim", default: none)
  if (
    xlim != none
      and trained.at("x", default: none) != none
      and trained.x.type == "continuous"
  ) {
    let new-x = trained.x
    new-x.insert("domain", _coord-limits-to-domain(trained.x, xlim))
    trained.insert("x", new-x)
  }
  let ylim = coord.at("ylim", default: none)
  if (
    ylim != none
      and trained.at("y", default: none) != none
      and trained.y.type == "continuous"
  ) {
    let new-y = trained.y
    new-y.insert("domain", _coord-limits-to-domain(trained.y, ylim))
    trained.insert("y", new-y)
  }
  trained
}

// Detect whether the spec asks for axis-flipping at render time.
#let _is-flipped(coord) = (
  coord != none and coord.at("coord", default: none) == "flip"
)

// Swap the trained x and y scales so the renderer's bottom axis shows the
// user's original y scale and the left axis shows the user's original x
// scale. Called after `_apply-coord` so any cartesian xlim/ylim overrides
// apply to the pre-flip axes as the user wrote them.
#let _apply-flip(trained, coord) = {
  if not _is-flipped(coord) { return trained }
  let x = trained.at("x", default: none)
  let y = trained.at("y", default: none)
  trained.insert("x", y)
  trained.insert("y", x)
  if x == none { return trained }

  let policy = coord.at("reverse", default: auto)
  let do-reverse = if policy == auto { x.type == "discrete" } else { policy }
  if not do-reverse { return trained }
  let new-y = x
  if x.type == "discrete" {
    new-y.insert("reverse", true)
  } else if x.type == "continuous" {
    new-y.insert("reverse", not new-y.at("reverse", default: false))
  }
  trained.insert("y", new-y)
  trained
}

// Swap a layer's mapping x and y so direction-agnostic geoms read the user's
// original y column where they expect x and vice versa. Direction-sensitive
// geoms (col, hline, vline, abline) read `ctx.flipped` instead and rotate
// their drawing without a mapping swap.
#let _flip-layer-mapping(layer) = {
  let mapping = layer.at("mapping", default: none)
  if mapping == none { return layer }
  let x = mapping.at("x", default: none)
  let y = mapping.at("y", default: none)
  let new-mapping = mapping
  new-mapping.insert("x", y)
  new-mapping.insert("y", x)
  let new = layer
  new.mapping = new-mapping
  new
}

// Shrink the inner panel along the longer axis so that one x data unit
// projects to `ratio` y data units. Returns the adjusted (width, height).
// Falls back to the input box if either trained scale is missing or has a
// zero-length domain.
#let _fixed-inner-size(coord, trained, box-w, box-h) = {
  if coord == none or coord.coord != "fixed" { return (box-w, box-h) }
  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)
  if x-trained == none or y-trained == none { return (box-w, box-h) }
  if x-trained.type != "continuous" or y-trained.type != "continuous" {
    return (box-w, box-h)
  }
  let (x-lo, x-hi) = x-trained.domain
  let (y-lo, y-hi) = y-trained.domain
  let dx = x-hi - x-lo
  let dy = y-hi - y-lo
  if dx <= 0 or dy <= 0 { return (box-w, box-h) }
  let ratio = coord.at("ratio", default: 1)
  // Pixels-per-x-unit must equal ratio * pixels-per-y-unit.
  let want = (dy * ratio) / dx
  let have = box-h / box-w
  if want >= have {
    (box-h / want, box-h)
  } else {
    (box-w, box-w * want)
  }
}

// Apply scale expansion on top of the already-padded domain produced by
// `_post-train`. Multiplicative breathing room (ratio) is folded into
// `view-transform` (continuous) / `view-index` (discrete); absolute additive
// padding (length) is recorded as `view-pad-cm` and applied later by
// `_draw-axis-and-layers` as a canvas-cm inset on the data area.
// `coord-cartesian(expand: false)` zeroes everything.
#let _apply-expand(trained, coord) = {
  let coord-no-expand = (
    coord != none
      and coord.at("coord", default: none) == "cartesian"
      and coord.at("expand", default: true) == false
  )
  // Under `coord-radial`, the radial axis maps view-min to canvas radius 0,
  // so any lo-side padding leaves a hole at the centre. Collapse the radial
  // lo-side to zero when `expand` is auto.
  let radial-axis = radial-axis-of(coord)
  for axis in ("x", "y") {
    let entry = trained.at(axis, default: none)
    if entry == none { continue }
    let spec = entry.at("spec", default: none)
    let raw = if spec == none { auto } else { spec.at("expand", default: auto) }
    let expand = if coord-no-expand { false } else { raw }
    let (mult-lo, add-cm-lo, mult-hi, add-cm-hi) = normalise-expansion(
      expand,
      entry.type,
    )
    // Bars / areas anchor at y=0: when the user did not pin `expand`
    // explicitly, drop the multiplicative expansion on the anchored side so
    // the baseline sits flush against the axis line. Length-add is always
    // honoured.
    let anchor = entry.at("anchor-zero", default: none)
    if anchor != none and raw == auto {
      if anchor == "lo" or anchor == "both" { mult-lo = 0 }
      if anchor == "hi" or anchor == "both" { mult-hi = 0 }
    }
    let radial-zero-lo = axis == radial-axis and raw == auto
    if radial-zero-lo {
      mult-lo = 0
      add-cm-lo = 0
    }
    let new-entry = entry
    if entry.type == "continuous" {
      let (lo, hi) = entry.domain
      let transform = entry.at("transform", default: "identity")
      let pre = entry.at("pre-transformed", default: false)
      // Pre-transformed domains already live in stat space; warping again
      // would double-apply.
      let t-lo = if pre { lo } else { transform-fwd(transform, lo) }
      let t-hi = if pre { hi } else { transform-fwd(transform, hi) }
      let span = t-hi - t-lo
      new-entry.insert(
        "view-transform",
        (t-lo - mult-lo * span, t-hi + mult-hi * span),
      )
    } else if entry.type == "discrete" {
      let n = entry.domain.len()
      let span = if n > 1 { n - 1 } else { 0 }
      // Discrete `auto` gets a default 0.6-slot data-unit pad on each side;
      // any explicit `expand:` value supersedes it. Radial axes skip
      // the lo-side data pad so the inner edge sits at radius 0.
      let auto-data-pad = if raw == auto { DISCRETE-AUTO-DATA-PAD } else { 0 }
      let geom-min = entry.at("geom-min-pad", default: 0)
      let lo-pad-base = if radial-zero-lo { 0 } else { auto-data-pad }
      let pad-lo = calc.max(mult-lo * span + lo-pad-base, geom-min)
      let pad-hi = calc.max(mult-hi * span + auto-data-pad, geom-min)
      new-entry.insert("view-index", (0 - pad-lo, (n - 1) + pad-hi))
    }
    new-entry.insert("view-pad-cm", (add-cm-lo, add-cm-hi))
    trained.insert(axis, new-entry)
  }
  trained
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

// Apply post-training domain fix-ups (bar-zero floor, bin width padding,
// ribbon ymin/ymax padding). Called once globally and once per panel under
// free scales so each panel's domain reflects its own subset.
#let _post-train(trained, layers) = {
  let scan = _post-train-scan(layers)

  // Bars and areas anchor against y=0. The touching side is tagged so
  // `_apply-expand` collapses its auto-expansion to zero, matching the
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

  if scan.bin-half-max > 0 {
    let pad = scan.bin-half-max
    trained = _rewrite-continuous-domain(trained, "x", ((lo, hi)) => (
      lo - pad,
      hi + pad,
    ))
  }

  // `geom-col` mirrors its own min-gap heuristic: pad the continuous category
  // axis by half a bar width so outer bars stay inside the panel. Coord-flip
  // is applied later, so padding pre-flip x covers both orientations.
  if scan.cols.len() > 0 {
    let max-half = _col-half-width-x(scan.cols)
    if max-half > 0 {
      trained = _rewrite-continuous-domain(trained, "x", ((lo, hi)) => (
        lo - max-half,
        hi + max-half,
      ))
    }
  }

  if scan.ribbon-y-min != none {
    let lo-extra = scan.ribbon-y-min
    let hi-extra = scan.ribbon-y-max
    trained = _rewrite-continuous-domain(trained, "y", ((lo, hi)) => (
      calc.min(lo, lo-extra),
      calc.max(hi, hi-extra),
    ))
  }

  let _seed-or-extend(t, axis, lo-extra, hi-extra) = {
    if t.at(axis, default: none) == none {
      t.insert(axis, (
        type: "continuous",
        domain: (lo-extra, hi-extra),
        spec: none,
        transform: "identity",
        typst-mark: false,
      ))
      t
    } else {
      _rewrite-continuous-domain(t, axis, ((lo, hi)) => (
        calc.min(lo, lo-extra),
        calc.max(hi, hi-extra),
      ))
    }
  }
  if scan.ellipse-x-min != none {
    trained = _seed-or-extend(
      trained,
      "x",
      scan.ellipse-x-min,
      scan.ellipse-x-max,
    )
  }
  if scan.ellipse-y-min != none {
    trained = _seed-or-extend(
      trained,
      "y",
      scan.ellipse-y-min,
      scan.ellipse-y-max,
    )
  }

  // Discrete category axes get `geom-min-pad` so `_apply-expand` keeps outer
  // bars inside the panel; the continuous case is already covered above.
  if scan.cols.len() > 0 {
    let bar-half = 0
    for layer in scan.cols {
      let half = layer.bar-frac / 2
      if half > bar-half { bar-half = half }
    }
    if bar-half > 0 {
      let xt = trained.at("x", default: none)
      if xt != none and xt.type == "discrete" {
        let new-x = xt
        new-x.insert("geom-min-pad", bar-half)
        trained.insert("x", new-x)
      }
    }
  }

  trained
}
