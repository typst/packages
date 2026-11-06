// CeTZ rendering glue.
// Draws a single cartesian panel with axes and layer marks.

#import "deps.typ": cetz
#import "scale/train.typ": (
  _SYNTHETIC-FEEDERS, _find-user-scale, _resolve-forced-type, all-aesthetics,
  map-axis, map-axis-data, map-continuous, map-position, mapping-display-name,
  mapping-ref-col, positional-aesthetics, train, transform-fwd, transform-inv,
)
#import "scale/expansion.typ": DISCRETE-AUTO-DATA-PAD, normalise-expansion
#import "scale/oob.typ": filter-oob
#import "stat/apply.typ": apply-stat, setup-stat, stat-default-params
#import "stat/info.typ": stat-info
#import "position/apply.typ": apply-position, position-name-of
#import "theme/current.typ": _theme-state
#import "theme/defaults.typ": merge-theme, resolve-colour
#import "theme/theme.typ": (
  _line-stroke, _rect-outset-cm, _rect-style, _scalar-cascade, _text-style,
)
#import "utils/pretty.typ": pretty, pretty-log10, pretty-sqrt
#import "utils/types.typ": parse-number
#import "utils/format.typ": format-break
#import "utils/palette.typ": default-discrete, palette-at, spec-palette
#import "utils/colour.typ": resolve-continuous-colour
#import "utils/group.typ": group-aesthetics, group-cols, partition-by-group
#import "utils/typst-markup.typ": is-typst-markup, resolve-prose
#import "utils/aes-resolve.typ": merge-mapping, resolve-label
#import "utils/late-binding.typ": (
  apply-stages, eval-after-stat, is-late-binding, late-binding-kind,
  resolve-from-theme, stash-stages,
)
#import "utils/radial.typ": (
  group-theta-breaks, polar-canvas, radial-arc, radial-axis-of, radial-ctx,
)
#import "utils/margin.typ": (
  length-to-cm, opposite-side, perpendicular-sides, resolve-margin-side-cm,
  resolve-margin-side-rel-cm,
)
#import "utils/label-draw.typ" as label-draw
#import "utils/measure.typ": measure-labels-cm, measure-text-cm
#import "utils/typst-markup.typ": eval-as-markup
#import "data.typ": _normalise-data, group-by
#import "geom/point.typ" as point-geom
#import "geom/line.typ" as line-geom
#import "geom/path.typ" as path-geom
#import "geom/step.typ" as step-geom
#import "geom/area.typ" as area-geom
#import "geom/rect.typ" as rect-geom
#import "geom/tile.typ" as tile-geom
#import "geom/segment.typ" as segment-geom
#import "geom/curve.typ" as curve-geom
#import "geom/spoke.typ" as spoke-geom
#import "geom/polygon.typ" as polygon-geom
#import "geom/ellipse.typ" as ellipse-geom
#import "geom/mark.typ" as mark-geom
#import "geom/col.typ" as col-geom
#import "geom/ribbon.typ" as ribbon-geom
#import "geom/smooth.typ" as smooth-geom
#import "geom/hline.typ" as hline-geom
#import "geom/vline.typ" as vline-geom
#import "geom/abline.typ" as abline-geom
#import "geom/text.typ" as text-geom
#import "geom/typst.typ" as typst-geom
#import "geom/label.typ" as label-geom
#import "geom/boxplot.typ" as boxplot-geom
#import "geom/errorbar.typ" as errorbar-geom
#import "geom/errorbarh.typ" as errorbarh-geom
#import "geom/linerange.typ" as linerange-geom
#import "geom/crossbar.typ" as crossbar-geom
#import "geom/pointrange.typ" as pointrange-geom
#import "geom/blank.typ" as blank-geom
#import "geom/rug.typ" as rug-geom
#import "geom/function.typ" as function-geom
#import "geom/dotplot.typ" as dotplot-geom
#import "geom/hex.typ" as hex-geom

// Single source of truth for layer dispatch in `_draw-axis-and-layers`.
// Each entry maps a layer's `geom` string to its `draw(layer, ctx)` function.
// Adding a new geom only requires importing it above and adding an entry here.
#let _geom-draw = (
  point: point-geom.draw,
  line: line-geom.draw,
  path: path-geom.draw,
  step: step-geom.draw,
  area: area-geom.draw,
  rect: rect-geom.draw,
  tile: tile-geom.draw,
  segment: segment-geom.draw,
  curve: curve-geom.draw,
  spoke: spoke-geom.draw,
  polygon: polygon-geom.draw,
  ellipse: ellipse-geom.draw,
  mark: mark-geom.draw,
  col: col-geom.draw,
  ribbon: ribbon-geom.draw,
  smooth: smooth-geom.draw,
  hline: hline-geom.draw,
  vline: vline-geom.draw,
  abline: abline-geom.draw,
  text: text-geom.draw,
  typst: typst-geom.draw,
  label: label-geom.draw,
  boxplot: boxplot-geom.draw,
  errorbar: errorbar-geom.draw,
  errorbarh: errorbarh-geom.draw,
  linerange: linerange-geom.draw,
  crossbar: crossbar-geom.draw,
  pointrange: pointrange-geom.draw,
  blank: blank-geom.draw,
  rug: rug-geom.draw,
  function: function-geom.draw,
  dotplot: dotplot-geom.draw,
  hex: hex-geom.draw,
)

// Layers whose `geom` is missing from this set panic under `coord-radial`
// rather than silently falling back to cartesian rendering. Every registered
// geom is currently radial-aware; the check below guards against typos and
// future geoms that intentionally opt out. Stored as a dict-set so per-layer
// membership tests are O(1) instead of an array scan.
#let _RADIAL-AWARE = {
  let s = (:)
  for k in _geom-draw.keys() { s.insert(k, true) }
  s
}

#import "legend.typ" as legend-mod
#import "facet/labellers.typ" as labellers
#import "scale/secondary.typ" as secondary-mod

// Flatten a merged aesthetic mapping so geoms receive plain column-name
// strings. Both `mapping-ref` annotations (`as-factor`/`as-numeric`) and
// `typst-markup` annotations (`typst()`) are collapsed; the typst intent
// is captured separately by `_typst-marks-of` so display surfaces can
// honour it. Late-binding markers (`from-theme`, `after-stat`, ...)
// pass through unchanged because `mapping-ref-col` is a no-op on them.
#let _strip-mapping-refs(mapping) = {
  if mapping == none { return none }
  // Fast path: nothing carries a `mapping-ref` annotation.
  let any-ref = false
  for (_, v) in mapping.pairs() {
    if v == none { continue }
    if mapping-ref-col(v) != v {
      any-ref = true
      break
    }
  }
  if not any-ref { return mapping }
  let out = mapping
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    let col = mapping-ref-col(v)
    if col != v { out.insert(k, col) }
  }
  out
}

// Build a dictionary of `(aes-name: true)` entries for every aesthetic
// whose mapping value carries a `typst-markup` tag (at any nesting depth
// inside `mapping-ref` wrappers). Returns an empty dict when nothing is
// typst-tagged.
#let _typst-marks-of(mapping) = {
  if mapping == none { return (:) }
  // Fast path: if no value is typst-tagged we don't allocate at all.
  let any = false
  for (_, v) in mapping.pairs() {
    if v != none and is-typst-markup(v) {
      any = true
      break
    }
  }
  if not any { return (:) }
  let marks = (:)
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    if is-typst-markup(v) { marks.insert(k, true) }
  }
  marks
}

#let _resolve-mapping(layer, plot-mapping) = {
  _strip-mapping-refs(merge-mapping(layer, plot-mapping))
}

// Axis title fallback: trained scale's `spec.name` wins; otherwise the bare
// mapping column name (which may be `none` when neither is set). Used by
// the cartesian title path and the faceted (wrap/grid) finishers.
#let _axis-title(trained, mapping-name) = {
  let from-scale = if trained != none and trained.spec != none {
    trained.spec.name
  } else { none }
  if from-scale != none { from-scale } else { mapping-name }
}

// `data-trusted: true` on the layer signals that `layer.data` is already in
// canonical row-store form; the faceted path sets it on per-panel buckets it
// has just produced from a normalised source, avoiding a second validation
// pass over the same rows.
#let _resolve-data(layer, plot-data) = {
  if layer.data == none { return plot-data }
  if layer.at("data-trusted", default: false) { return layer.data }
  _normalise-data(layer.data)
}

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

// `from-theme` resolves to a literal scalar that we write into
// `layer.params.<channel>` so per-row resolvers honour it through their
// existing pinned-param paths. Positional aesthetics (x/y and synthetic
// feeders) have no fixed-value param to write to, hence the exclusion.
#let _FROM-THEME-PARAM-CHANNELS = all-aesthetics.filter(a => (
  not positional-aesthetics.contains(a)
))

// Resolve `from-theme(...)` markers in `mapping`. The resolved scalar is
// pushed into `layer.params.<channel>` and the mapping entry is cleared so
// scale training and per-row mapping reads see no ghost binding.
#let _apply-from-theme(layer, mapping, theme) = {
  if mapping == none { return (layer: layer, mapping: mapping) }
  if not mapping.values().any(v => late-binding-kind(v) == "from-theme") {
    return (layer: layer, mapping: mapping)
  }
  let new-mapping = mapping
  let params = layer.at("params", default: (:))
  for (channel, value) in mapping.pairs() {
    if late-binding-kind(value) != "from-theme" { continue }
    if not _FROM-THEME-PARAM-CHANNELS.contains(channel) {
      panic(
        "from-theme: unsupported on '"
          + channel
          + "'; use one of: "
          + _FROM-THEME-PARAM-CHANNELS.join(", "),
      )
    }
    params.insert(channel, resolve-from-theme(theme, value.path))
    new-mapping.insert(channel, none)
  }
  let new-layer = layer
  new-layer.insert("params", params)
  (layer: new-layer, mapping: new-mapping)
}

#let _prepare-layer(
  layer,
  plot-mapping,
  plot-data,
  theme: none,
  coord: none,
) = {
  // Keep mapping-ref annotations intact on the layer so scale training can
  // read forced types; only strip them when the renderer hands a mapping to
  // a geom's draw function.
  let mapping = merge-mapping(layer, plot-mapping)
  if theme != none {
    let resolved = _apply-from-theme(layer, mapping, theme)
    layer = resolved.layer
    mapping = resolved.mapping
  }
  // Stash any `stage(...)` markers and replace each with its `start`
  // column ref so stat application and downstream column reads see a
  // plain string. The post-stat lanes are reapplied after `eval-after-stat`.
  let stage-stash = stash-stages(mapping)
  mapping = stage-stash.mapping
  let stages = stage-stash.stages
  let data = _resolve-data(layer, plot-data)
  // `stat:` accepts either a string name (with default params from the geom's
  // own params dict) or a dict returned by a `stat-*()` constructor carrying
  // its own name and params. Match the same pattern used for `position:` below.
  let stat-spec = layer.at("stat", default: "identity")
  let params = layer.at("params", default: (:))
  let stat-name = if type(stat-spec) == str {
    stat-spec
  } else { stat-spec.at("name", default: "identity") }
  let stat-params = if type(stat-spec) == str {
    stat-default-params(stat-name)
  } else {
    stat-spec.at("params", default: (:))
  }
  let stripped = _strip-mapping-refs(mapping)

  let stat-identity = stat-name == none or stat-name == "identity"
  let stat-data = data
  let stat-mapping = if stat-identity { mapping } else { stripped }
  if not stat-identity {
    // compute-group pattern: split by discrete-aesthetic groups,
    // apply the stat to each group independently, then recombine.
    // A panel-level setup pass first lets binning stats compute a shared
    // partition over the full data so groups end up on the same bin grid.
    let resolved-params = setup-stat(
      stat-name,
      data,
      stripped,
      stat-params,
    )
    let gcols = group-cols(mapping)
    let group-list = partition-by-group(data, mapping)
    let combined = ()
    let last-mapping = stripped
    for g in group-list {
      let r = apply-stat(stat-name, g.data, stripped, resolved-params)
      last-mapping = r.mapping
      // Re-inject group column values from the first row of this group so
      // scale training and position adjustments can still see them.
      let proto = g.data.at(0, default: (:))
      let enriched = r.data.map(row => {
        let new-row = row
        for gc in gcols {
          if new-row.at(gc, default: none) == none {
            new-row.insert(gc, proto.at(gc, default: none))
          }
        }
        new-row
      })
      combined += enriched
    }
    // stat-output-mapping preserves whatever keys we passed in, but we
    // passed `stripped` so any `as-factor`/`as-numeric`/`typst` wrappers
    // were dropped. Restore them on aesthetics the stat passed through
    // unchanged so scale training can read the forced type.
    for (k, v) in mapping.pairs() {
      if v == none { continue }
      let plain = stripped.at(k, default: none)
      if plain == none or v == plain { continue }
      if last-mapping.at(k, default: none) == plain {
        last-mapping.insert(k, v)
      }
    }
    // Re-attach grouping aesthetics the stat dropped from its base mapping;
    // the columns were re-injected above so downstream can still resolve them.
    for gc-key in group-aesthetics {
      let v = mapping.at(gc-key, default: none)
      if v == none { continue }
      if last-mapping.at(gc-key, default: none) == none {
        last-mapping.insert(gc-key, v)
      }
    }
    stat-data = combined
    stat-mapping = last-mapping
  }

  // Resolve `after-stat` markers now that the stat has run; downstream
  // (position, train, geom draw) only sees real column names.
  let after-ctx = (
    theme: theme,
    palette: default-discrete,
    stat-name: stat-name,
    stat-info: stat-info(stat-name),
  )
  let after = eval-after-stat(stat-data, stat-mapping, after-ctx)
  stat-data = after.rows
  stat-mapping = after.mapping
  // Reapply any stage lanes stashed before the stat: after-stat rewrites
  // the column ref; after-scale wraps it in an `after-scale` marker that
  // carries the source column for the per-row resolver to scale through.
  let staged = apply-stages(stat-data, stat-mapping, stages, after-ctx)
  stat-data = staged.rows
  stat-mapping = staged.mapping

  // `position:` accepts either a string name (default params) or a dict
  // returned by a `position-*()` constructor carrying its own params.
  let position-spec = layer.at("position", default: "identity")
  let position-name = position-name-of(position-spec)
  let position-params = if type(position-spec) == str { params } else {
    position-spec.at("params", default: (:))
  }
  let pos-data = stat-data
  let pos-mapping = stat-mapping
  let factor-levels = (:)
  if position-name != none and position-name != "identity" {
    // Rewrite `as-factor`-marked positional columns to 1-indexed level
    // positions before position adjusts them, so `position-jitter` and
    // friends operate in numeric space without exploding the discrete
    // domain. See `_rewrite-factor-cols` for the full rationale.
    let rewritten = _rewrite-factor-cols(stat-mapping, stat-data)
    factor-levels = rewritten.factor-levels
    // Position needs plain column names; strip again in case stat-identity
    // left annotations in place.
    let pos-in = _strip-mapping-refs(stat-mapping)
    let r = apply-position(
      position-name,
      rewritten.data,
      pos-in,
      params: position-params,
      coord: coord,
    )
    pos-data = r.data
    // Merge position's additions (e.g., ymin/ymax) into the annotated mapping
    // while preserving existing annotations on x/y/...
    let merged = stat-mapping
    for (k, v) in r.mapping.pairs() {
      if merged.at(k, default: none) == none {
        merged.insert(k, v)
      }
    }
    pos-mapping = merged
  }

  let new = layer
  new.data = pos-data
  new.mapping = pos-mapping
  new.inherit-aes = false
  new.typst-marks = _typst-marks-of(mapping)
  if factor-levels.len() > 0 {
    new.insert("_factor-levels", factor-levels)
  }
  if not stat-identity { new.stat = "identity" }
  new
}

// Build a colour resolver curried over the (trained, palette) pair so per-row
// callers resolve the palette once outside the row loop and call the returned
// closure with bare values. One-shot callers can still chain immediately:
// `(ctx.resolve-colour)(trained, palette)(value)`.
#let _make-resolve-colour(ink) = (trained, palette) => {
  if trained == none {
    return _ => ink
  }
  if trained.type == "identity" {
    return value => {
      if value == none or value == "" { return ink }
      if type(value) == color { return value }
      if type(value) == str { return rgb(value) }
      ink
    }
  }
  let pal = spec-palette(trained, palette)
  if trained.type == "discrete" {
    let lookup = trained.at("level-index", default: none)
    return value => {
      if value == none or value == "" { return ink }
      let s = str(value)
      let idx = if lookup == none {
        trained.domain.position(v => v == s)
      } else { lookup.at(s, default: none) }
      if idx == none { return ink }
      palette-at(pal, idx)
    }
  }
  value => {
    if value == none or value == "" { return ink }
    let v = if type(value) == str { float(value.trim()) } else { float(value) }
    resolve-continuous-colour(trained, v, pal, ink)
  }
}

// Transform-aware axis break dispatch. Honours the trained scale's
// `transform` so log10 and sqrt panels get geometry-aware ticks instead of
// bunched linear ticks. If the user spec carries `binned: true`, ticks are
// placed at bin midpoints so labels sit under each `n-breaks`-wide
// quantised interval.
#let _axis-breaks(trained) = {
  let spec = trained.at("spec", default: none)
  let binned = if spec == none { false } else {
    spec.at("binned", default: false)
  }
  if binned {
    let (lo, hi) = trained.domain
    let n = if spec == none { 10 } else { spec.at("n-breaks", default: 10) }
    let count = calc.max(1, int(n))
    let span = hi - lo
    if span <= 0 { return (lo,) }
    let step = span / count
    return range(count).map(i => lo + (i + 0.5) * step)
  }
  let transform = trained.at("transform", default: none)
  let pre = trained.at("pre-transformed", default: false)
  let view-transform = trained.at("view-transform", default: none)
  let (lo, hi) = if view-transform != none {
    (
      transform-inv(transform, view-transform.at(0)),
      transform-inv(transform, view-transform.at(1)),
    )
  } else if pre {
    (
      transform-inv(transform, trained.domain.at(0)),
      transform-inv(transform, trained.domain.at(1)),
    )
  } else {
    trained.domain
  }
  if transform == "log10" { return pretty-log10(lo, hi) }
  if transform == "sqrt" { return pretty-sqrt(lo, hi) }
  pretty(lo, hi, n: 5)
}


// Convert a numeric break back to a Typst datetime against a fixed epoch and
// render it via `dt.display(fmt)`. `kind` selects the unit of `n`: `"date"`
// counts whole days, `"datetime"` and `"time"` count whole seconds.
#let _format-temporal(n, kind, fmt) = {
  let epoch = datetime(
    year: 2000,
    month: 1,
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
  )
  let dt = if kind == "date" {
    epoch + duration(days: int(calc.round(n)))
  } else {
    epoch + duration(seconds: int(calc.round(n)))
  }
  dt.display(fmt)
}

#let _axis-label(trained, n) = {
  let temporal = trained.at("temporal", default: none)
  if temporal != none {
    return _format-temporal(
      n,
      temporal,
      trained.at("date-format", default: ""),
    )
  }
  format-break(n)
}

// Per-row min/max accumulator helper used by the `_scan-*` passes.
#let _track-min-max(lo, hi, v) = (
  if lo == none { v } else { calc.min(lo, v) },
  if hi == none { v } else { calc.max(hi, v) },
)

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

#let _sec-spec(scale) = if (
  scale != none
    and scale.type == "continuous"
    and scale.at("spec", default: none) != none
) {
  scale.spec.at("secondary", default: none)
} else { none }

// Pre-compute primary and secondary x/y axis breaks for a trained scale set.
// Callers that share `trained` across panels (e.g., grid facets without free
// scales) build this once and pass it down so per-panel renders skip the
// redundant `_axis-breaks` calls.
#let _shared-axis-breaks(trained) = {
  let xt = trained.at("x", default: none)
  let yt = trained.at("y", default: none)
  let x-breaks = if xt != none and xt.type == "continuous" {
    _axis-breaks(xt)
  } else { none }
  let y-breaks = if yt != none and yt.type == "continuous" {
    _axis-breaks(yt)
  } else { none }
  let x-sec-breaks = if _sec-spec(xt) != none { x-breaks } else { none }
  let y-sec-breaks = if _sec-spec(yt) != none { y-breaks } else { none }
  (x: x-breaks, y: y-breaks, x-sec: x-sec-breaks, y-sec: y-sec-breaks)
}

// Normalise a single `guide-axis*` spec to the flat shape consumers expect.
// Always carries a `stack` flag so callers can branch on the same field
// regardless of whether the guide originated from a stack or stand-alone.
#let _normalise-axis-guide(g) = (
  angle: g.at("angle", default: 0),
  n-dodge: calc.max(1, g.at("n-dodge", default: 1)),
  logticks: g.at("logticks", default: false),
  stack: false,
)

// Read a `guide-axis(...)` or `guide-axis-stack(...)` configuration off the
// plot spec. Single guides flatten to `(angle, n-dodge, logticks, stack)`;
// stacks add `(guides, spacing)` plus aggregate fields so flat (non-stack)
// callers (label-anchor, log-minors) still see a sensible single-row view.
#let _read-axis-guide(spec, aes) = {
  let g = spec.at("guides", default: (:)).at(aes, default: none)
  if g == none { return (angle: 0, n-dodge: 1, logticks: false, stack: false) }
  if not g.at("stack", default: false) { return _normalise-axis-guide(g) }
  let subs = g.guides.map(_normalise-axis-guide)
  if subs.len() == 0 {
    panic(
      "guide-axis-stack requires at least one sub-guide; got an empty list.",
    )
  }
  (
    angle: subs.first().angle,
    n-dodge: subs.map(s => s.n-dodge).sum(),
    logticks: subs.any(s => s.logticks),
    stack: true,
    guides: subs,
    spacing: length-to-cm(g.at("spacing", default: 4pt), 0),
  )
}

// Cap trim is a small wedge at the named axis-arc end, capped at 2° so it
// stays a visible-but-modest "fade" no matter how wide the theta sweep is.
#let _THETA-CAP-FRAC = 0.02
#let _THETA-CAP-MAX-RAD = calc.pi / 90
#let _THETA-MINOR-TICK-FRAC = 0.03
#let _THETA-CAP-VALUES = ("none", "both", "upper", "lower")

// Read a `guide-axis-theta(...)` configuration off the plot spec. Returns
// `none` when no theta guide is bound so the radial renderer keeps its
// spoke-only path (no theta guide).
#let _read-theta-guide(spec) = {
  let g = spec.at("guides", default: (:)).at("theta", default: none)
  if g == none { return none }
  let cap = g.at("cap", default: "none")
  if not _THETA-CAP-VALUES.contains(cap) {
    panic(
      "guide-axis-theta cap must be one of "
        + _THETA-CAP-VALUES.map(v => "\"" + v + "\"").join(", ")
        + ", got \""
        + cap
        + "\".",
    )
  }
  (
    angle: g.at("angle", default: 0),
    minor-ticks: g.at("minor-ticks", default: false),
    cap: cap,
  )
}

// Convert the axis-text font size in pt to cm. Used as a fallback ink-height
// when no actual labels are measured (e.g., an axis with no breaks).
#let _ax-text-cm(size-pt) = size-pt / 1pt * 0.0353

// Resolve every side of an axis-* family into a record keyed by short side
// codes (xb=x-bottom, xt=x-top, yl=y-left, yr=y-right). The builder receives
// `(prefix, side, axis)` so it can either build a full surface key
// (`prefix + "-" + side`) or hand `(prefix, side, axis)` to a cascade.
#let _per-side(builder, prefix) = (
  xb: builder(prefix, "x-bottom", "x"),
  xt: builder(prefix, "x-top", "x"),
  yl: builder(prefix, "y-left", "y"),
  yr: builder(prefix, "y-right", "y"),
)

// Whether a tick draw should emit anything: needs both an active stroke and
// a positive length.
#let _should-draw-tick(stroke, len) = stroke != none and len > 0

// Resolve a margin side on a text-style record to a cm float, falling back to
// the supplied default length when the user has not overridden the side. The
// surface's font size is forwarded so em values scale with it.
#let _text-margin-cm(style, side, default-length) = {
  resolve-margin-side-cm(
    style.margin.at(side),
    default-length,
    size-pt: style.size / 1pt,
  )
}

// Default extents for an axis without labels: zero width, font-height as a
// safe fallback so layouts that ask for a depth before measurement is
// possible still leave room for a single line of text.
#let _empty-extents(size) = (
  width: 0.0,
  height: _ax-text-cm(size),
)

// Either the supplied extents record or `_empty-extents(size)` when caller
// did not measure any labels (e.g., callers that skip measurement or have no secondary axis).
#let _resolve-extents(extents, size) = if extents != none {
  extents
} else { _empty-extents(size) }

// Resolve a single tick label to its rendered form so measurement matches
// what the axis-draw path will emit.
#let _resolve-tick(labels-cb, typst-mark, idx, value, fallback, typst-eval) = (
  resolve-prose(
    resolve-label(labels-cb, value, idx, fallback, typst-mark: typst-mark),
    eval-strings: typst-eval,
  )
)

#let _trained-labels-cb(trained) = if (
  trained.at("spec", default: none) != none
) {
  trained.spec.at("labels", default: auto)
} else { auto }

// Collect the formatted tick labels for the trained scale and measure them
// via Typst. Returns `(width, height)` in cm of the longest label's ink box.
// Caller must already be inside a `context { ... }` block.
// `typst-eval` mirrors the axis-text style's `typst` flag so typst-marked
// labels measure at their rendered width.
#let _axis-label-extents(trained, size, typst-eval: false) = {
  if trained == none { return _empty-extents(size) }
  let labels-cb = _trained-labels-cb(trained)
  let typst-mark = trained.at("typst-mark", default: false)
  let labels = ()
  if trained.type == "discrete" {
    labels = trained
      .domain
      .enumerate()
      .map(((idx, level)) => (
        _resolve-tick(labels-cb, typst-mark, idx, level, level, typst-eval)
      ))
  } else if trained.type == "continuous" {
    labels = _axis-breaks(trained)
      .enumerate()
      .map(((idx, b)) => (
        _resolve-tick(
          labels-cb,
          typst-mark,
          idx,
          b,
          _axis-label(trained, b),
          typst-eval,
        )
      ))
  }
  if labels.len() == 0 { return _empty-extents(size) }
  measure-labels-cm(labels, size)
}

// Same as `_axis-label-extents` but for the secondary axis: each break is
// routed through the user's transformation before formatting. Returns zero
// extents when no secondary axis is configured.
#let _secondary-label-extents(trained, sec, size, typst-eval: false) = {
  if trained == none or sec == none { return (width: 0.0, height: 0.0) }
  if trained.type != "continuous" { return (width: 0.0, height: 0.0) }
  let labels-cb = _trained-labels-cb(trained)
  let typst-mark = trained.at("typst-mark", default: false)
  let labels = _axis-breaks(trained)
    .enumerate()
    .map(((idx, b)) => {
      let transformed = secondary-mod.apply-transform(sec, b)
      _resolve-tick(
        labels-cb,
        typst-mark,
        idx,
        transformed,
        format-break(transformed),
        typst-eval,
      )
    })
  if labels.len() == 0 { return (width: 0.0, height: 0.0) }
  measure-labels-cm(labels, size)
}

// Perpendicular extent of x-axis tick labels (cm). Inputs are the measured
// ink-bbox width and height of the longest label; rotating composes them
// trigonometrically, and `n-dodge > 1` adds the staggered rows.
#let _x-label-depth(angle, n-dodge, label-w-cm, label-h-cm) = {
  let a = calc.abs(angle) * 1deg
  label-w-cm * calc.sin(a) + label-h-cm * calc.cos(a) + (n-dodge - 1) * 0.35
}

// Perpendicular extent of y-axis tick labels (cm). At angle 0 the labels
// extend leftward by their full measured width; rotating swaps the extents
// according to the rotated bounding box, and `n-dodge > 1` adds dodge cols.
#let _y-label-width(angle, n-dodge, label-w-cm, label-h-cm) = {
  let a = calc.abs(angle) * 1deg
  label-w-cm * calc.cos(a) + label-h-cm * calc.sin(a) + (n-dodge - 1) * 0.5
}

// Inter-row gap between dodged labels on the x and y axes (cm). The depth
// helpers and the per-label draw closures both apply these so the reserved
// axis area stays in sync with the actual ink.
#let _X-LABEL-ROW-GAP = 0.35
#let _Y-LABEL-COL-GAP = 0.5

// Default gap between axis tick labels and axis title (all sides). Used as
// the fallback for `axis-title-*` margin sides left at `auto`. Absolute pt so
// the gap stays stable when users tune the axis-title font size.
#let _AX-TITLE-LABEL-GAP = 5pt

// One-element tuple for stand-alone guides, so callers can iterate uniformly
// across stacks and singletons. Shared between x and y; placement on either
// axis flows through the same rendering path.
#let _axis-guide-rows(g) = if g.stack { g.guides } else { (g,) }

// Stack-aware variants: a `guide-axis-stack` carries multiple sub-guides
// rendered as separate label rows. Inter-row spacing is added once per gap
// between successive rows; non-stack guides degenerate to a single row.
#let _stacked-extent(g, per-row-fn) = {
  let rows = _axis-guide-rows(g)
  let spacing = if g.stack { g.spacing } else { 0 }
  rows.map(per-row-fn).sum() + (rows.len() - 1) * spacing
}
#let _x-label-depth-stack(g, w, h) = _stacked-extent(
  g,
  s => _x-label-depth(s.angle, s.n-dodge, w, h),
)
#let _y-label-width-stack(g, w, h) = _stacked-extent(
  g,
  s => _y-label-width(s.angle, s.n-dodge, w, h),
)

#let _draw-axis-and-layers(
  prepared,
  trained,
  theme,
  spec,
  origin,
  inner-size,
  guides: (),
  legend-args: none,
  show-x-labels: true,
  show-y-labels: true,
  show-x-title: true,
  show-y-title: true,
  show-x-sec: true,
  show-y-sec: true,
  flipped: false,
  axis-breaks: none,
  x-extents: none,
  y-extents: none,
  x-sec-extents: none,
  y-sec-extents: none,
  canvas-w: 0,
  canvas-h: 0,
) = {
  import cetz.draw: *
  let (ox, oy) = origin
  let (iw, ih) = inner-size
  let px-lo = ox
  let px-hi = ox + iw
  let py-lo = oy
  let py-hi = oy + ih
  // `px-range`/`py-range` carry the inset *data area* (panel bounds shrunk by
  // any canvas-cm padding from `view-pad-cm`), so geoms and ticks land on the
  // correct data positions. Bare `px-lo`/`py-lo`/`px-hi`/`py-hi` keep the
  // outer panel bounds and are used for axis lines, panel fill, and gridline
  // endpoints that span the full panel.
  let _read-pad(t) = if t == none { (0, 0) } else {
    t.at("view-pad-cm", default: (0, 0))
  }
  let (x-pad-lo, x-pad-hi) = _read-pad(trained.at("x", default: none))
  let (y-pad-lo, y-pad-hi) = _read-pad(trained.at("y", default: none))
  let px-range = (px-lo + x-pad-lo, px-hi - x-pad-hi)
  let py-range = (py-lo + y-pad-lo, py-hi - y-pad-hi)

  let _ink = resolve-colour(theme, "ink")
  let _surface-style = (p, s, _) => _text-style(theme, p + "-" + s)
  let _ax-text = _per-side(_surface-style, "axis-text")
  let _ax-title = _per-side(_surface-style, "axis-title")

  let _resolve-mapping-flipped(layer) = {
    let m = _resolve-mapping(layer, spec.mapping)
    if not flipped or m == none { return m }
    let x = m.at("x", default: none)
    let y = m.at("y", default: none)
    let out = m
    out.insert("x", y)
    out.insert("y", x)
    out
  }

  let ctx = (
    trained: trained,
    px-range: px-range,
    py-range: py-range,
    palette: default-discrete,
    resolve-mapping: layer => _resolve-mapping-flipped(layer),
    resolve-data: layer => _resolve-data(layer, spec.data),
    resolve-colour: _make-resolve-colour(_ink),
    theme: theme,
    flipped: flipped,
    canvas-w: canvas-w,
    canvas-h: canvas-h,
  )

  let x-trained = trained.at("x", default: none)
  let y-trained = trained.at("y", default: none)

  let coord = spec.at("coord", default: none)
  let outer-radial = radial-ctx(coord, x-trained, y-trained, px-range, py-range)
  let is-radial = outer-radial != none

  let _panel = _rect-style(
    theme,
    "panel-background",
    fallback-fill: theme.paper,
    outset-ref-w: canvas-w,
    outset-ref-h: canvas-h,
  )
  // Panel rect stays glued to the natural panel canvas so a themed `inset`
  // cannot bleed past adjacent facets or chrome. Visible breathing room
  // around a panel is the job of `outset` (chrome reservation upstream).
  if _panel.fill != none or _panel.stroke != none {
    if is-radial {
      cetz.draw.circle(
        outer-radial.centre,
        radius: outer-radial.r-max,
        fill: _panel.fill,
        stroke: _panel.stroke,
      )
    } else {
      rect(
        (px-lo, py-lo),
        (px-hi, py-hi),
        fill: _panel.fill,
        stroke: _panel.stroke,
      )
    }
  }

  let grid-stroke = _line-stroke(theme, "panel-grid", fallback-colour: _ink)
  let _stroke-side = (p, s, _) => _line-stroke(
    theme,
    p + "-" + s,
    fallback-colour: _ink,
  )
  let _ax-line = _per-side(_stroke-side, "axis-line")
  let _ax-ticks = _per-side(_stroke-side, "axis-ticks")
  let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
  let _tick-len = _per-side(_len-side, "tick-length")

  let x-guide = _read-axis-guide(spec, "x")
  let y-guide = _read-axis-guide(spec, "y")
  let _x-label-anchor(angle) = {
    if angle == 0 { "north" } else if angle > 0 { "north-east" } else {
      "north-west"
    }
  }
  // Pre-compute row metadata for each axis: the sub-guide, the cumulative
  // dodge offset (in row units) up to this sub-guide, and the inter-row gap
  // offset (in cm). Lifted out of the per-break draw loops so flat plots
  // walk a single tuple instead of rebuilding it every label.
  let _stack-rows(g, gap) = {
    let rows = _axis-guide-rows(g)
    let spacing = if g.stack { g.spacing } else { 0 }
    let row-base = 0
    let metas = ()
    for (i, sub) in rows.enumerate() {
      metas.push((sub: sub, dodge-base: row-base, stack-offset: i * spacing))
      row-base += sub.n-dodge
    }
    metas
  }
  let _x-rows = _stack-rows(x-guide, _X-LABEL-ROW-GAP)
  let _y-rows = _stack-rows(y-guide, _Y-LABEL-COL-GAP)
  let _draw-x-label(cx, label-text, idx) = {
    if not (show-x-labels and theme.tick-labels) { return }
    for r in _x-rows {
      let dodge-row = calc.rem(idx, r.sub.n-dodge)
      let cy = (
        py-lo
          - _tick-len.xb
          - 0.1
          - (r.dodge-base + dodge-row) * _X-LABEL-ROW-GAP
          - r.stack-offset
      )
      content(
        (cx, cy),
        text(
          size: _ax-text.xb.size,
          fill: _ax-text.xb.fill,
          weight: _ax-text.xb.weight,
        )[#label-text],
        anchor: _x-label-anchor(r.sub.angle),
        angle: r.sub.angle * 1deg,
      )
    }
  }
  let _draw-y-label(cy, label-text, idx) = {
    if not (show-y-labels and theme.tick-labels) { return }
    for r in _y-rows {
      let dodge-col = calc.rem(idx, r.sub.n-dodge)
      let cx = (
        px-lo
          - _tick-len.yl
          - 0.1
          - (r.dodge-base + dodge-col) * _Y-LABEL-COL-GAP
          - r.stack-offset
      )
      content(
        (cx, cy),
        text(
          size: _ax-text.yl.size,
          fill: _ax-text.yl.fill,
          weight: _ax-text.yl.weight,
        )[#label-text],
        anchor: "east",
        angle: r.sub.angle * 1deg,
      )
    }
  }

  let _axis-display(trained) = (
    typst-mark: if trained != none {
      trained.at("typst-mark", default: false)
    } else { false },
    labels: if trained != none and trained.at("spec", default: none) != none {
      trained.spec.at("labels", default: auto)
    } else { auto },
  )
  let _x-disp = _axis-display(x-trained)
  let _y-disp = _axis-display(y-trained)

  // Draw the cartesian axis ticks, gridlines, and labels for one axis.
  // Continuous and discrete axes share everything except how `cx`/`cy` is
  // mapped, where the labels come from, and whether gridlines are drawn
  // (continuous only, since discrete ticks already mark every level).
  let _draw-cartesian-axis(axis, trained, disp, ax-text-typst, draw-label) = {
    if is-radial or trained == none { return }
    let is-continuous = trained.type == "continuous"
    if not is-continuous and trained.type != "discrete" { return }
    let stroke = if axis == "x" { _ax-ticks.xb } else { _ax-ticks.yl }
    let tick-len = if axis == "x" { _tick-len.xb } else { _tick-len.yl }
    let range = if axis == "x" { px-range } else { py-range }
    let breaks = if is-continuous {
      if axis-breaks != none and axis-breaks.at(axis, default: none) != none {
        axis-breaks.at(axis)
      } else { _axis-breaks(trained) }
    } else { trained.domain }
    for (idx, b) in breaks.enumerate() {
      let c = if is-continuous {
        map-axis-data(trained, b, range)
      } else { map-position(trained, b, range) }
      if is-continuous and grid-stroke != none {
        if axis == "x" {
          line((c, py-lo), (c, py-hi), stroke: grid-stroke)
        } else {
          line((px-lo, c), (px-hi, c), stroke: grid-stroke)
        }
      }
      if _should-draw-tick(stroke, tick-len) {
        if axis == "x" {
          line((c, py-lo), (c, py-lo - tick-len), stroke: stroke)
        } else {
          line((px-lo - tick-len, c), (px-lo, c), stroke: stroke)
        }
      }
      let fallback = if is-continuous { _axis-label(trained, b) } else { b }
      draw-label(
        c,
        resolve-prose(
          resolve-label(
            disp.labels,
            b,
            idx,
            fallback,
            typst-mark: disp.typst-mark,
          ),
          eval-strings: ax-text-typst,
        ),
        idx,
      )
    }
  }
  _draw-cartesian-axis(
    "x",
    x-trained,
    _x-disp,
    _ax-text.xb.typst,
    _draw-x-label,
  )
  _draw-cartesian-axis(
    "y",
    y-trained,
    _y-disp,
    _ax-text.yl.typst,
    _draw-y-label,
  )

  // Minor log ticks: opt-in via guide-axis-logticks() on a log10-trans axis.
  // Emits half-length, unlabelled ticks at sub-decade positions (2, 3, ..., 9
  // within each decade) covered by the visible domain.
  let _draw-log-minors(trained, guide, axis, range, stroke, tick-len) = {
    if not guide.logticks { return }
    if trained == none { return }
    if trained.type != "continuous" { return }
    if trained.at("transform", default: "identity") != "log10" { return }
    if not _should-draw-tick(stroke, tick-len) { return }
    let view-transform = trained.at("view-transform", default: none)
    let (lo, hi) = if view-transform != none {
      (
        transform-inv("log10", view-transform.at(0)),
        transform-inv("log10", view-transform.at(1)),
      )
    } else { trained.domain }
    if lo <= 0 or hi <= 0 { return }
    let minor-len = tick-len * 0.5
    let k-lo = int(calc.floor(calc.log(lo, base: 10)))
    let k-hi = int(calc.ceil(calc.log(hi, base: 10)))
    let k = k-lo
    while k <= k-hi {
      let scale = calc.pow(10.0, k)
      for c in (2, 3, 4, 5, 6, 7, 8, 9) {
        let v = c * scale
        if v >= lo and v <= hi {
          if axis == "x" {
            let cx = map-axis-data(trained, v, range)
            line((cx, py-lo), (cx, py-lo - minor-len), stroke: stroke)
          } else {
            let cy = map-axis-data(trained, v, range)
            line((px-lo - minor-len, cy), (px-lo, cy), stroke: stroke)
          }
        }
      }
      k = k + 1
    }
  }
  if not is-radial {
    _draw-log-minors(
      x-trained,
      x-guide,
      "x",
      px-range,
      _ax-ticks.xb,
      _tick-len.xb,
    )
    _draw-log-minors(
      y-trained,
      y-guide,
      "y",
      py-range,
      _ax-ticks.yl,
      _tick-len.yl,
    )
  }

  // Secondary x-axis: draw on top edge if the trained x scale carries a
  // secondary spec. Breaks reuse the primary axis grid; their labels go
  // through the user's transformation function.
  let _x-sec = _sec-spec(x-trained)
  if not is-radial and _x-sec != none and show-x-sec {
    let breaks = if axis-breaks != none and axis-breaks.x-sec != none {
      axis-breaks.x-sec
    } else { _axis-breaks(x-trained) }
    for b in breaks {
      let cx = map-axis-data(x-trained, b, px-range)
      if _should-draw-tick(_ax-ticks.xt, _tick-len.xt) {
        line((cx, py-hi), (cx, py-hi + _tick-len.xt), stroke: _ax-ticks.xt)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_x-sec, b)
        content(
          (cx, py-hi + _tick-len.xt + 0.1),
          text(
            size: _ax-text.xt.size,
            fill: _ax-text.xt.fill,
            weight: _ax-text.xt.weight,
          )[#resolve-prose(
            format-break(mapped),
            eval-strings: _ax-text.xt.typst,
          )],
          anchor: "south",
        )
      }
    }
    if _ax-line.xt != none {
      line((px-lo, py-hi), (px-hi, py-hi), stroke: _ax-line.xt)
    }
    if _x-sec.name != none and _ax-title.xt.size > 0pt {
      let _x-sec-ext = _resolve-extents(x-sec-extents, _ax-text.xt.size)
      let x-sec-depth = _x-label-depth(
        0,
        1,
        _x-sec-ext.width,
        _x-sec-ext.height,
      )
      let x-sec-gap = _text-margin-cm(
        _ax-title.xt,
        "bottom",
        _AX-TITLE-LABEL-GAP,
      )
      content(
        (
          (px-lo + px-hi) / 2,
          py-hi + _tick-len.xt + 0.1 + x-sec-depth + x-sec-gap,
        ),
        text(
          size: _ax-title.xt.size,
          fill: _ax-title.xt.fill,
          weight: _ax-title.xt.weight,
        )[#resolve-prose(_x-sec.name, eval-strings: _ax-title.xt.typst)],
        anchor: "south",
      )
    }
  }

  // Secondary y-axis: draw on right edge if the trained y scale carries a
  // secondary spec.
  let _y-sec = _sec-spec(y-trained)
  if not is-radial and _y-sec != none and show-y-sec {
    let breaks = if axis-breaks != none and axis-breaks.y-sec != none {
      axis-breaks.y-sec
    } else { _axis-breaks(y-trained) }
    for b in breaks {
      let cy = map-axis-data(y-trained, b, py-range)
      if _should-draw-tick(_ax-ticks.yr, _tick-len.yr) {
        line((px-hi, cy), (px-hi + _tick-len.yr, cy), stroke: _ax-ticks.yr)
      }
      if theme.tick-labels {
        let mapped = secondary-mod.apply-transform(_y-sec, b)
        content(
          (px-hi + _tick-len.yr + 0.1, cy),
          text(
            size: _ax-text.yr.size,
            fill: _ax-text.yr.fill,
            weight: _ax-text.yr.weight,
          )[#resolve-prose(
            format-break(mapped),
            eval-strings: _ax-text.yr.typst,
          )],
          anchor: "west",
        )
      }
    }
    if _ax-line.yr != none {
      line((px-hi, py-lo), (px-hi, py-hi), stroke: _ax-line.yr)
    }
    if _y-sec.name != none and _ax-title.yr.size > 0pt {
      let _y-sec-ext = _resolve-extents(y-sec-extents, _ax-text.yr.size)
      let y-sec-width = _y-label-width(
        0,
        1,
        _y-sec-ext.width,
        _y-sec-ext.height,
      )
      let title-text-cm = _ax-text-cm(_ax-title.yr.size)
      let y-sec-gap = _text-margin-cm(_ax-title.yr, "left", _AX-TITLE-LABEL-GAP)
      content(
        (
          px-hi
            + _tick-len.yr
            + 0.1
            + y-sec-width
            + y-sec-gap
            + title-text-cm / 2,
          (py-lo + py-hi) / 2,
        ),
        text(
          size: _ax-title.yr.size,
          fill: _ax-title.yr.fill,
          weight: _ax-title.yr.weight,
        )[#resolve-prose(_y-sec.name, eval-strings: _ax-title.yr.typst)],
        angle: 90deg,
      )
    }
  }

  if not is-radial and _ax-line.xb != none {
    line((px-lo, py-lo), (px-hi, py-lo), stroke: _ax-line.xb)
  }
  if not is-radial and _ax-line.yl != none {
    line((px-lo, py-lo), (px-lo, py-hi), stroke: _ax-line.yl)
  }

  if is-radial {
    let theta-guide = _read-theta-guide(spec)
    let (cx, cy) = outer-radial.centre
    let r-max = outer-radial.r-max
    let theta-range = outer-radial.theta-range
    let r-range = outer-radial.r-range

    let (theta-trained, r-trained, theta-disp, theta-text) = if (
      outer-radial.cat-is-theta
    ) {
      (x-trained, y-trained, _x-disp, _ax-text.xb)
    } else {
      (y-trained, x-trained, _y-disp, _ax-text.yl)
    }

    let _radial-theta-of(trained, value) = if trained.type == "continuous" {
      map-axis-data(trained, value, theta-range)
    } else {
      map-position(trained, value, theta-range)
    }

    if grid-stroke != none and r-trained != none {
      if r-trained.type == "continuous" {
        for b in _axis-breaks(r-trained) {
          let r = map-axis-data(r-trained, b, r-range)
          if r > 0 and r <= r-max {
            circle((cx, cy), radius: r, fill: none, stroke: grid-stroke)
          }
        }
      }
    }

    let theta-breaks = if theta-trained == none { () } else if (
      theta-trained.type == "continuous"
    ) {
      _axis-breaks(theta-trained)
    } else { theta-trained.domain }

    // Full-sweep domain endpoints can land on the same canvas angle (e.g., 0
    // and 24 on a 24-hour clock both sit at 12 o'clock); group them so we
    // draw one spoke and one merged "end/start" label per shared angle.
    let theta-groups = group-theta-breaks(
      theta-breaks,
      b => _radial-theta-of(theta-trained, b),
    )

    if grid-stroke != none and theta-trained != none {
      for group in theta-groups {
        let theta = group.first().theta
        line(
          (cx, cy),
          (cx + r-max * calc.cos(theta), cy + r-max * calc.sin(theta)),
          stroke: grid-stroke,
        )
      }
    }

    // Outer axis arc plus optional minor ticks (the `guide-axis-theta`
    // guide). Spoke-only plots (no theta guide) skip this whole block.
    if theta-guide != none and _ax-line.xb != none {
      let (theta-lo, theta-hi) = (theta-range.at(0), theta-range.at(1))
      let span = calc.abs(theta-hi - theta-lo)
      let trim = if theta-guide.cap == "none" { 0 } else {
        calc.min(span * _THETA-CAP-FRAC, _THETA-CAP-MAX-RAD)
      }
      let direction = if theta-hi >= theta-lo { 1 } else { -1 }
      let arc-lo = if theta-guide.cap == "lower" or theta-guide.cap == "both" {
        theta-lo + direction * trim
      } else { theta-lo }
      let arc-hi = if theta-guide.cap == "upper" or theta-guide.cap == "both" {
        theta-hi - direction * trim
      } else { theta-hi }
      let arc-pts = radial-arc(arc-lo, arc-hi, r-max, outer-radial)
      line(..arc-pts, stroke: _ax-line.xb)

      if theta-guide.minor-ticks and theta-groups.len() >= 2 {
        let minor-r = r-max * (1 + _THETA-MINOR-TICK-FRAC)
        let prev = theta-groups.first().first().theta
        for i in range(1, theta-groups.len()) {
          let cur = theta-groups.at(i).first().theta
          let mid = (prev + cur) / 2
          line(
            polar-canvas(outer-radial, mid, r-max),
            polar-canvas(outer-radial, mid, minor-r),
            stroke: _ax-line.xb,
          )
          prev = cur
        }
      }
    }

    if (
      show-x-labels and theme.tick-labels and theta-trained != none
    ) {
      let pad = 0.2
      for group in theta-groups {
        // `labels` callbacks may return `none` to drop a wrap-side break from
        // the merged label (e.g., hide "6" so a 0..6 radar shows "0", not "6/0").
        let labels = group
          .map(rec => {
            let raw = if theta-trained.type == "continuous" {
              _axis-label(theta-trained, rec.b)
            } else { rec.b }
            resolve-label(
              theta-disp.labels,
              rec.b,
              rec.idx,
              raw,
              typst-mark: theta-disp.typst-mark,
            )
          })
          .filter(l => l != none)
        if labels.len() == 0 { continue }
        // Higher-domain break first: "24/0", not "0/24".
        let label-text = labels.rev().join([/])
        let theta = group.first().theta
        let lr = r-max + pad
        content(
          (cx + lr * calc.cos(theta), cy + lr * calc.sin(theta)),
          text(
            size: theta-text.size,
            fill: theta-text.fill,
            weight: theta-text.weight,
          )[#resolve-prose(label-text, eval-strings: theta-text.typst)],
          anchor: "center",
          angle: if theta-guide == none { 0deg } else {
            theta-guide.angle * 1deg
          },
        )
      }
    }
  }

  // Render geoms into a sibling cetz canvas whose origin is (0, 0) and whose
  // bounds match the panel rectangle, then clip via Typst's `box(clip: true)`
  // before placing it back at the panel's south-west corner. cetz 0.5.0 has
  // no native clip primitive, so this nested-canvas hop is the only way to
  // bound geom marks to the panel.
  let panel-w = px-hi - px-lo
  let panel-h = py-hi - py-lo
  let inner-ctx = ctx
  inner-ctx.px-range = (x-pad-lo, panel-w - x-pad-hi)
  inner-ctx.py-range = (y-pad-lo, panel-h - y-pad-hi)
  let inner-radial = radial-ctx(
    coord,
    x-trained,
    y-trained,
    inner-ctx.px-range,
    inner-ctx.py-range,
  )
  inner-ctx.radial = inner-radial
  if inner-radial != none {
    for layer in prepared {
      if not _RADIAL-AWARE.at(layer.geom, default: false) {
        panic("coord-radial does not support geom-" + layer.geom + ".")
      }
    }
  }
  let geoms = cetz.canvas({
    import cetz.draw: floating, hide, rect
    hide(rect((0, 0), (panel-w, panel-h)), bounds: true)
    for layer in prepared {
      let draw = _geom-draw.at(layer.geom, default: none)
      if draw != none {
        floating({ draw(layer, inner-ctx) })
      }
    }
  })
  let clip-on = if inner-radial != none {
    inner-radial.clip
  } else if coord != none {
    coord.at("clip", default: "on") != "off"
  } else { true }
  content(
    (px-lo, py-lo),
    if clip-on {
      box(
        clip: true,
        width: panel-w * 1cm,
        height: panel-h * 1cm,
        geoms,
      )
    } else { geoms },
    anchor: "south-west",
  )

  // Radial-axis tick labels render after geoms so filled wedges, lines, and
  // points cannot mask them.
  if is-radial {
    let (cx, cy) = outer-radial.centre
    let r-max = outer-radial.r-max
    let theta-range = outer-radial.theta-range
    let r-range = outer-radial.r-range
    let r-trained = if outer-radial.cat-is-theta {
      y-trained
    } else { x-trained }
    let r-disp = if outer-radial.cat-is-theta { _y-disp } else { _x-disp }
    let r-text = if outer-radial.cat-is-theta {
      _ax-text.yl
    } else { _ax-text.xb }
    if (
      show-y-labels
        and theme.tick-labels
        and r-trained != none
        and r-trained.type == "continuous"
    ) {
      let start-angle = theta-range.at(0)
      let dx = calc.cos(start-angle)
      let dy = calc.sin(start-angle)
      for (idx, b) in _axis-breaks(r-trained).enumerate() {
        let r = map-axis-data(r-trained, b, r-range)
        if r < 0 or r > r-max { continue }
        let label-text = resolve-label(
          r-disp.labels,
          b,
          idx,
          _axis-label(r-trained, b),
          typst-mark: r-disp.typst-mark,
        )
        content(
          (cx + r * dx, cy + r * dy),
          text(
            size: r-text.size,
            fill: r-text.fill,
            weight: r-text.weight,
          )[#resolve-prose(label-text, eval-strings: r-text.typst)],
          anchor: "center",
        )
      }
    }
  }

  // When flipped, the bottom axis shows the user's original y mapping and
  // the left axis shows the user's original x mapping; trained.x and
  // trained.y already carry the swapped scale specs (and labs labels), so
  // only the mapping-name fallback needs an explicit swap here.
  let _mapping-x-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("y", default: none))
  } else { mapping-display-name(spec.mapping.at("x", default: none)) }
  let _mapping-y-name = if spec.mapping == none { none } else if flipped {
    mapping-display-name(spec.mapping.at("x", default: none))
  } else { mapping-display-name(spec.mapping.at("y", default: none)) }
  let x-title = _axis-title(x-trained, _mapping-x-name)
  let y-title = _axis-title(y-trained, _mapping-y-name)
  let _x-ext = _resolve-extents(x-extents, _ax-text.xb.size)
  let _y-ext = _resolve-extents(y-extents, _ax-text.yl.size)
  let x-label-depth = _x-label-depth-stack(x-guide, _x-ext.width, _x-ext.height)
  let y-label-width = _y-label-width-stack(y-guide, _y-ext.width, _y-ext.height)
  let x-title-cm = _ax-text-cm(_ax-title.xb.size)
  let y-title-cm = _ax-text-cm(_ax-title.yl.size)
  let x-title-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  let y-title-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  let x-edge-offset = _tick-len.xb + 0.1 + x-label-depth + x-title-gap
  let y-edge-offset = _tick-len.yl + 0.1 + y-label-width + y-title-gap
  if show-x-title and x-title != none and _ax-title.xb.size > 0pt {
    content(
      ((px-lo + px-hi) / 2, oy - (x-edge-offset + x-title-cm)),
      text(
        size: _ax-title.xb.size,
        fill: _ax-title.xb.fill,
        weight: _ax-title.xb.weight,
      )[#resolve-prose(x-title, eval-strings: _ax-title.xb.typst)],
      anchor: "south",
    )
  }
  if show-y-title and y-title != none and _ax-title.yl.size > 0pt {
    content(
      (px-lo - (y-edge-offset + y-title-cm / 2), (py-lo + py-hi) / 2),
      text(
        size: _ax-title.yl.size,
        fill: _ax-title.yl.fill,
        weight: _ax-title.yl.weight,
      )[#resolve-prose(y-title, eval-strings: _ax-title.yl.typst)],
      angle: 90deg,
    )
  }

  if guides.len() > 0 and legend-args != none {
    legend-mod.draw(
      guides,
      ctx,
      panel-rect: legend-args.panel-rect,
      margin: legend-args.margin,
      legend-gap: legend-args.legend-gap,
      sec-y-extent: legend-args.sec-y-extent,
      sec-x-extent: legend-args.sec-x-extent,
      right-strip: legend-args.right-strip,
      theme: theme,
    )
  }
}

// Inject labs `x`/`y`/... names into trained scale specs so axis and legend
// titles follow labs() overrides.
#let _apply-labs(trained, labs) = {
  if labs == none { return trained }
  for (aes-name, label) in labs.axes.pairs() {
    if label == none { continue }
    let t = trained.at(aes-name, default: none)
    if t == none { continue }
    let spec = t.at("spec", default: none)
    let new-spec = if spec == none { (aesthetic: aes-name, name: label) } else {
      let s = spec
      s.insert("name", label)
      s
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
    new-y.insert("transform", "reverse")
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

#let _render-style(theme) = (
  strip-text: _text-style(theme, "strip-text"),
  ax-title: _per-side(
    (p, s, _) => _text-style(theme, p + "-" + s),
    "axis-title",
  ),
)

// Draw one facet strip: a filled rectangle with the labeller text centred
// inside. Shared between facet-wrap (top strip) and facet-grid (top + side
// strips). `angle` is `-90deg` for the rotated row-strip, else `0deg`. Text
// stays centred on the natural band so themed inset offsets paint past
// the band without dragging the label with them. `%` on inset resolves
// against the band's own dims (band-w x band-h) so a 5% inset paints
// inside the band rather than overflowing onto neighbouring panels.
#let _draw-strip(
  corner-lo,
  corner-hi,
  label-text,
  style,
  theme,
  angle: 0deg,
) = {
  let strip = _rect-style(
    theme,
    "strip-background",
    fallback-fill: theme.paper,
  )
  cetz.draw.rect(
    corner-lo,
    corner-hi,
    fill: strip.fill,
    stroke: strip.stroke,
  )
  let (cx, cy) = (
    (corner-lo.at(0) + corner-hi.at(0)) / 2,
    (corner-lo.at(1) + corner-hi.at(1)) / 2,
  )
  cetz.draw.content(
    (cx, cy),
    text(
      size: style.strip-text.size,
      fill: style.strip-text.fill,
      weight: style.strip-text.weight,
    )[#resolve-prose(label-text, eval-strings: style.strip-text.typst)],
    angle: angle,
  )
}

// Resolve the strip text for every facet level once. The labeller text is
// needed both to size the strip band and (in facet-grid) to draw it, so it
// is computed up front rather than inside the cetz canvas closure, which
// cannot `measure` (the operation `_strip-band` relies on). `count-of` maps
// a level index to the row count fed to a context labeller.
#let _strip-texts(labeller, var, levels, count-of) = {
  levels
    .enumerate()
    .map(((i, lv)) => labellers.format(labeller, var, lv, count: count-of(i)))
}

// cm extent of a strip band sized to the tallest label, floored at `base`.
// A wrapped labeller (`label-wrap`) emits `\n`-joined lines, so the rendered
// height grows with the line count; `pad` keeps the same breathing room the
// old fixed constants gave a single line. For the rotated row-strip the
// measured height is the band's *width*, which is exactly what the caller
// wants.
#let _strip-band(labels, style, base) = {
  let prose = labels.map(l => resolve-prose(
    l,
    eval-strings: style.strip-text.typst,
  ))
  let pad = 0.16
  calc.max(base, measure-labels-cm(prose, style.strip-text.size).height + pad)
}

// Reserved extent between the panel and the canvas edge for the secondary
// axis ticks, labels, and title. `axis` selects orientation: `"y"` (right
// edge, label width) or `"x"` (top edge, label depth). Matches the primary
// formula so the title-to-label gap stays symmetric on opposing edges.
#let _sec-extent(sec, tick-len, sec-extents, ax-title, axis) = {
  if sec == none { return 0.0 }
  let label-extent = if axis == "y" {
    _y-label-width(0, 1, sec-extents.width, sec-extents.height)
  } else {
    _x-label-depth(0, 1, sec-extents.width, sec-extents.height)
  }
  let title-cm = if sec.at("name", default: none) != none {
    _ax-text-cm(ax-title.size)
  } else { 0.0 }
  let gap-side = if axis == "y" { "left" } else { "bottom" }
  let gap = _text-margin-cm(ax-title, gap-side, _AX-TITLE-LABEL-GAP)
  tick-len + 0.1 + label-extent + gap + title-cm + 0.05
}


// ASCII Unit Separator joins the two grid-facet level strings into a single
// dict key. Assumed absent from any user-facing facet level.
#let _facet-key-sep = "\u{1F}"

// Build a (row-key-fn, panel-key-fn) pair for a grid facet spec, specialised
// on which of `rows` / `cols` is set. The row-key-fn is invoked once per data
// row inside `group-by` and must avoid per-row allocation. `none` values are
// coerced to "" so rows with missing facet variables drop out (panel levels
// from `_raw-levels-for` exclude `none`).
#let _facet-cell-str(row, col) = {
  let v = row.at(col, default: none)
  if v == none { "" } else { str(v) }
}

#let _grid-facet-keyers(spec) = {
  let r = spec.facet.rows
  let c = spec.facet.columns
  if r != none and c != none {
    return (
      row: row => (
        _facet-cell-str(row, r) + _facet-key-sep + _facet-cell-str(row, c)
      ),
      panel: (rl, cl) => rl + _facet-key-sep + cl,
    )
  }
  if r != none {
    return (
      row: row => _facet-cell-str(row, r),
      panel: (rl, _) => rl,
    )
  }
  (
    row: row => _facet-cell-str(row, c),
    panel: (_, cl) => cl,
  )
}

// Typst `measure()` is unreachable inside cetz canvas closures, so size each
// row's final label here and stash the result on the layer. The segment
// router consumes the sizes to clip connectors at the label edge and to
// detect crossings against sibling labels.
#let _measure-label-sizes(layer) = {
  let geom = layer.at("geom", default: none)
  if geom not in label-draw.LABEL-GEOMS { return layer }
  let params = layer.at("params", default: (:))
  if not (
    params.at("segment", default: false) or params.at("repel", default: false)
  ) { return layer }
  let mapping = layer.at("mapping", default: none)
  if mapping == none { return layer }
  let label-col = mapping.at("label", default: none)
  let const-label = params.at("label", default: none)
  let use-const = const-label != none
  if not use-const and label-col == none { return layer }
  let label-typst = (
    layer.at("typst-marks", default: (:)).at("label", default: false)
      or geom == "typst"
  )
  let size = params.at("size", default: 8pt)
  let inset = params.at("inset", default: 0pt)
  let inset-cm = if type(inset) == length { inset / 1cm } else { 0.0 }
  let sizes = layer
    .at("data", default: ())
    .map(row => {
      let label = if use-const { const-label } else {
        row.at(label-col, default: none)
      }
      if label == none { return (w: 0.0, h: 0.0) }
      if label-typst and type(label) == str { label = eval-as-markup(label) }
      let m = measure-text-cm(label, size)
      (w: m.width + 2 * inset-cm, h: m.height + 2 * inset-cm)
    })
  let new = layer
  new.insert("_label-sizes", sizes)
  new
}

#let _render-prepare(spec, theme) = {
  let facet-wrap-mode = spec.facet != none and spec.facet.facet == "wrap"
  let facet-grid-mode = spec.facet != none and spec.facet.facet == "grid"
  let coord = spec.at("coord", default: none)

  let wrap-levels = if facet-wrap-mode {
    _raw-levels-for(spec, spec.facet.variable)
  } else { () }

  let grid-row-levels = if facet-grid-mode and spec.facet.rows != none {
    _raw-levels-for(spec, spec.facet.rows)
  } else if facet-grid-mode { ("",) } else { () }
  let grid-col-levels = if facet-grid-mode and spec.facet.columns != none {
    _raw-levels-for(spec, spec.facet.columns)
  } else if facet-grid-mode { ("",) } else { () }

  // Partition each layer's data once by the facet key, then look up each
  // panel's subset in O(1).
  let panels = if facet-wrap-mode {
    let var = spec.facet.variable
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      row => _facet-cell-str(row, var),
    ))
    wrap-levels.map(level => (
      level: level,
      layers: spec
        .layers
        .enumerate()
        .map(((i, l)) => {
          let with-subset = l
          with-subset.data = layer-groups.at(i).at(level, default: ())
          with-subset.insert("data-trusted", true)
          _prepare-layer(
            with-subset,
            spec.mapping,
            spec.data,
            theme: theme,
            coord: coord,
          )
        }),
    ))
  } else if facet-grid-mode {
    let keyers = _grid-facet-keyers(spec)
    let layer-groups = spec.layers.map(l => group-by(
      _resolve-data(l, spec.data),
      keyers.row,
    ))
    let out = ()
    for row-lv in grid-row-levels {
      for col-lv in grid-col-levels {
        let key = (keyers.panel)(row-lv, col-lv)
        out.push((
          row-level: row-lv,
          col-level: col-lv,
          layers: spec
            .layers
            .enumerate()
            .map(((i, l)) => {
              let with-subset = l
              with-subset.data = layer-groups.at(i).at(key, default: ())
              with-subset.insert("data-trusted", true)
              _prepare-layer(
                with-subset,
                spec.mapping,
                spec.data,
                theme: theme,
                coord: coord,
              )
            }),
        ))
      }
    }
    out
  } else { () }

  let prepared = if facet-wrap-mode or facet-grid-mode {
    let union = ()
    for panel in panels { union += panel.layers }
    union
  } else {
    spec.layers.map(l => _prepare-layer(
      l,
      spec.mapping,
      spec.data,
      theme: theme,
      coord: coord,
    ))
  }

  (
    facet-wrap-mode: facet-wrap-mode,
    facet-grid-mode: facet-grid-mode,
    wrap-levels: wrap-levels,
    grid-row-levels: grid-row-levels,
    grid-col-levels: grid-col-levels,
    panels: panels,
    prepared: prepared,
  )
}

#let _panel-row-count(panel-layers) = {
  let n = 0
  for layer in panel-layers { n += layer.data.len() }
  n
}

#let _train-panels(spec, panels, trained, coord, labs, free-x, free-y) = {
  if not (free-x or free-y) { return () }
  // Only positional aesthetics are retrained per panel; non-positionals stay
  // shared so legends do not fragment. Labs labels must be re-applied because
  // pt.x / pt.y overwrite the globally-labelled merged.x / merged.y below.
  panels.map(p => {
    let pt = train(
      scales: spec.scales,
      layers: p.layers,
      mapping: spec.mapping,
      data: spec.data,
      aesthetics: positional-aesthetics,
    )
    pt = _apply-labs(pt, labs)
    pt = _post-train(pt, p.layers)
    pt = _apply-coord-transform(pt, coord)
    pt = _apply-expand(pt, coord)
    pt = _apply-coord(pt, coord)
    pt = _apply-flip(pt, coord)
    let merged = trained
    if free-x and pt.at("x", default: none) != none {
      merged.insert("x", pt.x)
    }
    if free-y and pt.at("y", default: none) != none {
      merged.insert("y", pt.y)
    }
    merged
  })
}

#let _render-canvas-wrap(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let panel-trained-list = ctx.panel-trained-list
  let wrap-levels = ctx.wrap-levels
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let sec-y-extent = ctx.sec-y-extent
  let sec-x-extent = ctx.sec-x-extent
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let free-x = ctx.free-x
  let free-y = ctx.free-y
  let style = ctx.style
  let _ax-title = style.ax-title
  let x-extents = ctx.x-extents
  let y-extents = ctx.y-extents
  let x-sec-extents = ctx.x-sec-extents
  let y-sec-extents = ctx.y-sec-extents
  let ax-text = ctx.ax-text

  // Per-panel extents under free scales: each panel's trained scale carries
  // its own break/level set, so the longest label can differ panel-to-panel.
  // Measured here (still inside the outer `context`) before the canvas
  // closure, since cetz canvas does not expose layout measurement.
  let panel-extents = if not (free-x or free-y) {
    none
  } else {
    panel-trained-list.map(pt => {
      let xt = pt.at("x", default: none)
      let yt = pt.at("y", default: none)
      let xs = _sec-spec(xt)
      let ys = _sec-spec(yt)
      (
        x: if free-x {
          _axis-label-extents(xt, ax-text.xb.size, typst-eval: ax-text.xb.typst)
        } else { x-extents },
        y: if free-y {
          _axis-label-extents(yt, ax-text.yl.size, typst-eval: ax-text.yl.typst)
        } else { y-extents },
        x-sec: if free-x {
          _secondary-label-extents(
            xt,
            xs,
            ax-text.xt.size,
            typst-eval: ax-text.xt.typst,
          )
        } else { x-sec-extents },
        y-sec: if free-y {
          _secondary-label-extents(
            yt,
            ys,
            ax-text.yr.size,
            typst-eval: ax-text.yr.typst,
          )
        } else { y-sec-extents },
      )
    })
  }

  let levels = wrap-levels
  let n = levels.len()
  let ncol = if spec.facet.ncolumn != none {
    spec.facet.ncolumn
  } else if spec.facet.nrow != none {
    calc.ceil(n / spec.facet.nrow)
  } else {
    calc.max(1, int(calc.ceil(calc.sqrt(n))))
  }
  let nrow = calc.max(1, int(calc.ceil(n / ncol)))
  let strip-texts = _strip-texts(
    spec.facet.at("labeller", default: none),
    spec.facet.variable,
    levels,
    i => _panel-row-count(panels.at(i).layers),
  )
  let strip-h = _strip-band(strip-texts, style, 0.45)
  let gutter-x = 0.4
  let gutter-y = 0.4
  let grid-w = width-units - margin.left - margin.right
  let grid-h = height-units - margin.bottom - margin.top
  let panel-w = (grid-w - gutter-x * (ncol - 1)) / ncol
  let panel-h = (grid-h - gutter-y * (nrow - 1) - strip-h * nrow) / nrow

  // Compute shared breaks once per axis. A free axis sets its entry to
  // `none` so `_draw-axis-and-layers` falls back to per-panel computation
  // (the per-panel scale is what differs); the fixed axis still benefits
  // from the cached breaks even when the other axis is free.
  let shared-breaks = {
    let s = _shared-axis-breaks(trained)
    if free-x {
      s.insert("x", none)
      s.insert("x-sec", none)
    }
    if free-y {
      s.insert("y", none)
      s.insert("y-sec", none)
    }
    s
  }

  let all-x = ("all_x", "all").contains(spec.facet.axes)
  let all-y = ("all_y", "all").contains(spec.facet.axes)

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    for (i, level) in levels.enumerate() {
      let col = calc.rem(i, ncol)
      let row = int(i / ncol)
      let x0 = margin.left + col * (panel-w + gutter-x)
      let y0 = (
        margin.bottom + (nrow - 1 - row) * (panel-h + gutter-y + strip-h)
      )
      let panel-layers = panels.at(i).layers
      let strip-text = strip-texts.at(i)
      _draw-strip(
        (x0, y0 + panel-h),
        (x0 + panel-w, y0 + panel-h + strip-h),
        strip-text,
        style,
        theme,
      )
      let panel-trained = if panel-trained-list.len() == 0 {
        trained
      } else { panel-trained-list.at(i) }
      let (inner-w, inner-h) = _fixed-inner-size(
        coord,
        panel-trained,
        panel-w,
        panel-h,
      )
      let inner-y0 = y0 + (panel-h - inner-h)
      let _pe = if panel-extents != none {
        panel-extents.at(i)
      } else {
        (
          x: x-extents,
          y: y-extents,
          x-sec: x-sec-extents,
          y-sec: y-sec-extents,
        )
      }
      _draw-axis-and-layers(
        panel-layers,
        panel-trained,
        theme,
        spec,
        (x0, inner-y0),
        (inner-w, inner-h),
        // `i + ncol >= n`: no panel sits below this one, so it owns the
        // bottom x axis even if its row isn't the geometric last row
        // (trailing empty slots in a partial wrap).
        show-x-labels: free-x or all-x or i + ncol >= n,
        show-y-labels: free-y or all-y or col == 0,
        show-x-title: false,
        show-y-title: false,
        show-x-sec: free-x or all-x or row == 0,
        show-y-sec: free-y or all-y or col == ncol - 1,
        flipped: _is-flipped(coord),
        axis-breaks: shared-breaks,
        x-extents: _pe.x,
        y-extents: _pe.y,
        x-sec-extents: _pe.x-sec,
        y-sec-extents: _pe.y-sec,
        canvas-w: width-units,
        canvas-h: height-units,
      )
    }

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let _map-name(axis) = if spec.mapping == none { none } else {
      mapping-display-name(spec.mapping.at(axis, default: none))
    }
    let x-title = _axis-title(x-trained, _map-name("x"))
    let y-title = _axis-title(y-trained, _map-name("y"))
    let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
    let _tick-len = _per-side(_len-side, "tick-length")
    let _xlbl-depth = _x-label-depth(0, 1, x-extents.width, x-extents.height)
    let _ylbl-width = _y-label-width(0, 1, y-extents.width, y-extents.height)
    let _xt-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
    let _yt-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
    let _xt-cm = _ax-text-cm(_ax-title.xb.size)
    let _yt-cm = _ax-text-cm(_ax-title.yl.size)
    if x-title != none and _ax-title.xb.size > 0pt {
      content(
        (
          margin.left + grid-w / 2,
          margin.bottom - _tick-len.xb - 0.1 - _xlbl-depth - _xt-gap - _xt-cm,
        ),
        text(
          size: _ax-title.xb.size,
          fill: _ax-title.xb.fill,
          weight: _ax-title.xb.weight,
        )[#resolve-prose(x-title, eval-strings: _ax-title.xb.typst)],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.yl.size > 0pt {
      content(
        (
          margin.left - _tick-len.yl - 0.1 - _ylbl-width - _yt-gap - _yt-cm / 2,
          margin.bottom + grid-h / 2,
        ),
        text(
          size: _ax-title.yl.size,
          fill: _ax-title.yl.fill,
          weight: _ax-title.yl.weight,
        )[#resolve-prose(y-title, eval-strings: _ax-title.yl.typst)],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
        canvas-w: width-units,
        canvas-h: height-units,
      )
      legend-mod.draw(
        guides,
        lctx,
        panel-rect: (
          x: margin.left,
          y: margin.bottom,
          w: grid-w,
          h: grid-h,
        ),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        sec-x-extent: sec-x-extent,
        right-strip: 0.0,
        theme: theme,
      )
    }
  })
}

#let _render-canvas-grid(ctx) = {
  let spec = ctx.spec
  let theme = ctx.theme
  let coord = ctx.coord
  let trained = ctx.trained
  let panels = ctx.panels
  let grid-row-levels = ctx.grid-row-levels
  let grid-col-levels = ctx.grid-col-levels
  let guides = ctx.guides
  let legend-gap = ctx.legend-gap
  let sec-y-extent = ctx.sec-y-extent
  let sec-x-extent = ctx.sec-x-extent
  let margin = ctx.margin
  let width-units = ctx.width-units
  let height-units = ctx.height-units
  let style = ctx.style
  let _ax-title = style.ax-title
  let x-extents = ctx.x-extents
  let y-extents = ctx.y-extents
  let x-sec-extents = ctx.x-sec-extents
  let y-sec-extents = ctx.y-sec-extents

  let row-var = spec.facet.rows
  let col-var = spec.facet.columns
  let row-levels = grid-row-levels
  let col-levels = grid-col-levels
  let n-rows = calc.max(1, row-levels.len())
  let n-cols = calc.max(1, col-levels.len())
  let _grid-labeller = spec.facet.at("labeller", default: none)
  let _col-count(c) = {
    let n = 0
    for r in range(n-rows) {
      n += _panel-row-count(panels.at(r * n-cols + c).layers)
    }
    n
  }
  let _row-count(r) = {
    let n = 0
    for c in range(n-cols) {
      n += _panel-row-count(panels.at(r * n-cols + c).layers)
    }
    n
  }
  let col-strip-texts = if col-var == none { () } else {
    _strip-texts(_grid-labeller, col-var, col-levels, _col-count)
  }
  let row-strip-texts = if row-var == none { () } else {
    _strip-texts(_grid-labeller, row-var, row-levels, _row-count)
  }
  let strip-h = _strip-band(col-strip-texts, style, 0.45)
  let strip-w = _strip-band(row-strip-texts, style, 0.55)
  let gutter-x = 0.3
  let gutter-y = 0.3
  let top-strip = if col-var != none { strip-h } else { 0.0 }
  let right-strip = if row-var != none { strip-w } else { 0.0 }
  let inner-right = margin.right + right-strip
  let grid-w = width-units - margin.left - inner-right
  let grid-h = height-units - margin.bottom - margin.top - top-strip
  let panel-w = (grid-w - gutter-x * (n-cols - 1)) / n-cols
  let panel-h = (grid-h - gutter-y * (n-rows - 1)) / n-rows

  let shared-breaks = _shared-axis-breaks(trained)

  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    for (r, row-lv) in row-levels.enumerate() {
      for (c, col-lv) in col-levels.enumerate() {
        let x0 = margin.left + c * (panel-w + gutter-x)
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        let panel-layers = panels.at(r * n-cols + c).layers
        let (inner-w, inner-h) = _fixed-inner-size(
          coord,
          trained,
          panel-w,
          panel-h,
        )
        let inner-y0 = y0 + (panel-h - inner-h)
        _draw-axis-and-layers(
          panel-layers,
          trained,
          theme,
          spec,
          (x0, inner-y0),
          (inner-w, inner-h),
          show-x-labels: r == n-rows - 1,
          show-y-labels: c == 0,
          show-x-title: false,
          show-y-title: false,
          show-x-sec: r == 0,
          show-y-sec: c == n-cols - 1,
          flipped: _is-flipped(coord),
          axis-breaks: shared-breaks,
          x-extents: x-extents,
          y-extents: y-extents,
          x-sec-extents: x-sec-extents,
          y-sec-extents: y-sec-extents,
          canvas-w: width-units,
          canvas-h: height-units,
        )
      }
    }

    if col-var != none {
      let strip-y = margin.bottom + grid-h
      for c in range(col-levels.len()) {
        let x0 = margin.left + c * (panel-w + gutter-x)
        _draw-strip(
          (x0, strip-y),
          (x0 + panel-w, strip-y + top-strip),
          col-strip-texts.at(c),
          style,
          theme,
        )
      }
    }

    if row-var != none {
      let strip-x = margin.left + grid-w
      for r in range(row-levels.len()) {
        let y0 = margin.bottom + (n-rows - 1 - r) * (panel-h + gutter-y)
        _draw-strip(
          (strip-x, y0),
          (strip-x + right-strip, y0 + panel-h),
          row-strip-texts.at(r),
          style,
          theme,
          angle: -90deg,
        )
      }
    }

    let x-trained = trained.at("x", default: none)
    let y-trained = trained.at("y", default: none)
    let _map-name(axis) = if spec.mapping == none { none } else {
      mapping-display-name(spec.mapping.at(axis, default: none))
    }
    let x-title = _axis-title(x-trained, _map-name("x"))
    let y-title = _axis-title(y-trained, _map-name("y"))
    let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
    let _tick-len = _per-side(_len-side, "tick-length")
    let _xlbl-depth = _x-label-depth(0, 1, x-extents.width, x-extents.height)
    let _ylbl-width = _y-label-width(0, 1, y-extents.width, y-extents.height)
    let _xt-gap = _text-margin-cm(_ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
    let _yt-gap = _text-margin-cm(_ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
    let _xt-cm = _ax-text-cm(_ax-title.xb.size)
    let _yt-cm = _ax-text-cm(_ax-title.yl.size)
    if x-title != none and _ax-title.xb.size > 0pt {
      content(
        (
          margin.left + grid-w / 2,
          margin.bottom - _tick-len.xb - 0.1 - _xlbl-depth - _xt-gap - _xt-cm,
        ),
        text(
          size: _ax-title.xb.size,
          fill: _ax-title.xb.fill,
          weight: _ax-title.xb.weight,
        )[#resolve-prose(x-title, eval-strings: _ax-title.xb.typst)],
        anchor: "south",
      )
    }
    if y-title != none and _ax-title.yl.size > 0pt {
      content(
        (
          margin.left - _tick-len.yl - 0.1 - _ylbl-width - _yt-gap - _yt-cm / 2,
          margin.bottom + grid-h / 2,
        ),
        text(
          size: _ax-title.yl.size,
          fill: _ax-title.yl.fill,
          weight: _ax-title.yl.weight,
        )[#resolve-prose(y-title, eval-strings: _ax-title.yl.typst)],
        angle: 90deg,
      )
    }

    if guides.len() > 0 {
      let lctx = (
        trained: trained,
        palette: default-discrete,
        theme: theme,
        canvas-w: width-units,
        canvas-h: height-units,
      )
      legend-mod.draw(
        guides,
        lctx,
        panel-rect: (
          x: margin.left,
          y: margin.bottom,
          w: grid-w,
          h: grid-h,
        ),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        right-strip: right-strip,
        top-strip: top-strip,
        theme: theme,
      )
    }
  })
}

#let _render-canvas-single(
  spec,
  theme,
  trained,
  prepared,
  coord,
  guides,
  legend-gap,
  sec-y-extent,
  sec-x-extent,
  margin,
  width-units,
  height-units,
  x-extents,
  y-extents,
  x-sec-extents,
  y-sec-extents,
) = {
  let px-lo = margin.left
  let px-hi = width-units - margin.right
  let py-lo = margin.bottom
  let py-hi = height-units - margin.top

  let box-w = px-hi - px-lo
  let box-h = py-hi - py-lo
  let (inner-w, inner-h) = _fixed-inner-size(coord, trained, box-w, box-h)

  cetz.canvas(length: 1cm, {
    import cetz.draw: hide, rect
    hide(rect((0, 0), (width-units, height-units)), bounds: true)
    _draw-axis-and-layers(
      prepared,
      trained,
      theme,
      spec,
      (px-lo, py-lo),
      (inner-w, inner-h),
      guides: guides,
      legend-args: (
        panel-rect: (x: px-lo, y: py-lo, w: inner-w, h: inner-h),
        margin: margin,
        legend-gap: legend-gap,
        sec-y-extent: sec-y-extent,
        sec-x-extent: sec-x-extent,
        right-strip: 0.0,
      ),
      flipped: _is-flipped(coord),
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
      canvas-w: width-units,
      canvas-h: height-units,
    )
  })
}

// Resolve a `margin(...)` record into a four-side dict of absolute Typst
// cm lengths. Per-side `%` / `relative` values are resolved against the
// canvas dims (`ref-w` for horizontal sides, `ref-h` for vertical), so
// plot-background's `pad()` / `block(inset:)` agree with the cetz rect
// surfaces on what `100%` means (the plot canvas, not the surrounding
// Typst block).
#let _margin-lengths(rec, ref-w, ref-h, size-pt) = (
  top: resolve-margin-side-rel-cm(rec.top, ref-h, size-pt: size-pt) * 1cm,
  right: resolve-margin-side-rel-cm(rec.right, ref-w, size-pt: size-pt) * 1cm,
  bottom: resolve-margin-side-rel-cm(rec.bottom, ref-h, size-pt: size-pt) * 1cm,
  left: resolve-margin-side-rel-cm(rec.left, ref-w, size-pt: size-pt) * 1cm,
)

#let _render-decorate(canvas, labs, theme, canvas-w, canvas-h) = {
  let plot-bg = _rect-style(
    theme,
    "plot-background",
    inset-ref-w: canvas-w,
    inset-ref-h: canvas-h,
    outset-ref-w: canvas-w,
    outset-ref-h: canvas-h,
  )
  // `inset` grows the fill past the content via Typst `block(inset: ...)`
  // (inner padding); `outset` reserves whitespace around the block by
  // wrapping it in an outer `pad(...)` (outer margin).
  let _size-pt = if (
    type(theme.at("text", default: none)) == dictionary
      and theme.text.at("size", default: none) != none
  ) { theme.text.size / 1pt } else { 9 }
  let outer-pad = _margin-lengths(plot-bg.outset, canvas-w, canvas-h, _size-pt)
  let inner-inset = _margin-lengths(plot-bg.inset, canvas-w, canvas-h, _size-pt)
  let _nonzero(d) = (
    d.top != 0pt or d.right != 0pt or d.bottom != 0pt or d.left != 0pt
  )
  let _wrap(content) = if (
    plot-bg.fill != none
      or plot-bg.stroke != none
      or _nonzero(inner-inset)
      or _nonzero(outer-pad)
  ) {
    pad(
      top: outer-pad.top,
      right: outer-pad.right,
      bottom: outer-pad.bottom,
      left: outer-pad.left,
      block(
        fill: plot-bg.fill,
        stroke: plot-bg.stroke,
        breakable: false,
        inset: inner-inset,
        content,
      ),
    )
  } else { content }
  if labs == none { return _wrap(canvas) }
  let title = _text-style(theme, "plot-title")
  let subtitle = _text-style(theme, "plot-subtitle")
  let caption = _text-style(theme, "plot-caption")
  let title-block = if labs.title != none {
    text(
      size: title.size,
      weight: title.weight,
      fill: title.fill,
    )[#resolve-prose(labs.title, eval-strings: title.typst)]
  } else { none }
  let subtitle-block = if labs.subtitle != none {
    text(
      size: subtitle.size,
      fill: subtitle.fill,
    )[#resolve-prose(labs.subtitle, eval-strings: subtitle.typst)]
  } else { none }
  let caption-block = if labs.caption != none {
    text(
      size: caption.size,
      fill: caption.fill,
      style: "italic",
    )[#resolve-prose(labs.caption, eval-strings: caption.typst)]
  } else { none }

  // Multiplied by 1cm so the resolved em is baked in against the upstream
  // text style, not re-resolved against the surrounding document font size.
  let _gap-length(style, side) = {
    _text-margin-cm(style, side, 0.6em) * 1cm
  }

  let above-canvas = if subtitle-block != none {
    subtitle
  } else if title-block != none { title } else { none }

  let items = ()
  if title-block != none { items.push(title-block) }
  if subtitle-block != none {
    if items.len() > 0 { items.push(v(_gap-length(title, "bottom"))) }
    items.push(subtitle-block)
  }
  if above-canvas != none {
    items.push(v(_gap-length(above-canvas, "bottom")))
  }
  items.push(canvas)
  if caption-block != none {
    items.push(v(_gap-length(caption, "top")))
    items.push(caption-block)
  }
  if items.len() == 1 { return _wrap(canvas) }
  _wrap(block(stack(dir: ttb, spacing: 0pt, ..items)))
}

#let render-plot-deferred(spec, suppress-aesthetics: (), tight-sides: ()) = {
  let user-theme = if spec.theme != none { spec.theme } else {
    _theme-state.get()
  }
  let theme = merge-theme(user-theme)
  let labs = spec.at("labs", default: none)

  // Canvas dims known up-front from `spec.width` / `spec.height`; cetz
  // draw sites resolve their own rect `%` insets against per-rect natural
  // dims, but layout-time `outset` reservation references the canvas.
  let width-units-early = spec.width / 1cm
  let height-units-early = spec.height / 1cm
  let style = _render-style(theme)

  let spec = _preprocess-data(spec)

  // Faceted plots prepare layers per panel so stats (smooth, bin, count) fit
  // each panel's own row subset, following grammar-of-graphics semantics.
  let prep = _render-prepare(spec, theme)
  let facet-wrap-mode = prep.facet-wrap-mode
  let facet-grid-mode = prep.facet-grid-mode
  let wrap-levels = prep.wrap-levels
  let grid-row-levels = prep.grid-row-levels
  let grid-col-levels = prep.grid-col-levels
  let panels = prep.panels
  let prepared = prep.prepared

  let trained = train(
    scales: spec.scales,
    layers: prepared,
    mapping: spec.mapping,
    data: spec.data,
  )
  trained = _apply-labs(trained, labs)

  // Once training is done, mapping-ref annotations have served their purpose;
  // flatten them so geoms receive plain column names.
  prepared = prepared.map(l => {
    let new = l
    new.mapping = _strip-mapping-refs(l.mapping)
    new
  })
  panels = panels.map(p => {
    let new = p
    new.layers = p.layers.map(l => {
      let ll = l
      ll.mapping = _strip-mapping-refs(l.mapping)
      ll
    })
    new
  })

  // Faceted plots render the per-panel copies under `panels`; single plots
  // render `prepared` directly. Only the path that the canvas dispatch will
  // touch needs label sizes.
  if facet-wrap-mode or facet-grid-mode {
    panels = panels.map(p => {
      let new = p
      new.layers = p.layers.map(_measure-label-sizes)
      new
    })
  } else {
    prepared = prepared.map(_measure-label-sizes)
  }

  trained = _post-train(trained, prepared)

  // coord-cartesian zooms the view: override trained domains with the user's
  // clip limits so axis ticks and marks follow them. Data outside the limits
  // is preserved for stats and training but may render outside the panel.
  let coord = spec.at("coord", default: none)
  trained = _apply-coord-transform(trained, coord)
  trained = _apply-expand(trained, coord)
  trained = _apply-coord(trained, coord)
  // coord-flip swaps trained x and y so axis labels swap automatically;
  // direction-sensitive geoms branch on `ctx.flipped` inside their draw.
  trained = _apply-flip(trained, coord)

  // Drop (or clamp under `oob: "squish"`) rows whose value falls outside any
  // user-supplied scale `limits`. Runs after training so the trained domain
  // is the rendered cutoff; before per-panel re-train so panel scales see
  // the filtered subset.
  let strict = spec.at("strict", default: false)
  let oob-pass = filter-oob(prepared, trained, strict: strict)
  prepared = oob-pass.layers
  if facet-wrap-mode or facet-grid-mode {
    panels = panels.map(p => {
      let pass = filter-oob(p.layers, trained, strict: strict)
      let new = p
      new.layers = pass.layers
      new
    })
  }

  // For facet-wrap with non-fixed scales, train each panel's positional axes
  // on its own subset so x and/or y differ across panels. Non-positional
  // scales (colour, fill, size, shape, linetype) stay shared so legends do
  // not fragment.
  let wrap-scales = if facet-wrap-mode { spec.facet.scales } else { "fixed" }
  let free-x = (
    facet-wrap-mode
      and (
        wrap-scales == "free" or wrap-scales == "free_x"
      )
  )
  let free-y = (
    facet-wrap-mode
      and (
        wrap-scales == "free" or wrap-scales == "free_y"
      )
  )
  let panel-trained-list = _train-panels(
    spec,
    panels,
    trained,
    coord,
    labs,
    free-x,
    free-y,
  )

  let width-units = width-units-early
  let height-units = height-units-early

  // Legend-text font size drives every label-width / line-height
  // measurement done inside `guides-for`.
  let _legend-size-pt = _text-style(theme, "legend-text").size / 1pt
  // Custom guides lack `aesthetics`; default keeps them unsuppressed.
  let guides = legend-mod
    .guides-for(spec, trained, size-pt: _legend-size-pt)
    .filter(g => {
      let aes = g.at("aesthetics", default: ())
      not aes.any(a => suppress-aesthetics.contains(a))
    })
  let extents = legend-mod.estimate-extents(guides)
  let any-legend = (
    extents.top > 0
      or extents.right > 0
      or extents.bottom > 0
      or extents.left > 0
      or extents.inside.len() > 0
  )
  let legend-title-style = _text-style(theme, "legend-title")
  let legend-gap = if any-legend {
    _text-margin-cm(legend-title-style, "left", 1.6em)
  } else { 0.0 }

  let x-trained-top = trained.at("x", default: none)
  let y-trained-top = trained.at("y", default: none)
  let x-sec = _sec-spec(x-trained-top)
  let y-sec = _sec-spec(y-trained-top)
  let _surface-style = (p, s, _) => _text-style(theme, p + "-" + s)
  let _len-side = (p, s, a) => _scalar-cascade(theme, p, s, a) / 1cm
  let tick-len = _per-side(_len-side, "tick-length")
  let ax-text = _per-side(_surface-style, "axis-text")
  let ax-title = _per-side(_surface-style, "axis-title")

  let x-extents = _axis-label-extents(
    x-trained-top,
    ax-text.xb.size,
    typst-eval: ax-text.xb.typst,
  )
  let y-extents = _axis-label-extents(
    y-trained-top,
    ax-text.yl.size,
    typst-eval: ax-text.yl.typst,
  )
  let x-sec-extents = _secondary-label-extents(
    x-trained-top,
    x-sec,
    ax-text.xt.size,
    typst-eval: ax-text.xt.typst,
  )
  let y-sec-extents = _secondary-label-extents(
    y-trained-top,
    y-sec,
    ax-text.yr.size,
    typst-eval: ax-text.yr.typst,
  )

  let sec-x-extent = _sec-extent(
    x-sec,
    tick-len.xt,
    x-sec-extents,
    ax-title.xt,
    "x",
  )
  let sec-y-extent = _sec-extent(
    y-sec,
    tick-len.yr,
    y-sec-extents,
    ax-title.yr,
    "y",
  )

  let x-guide = _read-axis-guide(spec, "x")
  let y-guide = _read-axis-guide(spec, "y")
  // Themes that disable tick labels (`theme-void`) reserve no perpendicular
  // depth for them; otherwise the chrome margin reserves space for ink that
  // never draws, inverting the panel rect on small plot sizes.
  let labels-on = theme.at("tick-labels", default: true)
  let x-label-depth = if labels-on {
    _x-label-depth-stack(x-guide, x-extents.width, x-extents.height)
  } else { 0.0 }
  let y-label-width = if labels-on {
    _y-label-width-stack(y-guide, y-extents.width, y-extents.height)
  } else { 0.0 }
  // Only reserve the title-to-label gap when a title actually renders;
  // a `0pt` axis title (e.g., `theme-void`) needs no gap, and the absolute
  // `_AX-TITLE-LABEL-GAP` would otherwise tip `bottom-extent` over the floor
  // threshold and invert the panel rect on short plots.
  let bottom-gap = if ax-title.xb.size > 0pt {
    _text-margin-cm(ax-title.xb, "top", _AX-TITLE-LABEL-GAP)
  } else { 0.0 }
  let left-gap = if ax-title.yl.size > 0pt {
    _text-margin-cm(ax-title.yl, "right", _AX-TITLE-LABEL-GAP)
  } else { 0.0 }
  let x-title-cm = _ax-text-cm(ax-title.xb.size)
  let y-title-cm = _ax-text-cm(ax-title.yl.size)
  let bottom-extent = (
    tick-len.xb + 0.1 + x-label-depth + bottom-gap + x-title-cm + 0.05
  )
  let left-extent = (
    tick-len.yl + 0.1 + y-label-width + left-gap + y-title-cm
  )

  // Cap the right margin so the legend can never push panel width below the
  // single-tick minimum. Without the cap, `px-hi - px-lo` goes negative and
  // axis labels render reversed (panel becomes mirror-imaged into the legend).
  let max-right-margin = calc.max(0.0, width-units - left-extent - 0.5)
  let _side-gap = side => (
    extents.at(side) + (if extents.at(side) > 0 { legend-gap } else { 0.0 })
  )
  // `tight-sides` lets `compose()` skip the conservative floors (1.5 cm /
  // 1.1 cm) on the side it hoists the shared legend to, so the panel butts
  // against the legend instead of carrying ~0.5 cm of unused axis-title slack.
  // Themes that strip axis decoration (e.g., `theme-void`) leave the
  // computed extent at ~0.15 cm; the floor would then exceed small plot
  // heights/widths and invert the panel rect. Drop the floor when the
  // computed extent is below ~0.3 cm (no meaningful axis content to clear).
  let bottom-floor = if bottom-extent > 0.3 { 1.1 } else { 0.0 }
  let left-floor = 0.0
  let _floor(side, floor, computed) = if tight-sides.contains(side) {
    computed
  } else { calc.max(floor, computed) }
  // Themed `outset` on rect surfaces reserves outer whitespace by widening
  // the chrome slot on each side; the panel canvas absorbs the diff.
  // `strip-background` is the facet decoration band itself, so its `inset`
  // and `outset` are ignored (no chrome reservation, no rect growth).
  // For every legend on side S, all four `outset` sides feed chrome
  // reservation: slot-axis sides (S and its opposite) inflate `margin.S`
  // -- the opposite side (panel-facing) is also mirrored into
  // `legend-gap` so the visible gap between panel and legend grows;
  // perpendicular sides inflate the matching `margin.{perpendicular}`.
  let any-bar = guides.any(g => g.kind == "colourbar")
  let panel-out = _rect-outset-cm(
    theme,
    "panel-background",
    ref-w: width-units,
    ref-h: height-units,
  )
  let legend-out = _rect-outset-cm(
    theme,
    "legend-background",
    ref-w: width-units,
    ref-h: height-units,
  )
  let bar-out = if any-bar {
    _rect-outset-cm(
      theme,
      "legend-bar",
      ref-w: width-units,
      ref-h: height-units,
    )
  } else { (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0) }
  // For every active legend on side `leg-side`, the slot-axis outset
  // sides (leg-side + its opposite) sum into `margin.{leg-side}`; the
  // perpendicular sides feed `margin.{perpendicular}`. Fold once into a
  // four-side dict so `_surface-out` is a flat read.
  let _by-margin-side(out) = {
    let acc = (top: 0.0, right: 0.0, bottom: 0.0, left: 0.0)
    for leg-side in ("top", "right", "bottom", "left") {
      if extents.at(leg-side) <= 0 { continue }
      acc.insert(
        leg-side,
        acc.at(leg-side)
          + out.at(leg-side)
          + out.at(opposite-side.at(leg-side)),
      )
      for perp in perpendicular-sides.at(leg-side) {
        acc.insert(perp, acc.at(perp) + out.at(perp))
      }
    }
    acc
  }
  let legend-by-side = _by-margin-side(legend-out)
  let bar-by-side = _by-margin-side(bar-out)
  let _surface-out(side) = (
    panel-out.at(side) + legend-by-side.at(side) + bar-by-side.at(side)
  )
  let margin = (
    left: _floor("left", left-floor, left-extent + _side-gap("left"))
      + _surface-out("left"),
    bottom: _floor("bottom", bottom-floor, bottom-extent + _side-gap("bottom"))
      + _surface-out("bottom"),
    top: 0.3 + sec-x-extent + _side-gap("top") + _surface-out("top"),
    right: calc.min(
      0.3 + sec-y-extent + _side-gap("right") + _surface-out("right"),
      max-right-margin,
    ),
  )

  let canvas = if facet-wrap-mode {
    _render-canvas-wrap((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      panel-trained-list: panel-trained-list,
      wrap-levels: wrap-levels,
      guides: guides,
      legend-gap: legend-gap,
      sec-y-extent: sec-y-extent,
      sec-x-extent: sec-x-extent,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      free-x: free-x,
      free-y: free-y,
      style: style,
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
      ax-text: ax-text,
    ))
  } else if facet-grid-mode {
    _render-canvas-grid((
      spec: spec,
      theme: theme,
      coord: coord,
      trained: trained,
      panels: panels,
      grid-row-levels: grid-row-levels,
      grid-col-levels: grid-col-levels,
      guides: guides,
      legend-gap: legend-gap,
      sec-y-extent: sec-y-extent,
      sec-x-extent: sec-x-extent,
      margin: margin,
      width-units: width-units,
      height-units: height-units,
      style: style,
      x-extents: x-extents,
      y-extents: y-extents,
      x-sec-extents: x-sec-extents,
      y-sec-extents: y-sec-extents,
    ))
  } else {
    _render-canvas-single(
      spec,
      theme,
      trained,
      prepared,
      coord,
      guides,
      legend-gap,
      sec-y-extent,
      sec-x-extent,
      margin,
      width-units,
      height-units,
      x-extents,
      y-extents,
      x-sec-extents,
      y-sec-extents,
    )
  }

  (
    content: _render-decorate(canvas, labs, theme, width-units, height-units),
    guides: guides,
    trained: trained,
  )
}

#let render-plot(spec) = render-plot-deferred(spec).content
