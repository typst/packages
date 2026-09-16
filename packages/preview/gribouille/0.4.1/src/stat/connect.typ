///! Connection vertices between consecutive observations.
///!
///! `stat-connect` expands each gap between two ordered points into a
///! step-, mid-, or linear-style connector by inserting intermediate
///! vertices. Pair with `geom-path` (or `geom-line`) to render.

#import "../utils/types.typ": parse-number
#import "../utils/errors.typ": fail-enum

#let _CONNECTION-MODES = ("hv", "vh", "mid", "linear")

/// Connection statistic: expand consecutive points with intermediate vertices.
///
/// Modes:
///
/// - `"hv"` (default): horizontal then vertical. Inserts `(x_{i+1}, y_i)` between each pair.
/// - `"vh"`: vertical then horizontal. Inserts `(x_i, y_{i+1})`.
/// - `"mid"`: half-step both ways. Inserts `(mid, y_i)` and `(mid, y_{i+1})` at the midpoint.
/// - `"linear"`: pass-through (no intermediate vertices).
///
/// - connection: Connection mode (`"hv"` / `"vh"` / `"mid"` / `"linear"`).
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
#let stat-connect(connection: "hv") = {
  if not _CONNECTION-MODES.contains(connection) {
    fail-enum("stat-connect", "connection", connection, _CONNECTION-MODES)
  }
  (kind: "stat", name: "connect", params: (connection: connection))
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
