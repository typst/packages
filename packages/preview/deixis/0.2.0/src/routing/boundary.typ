// Finite visibility candidates on one horizontal continuation boundary. This
// is geometry only: obstacle/stub validity and reachability belong to search.
#let _deixis-boundary-targets(target, first, prepared, boundary, via, escape, additional: ()) = {
  assert(target.owner == none and target.normal in ((0, 1), (0, -1)),
    message: "deixis: Automatic continuation allocation requires an unowned horizontal boundary.")
  let lo = boundary.left
  let hi = boundary.right
  if prepared.bounds != none {
    lo = calc.max(lo, prepared.bounds.left)
    hi = calc.min(hi, prepared.bounds.right)
  }
  if lo > hi { return () }
  let anchors = (first,) + additional + via
  let xs = ((lo, hi, calc.min(hi, calc.max(lo, boundary.preferred)))
    + anchors.map(p => (p.first() - escape, p.first(), p.first() + escape)).flatten()
    + prepared.obstacles.map(r => (r.left, r.right)).flatten())
  xs.sorted().dedup().filter(x => lo <= x and x <= hi).map(x =>
    target + (point: (x, target.point.last()), preference: calc.abs(x - boundary.preferred)))
}
