// Per-layer preparation: resolve `from-theme`, apply stat then position, and
// evaluate the late-binding lanes, yielding a draw-ready layer.

#import "../geom/registry.typ": GEOMS
#import "../scale/train.typ": all-aesthetics, positional-aesthetics
#import "../stat/apply.typ": apply-stat, resolve-stat-spec, setup-stat
#import "../utils/errors.typ": fail-enum
#import "../stat/info.typ": stat-info
#import "../position/apply.typ": apply-position, position-name-of
#import "../utils/aes-resolve.typ": merge-mapping
#import "../utils/late-binding.typ": (
  apply-stages, eval-after-stat, late-binding-kind, resolve-from-theme,
  stash-stages,
)
#import "../utils/group.typ": (
  expose-shared-positional, group-aesthetics, group-cols, partition-by-group,
)
#import "../theme/theme.typ": resolve-theme-palette
#import "../utils/typst-markup.typ": is-typst-markup, typst
#import "../data.typ": _mapping-ref
#import "common.typ": _resolve-data, _strip-mapping-refs, _typst-marks-of
#import "prestat.typ": _rewrite-factor-cols, layer-discrete

// `from-theme` resolves to a literal scalar that we write into
// `layer.params.<channel>` so per-row resolvers honour it through their
// existing pinned-param paths. Positional aesthetics (x/y and synthetic
// feeders) have no fixed-value param to write to, hence the exclusion.
#let _FROM-THEME-PARAM-CHANNELS = all-aesthetics.filter(a => (
  not positional-aesthetics.contains(a)
))

// Positions that numerically offset a positional value, so a discrete
// positional column must first be rewritten to its numeric level spine. The
// remaining non-identity positions (`dodge`, `stack`, `fill`) leave x
// categorical and are excluded.
#let _NUMERIC-OFFSET-POSITIONS = ("jitter", "beeswarm", "jitterdodge", "nudge")

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
      fail-enum(
        "from-theme",
        "channel",
        channel,
        _FROM-THEME-PARAM-CHANNELS,
      )
    }
    params.insert(channel, resolve-from-theme(theme, value.path))
    new-mapping.insert(channel, none)
  }
  let new-layer = layer
  new-layer.insert("params", params)
  (layer: new-layer, mapping: new-mapping)
}

// Run a non-identity stat: split by discrete-aesthetic groups, apply the
// stat to each group independently, then recombine. A panel-level setup
// pass first lets binning stats compute a shared partition over the full
// data so groups end up on the same bin grid. Returns the stat output rows
// and mapping.
#let _stat-pass(resolved-stat, data, mapping, stripped, discrete) = {
  let stat-name = resolved-stat.name
  let resolved-params = setup-stat(
    stat-name,
    data,
    stripped,
    resolved-stat.params,
  )
  resolved-params.insert("discrete", discrete)
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
    // Pushed, not concatenated: rebinding `combined = combined + enriched`
    // copies everything gathered so far on every group.
    combined.push(enriched)
  }
  combined = combined.flatten()
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
  // Expose a positional column reused by a grouping aesthetic (e.g. fill ==
  // x) under its source name; `group-cols` cannot re-inject an x/y column.
  combined = expose-shared-positional(combined, mapping, last-mapping)
  (data: combined, mapping: last-mapping)
}

// `(col, order)` for the first of `fill` and `colour` that is mapped and has a
// discrete user scale with explicit `limits`, or `none`. Positions run before
// scales are trained, so they read the user spec here. `col` is the aesthetic's
// column, which the stack sort reads because the group key joins every
// grouping aesthetic.
#let _group-limits(mapping, user-scales) = {
  let plain = _strip-mapping-refs(mapping)
  for aes-name in ("fill", "colour") {
    let col = plain.at(aes-name, default: none)
    let user = user-scales.at(aes-name, default: none)
    if type(col) != str or user == none { continue }
    let order = user.at("limits", default: none)
    if user.at("type", default: none) == "discrete" and order != none {
      return (col: col, order: order)
    }
  }
  none
}

#let _prepare-layer(
  layer,
  plot-mapping,
  plot-data,
  theme: none,
  coord: none,
  stat-override: none,
  user-scales: (:),
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
  let resolved-stat = resolve-stat-spec(stat-spec, params)
  let stat-name = resolved-stat.name
  let stat-params = resolved-stat.params
  let stripped = _strip-mapping-refs(mapping)

  let stat-identity = stat-name == none or stat-name == "identity"
  let stat-data = data
  let stat-mapping = if stat-identity { mapping } else { stripped }
  if stat-override != none {
    // A caller (see `prepare-layers`) already ran this layer's stat pass
    // for an identical (stat, data, mapping) sibling; reuse its output.
    stat-data = stat-override.data
    stat-mapping = stat-override.mapping
  } else if not stat-identity {
    let pass = _stat-pass(
      (name: stat-name, params: stat-params),
      data,
      mapping,
      stripped,
      layer-discrete(mapping, data, user-scales),
    )
    stat-data = pass.data
    stat-mapping = pass.mapping
  }

  // Resolve `after-stat` markers now that the stat has run; downstream
  // (position, train, geom draw) only sees real column names.
  let after-ctx = (
    theme: theme,
    palette: resolve-theme-palette(theme),
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
  position-params.insert(
    "discrete",
    layer-discrete(stat-mapping, stat-data, user-scales),
  )
  if position-name == "stack" or position-name == "fill" {
    let levels = _group-limits(stat-mapping, user-scales)
    if levels != none {
      position-params.insert("levels", levels)
    }
  }
  let pos-data = stat-data
  let pos-mapping = stat-mapping
  let factor-levels = (:)
  if position-name != none and position-name != "identity" {
    // Rewrite discrete positional columns to 1-indexed level positions before
    // the position adjusts them, so offsetting positions operate in numeric
    // space without exploding the discrete domain. Only positions that
    // numerically shift a positional value need this; `dodge`/`stack`/`fill`
    // keep x categorical (they annotate rows or stack y), and rewriting their
    // x would turn a plain string category into a synthetic column the bar
    // domain scan cannot read. See `_rewrite-factor-cols` for the rationale.
    let rewritten = if _NUMERIC-OFFSET-POSITIONS.contains(position-name) {
      _rewrite-factor-cols(stat-mapping, stat-data)
    } else {
      (data: stat-data, factor-levels: (:), repoint: (:))
    }
    factor-levels = rewritten.factor-levels
    // `_rewrite-factor-cols` wrote the 1-indexed positions to synthetic
    // columns; repoint the positional mapping entries to them so positions,
    // training, and the geom draw all read the numeric spine, while any other
    // aesthetic mapped to the same source column keeps reading its raw levels.
    let repoint = rewritten.repoint
    // Position needs plain column names; strip again in case stat-identity
    // left annotations in place.
    let pos-in = _strip-mapping-refs(stat-mapping)
    for (axis, pos-col) in repoint {
      pos-in.insert(axis, pos-col)
    }
    if position-name == "beeswarm" {
      position-params.insert("discrete-axes", repoint.keys())
    }
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
    // Repoint x/y to the synthetic position column, forcing the discrete type
    // so training keeps the level domain (from `_factor-levels`) and
    // `map-discrete` reads the offset floats as fractional level positions.
    // Preserve a `typst(...)` wrapper on the axis so its ticks still render as
    // Typst markup.
    for (axis, pos-col) in repoint {
      let ref = _mapping-ref(pos-col, "discrete")
      if is-typst-markup(stat-mapping.at(axis, default: none)) {
        ref = typst(ref)
      }
      merged.insert(axis, ref)
    }
    pos-mapping = merged
  }

  let new = layer
  new.data = pos-data
  // The rows leaving this stage are canonical: they came out of the stat and
  // the position passes, both of which read a normalised source. Saying so
  // keeps every geom `draw` from validating the same rows a second time, which
  // the faceted path has always avoided by the same flag.
  new.insert("data-trusted", true)
  new.mapping = pos-mapping
  new.inherit-aes = false
  // A layer with its own data trains only the aesthetics its geom reads, so a
  // plot-level `x` that this data lacks does not turn the axis discrete. A
  // layer on the plot data keeps training them all, and so does a geom that
  // reads nothing: `geom-blank()` and `geom-function()` set the axes from
  // aesthetics they do not draw.
  let geom = GEOMS.at(str(layer.name), default: none)
  if geom != none and layer.data != none and geom.spec.reads.len() > 0 {
    new.insert("reads", geom.spec.reads)
  }
  new.typst-marks = _typst-marks-of(mapping)
  if factor-levels.len() > 0 {
    new.insert("_factor-levels", factor-levels)
  }
  // The stat has run, so the layer reads as identity from here on;
  // `stat-source` keeps the name for the stat's renderer-facing flags.
  if not stat-identity {
    new.insert("stat-source", stat-name)
    new.stat = "identity"
  }
  new
}

// Run only the stat stage for a layer, mirroring `_prepare-layer`'s pre-stat
// pipeline (from-theme resolution, stage stash, data resolution). Feeds the
// `stat-override` fast path below; keep the two preambles in sync.
#let _layer-stat(
  layer,
  plot-mapping,
  plot-data,
  theme: none,
  user-scales: (:),
) = {
  let mapping = merge-mapping(layer, plot-mapping)
  if theme != none {
    let resolved = _apply-from-theme(layer, mapping, theme)
    layer = resolved.layer
    mapping = resolved.mapping
  }
  let mapping = stash-stages(mapping).mapping
  let data = _resolve-data(layer, plot-data)
  let resolved-stat = resolve-stat-spec(
    layer.at("stat", default: "identity"),
    layer.at("params", default: (:)),
  )
  _stat-pass(
    resolved-stat,
    data,
    mapping,
    _strip-mapping-refs(mapping),
    layer-discrete(mapping, data, user-scales),
  )
}

// Prepare a list of layers, running a non-identity stat once per unique
// (resolved stat, layer data, merged mapping) triple: a geom-line +
// geom-ribbon pair over the same `stat-summary(fun: "mean-cl-boot")`
// bootstraps once instead of once per layer. Keys compare structurally;
// closure-valued stat params compare by identity, so sharing only happens
// within one constructed stat object.
#let prepare-layers(
  layers,
  plot-mapping,
  plot-data,
  theme: none,
  coord: none,
  user-scales: (:),
) = {
  let memo = ()
  let out = ()
  for layer in layers {
    let resolved = resolve-stat-spec(
      layer.at("stat", default: "identity"),
      layer.at("params", default: (:)),
    )
    let override = none
    if resolved.name != none and resolved.name != "identity" {
      let key = (
        stat: resolved,
        data: layer.at("data", default: none),
        mapping: merge-mapping(layer, plot-mapping),
      )
      let hit = memo.find(e => e.key == key)
      if hit != none { override = hit.value } else {
        override = _layer-stat(
          layer,
          plot-mapping,
          plot-data,
          theme: theme,
          user-scales: user-scales,
        )
        memo.push((key: key, value: override))
      }
    }
    out.push(_prepare-layer(
      layer,
      plot-mapping,
      plot-data,
      theme: theme,
      coord: coord,
      stat-override: override,
      user-scales: user-scales,
    ))
  }
  out
}
