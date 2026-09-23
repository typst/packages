// Axis break computation, label formatting, and axis-title fallback shared by
// the panel-draw, extents, and canvas render submodules.

#import "../scale/train.typ": transform-fwd, transform-inv
#import "../utils/colour.typ": edge-midpoints
#import "../utils/pretty.typ": pretty, pretty-log10, pretty-sqrt
#import "../utils/format.typ": format-break

// Axis title fallback: a `labels(x: none)` suppression (`spec.blank`) wins and
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
  // User `breaks` (continuous tick positions, or bin edges when `binned`),
  // coerced to an array; `auto` when unset.
  let user-breaks = if spec == none { auto } else {
    spec.at("breaks", default: auto)
  }
  let user-break-array = if user-breaks == auto { auto } else if (
    type(user-breaks) == array
  ) { user-breaks } else { (user-breaks,) }
  if binned {
    // Explicit `breaks` are bin edges: tick each interval at its midpoint and
    // ignore `n-breaks`. The trained domain already covers the edges via the
    // break-driven fold in `_train-entry`.
    if user-break-array != auto {
      let sorted = user-break-array.sorted()
      if sorted.len() < 2 { return sorted }
      return edge-midpoints(sorted)
    }
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
  if user-break-array != auto {
    let blo = calc.min(lo, hi)
    let bhi = calc.max(lo, hi)
    return user-break-array.filter(b => b >= blo and b <= bhi)
  }
  if transform == "log10" { return pretty-log10(lo, hi) }
  if transform == "sqrt" { return pretty-sqrt(lo, hi) }
  pretty(lo, hi, n: 5)
}

// Visible domain (data space) for a trained continuous scale, mirroring the
// derivation in `_axis-breaks`: prefer the expanded `view-transform`, else the
// unwarped `pre-transformed` domain, else the raw domain. Returned sorted.
#let _visible-domain(trained) = {
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
  (calc.min(lo, hi), calc.max(lo, hi))
}

// Sub-decade positions 2..9 x 10^k inside `[lo, hi]` for a log10 axis. Shared
// by minor gridlines and the opt-in `guide-axis-logticks` minor ticks. Assumes
// `lo` and `hi` are strictly positive (callers guard).
#let _log10-minor-positions(lo, hi) = {
  let k-lo = int(calc.floor(calc.log(lo, base: 10)))
  let k-hi = int(calc.ceil(calc.log(hi, base: 10)))
  let out = ()
  let k = k-lo
  while k <= k-hi {
    let decade = calc.pow(10.0, k)
    for c in (2, 3, 4, 5, 6, 7, 8, 9) {
      let v = c * decade
      if v >= lo and v <= hi { out.push(v) }
    }
    k = k + 1
  }
  out
}

// Minor gridline positions for a continuous axis, given its drawn `majors`.
// linear/sqrt/reverse subdivide between majors (default one
// minor per gap) and extend one step past each end; log10 uses sub-decade
// lines; binned scales get none. Honours a user `minor-breaks` override and an
// `n-minor` subdivision count from the scale spec.
#let _axis-minor-breaks(trained, majors) = {
  let spec = trained.at("spec", default: none)
  // Binned ticks already sit at bin midpoints; no minor gridlines.
  if spec != none and spec.at("binned", default: false) { return () }
  let transform = trained.at("transform", default: "identity")
  let (dlo, dhi) = _visible-domain(trained)
  // A user-positioned set wins outright, clipped to the visible domain.
  let user-minor = if spec == none { auto } else {
    spec.at("minor-breaks", default: auto)
  }
  if user-minor != auto {
    let arr = if type(user-minor) == array { user-minor } else { (user-minor,) }
    return arr.filter(b => b >= dlo and b <= dhi)
  }
  // log10: sub-decade positions 2..9 x 10^k inside the domain.
  if transform == "log10" {
    if dlo <= 0 or dhi <= 0 { return () }
    return _log10-minor-positions(dlo, dhi)
  }
  if majors == none or majors.len() < 2 { return () }
  let n-minor = if spec == none { auto } else {
    spec.at("n-minor", default: auto)
  }
  let n = if n-minor == auto { 1 } else { calc.max(0, int(n-minor)) }
  if n == 0 { return () }
  // Work in transformed (stat) space so sqrt minors space evenly on screen.
  let sorted = majors.sorted()
  let t = sorted.map(b => transform-fwd(transform, b))
  let step = t.at(1) - t.at(0)
  if step == 0 { return () }
  let tol = calc.abs(step) * 1e-6
  // Irregular majors (e.g. user-supplied breaks) have no single step; fall back
  // to one minor per gap at the data-space midpoint, with no end extension.
  let uniform = range(t.len() - 1).all(i => (
    calc.abs((t.at(i + 1) - t.at(i)) - step) <= tol
  ))
  if not uniform {
    return edge-midpoints(sorted).filter(b => b >= dlo and b <= dhi)
  }
  let spacing = step / (n + 1)
  // Candidates span one major step beyond each end; interior subdivisions that
  // land on a major are dropped, leaving only the genuine minors.
  let candidates = ()
  let pos = t.first() - step + spacing
  let last = t.last() + step
  while pos <= last + tol {
    candidates.push(pos)
    pos = pos + spacing
  }
  candidates
    .filter(p => not t.any(m => calc.abs(m - p) <= tol))
    .map(p => transform-inv(transform, p))
    .filter(b => b >= dlo and b <= dhi)
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
