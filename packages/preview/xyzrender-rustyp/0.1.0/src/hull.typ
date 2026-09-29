// Mirrors upstream src/xyzrender/hull.py.
//
// v1 ports only `_convex_hull_2d` — the dependency of `interlock.typ`.
// The rest of upstream hull.py (3D hulls, hull facets, hull edges,
// silhouette polygons, hull rings/pores/faces, `apply_hull_to_config`)
// is feature-out-of-scope for v1; bring it in alongside the matching
// feature when needed.

// Upstream hull.py:34-82 — Andrew's monotone chain.
//
// Returns the boundary-vertex indices into `points` in
// counter-clockwise order. Input must be a list of (x, y) tuples
// (length >= 0). Degenerate inputs (n <= 1) return all indices in
// place; collinear inputs return the extremal pair.
#let _convex-hull-2d(points) = {
  let n = points.len()
  if n <= 1 {
    return range(n)
  }

  // Lex sort by (x, y).
  let order = range(n).sorted(key: i => (
    float(points.at(i).at(0)),
    float(points.at(i).at(1)),
  ))
  let xs = order.map(i => float(points.at(i).at(0)))
  let ys = order.map(i => float(points.at(i).at(1)))

  // Andrew's half-hull; pop while the last turn is non-left
  // (cross <= 0). Indices are into the sorted `xs`/`ys` arrays.
  let half-hull(seq) = {
    let hull = ()
    for i in seq {
      let bx = xs.at(i)
      let by = ys.at(i)
      while hull.len() >= 2 {
        let h1 = hull.at(hull.len() - 1)
        let h0 = hull.at(hull.len() - 2)
        let ox = xs.at(h0)
        let oy = ys.at(h0)
        let cross = (xs.at(h1) - ox) * (by - oy) - (ys.at(h1) - oy) * (bx - ox)
        if cross <= 0 {
          let _ = hull.pop()
        } else {
          break
        }
      }
      hull.push(i)
    }
    hull
  }

  let lower = half-hull(range(n))
  let upper = half-hull(range(n - 1, -1, step: -1))

  // Drop the last point of each chain to avoid duplicating the
  // join points.
  let hull-local = lower.slice(0, lower.len() - 1) + upper.slice(0, upper.len() - 1)
  hull-local.map(k => order.at(k))
}
