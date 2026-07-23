// Scale training and value-to-range mapping.
//
// Training walks every layer's data for the given aesthetic and computes
// the union domain. A continuous domain is (min, max); a discrete domain
// is the list of unique levels in order of first appearance.
//
// Mapping turns a trained domain plus a target range into a scalar position.

#import "../data.typ": _normalise-data, column
#import "../utils/types.typ": infer-column-type, parse-number
#import "../utils/typst-markup.typ": is-typst-markup
#import "../utils/errors.typ": check, fail
#import "../utils/late-binding.typ": (
  after-scale-source, is-late-binding, late-binding-name,
)

// Merge the layer and plot mappings WITHOUT stripping `mapping-ref`
// annotations: training reads them to force discrete/numeric typing.
// The render-side `_resolve-mapping` (`render/common.typ`) strips them.
// Not shared with `merge-mapping` (`utils/aes-resolve.typ`): importing it
// here would close the cycle train -> aes-resolve -> level-resolve -> train.
#let _merged-mapping(layer, plot-mapping) = {
  if layer.at("inherit-aes", default: true) and plot-mapping != none {
    let merged = plot-mapping
    if layer.mapping != none {
      for (k, v) in layer.mapping.pairs() {
        if v != none { merged.insert(k, v) }
      }
    }
    merged
  } else if layer.mapping != none {
    layer.mapping
  } else {
    plot-mapping
  }
}

// Training runs on prepared layers whose literal `data` is already in
// canonical row-store form, so unlike the render-side `_resolve-data`
// (`render/common.typ`) only a function value needs normalising.
#let _layer-data(layer, plot-data) = {
  if layer.data == none { return plot-data }
  if type(layer.data) == function {
    return _normalise-data((layer.data)(plot-data))
  }
  layer.data
}

// A mapping value is either a plain string (column name), a `mapping-ref`
// annotation produced by `as-factor("col")` / `as-numeric("col")`, or a
// `typst-markup` annotation produced by `typst("col")`. The two tag
// kinds compose. Return the column name either way.
#let mapping-ref-col(value) = {
  if type(value) != dictionary { return value }
  let kind = value.at("kind", default: none)
  if kind == "mapping-ref" {
    return mapping-ref-col(value.at("var", default: none))
  }
  if kind == "typst-markup" {
    return mapping-ref-col(value.at("source", default: none))
  }
  value
}

// Title/label-facing variant of `mapping-ref-col`: a late-binding marker
// (`after-stat`, `stage`, ...) carries no source column, so resolve it to a
// human label (or `none`) instead of leaking its dict repr into an axis or
// legend title.
#let mapping-display-name(value) = {
  if is-late-binding(value) { return late-binding-name(value) }
  mapping-ref-col(value)
}

// Return the forced type from a `mapping-ref` (`as-factor` /
// `as-numeric`), looking through `typst-markup` wrappers. Returns `none`
// when no `mapping-ref` is present.
#let mapping-ref-type(value) = {
  if type(value) != dictionary { return none }
  let kind = value.at("kind", default: none)
  if kind == "mapping-ref" { return value.type }
  if kind == "typst-markup" {
    return mapping-ref-type(value.at("source", default: none))
  }
  none
}

// Two-arg `as-factor(data, col)` stamps each row with `_gribouille-factors`
// listing every column it has stringified. Read the first row only because
// every row carries the same array.
#let _factor-sentinel-type(data, col-name) = {
  if type(data) != array or data.len() == 0 { return none }
  let first = data.at(0)
  if type(first) != dictionary { return none }
  let factors = first.at("_gribouille-factors", default: none)
  if type(factors) == array and factors.contains(col-name) {
    return "discrete"
  }
  none
}

// Centralise the "mapping-ref forced type, falling back to data sentinel"
// resolution used by both scale training and the discrete-axis rewrite step.
#let _resolve-forced-type(raw, data, col-name) = {
  let forced = mapping-ref-type(raw)
  if forced != none { return forced }
  _factor-sentinel-type(data, col-name)
}

#let _column-for-aesthetic(layer, aesthetic, plot-mapping, plot-data) = {
  let mapping = _merged-mapping(layer, plot-mapping)
  let data = _layer-data(layer, plot-data)
  if mapping == none { return none }
  let raw = mapping.at(aesthetic, default: none)
  if raw == none { return none }
  let col-name = mapping-ref-col(raw)
  (
    name: col-name,
    values: column(data, col-name),
    forced-type: _resolve-forced-type(raw, data, col-name),
  )
}

// Positional aesthetics drive panel layout and are retrained per panel under
// `facet-wrap` free scales. The order here matters: `train()` folds the
// synthetic feeders (xmin/xmax/ymin/ymax/xend/yend, xintercept/yintercept)
// into x and y after the per-aesthetic loop, so x/y appear first. The
// intercept feeders let a mapped `geom-vline`/`geom-hline` extend the panel to
// keep its data-driven reference lines in view.
#let positional-aesthetics = (
  "x",
  "y",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "xend",
  "yend",
  "xintercept",
  "yintercept",
)

// Synthetic feeder axes feed their min/max into the main x or y axis; they
// must not get singleton-domain expansion (which would turn `ymin: 0` on
// every bar into `(-0.5, 0.5)` and bleed below the y=0 baseline).
#let _SYNTHETIC-FEEDERS = positional-aesthetics.filter(a => (
  a != "x" and a != "y"
))

#let all-aesthetics = (
  "x",
  "y",
  "colour",
  "fill",
  "size",
  "alpha",
  "linewidth",
  "stroke",
  "shape",
  "linetype",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "xend",
  "yend",
  "xintercept",
  "yintercept",
)

#let _continuous-domain-from-cache(cols, aesthetic) = {
  // Single-pass min/max: avoid building an intermediate array per column,
  // which matters for plots with thousands of rows across multiple layers.
  let lo = none
  let hi = none
  for col in cols {
    for raw in col.values {
      let v = parse-number(raw)
      if v == none { continue }
      if lo == none {
        lo = v
        hi = v
      } else {
        if v < lo { lo = v }
        if v > hi { hi = v }
      }
    }
  }
  if lo == none { return (0.0, 1.0) }
  if lo == hi and not _SYNTHETIC-FEEDERS.contains(aesthetic) {
    return (lo - 0.5, hi + 0.5)
  }
  (lo, hi)
}

#let _discrete-domain-from-cache(cols) = {
  let seen = ()
  let seen-set = (:)
  for col in cols {
    // `_prepare-layer` records the original level set on the layer when it
    // rewrites a discrete-marked column to numeric indices for `position-jitter`
    // and friends. Use the recorded levels here so the trained domain doesn't
    // collapse onto the rewritten (and possibly fractional) values.
    let recorded = col.at("levels", default: none)
    let source = if recorded != none { recorded } else { col.values }
    for v in source {
      if v == none or v == "" { continue }
      let s = str(v)
      if seen-set.at(s, default: false) { continue }
      seen-set.insert(s, true)
      seen.push(s)
    }
  }
  // Alphabetic so palette index, geom draw order, and legend agree.
  // User `limits` override in `_train-entry`.
  seen.sorted()
}

// Build a `(level: index)` dict from a discrete domain. O(1) level lookup
// for downstream resolvers (palette index, colour mapping, position).
#let _level-index(domain) = {
  let idx = (:)
  for (i, v) in domain.enumerate() { idx.insert(v, i) }
  idx
}

#let _scale-type-from-cache(cols) = {
  for col in cols {
    if col.forced-type != none { return col.forced-type }
    let t = infer-column-type(col.values)
    if t == "numeric" { return "continuous" }
    if t == "colour" or t == "length" { return "identity" }
    return "discrete"
  }
  "continuous"
}

// Look up the user scale for `aesthetic` in the aesthetic-keyed dict built by
// `scales()`.
#let _find-user-scale(scales, aesthetic) = scales.at(aesthetic, default: none)

#let _scale-param(target, spec, key, fallback) = {
  if target != none { return target.at(key, default: fallback) }
  if spec != none { return spec.at(key, default: fallback) }
  fallback
}

// Forward axis transformation for `log10` and `sqrt`: warps coordinates so
// equal visual distances correspond to equal multiplicative or square-root
// steps. `reverse` is handled separately by swapping the range endpoints.
#let transform-fwd(name, x) = {
  if name == none or name == "identity" or name == "reverse" { return x }
  // Runs once per row on transformed scales; build the failure message only
  // on the error path rather than eagerly via `check`.
  if name == "log10" {
    if x <= 0 {
      fail("scale", "log10 transform requires positive values; got " + repr(x))
    }
    return calc.log(x, base: 10)
  }
  if name == "sqrt" {
    if x < 0 {
      fail(
        "scale",
        "sqrt transform requires non-negative values; got " + repr(x),
      )
    }
    return calc.sqrt(x)
  }
  x
}

// Inverse of `transform-fwd`: convert a transformed-space coordinate back to
// data space. Used to back-translate a padded view range so axis breaks
// can be picked in data units.
#let transform-inv(name, x) = {
  if name == none or name == "identity" or name == "reverse" { return x }
  if name == "log10" { return calc.pow(10, x) }
  if name == "sqrt" {
    // View padding can push a sqrt-space bound below zero; data space floors
    // at 0, and clamping keeps the inverse monotone instead of reflecting
    // negatives back to positive values.
    let clamped = calc.max(x, 0.0)
    return clamped * clamped
  }
  x
}

// Build the per-aesthetic cache that downstream stages consult.
// Each cache entry holds `(cols, typst-mark)` where `cols` is the array of
// column descriptors collected across every layer that maps the aesthetic.
#let _train-cache(layers, mapping, data, aes-list) = {
  let cache = (:)
  for a in aes-list { cache.insert(a, (cols: (), typst-mark: false)) }
  for layer in layers {
    let layer-mapping = _merged-mapping(layer, mapping)
    if layer-mapping == none { continue }
    let layer-data = _layer-data(layer, data)
    let layer-factor-levels = layer.at("_factor-levels", default: (:))
    for a in aes-list {
      let raw = layer-mapping.at(a, default: none)
      if raw == none { continue }
      // Late-binding markers that carry a `source` column (an `after-scale`
      // derived from `stage(start: ...)`) train on that column so the per-row
      // resolver hands the closure the channel's scale-resolved value, as
      // documented on `@after-scale`. Source-less markers (`after-stat`,
      // `from-theme`, and a pure `after-scale` closure) are evaluated
      // elsewhere; skip them.
      let train-ref = if is-late-binding(raw) { after-scale-source(raw) } else {
        raw
      }
      if train-ref == none or is-late-binding(train-ref) { continue }
      let col-name = mapping-ref-col(train-ref)
      let entry = cache.at(a)
      entry.cols.push((
        name: col-name,
        values: column(layer-data, col-name),
        forced-type: _resolve-forced-type(train-ref, layer-data, col-name),
        levels: layer-factor-levels.at(col-name, default: none),
      ))
      if is-typst-markup(train-ref) { entry.typst-mark = true }
      cache.insert(a, entry)
    }
  }
  cache
}

// Compute the scale type, raw domain, and any user-limit / extend overrides
// for a single aesthetic. Returns `none` when there is nothing to train.
#let _train-entry(aes, cached, user-scale) = {
  let cols = cached.cols
  let mapped = cols.len() > 0
  if not mapped and user-scale == none { return none }
  let scale-type = if user-scale != none {
    user-scale.type
  } else {
    _scale-type-from-cache(cols)
  }
  let domain = if scale-type == "identity" {
    ()
  } else if scale-type == "continuous" {
    _continuous-domain-from-cache(cols, aes)
  } else {
    _discrete-domain-from-cache(cols)
  }
  // Track which sides the user pinned with an explicit (non-`auto`) limit.
  // Feature 5 (break-driven expansion) only widens sides left unpinned, and
  // the transform lift below only transforms the pinned sides.
  let explicit-lo = false
  let explicit-hi = false
  if (
    scale-type != "identity"
      and user-scale != none
      and user-scale.at("limits", default: none) != none
  ) {
    if scale-type == "continuous" {
      let (ulo, uhi) = user-scale.limits
      let (dlo, dhi) = domain
      explicit-lo = ulo != auto
      explicit-hi = uhi != auto
      // ISO date/datetime/time string limits resolve to the same numeric epoch
      // the column data trains against; numeric limits pass through unchanged.
      if explicit-lo {
        let n = parse-number(ulo)
        check(n != none, "scale", "could not parse lower limit: " + repr(ulo))
        ulo = n
      }
      if explicit-hi {
        let n = parse-number(uhi)
        check(n != none, "scale", "could not parse upper limit: " + repr(uhi))
        uhi = n
      }
      domain = (
        if explicit-lo { ulo } else { dlo },
        if explicit-hi { uhi } else { dhi },
      )
    } else {
      // Discrete limits are a level array, not a `(lo, hi)` pair, so there is
      // no per-side `auto`; the continuous-only lift/fold below never reads the
      // `explicit-*` flags for this branch.
      domain = user-scale.limits
    }
  }
  if (
    scale-type == "continuous"
      and user-scale != none
      and user-scale.at("extend", default: none) != none
      and (user-scale.at("limits", default: none) == none)
  ) {
    let (lo, hi) = domain
    for v in user-scale.extend {
      let n = parse-number(v)
      if n == none { continue }
      lo = calc.min(lo, n)
      hi = calc.max(hi, n)
    }
    if lo == hi {
      lo -= 0.5
      hi += 0.5
    }
    domain = (lo, hi)
  }
  let transform = if user-scale != none {
    user-scale.at("transform", default: "identity")
  } else { "identity" }
  // Domain values cached above are already in stat space when the renderer's
  // preprocess pass has run for this transform.
  let pre-transformed = (
    scale-type == "continuous" and (transform == "log10" or transform == "sqrt")
  )
  // A value lies in the active transform's domain when it is positive (log10),
  // non-negative (sqrt), or unconstrained (any other transform).
  let in-transform-domain = v => {
    if transform == "log10" { v > 0 } else if transform == "sqrt" {
      v >= 0
    } else {
      true
    }
  }
  if (
    pre-transformed
      and user-scale != none
      and user-scale.at("limits", default: none) != none
  ) {
    // User-supplied limits come in data space; lift the pinned side(s) to stat
    // space. An `auto` side keeps the trained bound, which is already in stat
    // space, so it must not be transformed again.
    let lift = v => {
      if transform == "log10" {
        check(v > 0, "scale", "log10 limits must be positive; got " + repr(v))
      } else if transform == "sqrt" {
        check(
          v >= 0,
          "scale",
          "sqrt limits must be non-negative; got " + repr(v),
        )
      }
      transform-fwd(transform, v)
    }
    let (lo, hi) = domain
    if explicit-lo { lo = lift(lo) }
    if explicit-hi { hi = lift(hi) }
    domain = (lo, hi)
  }
  // Feature 5: explicit `breaks` widen the trained domain so requested ticks
  // are visible, except on a side pinned by an explicit limit. Breaks are in
  // data units; lift them into stat space for pre-transformed scales (dropping
  // values outside the transform's domain) so the comparison stays in the
  // domain's native unit.
  if scale-type == "continuous" and user-scale != none {
    let user-breaks = user-scale.at("breaks", default: auto)
    if type(user-breaks) == array and user-breaks.len() > 0 {
      // ISO date/datetime/time string breaks resolve to the same numeric epoch
      // the column data trains against; numeric breaks pass through unchanged.
      let numeric-breaks = user-breaks.map(parse-number).filter(b => b != none)
      user-scale = (..user-scale, breaks: numeric-breaks)
      let folded = if pre-transformed {
        numeric-breaks
          .filter(in-transform-domain)
          .map(b => transform-fwd(transform, b))
      } else { numeric-breaks }
      if folded.len() > 0 {
        let (lo, hi) = domain
        if not explicit-lo { lo = calc.min(lo, ..folded) }
        if not explicit-hi { hi = calc.max(hi, ..folded) }
        domain = (lo, hi)
      }
    }
  }
  let level-index = if scale-type == "discrete" {
    _level-index(domain)
  } else { none }
  // Canonical trained-scale shape (GLOSSARY.md "trained"). Later pipeline
  // stages extend it in place:
  //   - `temporal` / `date-format` just below, on date/datetime/time scales;
  //   - `reverse` in `_apply-flip` (render/domain.typ), discrete-axis flip;
  //   - `view-transform` (continuous) / `view-index` (discrete) and
  //     `view-pad-cm` in `_apply-expand` (render/domain.typ), the expanded
  //     view window that axis breaks and panel mapping read.
  // Read `spec` keys through `spec-attr` (utils/palette.typ), not by direct
  // `.spec.at(...)` pokes.
  let entry = (
    type: scale-type,
    domain: domain,
    level-index: level-index,
    spec: user-scale,
    transform: transform,
    pre-transformed: pre-transformed,
    typst-mark: cached.typst-mark,
  )
  if user-scale != none and user-scale.at("temporal", default: none) != none {
    entry.insert("temporal", user-scale.temporal)
    entry.insert("date-format", user-scale.at("date-format", default: ""))
  }
  entry
}

// Fold the directional aesthetics (xmin/xmax/xend, ymin/ymax/yend) into the
// x and y axes so positional geoms (segment, rect, ribbon, ...) extend the
// trained domain. Without this, `geom-segment(x: 0, xend: 4, ...)` would
// clip the panel at x = 0.
#let _fold-positional(trained, cache) = {
  for axis in ("x", "y") {
    let sources = _SYNTHETIC-FEEDERS.filter(s => s.starts-with(axis))
    let target = trained.at(axis, default: none)
    if target != none and target.type != "continuous" { continue }
    // Discard the (0, 1) fallback from `_continuous-domain-from-cache` when
    // the axis itself has no aesthetic mapping; otherwise that fallback would
    // contaminate a domain defined entirely by the feeders (e.g.,
    // `geom-rect()` with only xmin/xmax mapped).
    let target-mapped = cache.at(axis).cols.len() > 0
    let lo = if target != none and target-mapped {
      target.domain.at(0)
    } else { none }
    let hi = if target != none and target-mapped {
      target.domain.at(1)
    } else { none }
    for s in sources {
      let t = trained.at(s, default: none)
      if t == none or t.type != "continuous" { continue }
      let (slo, shi) = t.domain
      lo = if lo == none { slo } else { calc.min(lo, slo) }
      hi = if hi == none { shi } else { calc.max(hi, shi) }
    }
    if lo == none or hi == none { continue }
    if lo == hi {
      lo -= 0.5
      hi += 0.5
    }
    let spec = if target != none { target.spec } else { none }
    if spec != none and spec.at("limits", default: none) != none { continue }
    let entry = (
      type: "continuous",
      domain: (lo, hi),
      spec: spec,
      transform: _scale-param(target, spec, "transform", "identity"),
      pre-transformed: _scale-param(target, none, "pre-transformed", false),
      typst-mark: _scale-param(target, none, "typst-mark", false),
    )
    let temporal = _scale-param(target, spec, "temporal", none)
    if temporal != none {
      entry.insert("temporal", temporal)
      entry.insert(
        "date-format",
        _scale-param(target, spec, "date-format", ""),
      )
    }
    trained.insert(axis, entry)
  }
  trained
}

#let train(
  scales: (:),
  layers: (),
  mapping: none,
  data: none,
  aesthetics: none,
) = {
  let aes-list = if aesthetics == none { all-aesthetics } else { aesthetics }
  let cache = _train-cache(layers, mapping, data, aes-list)
  let trained = (:)
  for a in aes-list {
    let entry = _train-entry(a, cache.at(a), _find-user-scale(scales, a))
    if entry == none { continue }
    trained.insert(a, entry)
  }
  _fold-positional(trained, cache)
}

#let map-continuous(value, domain, range) = {
  let (d-lo, d-hi) = domain
  let (r-lo, r-hi) = range
  if d-hi == d-lo { return (r-lo + r-hi) / 2 }
  let t = (value - d-lo) / (d-hi - d-lo)
  r-lo + t * (r-hi - r-lo)
}

// `view-index` overrides the default midpoint placement: levels sit at
// integer positions `0..n-1` and map linearly through the supplied viewport.
// Used by positional discrete scales after expansion is applied. The default
// viewport `(-0.5, n - 0.5)` reproduces the midpoint-of-equal-slots layout
// used by non-positional discrete scales (colour, fill, shape, ...).
#let map-discrete(
  value,
  domain,
  range,
  view-index: none,
  level-index: none,
  reverse: false,
) = {
  let n = domain.len()
  if n == 0 { return none }
  let s = str(value)
  let lookup = if level-index == none { _level-index(domain) } else {
    level-index
  }
  let idx = lookup.at(s, default: none)
  if idx == none and (type(value) == int or type(value) == float) {
    // Numeric values that miss a string match are treated as 1-indexed
    // fractional level positions. `_prepare-layer` rewrites discrete-marked
    // positional columns to integer indices before `position-jitter` runs;
    // jitter writes back fractional floats that land here.
    idx = value - 1
  }
  if idx == none { return none }
  let (r-lo, r-hi) = if reverse {
    (range.last(), range.first())
  } else { range }
  let (v-lo, v-hi) = if view-index == none {
    (-0.5, n - 0.5)
  } else { view-index }
  if v-hi == v-lo { return (r-lo + r-hi) / 2 }
  r-lo + (idx - v-lo) * (r-hi - r-lo) / (v-hi - v-lo)
}

// Panel-units span between adjacent levels for a discrete trained scale,
// honouring `view-index` expansion. Returns `0` for an empty domain.
#let discrete-slot-width(trained, range) = {
  let (lo, hi) = range
  let view = trained.at("view-index", default: none)
  if view != none {
    let (v-lo, v-hi) = view
    if v-hi == v-lo { return hi - lo }
    return (hi - lo) / (v-hi - v-lo)
  }
  let n = trained.domain.len()
  if n == 0 { return 0 }
  (hi - lo) / n
}

// Forward-warp `value` to stat space unless the scale is already
// `pre-transformed` (in which case row values, the trained domain, and
// `view-transform` already live there).
#let _to-stat(trained, value) = {
  if trained.at("pre-transformed", default: false) { return value }
  transform-fwd(trained.at("transform", default: "identity"), value)
}

// Expanded scale bounds in stat space: the `view-transform` set by
// `_apply-expand` when present, else the raw domain warped through `_to-stat`.
// Shared by coordinate mapping and the out-of-range pre-pass so both honour the
// same expanded view.
#let view-bounds-stat(trained) = {
  let view-transform = trained.at("view-transform", default: none)
  if view-transform != none { return view-transform }
  let (d-lo, d-hi) = trained.domain
  (_to-stat(trained, d-lo), _to-stat(trained, d-hi))
}

#let _map-transform(trained, value, range) = {
  let transform = trained.at("transform", default: "identity")
  let (t-lo, t-hi) = view-bounds-stat(trained)
  let (r-lo, r-hi) = range
  // `reverse` rides alongside the numeric transform rather than replacing it,
  // so a log10/sqrt axis can also be reversed (e.g. under coord-flip).
  let reverse = transform == "reverse" or trained.at("reverse", default: false)
  let target = if reverse {
    (r-hi, r-lo)
  } else { (r-lo, r-hi) }
  map-continuous(_to-stat(trained, value), (t-lo, t-hi), target)
}

#let map-position(trained, value, range) = {
  if trained.type == "continuous" {
    let v = parse-number(value)
    if v == none { return none }
    _map-transform(trained, v, range)
  } else {
    map-discrete(
      value,
      trained.domain,
      range,
      view-index: trained.at("view-index", default: none),
      level-index: trained.at("level-index", default: none),
      reverse: trained.at("reverse", default: false),
    )
  }
}

// Numeric fast path: `value` is already in stat space (geom row values).
#let map-axis(trained, value, range) = {
  if trained.type != "continuous" { return none }
  _map-transform(trained, value, range)
}

// `value` is in original data space (axis ticks, secondary-axis ticks,
// vline/hline/abline reference geoms, cartesian x-limits/y-limits).
#let map-axis-data(trained, value, range) = {
  if trained.type != "continuous" { return none }
  let pre = trained.at("pre-transformed", default: false)
  let v = if pre {
    transform-fwd(trained.at("transform", default: "identity"), value)
  } else { value }
  _map-transform(trained, v, range)
}
