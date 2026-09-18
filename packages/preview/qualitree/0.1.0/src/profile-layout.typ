// Competitive scores are data: only y may move. This module works in row units,
// independent of Typst drawing, colors and fonts. The renderer maps x back to
// score ticks and y back to physical rows. Missing observations remain holes.

#let _cross(a, b, c) = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
#let _intersects(a, b, c, d) = {
  _cross(a, b, c) * _cross(a, b, d) < 0 and _cross(c, d, a) * _cross(c, d, b) < 0
}

// Count crossings adjacent to one row, using both incoming and outgoing edges.
// Touching endpoints are intentional ties, not crossings. A deterministic local
// search avoids factorial permutations when a chart contains many alternatives.
#let _cost(points, row) = {
  let cost = 0
  for edge in (row - 1, row) {
    if edge < 0 or edge + 1 >= points.first().len() { continue }
    for a in range(points.len()) {
      for b in range(a + 1, points.len()) {
        let p = (points.at(a).at(edge), points.at(a).at(edge + 1),
          points.at(b).at(edge), points.at(b).at(edge + 1))
        if p.any(v => v == none) { continue }
        if _intersects(..p) { cost += 1 }
      }
    }
  }
  cost
}

// Return an array per series of (x: original-score, y: row-center + offset).
// Nearby scores are grouped using diameter/x-step. Offsets never exceed spread
// (at most 0.3 row); ties get distinct lanes. This reduces avoidable crossings,
// but cannot remove crossings forced by reversals in the observed scores.
#let stagger-profiles(scores, enabled: true, spread: 0.30, diameter: 0.22, x-step: 1) = {
  assert(type(enabled) == bool, message: "qfd: marker-stagger must be boolean")
  assert(spread >= 0 and spread <= 0.30, message: "qfd: marker spread must be between 0 and 0.30 rows")
  if scores.len() == 0 { return () }
  assert(scores.all(s => s.len() == scores.first().len()), message: "qfd: profiles must have equal lengths")
  let points = scores.map(s => s.enumerate().map(((r, v)) =>
    if v == none { none } else { (x: v, y: r + 0.5) }))
  if not enabled or spread == 0 { return points }
  for r in range(scores.first().len()) {
    let indices = range(scores.len()).filter(s => scores.at(s).at(r) != none)
      .sorted(key: s => scores.at(s).at(r))
    let groups = ()
    for s in indices {
      if groups.len() == 0 or calc.abs(scores.at(s).at(r) - scores.at(groups.last().last()).at(r)) * x-step >= diameter {
        groups.push((s,))
      } else {
        let group = groups.pop()
        group.push(s)
        groups.push(group)
      }
    }
    for group in groups {
      if group.len() < 2 { continue }
      let span = calc.min(spread, diameter * (group.len() - 1) / 2)
      for (lane, s) in group.enumerate() {
        points.at(s).at(r).y += (2 * lane / (group.len() - 1) - 1) * span
      }
      // Pair swaps improve the neighboring segments without changing the lane
      // set. Equal costs keep input order, preventing arbitrary visual churn.
      for pass in range(2) {
        for a in range(group.len()) {
          for b in range(a + 1, group.len()) {
            let i = group.at(a)
            let j = group.at(b)
            let candidate = points
            let y = candidate.at(i).at(r).y
            candidate.at(i).at(r).y = candidate.at(j).at(r).y
            candidate.at(j).at(r).y = y
            if _cost(candidate, r) < _cost(points, r) { points = candidate }
          }
        }
      }
    }
  }
  points
}
