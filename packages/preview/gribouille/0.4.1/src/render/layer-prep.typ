// Per-layer preparation: resolve `from-theme`, apply stat then position, and
// evaluate the late-binding lanes, yielding a draw-ready layer.

#import "../scale/train.typ": all-aesthetics, positional-aesthetics
#import "../stat/apply.typ": apply-stat, resolve-stat-spec, setup-stat
#import "../utils/errors.typ": fail
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
#import "../utils/palette.typ": default-discrete
#import "common.typ": _resolve-data, _strip-mapping-refs, _typst-marks-of
#import "prestat.typ": _rewrite-factor-cols

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
      fail(
        "from-theme",
        "unsupported on '"
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
  let resolved-stat = resolve-stat-spec(stat-spec, params)
  let stat-name = resolved-stat.name
  let stat-params = resolved-stat.params
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
    // Expose a positional column reused by a grouping aesthetic (e.g. fill ==
    // x) under its source name; `group-cols` cannot re-inject an x/y column.
    combined = expose-shared-positional(combined, mapping, last-mapping)
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
