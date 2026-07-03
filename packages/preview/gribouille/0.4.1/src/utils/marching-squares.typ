// Marching-squares isoline extraction over a regular grid. Saddle cases
// (5, 10) are disambiguated by the cell-centre average so the segments
// separate the high regions from the low ones.

// Edge codes used by the case table.
#let _T = 0  // top    (NW-NE)
#let _R = 1  // right  (NE-SE)
#let _B = 2  // bottom (SE-SW)
#let _L = 3  // left   (NW-SW)

// Per-case segment list. Each segment is `(edge-a, edge-b)`. Saddle cases
// 5 and 10 carry both branchings; `_disambiguate-saddle` picks one at runtime.
#let _CASES = (
  (), // 0 = 0000
  ((_L, _B),), // 1 = 0001
  ((_B, _R),), // 2 = 0010
  ((_L, _R),), // 3 = 0011
  ((_T, _R),), // 4 = 0100
  none, // 5 saddle
  ((_T, _B),), // 6 = 0110
  ((_L, _T),), // 7 = 0111
  ((_L, _T),), // 8 = 1000
  ((_T, _B),), // 9 = 1001
  none, // 10 saddle
  ((_T, _R),), // 11 = 1011
  ((_L, _R),), // 12 = 1100
  ((_B, _R),), // 13 = 1101
  ((_L, _B),), // 14 = 1110
  (), // 15 = 1111
)

#let _interp(va, vb, pa, pb, level) = {
  pa + (level - va) / (vb - va) * (pb - pa)
}

// Edge crossing in (x, y) at the given level. `nw, ne, se, sw` are corner
// values; `xw, xe, ys, yn` are the cell extents (xw < xe, ys < yn).
#let _edge-point(edge, level, nw, ne, se, sw, xw, xe, ys, yn) = {
  if edge == _T { return (_interp(nw, ne, xw, xe, level), yn) }
  if edge == _R { return (xe, _interp(ne, se, yn, ys, level)) }
  if edge == _B { return (_interp(sw, se, xw, xe, level), ys) }
  (xw, _interp(nw, sw, yn, ys, level))
}

// Connect segments through the centre's region: when centre >= level the
// two "above" corners sit in one region and segments isolate the "below"
// pair, and vice versa.
#let _disambiguate-saddle(case, nw, ne, se, sw, level) = {
  let centre = (nw + ne + se + sw) / 4
  let centre-above = centre >= level
  if case == 5 {
    if centre-above {
      ((_L, _T), (_B, _R))
    } else {
      ((_L, _B), (_T, _R))
    }
  } else {
    if centre-above {
      ((_L, _B), (_T, _R))
    } else {
      ((_L, _T), (_B, _R))
    }
  }
}

// Extract isoline segments at `level` from a regular `(xs, ys, z)` grid.
// `xs` and `ys` are sorted ascending; `z` is `z[i][j]` indexed by
// `(x-index, y-index)`. Returns a flat array of `((x0, y0), (x1, y1))` pairs.
#let isolines(xs, ys, z, level) = {
  let nx = xs.len()
  let ny = ys.len()
  let out = ()
  if nx < 2 or ny < 2 { return out }
  for i in range(nx - 1) {
    let xw = xs.at(i)
    let xe = xs.at(i + 1)
    for j in range(ny - 1) {
      let ys-bottom = ys.at(j)
      let yn-top = ys.at(j + 1)
      let sw = z.at(i).at(j)
      let se = z.at(i + 1).at(j)
      let ne = z.at(i + 1).at(j + 1)
      let nw = z.at(i).at(j + 1)
      // Sparse grids leave incomplete cells as `none`; skip them.
      if sw == none or se == none or ne == none or nw == none { continue }
      let case = (
        (if nw >= level { 8 } else { 0 })
          + (if ne >= level { 4 } else { 0 })
          + (if se >= level { 2 } else { 0 })
          + (if sw >= level { 1 } else { 0 })
      )
      let segs = _CASES.at(case)
      if segs == none {
        segs = _disambiguate-saddle(case, nw, ne, se, sw, level)
      }
      for (ea, eb) in segs {
        let p0 = _edge-point(
          ea,
          level,
          nw,
          ne,
          se,
          sw,
          xw,
          xe,
          ys-bottom,
          yn-top,
        )
        let p1 = _edge-point(
          eb,
          level,
          nw,
          ne,
          se,
          sw,
          xw,
          xe,
          ys-bottom,
          yn-top,
        )
        out.push((p0, p1))
      }
    }
  }
  out
}
