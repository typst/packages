///! Connection vertices between consecutive observations.
///!
///! `stat-connect` expands each gap between two ordered points into a
///! step-, mid-, sigmoid-, or linear-style connector by inserting
///! intermediate vertices. Pair with `geom-path` (or `geom-line`) to
///! render.

#import "../utils/types.typ": parse-number
#import "../utils/errors.typ": fail, fail-enum

#let _CONNECTION-MODES = ("hv", "vh", "mid", "sigmoid", "linear")

#let _logistic(u) = 1.0 / (1.0 + calc.exp(-u))

// Interior vertices of a logistic S-curve from (x1, y1) to (x2, y2):
// y(t) = y1 + (y2 - y1) * (sigma(s * (2t - 1)) - sigma(-s)) / (sigma(s) - sigma(-s))
// over n points at t = j / (n + 1). The rescale by sigma(±s) pins the
// curve exactly onto both endpoints, so steeper `smooth` values change
// the shape but never detach the connector from its observations.
#let _sigmoid-interior(x1, y1, x2, y2, smooth, n) = {
  let lo = _logistic(-smooth)
  let span = _logistic(smooth) - lo
  range(1, n + 1).map(j => {
    let t = j / (n + 1)
    let eased = (_logistic(smooth * (2 * t - 1)) - lo) / span
    (x: x1 + (x2 - x1) * t, y: y1 + (y2 - y1) * eased)
  })
}

/// Connection statistic: expand consecutive points with intermediate vertices.
///
/// Modes:
///
/// - `"hv"` (default): horizontal then vertical. Inserts `(x_{i+1}, y_i)` between each pair.
/// - `"vh"`: vertical then horizontal. Inserts `(x_i, y_{i+1})`.
/// - `"mid"`: half-step both ways. Inserts `(mid, y_i)` and `(mid, y_{i+1})` at the midpoint.
/// - `"sigmoid"`: logistic S-curve. Inserts `n` vertices easing y between the pair, rescaled so the curve passes exactly through both observations; the bump-chart connector.
/// - `"linear"`: pass-through (no intermediate vertices).
///
/// - connection: Connection mode (`"hv"` / `"vh"` / `"mid"` / `"sigmoid"` / `"linear"`).
/// - smooth: Steepness of the `"sigmoid"` S-curve (a positive number). Larger values flatten the shoulders and sharpen the middle transition; ignored by the other modes.
/// - n: Number of intermediate vertices inserted per gap by `"sigmoid"` (a positive integer); ignored by the other modes.
///
/// Returns: Statistic object with `name: "connect"`, consumed by geom layers.
///
/// See also: `geom-step`, `geom-path`.
///
/// Step-style line via `"mid"`: midpoint corners between consecutive observations.
///
/// ```typst
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-path(stat: stat-connect(connection: "mid"), stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Bump chart: rank trajectories eased through sigmoid connectors, rank 1 on top via a reversed y scale.
///
/// ```typst
/// #let ranks = (
///   alpha: (1, 1, 2, 3, 3),
///   beta: (2, 3, 1, 1, 2),
///   gamma: (3, 2, 3, 2, 1),
/// )
/// #let d = ()
/// #for (team, rs) in ranks {
///   for (i, r) in rs.enumerate() { d.push((round: i + 1, rank: r, team: team)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "round", y: "rank", colour: "team"),
///   layers: (
///     geom-line(stat: stat-connect(connection: "sigmoid"), stroke: 2pt),
///     geom-point(size: 3.5pt),
///   ),
///   scales: scales(
///     y: scale-continuous(transform: "reverse", breaks: (1, 2, 3)),
///   ),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let stat-connect(connection: "hv", smooth: 8, n: 20) = {
  if not _CONNECTION-MODES.contains(connection) {
    fail-enum("stat-connect", "connection", connection, _CONNECTION-MODES)
  }
  if type(smooth) not in (int, float) or smooth <= 0 {
    fail(
      "stat-connect",
      "smooth must be a positive number, got " + repr(smooth),
    )
  }
  if type(n) != int or n < 1 {
    fail("stat-connect", "n must be a positive integer, got " + repr(n))
  }
  (
    kind: "stat",
    name: "connect",
    params: (connection: connection, smooth: smooth, n: n),
  )
}

#let apply(data, mapping, params: (:)) = {
  if mapping == none { return (data: data, mapping: mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: data, mapping: mapping)
  }
  let mode = params.at("connection", default: "hv")

  // Parse x/y to numeric: required for the midpoint mode and for
  // order-correct sorting against string-typed numerics ("10" vs "2").
  // Rows whose x or y doesn't parse are dropped silently.
  let decorated = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      (x: xv, y: yv, row: r)
    })
    .filter(p => p.x != none and p.y != none)

  if decorated.len() < 2 {
    return (data: decorated.map(p => p.row), mapping: mapping)
  }

  let sorted = decorated.sorted(key: p => p.x)
  let rows = sorted.map(p => p.row)

  if mode == "linear" {
    return (data: rows, mapping: mapping)
  }

  let out = (rows.first(),)
  let n = sorted.len()
  let prev = sorted.first()
  for i in range(1, n) {
    let cur = sorted.at(i)
    if mode == "hv" {
      out.push(
        prev.row + ((x-col): cur.row.at(x-col), (y-col): prev.row.at(y-col)),
      )
    } else if mode == "vh" {
      out.push(
        prev.row + ((x-col): prev.row.at(x-col), (y-col): cur.row.at(y-col)),
      )
    } else if mode == "sigmoid" {
      let interior = _sigmoid-interior(
        prev.x,
        prev.y,
        cur.x,
        cur.y,
        params.at("smooth", default: 8),
        params.at("n", default: 20),
      )
      for p in interior {
        out.push(prev.row + ((x-col): p.x, (y-col): p.y))
      }
    } else {
      let mid = (prev.x + cur.x) / 2
      out.push(prev.row + ((x-col): mid, (y-col): prev.row.at(y-col)))
      out.push(prev.row + ((x-col): mid, (y-col): cur.row.at(y-col)))
    }
    out.push(cur.row)
    prev = cur
  }
  (data: out, mapping: mapping)
}
