// Connector routing for text/label/typst geoms.
//
// Given a label centre and its measured box, plus the anchor it points back
// to and the AABBs of every other label drawn by the same geom, pick a
// connector path:
//
//   1. Straight `anchor -> label-edge`, when it crosses no other AABB.
//   2. Two L-bends (horizontal-then-vertical, vertical-then-horizontal),
//      the first whose two legs both clear all other AABBs.
//   3. `none`: skip the connector for this row.
//
// All inputs are in canvas-cm. Returns either `none` or an array of points
// `((x0, y0), (x1, y1), ...)` describing a polyline.

// Build an axis-aligned bounding box from a centre point, width, and height,
// optionally inflated on every side by `pad`.
#let aabb-from-centre(centre, w, h, pad: 0) = {
  let (cx, cy) = centre
  let hw = w / 2 + pad
  let hh = h / 2 + pad
  (x-lo: cx - hw, y-lo: cy - hh, x-hi: cx + hw, y-hi: cy + hh)
}

// AABB overlap: returns `(ox, oy)` strictly positive when the two boxes
// intersect, else `none`. Used by the repel algorithm to derive a push
// vector from a pair of overlapping label boxes.
#let aabb-overlap(a, b) = {
  let ox = calc.min(a.x-hi, b.x-hi) - calc.max(a.x-lo, b.x-lo)
  let oy = calc.min(a.y-hi, b.y-hi) - calc.max(a.y-lo, b.y-lo)
  if ox <= 0 or oy <= 0 { return none }
  (ox, oy)
}

// Liang-Barsky parametric clip: return the `t` value in `[0, 1]` where the
// line from `p0` to `p1` first enters `aabb`, or `none` when the segment
// stays entirely outside. Each `(p, q)` pair describes one of the four
// half-planes; we walk them in sequence and shrink `(t-lo, t-hi)` as we go.
// Typst closures cannot mutate variables captured from their enclosing
// scope, so the loop folds state explicitly rather than calling a helper.
#let _enter-t(p0, p1, aabb) = {
  let (p0x, p0y) = p0
  let (p1x, p1y) = p1
  let dx = p1x - p0x
  let dy = p1y - p0y
  let edges = (
    (-dx, p0x - aabb.x-lo),
    (dx, aabb.x-hi - p0x),
    (-dy, p0y - aabb.y-lo),
    (dy, aabb.y-hi - p0y),
  )
  let t-lo = 0.0
  let t-hi = 1.0
  for (p, q) in edges {
    if p == 0 {
      // Parallel to slab: a negative offset means the segment lies entirely
      // outside the slab, so the whole line misses the AABB.
      if q < 0 { return none }
    } else {
      let r = q / p
      if p < 0 {
        if r > t-hi { return none }
        if r > t-lo { t-lo = r }
      } else {
        if r < t-lo { return none }
        if r < t-hi { t-hi = r }
      }
    }
  }
  if t-lo > t-hi { return none }
  if t-lo > 1 or t-hi < 0 { return none }
  t-lo
}

// True when the segment `p0 -> p1` intersects `aabb` at any point in (0, 1).
// Endpoints exactly on the boundary count as clear so adjacent labels do not
// reject their own anchor stub.
#let segment-crosses(p0, p1, aabb, eps: 1e-6) = {
  let t = _enter-t(p0, p1, aabb)
  if t == none { return false }
  // A crossing that only grazes an endpoint (t near 0 or 1) is harmless;
  // anything strictly between the endpoints counts as a hit.
  t > eps and t < 1 - eps
}

// Project the anchor->centre ray onto the inflated `aabb` around the label
// centre and return the entry point. Used as the connector's label-side
// endpoint so the line stops just outside the label box.
#let project-onto-edge(anchor, centre, aabb) = {
  let t = _enter-t(anchor, centre, aabb)
  if t == none { return centre }
  let (ax, ay) = anchor
  let (cx, cy) = centre
  (ax + t * (cx - ax), ay + t * (cy - ay))
}

#let _path-clear(points, boxes, skip-idx) = {
  for i in range(points.len() - 1) {
    let a = points.at(i)
    let b = points.at(i + 1)
    for (j, box) in boxes.enumerate() {
      if j == skip-idx or box == none { continue }
      if segment-crosses(a, b, box) { return false }
    }
  }
  true
}

// Route a connector from `anchor` to the label drawn at `centre` with the
// given measured `aabb` (already inflated by box padding). `boxes` is the
// full per-row AABB list of the layer; `idx` identifies this row so the
// router skips its own box.
#let route-segment(anchor, centre, aabb, boxes, idx) = {
  let end = project-onto-edge(anchor, centre, aabb)
  let straight = (anchor, end)
  if _path-clear(straight, boxes, idx) { return straight }
  let (ax, ay) = anchor
  let (ex, ey) = end
  let l-hv = (anchor, (ex, ay), end)
  if _path-clear(l-hv, boxes, idx) { return l-hv }
  let l-vh = (anchor, (ax, ey), end)
  if _path-clear(l-vh, boxes, idx) { return l-vh }
  none
}
