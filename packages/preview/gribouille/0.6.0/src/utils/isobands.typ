// Filled iso-bands over a regular grid. Each cell is the convex quad
// `[NW, NE, SE, SW]` carrying corner z values; clipping it against `z >= lo`
// then `z <= hi` (Sutherland-Hodgman) yields the cell's contribution to the
// band. Saddle cells produce a single connected region, matching the same
// linear-interpolation policy as `marching-squares.typ`.

#let _clip(polygon, level, keep) = {
  if polygon.len() == 0 { return polygon }
  let n = polygon.len()
  let out = ()
  for i in range(n) {
    let curr = polygon.at(i)
    let prev = polygon.at(if i == 0 { n - 1 } else { i - 1 })
    let curr-in = keep(curr.z, level)
    let prev-in = keep(prev.z, level)
    // `keep` is `>=` or `<=` against `level`, so equal endpoint z values
    // resolve both flags equal and crossings never interpolate; the explicit
    // `dz` guard makes that invariant local to the division.
    let dz = curr.z - prev.z
    if curr-in != prev-in and dz != 0 {
      let t = (level - prev.z) / dz
      out.push((
        x: prev.x + t * (curr.x - prev.x),
        y: prev.y + t * (curr.y - prev.y),
        z: level,
      ))
    }
    if curr-in { out.push(curr) }
  }
  out
}

#let _cell-quad(xw, xe, ys, yn, nw, ne, se, sw) = (
  (x: xw, y: yn, z: nw),
  (x: xe, y: yn, z: ne),
  (x: xe, y: ys, z: se),
  (x: xw, y: ys, z: sw),
)

// Single cell's contribution (up to a heptagon) to the band `[lo, hi]`.
// Returns an array of `(x, y)` vertices, or `()` when the cell sits
// entirely below `lo` or above `hi`.
#let isoband-cell(xw, xe, ys, yn, nw, ne, se, sw, lo, hi) = {
  let quad = _cell-quad(xw, xe, ys, yn, nw, ne, se, sw)
  let above = _clip(quad, lo, (z, L) => z >= L)
  let inside = _clip(above, hi, (z, L) => z <= L)
  inside.map(v => (x: v.x, y: v.y))
}

#let isobands(xs, ys, z, lo, hi) = {
  let nx = xs.len()
  let ny = ys.len()
  let out = ()
  if nx < 2 or ny < 2 { return out }
  for i in range(nx - 1) {
    let xw = xs.at(i)
    let xe = xs.at(i + 1)
    for j in range(ny - 1) {
      let ys-bot = ys.at(j)
      let yn-top = ys.at(j + 1)
      let sw = z.at(i).at(j)
      let se = z.at(i + 1).at(j)
      let ne = z.at(i + 1).at(j + 1)
      let nw = z.at(i).at(j + 1)
      // Sparse grids leave incomplete cells as `none`; skip them.
      if sw == none or se == none or ne == none or nw == none { continue }
      let poly = isoband-cell(xw, xe, ys-bot, yn-top, nw, ne, se, sw, lo, hi)
      if poly.len() >= 3 { out.push(poly) }
    }
  }
  out
}
