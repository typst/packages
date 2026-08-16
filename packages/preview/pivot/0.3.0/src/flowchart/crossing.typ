// Orthogonal crossing geometry for flowchart edge routing.
//
// Pure math over plain values — no cetz, no layout state. Placement uses it
// three ways: the corridor sweep counts the crossings a candidate column
// would force, the per-gap allocator orders the sideways runs sharing one
// inter-rank band, and the planned polylines let tests assert a whole
// diagram's crossing count.

// Touching is not crossing: two segments that meet at a bend or T-junction,
// or run collinear, are drawn as one clean joint. Only a strict interior
// pass-through counts, with a small tolerance so float noise on a shared
// endpoint never reads as a hit.
#let ceps = 0.005

// Whether two segments (x0, y0, x1, y1) cross. Only an axis-aligned
// horizontal/vertical pair can: parallel runs and degenerate points never
// count, and the planned geometry contains nothing diagonal.
#let seg-cross(a, b) = {
  let hor = s => (
    calc.abs(s.at(1) - s.at(3)) <= ceps and calc.abs(s.at(0) - s.at(2)) > ceps
  )
  let ver = s => (
    calc.abs(s.at(0) - s.at(2)) <= ceps and calc.abs(s.at(1) - s.at(3)) > ceps
  )
  let (h, v) = if hor(a) and ver(b) { (a, b) } else if ver(a) and hor(b) {
    (b, a)
  } else { return false }
  let (hlo, hhi) = (calc.min(h.at(0), h.at(2)), calc.max(h.at(0), h.at(2)))
  let (vlo, vhi) = (calc.min(v.at(1), v.at(3)), calc.max(v.at(1), v.at(3)))
  (
    v.at(0) > hlo + ceps
      and v.at(0) < hhi - ceps
      and h.at(1) > vlo + ceps
      and h.at(1) < vhi - ceps
  )
}

// Total crossings in a set of polylines (arrays of (x, y) points), counting
// pairs from different polylines only — consecutive segments of one edge
// share endpoints by construction.
#let count-crossings(polylines) = {
  let segs = ()
  for (pi, pts) in polylines.enumerate() {
    for i in range(pts.len() - 1) {
      let (a, b) = (pts.at(i), pts.at(i + 1))
      segs.push((pi, (a.at(0), a.at(1), b.at(0), b.at(1))))
    }
  }
  let n = 0
  for i in range(segs.len()) {
    for j in range(i + 1, segs.len()) {
      if (
        segs.at(i).at(0) != segs.at(j).at(0)
          and seg-cross(segs.at(i).at(1), segs.at(j).at(1))
      ) { n += 1 }
    }
  }
  n
}

// A track is one sideways run inside an inter-rank band:
//   (id, edge, kind, gap, x0, x1, ux, dx, legacy-y)
// x0/x1 span the run, ux is the x of the vertical rising above it, dx the x
// of the vertical dropping below it (none when absent), legacy-y the height
// the pre-allocator formula would give it.
#let track-inside = (p, a, b) => (
  p != none and p > calc.min(a, b) + ceps and p < calc.max(a, b) - ceps
)

// Crossings forced by stacking `a` above `b` in one band: b's riser must
// pierce a's span on its way up, and a's dropper must pierce b's span on its
// way down. Integer-valued, and an adjacent swap changes the band total by
// exactly this pair's difference — which is what lets the greedy ordering
// below terminate.
#let pair-cost(a, b) = {
  let up = if track-inside(b.ux, a.x0, a.x1) { 1 } else { 0 }
  let down = if track-inside(a.dx, b.x0, b.x1) { 1 } else { 0 }
  up + down
}

// Order a band's tracks top-to-bottom to reduce crossings. Optimal ordering
// is NP-hard; adjacent swaps taken only on strict improvement are the
// standard channel-routing heuristic — each swap lowers the integer total by
// at least one, so it settles. `constraints` are hard (above, below) id
// pairs (the entry/exit fans, already crossing-free internally): a swap that
// would invert one is never taken, and the caller passes tracks in a
// constraint-satisfying order, so they hold throughout. Returns
// (order, settled); an unsettled band keeps its legacy heights.
#let order-tracks(tracks, constraints, cap: none) = {
  let order = tracks.map(t => t.id)
  let by-id = (:)
  for t in tracks { by-id.insert(t.id, t) }
  let locked = (:)
  for c in constraints { locked.insert(c.above + "|" + c.below, true) }
  let rounds = if cap == none { tracks.len() + 2 } else { cap }
  let settled = false
  for pass in range(rounds) {
    let swapped = false
    for i in range(order.len() - 1) {
      let (ai, bi) = (order.at(i), order.at(i + 1))
      if (ai + "|" + bi) in locked { continue }
      if (
        pair-cost(by-id.at(bi), by-id.at(ai))
          < pair-cost(
            by-id.at(ai),
            by-id.at(bi),
          )
      ) {
        order.at(i) = bi
        order.at(i + 1) = ai
        swapped = true
      }
    }
    if not swapped {
      settled = true
      break
    }
  }
  (order: order, settled: settled)
}
