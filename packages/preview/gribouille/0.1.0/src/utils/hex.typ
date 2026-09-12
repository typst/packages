// Pointy-top hexagonal binning. Two interleaved rectangular lattices form a
// single hex grid; the nearest-centre rule matches the Voronoi regions of the
// combined lattice.

#import "bin.typ": bin-domain
#import "summaries.typ": read-weight
#import "types.typ": parse-number

#let _SQRT3-OVER-2 = calc.sqrt(3) / 2

#let _split-pair(value, fallback: none) = {
  if value == none { return (fallback, fallback) }
  if type(value) == array { return (value.at(0), value.at(1)) }
  (value, value)
}

// Build a hex grid from extents. `bins` and `binwidth` accept either a
// scalar (applied to both axes) or an `(x, y)` pair. The default `dy`
// gives a regular hex; callers may override it when axes have very
// different scales (which produces oblong cells that no longer tile).
#let hex-grid(xs, ys, bins, binwidth) = {
  let (bx, by) = _split-pair(bins, fallback: 30)
  let (wx, wy) = _split-pair(binwidth)
  let (x-lo, x-hi) = bin-domain(xs)
  let (y-lo, y-hi) = bin-domain(ys)
  let dx = if wx != none { wx } else { (x-hi - x-lo) / bx }
  let dy = if wy != none { wy } else { (y-hi - y-lo) / by * _SQRT3-OVER-2 }
  (x-lo: x-lo, y-lo: y-lo, dx: dx, dy: dy)
}

#let panel-hex-grid(data, mapping, params) = {
  if mapping == none { return params }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return params }
  let pairs = data
    .map(r => {
      let xv = parse-number(r.at(x-col, default: none))
      let yv = parse-number(r.at(y-col, default: none))
      if xv == none or yv == none { return none }
      (xv, yv)
    })
    .filter(p => p != none)
  if pairs.len() == 0 { return params }
  let grid = hex-grid(
    pairs.map(p => p.at(0)),
    pairs.map(p => p.at(1)),
    params.at("bins", default: 30),
    params.at("binwidth", default: none),
  )
  let out = params
  out.insert("grid", grid)
  out
}

#let resolve-hex-grid(xs, ys, params) = {
  let g = params.at("grid", default: none)
  if g != none { return g }
  hex-grid(xs, ys, params.at("bins", default: 30), params.at(
    "binwidth",
    default: none,
  ))
}

// Assign `(x, y)` to the closest hex centre. `iy` is even on lattice A and
// odd on lattice B (offset by `(dx/2, dy)`).
#let hex-bin-of(x, y, grid) = {
  let dx = grid.dx
  let dy = grid.dy
  let two-dy = 2 * dy
  let xrel = x - grid.x-lo
  let yrel = y - grid.y-lo
  let ia = calc.round(xrel / dx)
  let ja = calc.round(yrel / two-dy)
  let cxa = grid.x-lo + ia * dx
  let cya = grid.y-lo + ja * two-dy
  let dax = x - cxa
  let day = y - cya
  let da2 = dax * dax + day * day
  let ib = calc.round((xrel - dx / 2) / dx)
  let jb = calc.round((yrel - dy) / two-dy)
  let cxb = grid.x-lo + ib * dx + dx / 2
  let cyb = grid.y-lo + jb * two-dy + dy
  let dbx = x - cxb
  let dby = y - cyb
  let db2 = dbx * dbx + dby * dby
  if da2 <= db2 {
    (ix: ia, iy: 2 * ja, cx: cxa, cy: cya)
  } else {
    (ix: ib, iy: 2 * jb + 1, cx: cxb, cy: cyb)
  }
}

// Aggregate `data` rows into a sparse hex bin dict.
//
// Returns `(grid, cells)` where:
//   `grid`  : `(x-lo, y-lo, dx, dy)` lattice descriptor.
//   `cells` : sparse dict keyed by `"ix,iy"`. Each entry carries
//             `(count, cx, cy)` (when collecting weights only) or
//             `(zs, cx, cy)` (when `z-col` is mapped). `zs` is the list of
//             z-values for that cell; the centre is captured on first insert.
//
// Returns `none` when columns unmapped or no rows parse.
#let hex-cells(data, x-col, y-col, params, weight-col: none, z-col: none) = {
  if x-col == none or y-col == none { return none }
  let collect-z = z-col != none
  let entries = ()
  for r in data {
    let xv = parse-number(r.at(x-col, default: none))
    let yv = parse-number(r.at(y-col, default: none))
    if xv == none or yv == none { continue }
    let entry = (x: xv, y: yv, w: read-weight(r, weight-col))
    if collect-z {
      let zv = r.at(z-col, default: none)
      if zv == none { continue }
      entry.z = zv
    }
    entries.push(entry)
  }
  if entries.len() == 0 { return none }
  let grid = resolve-hex-grid(
    entries.map(e => e.x),
    entries.map(e => e.y),
    params,
  )
  let cells = (:)
  for e in entries {
    let cell = hex-bin-of(e.x, e.y, grid)
    let key = str(cell.ix) + "," + str(cell.iy)
    let prev = cells.at(key, default: none)
    if collect-z {
      if prev == none {
        cells.insert(key, (zs: (e.z,), cx: cell.cx, cy: cell.cy))
      } else {
        prev.zs.push(e.z)
        cells.insert(key, prev)
      }
    } else {
      if prev == none {
        cells.insert(key, (count: e.w, cx: cell.cx, cy: cell.cy))
      } else {
        prev.count += e.w
        cells.insert(key, prev)
      }
    }
  }
  (grid: grid, cells: cells)
}

// Six pointy-top vertices around `(cx, cy)`. The circumradius is `2 * dy / 3`,
// which matches a regular hex when `dy = dx * sqrt(3) / 2`.
#let hex-vertices(cx, cy, dx, dy) = {
  let hw = dx / 2
  let q = dy * 2 / 3
  let qh = q / 2
  (
    (cx, cy + q),
    (cx + hw, cy + qh),
    (cx + hw, cy - qh),
    (cx, cy - q),
    (cx - hw, cy - qh),
    (cx - hw, cy + qh),
  )
}
