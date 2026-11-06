// Dispatch table for stat transforms.
// Keeps render.typ free of per-stat knowledge.

#import "identity.typ" as identity-stat
#import "bin.typ" as bin-stat
#import "bin-2d.typ" as bin-2d-stat
#import "bin-hex.typ" as bin-hex-stat
#import "bindot.typ" as bindot-stat
#import "contour.typ" as contour-stat
#import "contour-filled.typ" as contour-filled-stat
#import "count.typ" as count-stat
#import "density.typ" as density-stat
#import "density-2d.typ" as density-2d-stat
#import "density-ridges.typ" as density-ridges-stat
#import "density-2d-filled.typ" as density-2d-filled-stat
#import "ydensity.typ" as ydensity-stat
#import "sum.typ" as sum-stat
#import "smooth.typ" as smooth-stat
#import "boxplot.typ" as boxplot-stat
#import "summary.typ" as summary-stat
#import "summary-bin.typ" as summary-bin-stat
#import "summary-2d.typ" as summary-2d-stat
#import "summary-hex.typ" as summary-hex-stat
#import "ecdf.typ" as ecdf-stat
#import "unique.typ" as unique-stat
#import "qq.typ" as qq-stat
#import "qq-line.typ" as qq-line-stat
#import "function.typ" as function-stat
#import "ellipse.typ" as ellipse-stat
#import "quantile.typ" as quantile-stat
#import "manual.typ" as manual-stat
#import "connect.typ" as connect-stat
#import "align.typ" as align-stat
#import "difference.typ" as difference-stat
#import "waffle.typ" as waffle-stat
#import "../utils/bin.typ": panel-bin-grid
#import "../utils/bin-2d.typ": panel-bin-grid-2d
#import "../utils/hex.typ": panel-hex-grid
#import "../utils/errors.typ": fail-enum

// Single source of truth for every stat. `setup:` is the optional panel-level
// pre-pass invoked before per-group `apply()`; it is `none` when the stat
// has no shared partition.
#let _STATS = (
  identity: (
    apply: identity-stat.apply,
    ctor: none,
  ),
  bin: (
    apply: bin-stat.apply,
    ctor: bin-stat.stat-bin,
    setup: panel-bin-grid,
  ),
  "bin-2d": (
    apply: bin-2d-stat.apply,
    ctor: bin-2d-stat.stat-bin-2d,
    setup: panel-bin-grid-2d,
  ),
  "bin-hex": (
    apply: bin-hex-stat.apply,
    ctor: bin-hex-stat.stat-bin-hex,
    setup: panel-hex-grid,
  ),
  bindot: (
    apply: bindot-stat.apply,
    ctor: bindot-stat.stat-bindot,
    setup: panel-bin-grid,
  ),
  contour: (
    apply: contour-stat.apply,
    ctor: contour-stat.stat-contour,
  ),
  "contour-filled": (
    apply: contour-filled-stat.apply,
    ctor: contour-filled-stat.stat-contour-filled,
  ),
  count: (
    apply: count-stat.apply,
    ctor: count-stat.stat-count,
  ),
  density: (
    apply: density-stat.apply,
    ctor: density-stat.stat-density,
  ),
  "density-2d": (
    apply: density-2d-stat.apply,
    ctor: density-2d-stat.stat-density-2d,
  ),
  "density-2d-filled": (
    apply: density-2d-filled-stat.apply,
    ctor: density-2d-filled-stat.stat-density-2d-filled,
  ),
  "density-ridges": (
    apply: density-ridges-stat.apply,
    ctor: density-ridges-stat.stat-density-ridges,
  ),
  ydensity: (
    apply: ydensity-stat.apply,
    ctor: ydensity-stat.stat-ydensity,
  ),
  sum: (
    apply: sum-stat.apply,
    ctor: sum-stat.stat-sum,
  ),
  smooth: (
    apply: smooth-stat.apply,
    ctor: smooth-stat.stat-smooth,
  ),
  boxplot: (
    apply: boxplot-stat.apply,
    ctor: boxplot-stat.stat-boxplot,
  ),
  summary: (
    apply: summary-stat.apply,
    ctor: summary-stat.stat-summary,
  ),
  "summary-bin": (
    apply: summary-bin-stat.apply,
    ctor: summary-bin-stat.stat-summary-bin,
    setup: panel-bin-grid,
  ),
  "summary-2d": (
    apply: summary-2d-stat.apply,
    ctor: summary-2d-stat.stat-summary-2d,
  ),
  "summary-hex": (
    apply: summary-hex-stat.apply,
    ctor: summary-hex-stat.stat-summary-hex,
  ),
  ecdf: (
    apply: ecdf-stat.apply,
    ctor: ecdf-stat.stat-ecdf,
  ),
  unique: (
    apply: unique-stat.apply,
    ctor: unique-stat.stat-unique,
  ),
  qq: (
    apply: qq-stat.apply,
    ctor: qq-stat.stat-qq,
  ),
  "qq-line": (
    apply: qq-line-stat.apply,
    ctor: qq-line-stat.stat-qq-line,
  ),
  function: (
    apply: function-stat.apply,
    ctor: function-stat.stat-function,
  ),
  ellipse: (
    apply: ellipse-stat.apply,
    ctor: ellipse-stat.stat-ellipse,
  ),
  quantile: (
    apply: quantile-stat.apply,
    ctor: quantile-stat.stat-quantile,
  ),
  manual: (
    apply: manual-stat.apply,
    ctor: manual-stat.stat-manual,
  ),
  connect: (
    apply: connect-stat.apply,
    ctor: connect-stat.stat-connect,
  ),
  align: (
    apply: align-stat.apply,
    ctor: align-stat.stat-align,
    setup: (data, mapping, params) => align-stat.setup(
      data,
      mapping,
      params: params,
    ),
  ),
  difference: (
    apply: difference-stat.apply,
    ctor: difference-stat.stat-difference,
  ),
  waffle: (
    apply: waffle-stat.apply,
    ctor: waffle-stat.stat-waffle,
    setup: (data, mapping, params) => waffle-stat.setup(
      data,
      mapping,
      params: params,
    ),
  ),
)

#let stat-default-params(name) = {
  let entry = _STATS.at(name, default: none)
  if entry == none { return (:) }
  let ctor = entry.at("ctor", default: none)
  if ctor == none { (:) } else { ctor().params }
}

// Panic unless `name` is a registered stat. Called once per layer at setup, so
// a typo like `stat: "smoothh"` fails loudly instead of silently running as
// identity downstream.
#let _check-stat-name(name) = {
  if name not in _STATS {
    fail-enum("layer", "stat", name, _STATS.keys())
  }
}

// Resolve a layer's `stat:` field into a `(name, params)` pair. A string name
// inherits the geom's own params over the stat constructor defaults, mirroring
// the `position:` string form, so geom params such as `distribution` reach the
// stat. A `stat-*()` dict carries its own name and params instead.
#let resolve-stat-spec(stat-spec, geom-params) = {
  let is-str = type(stat-spec) == str
  let name = if is-str { stat-spec } else {
    stat-spec.at("name", default: "identity")
  }
  _check-stat-name(name)
  let params = if is-str {
    stat-default-params(name) + geom-params
  } else {
    stat-spec.at("params", default: (:))
  }
  (name: name, params: params)
}

#let setup-stat(name, data, mapping, params) = {
  let entry = _STATS.at(name, default: none)
  if entry == none { return params }
  let setup = entry.at("setup", default: none)
  if setup == none { return params }
  setup(data, mapping, params)
}

#let apply-stat(name, data, mapping, params) = {
  if name == none or name == "identity" {
    return (data: data, mapping: mapping)
  }
  let entry = _STATS.at(name, default: none)
  if entry == none { return (data: data, mapping: mapping) }
  (entry.apply)(data, mapping, params: params)
}
