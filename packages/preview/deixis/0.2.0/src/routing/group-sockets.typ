#import "group-geometry.typ": endpoint, pair-metrics
#import "boundary.typ": _deixis-boundary-targets

// Finite, deterministic coordinate-descent proposals. The declaration adapter
// already owns allowed sides, exact pins/percentages and visibility projections.
// Keep current sockets first; cap each side before the Cartesian product, so a
// long sliding border cannot create an unbounded proposal list.
#let _deixis-socket-pairs(scene, edges, records, index, spacing, max-length) = {
  let edge = edges.at(index)
  let record = records.at(index)
  let allocation = edge.at("allocation", default: none)
  if (record.status != "ok" or allocation == none
    or not edge.at("reselect", default: true)) { return () }
  let congested = records.enumerate().any(((i, other)) => i != index and other.status == "ok"
    and other.page == record.page
    and pair-metrics(scene, edge, record, edges.at(i), other, spacing).exposure > 0)
  if not congested { return () }
  let distance(a, b) = a.zip(b).map(((x, y)) => calc.abs(x - y)).sum()
  let choices(values, current) = {
    let rest = values.filter(p => p != current).enumerate()
      .sorted(key: ((i, p)) => (distance(p.point, current.point), i)).map(((i, p)) => p)
    (current,) + rest.slice(0, calc.min(7, rest.len()))
  }
  let source = (endpoint(edge.from),)
  let target = (endpoint(edge.to),)
  if allocation.boundary == none {
    source = choices(allocation.source, source.first())
    target = choices(allocation.target, target.first())
  } else {
    // A page continuation can move only its automatic relay here. Its accepted
    // real socket, exact visits, boundary y and inward normal remain fixed.
    // Pages have separate obstacles and costs; pairing the remote searches
    // would add work without a coupling constraint or a different objective.
    let plane = scene.planes.find(p => p.page == record.page)
    let relay = if allocation.reverse { source.first() } else { target.first() }
    let real = if allocation.reverse { target.first() } else { source.first() }
    let rails = records.filter(r => r.status == "ok" and r.page == record.page)
      .fold((), (out, r) => out + r.points)
    let additional = rails.fold(rails, (out, p) => out + ((p.first() - spacing, p.last()),
      (p.first() + spacing, p.last())))
    let candidates = _deixis-boundary-targets(relay, real.point, plane,
      allocation.boundary, edge.at("via", default: ()), scene.escape, additional: additional)
      .map(p => { let _ = p.remove("preference"); p })
    let selected = choices(candidates, relay)
    if allocation.reverse { source = selected } else { target = selected }
  }
  let proposals = ()
  for (s, from) in source.enumerate() {
    for (t, to) in target.enumerate() {
      if s == 0 and t == 0 { continue }
      let visits = (from.point,) + edge.at("via", default: ()) + (to.point,)
      let lower = visits.windows(2).map(((a, b)) => distance(a, b)).sum()
      if lower > max-length { continue }
      proposals.push((from: from, to: to, rank: (int(s != 0) + int(t != 0), lower,
        distance(from.point, source.first().point) + distance(to.point, target.first().point), s, t)))
    }
  }
  proposals.sorted(key: p => p.rank)
}
