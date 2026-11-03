///! Difference statistic: split the band between two series by sign.
///!
///! Walks the `ymin`/`ymax` pair along x, finds every crossing of the two
///! series, and inserts the exact intersection point into both adjacent
///! runs so the ribbon segments meet cleanly instead of ending short of
///! the crossover. Each run carries a `_sign` level naming which series
///! is on top, ready to map onto `fill`.

#import "../utils/aes-resolve.typ": stat-output-mapping
#import "../utils/types.typ": parse-number
#import "../utils/errors.typ": fail

// Strict sign of the series difference: 1, -1, or 0 on an exact tie.
#let _sign-of(d) = if d > 0 { 1 } else if d < 0 { -1 } else { 0 }

// Parse, drop rows with a missing value on any of the three channels, sort
// by x. Each entry keeps the source row so extra columns survive the stat.
#let _parsed-points(data, x-col, lo-col, hi-col) = (
  data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let lo = parse-number(r.at(lo-col, default: none))
      let hi = parse-number(r.at(hi-col, default: none))
      if xv == none or lo == none or hi == none { return none }
      (x: xv, lo: lo, hi: hi, row: r)
    })
    .filter(p => p != none)
    .sorted(key: p => p.x)
)

/// Difference statistic: ribbon between two series, split at every crossing.
///
/// Consumes `x`, `ymin`, and `ymax`, where `ymin` and `ymax` are the two series to compare (either may be on top). Consecutive points whose difference changes sign are joined by the exact linear intersection of the two series, inserted as the last point of one run and the first point of the next, so adjacent ribbon segments share a vertex at the crossover. Each output row carries a `_sign` column holding `levels.at(0)` where `ymax > ymin` and `levels.at(1)` where `ymax < ymin`, and a `group` column separating the runs; map `fill` to `after-stat("_sign")` to colour the band by which series leads.
///
/// - levels: Pair of level names written to `_sign`: first where `ymax` is above `ymin`, second where it is below. Exact-tie points extend the run in progress; a group that only ever ties takes the first level (its band has zero area either way).
///
/// Returns: Statistic object with `name: "difference"`, consumed by geom layers (usually `geom-ribbon`).
///
/// See also: `geom-ribbon`, `stat-align`, `after-stat`.
///
/// Shade the gap between two series by which one is on top.
///
/// ```typst
/// #let d = range(0, 25).map(i => {
///   let x = i * 0.5
///   (x: x, a: calc.sin(x) + 2, b: calc.cos(x * 0.8) + 2)
/// })
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "a", ymax: "b", fill: after-stat("_sign")),
///   layers: (geom-ribbon(stat: stat-difference()),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
///
/// Name the levels and overlay the series themselves.
///
/// ```typst
/// #let d = range(0, 21).map(i => {
///   let x = i * 0.6
///   (x: x, forecast: 1 + x * 0.25, actual: 1 + x * 0.2 + calc.sin(x) * 0.8)
/// })
/// #plot(
///   data: d,
///   mapping: aes(x: "x"),
///   layers: (
///     geom-ribbon(
///       mapping: aes(
///         ymin: "forecast",
///         ymax: "actual",
///         fill: after-stat("_sign"),
///       ),
///       stat: stat-difference(levels: ("above forecast", "below forecast")),
///       alpha: 0.6,
///     ),
///     geom-line(mapping: aes(y: "forecast"), stroke: 1.2pt),
///     geom-line(mapping: aes(y: "actual"), stroke: 1.2pt, linetype: "dashed"),
///   ),
///   labels: labels(fill: "Actuals vs. forecast"),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let stat-difference(levels: ("+", "-")) = {
  if (
    type(levels) != array
      or levels.len() != 2
      or levels.any(l => type(l) != str)
      or levels.at(0) == levels.at(1)
  ) {
    fail(
      "stat-difference",
      "levels must be two distinct strings, got " + repr(levels),
      hint: "e.g., levels: (\"above\", \"below\")",
    )
  }
  (kind: "stat", name: "difference", params: (levels: levels))
}

#let apply(data, mapping, params: (:)) = {
  let new-mapping = stat-output-mapping(
    mapping,
    (x: "x", ymin: "ymin", ymax: "ymax", group: "group"),
  )
  if mapping == none { return (data: (), mapping: new-mapping) }
  let x-col = mapping.at("x", default: none)
  let lo-col = mapping.at("ymin", default: none)
  let hi-col = mapping.at("ymax", default: none)
  if x-col == none or lo-col == none or hi-col == none {
    return (data: (), mapping: new-mapping)
  }

  let pts = _parsed-points(data, x-col, lo-col, hi-col)
  let levels = params.at("levels", default: ("+", "-"))
  let level-for = sign => if sign >= 0 { levels.at(0) } else { levels.at(1) }

  // Split the points into runs of constant sign. A run is a list of
  // (x, lo, hi, row) vertices; `sign` is the strict sign it has committed
  // to, or 0 while it has only seen exact ties.
  let runs = ()
  let current = ()
  let current-sign = 0
  for (i, p) in pts.enumerate() {
    let s = _sign-of(p.hi - p.lo)
    if current-sign != 0 and s != 0 and s != current-sign {
      // Sign flipped between the previous point and this one: insert the
      // exact intersection of the two series as the shared vertex.
      let a = pts.at(i - 1)
      let da = a.hi - a.lo
      let db = p.hi - p.lo
      let t = da / (da - db)
      let xc = a.x + t * (p.x - a.x)
      let yc = a.lo + t * (p.lo - a.lo)
      let crossing = (x: xc, lo: yc, hi: yc, row: a.row)
      current.push(crossing)
      runs.push((sign: current-sign, points: current))
      current = (crossing,)
      current-sign = s
    } else if current-sign == 0 and s != 0 {
      current-sign = s
    }
    current.push(p)
  }
  if current.len() > 0 {
    runs.push((sign: current-sign, points: current))
  }

  let rows = ()
  for (ri, run) in runs.enumerate() {
    let level = level-for(run.sign)
    for p in run.points {
      rows.push(
        p.row
          + (
            x: p.x,
            ymin: p.lo,
            ymax: p.hi,
            _sign: level,
            group: str(ri),
          ),
      )
    }
  }
  (data: rows, mapping: new-mapping)
}
