// Axis break computation, label formatting, and axis-title fallback shared by
// the panel-draw, extents, and canvas render submodules.

#import "../scale/train.typ": transform-inv
#import "../utils/pretty.typ": pretty, pretty-log10, pretty-sqrt
#import "../utils/format.typ": format-break

// Axis title fallback: a `labs(x: none)` suppression (`spec.blank`) wins and
// yields no title; otherwise the trained scale's `spec.name`, else the bare
// mapping column name (which may be `none` when neither is set). Used by the
// cartesian title path and the faceted (wrap/grid) finishers.
#let _axis-title(trained, mapping-name) = {
  if (
    trained != none
      and trained.spec != none
      and trained.spec.at(
        "blank",
        default: false,
      )
  ) { return none }
  let from-scale = if trained != none and trained.spec != none {
    trained.spec.name
  } else { none }
  if from-scale != none { from-scale } else { mapping-name }
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
  let user-breaks = if spec == none { auto } else {
    spec.at("breaks", default: auto)
  }
  if user-breaks != auto {
    let bs = if type(user-breaks) == array { user-breaks } else {
      (user-breaks,)
    }
    let blo = calc.min(lo, hi)
    let bhi = calc.max(lo, hi)
    return bs.filter(b => b >= blo and b <= bhi)
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
