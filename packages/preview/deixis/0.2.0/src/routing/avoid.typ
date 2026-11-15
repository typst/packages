#import "lane-cost.typ": exposure, tracks
#import "lane-index.typ": prepare-costs, indexed-exposure
#import "scene-index.typ": _deixis-index-blocked
#import "boundary.typ": _deixis-boundary-targets

// Direction-aware A* over a lazy rectilinear lattice. Geometry/index preparation
// belongs to the immutable scene and is shared by all searches against it.
#let inside(p, r) = r.left < p.first() and p.first() < r.right and r.top < p.last() and p.last() < r.bottom
#let distance(a, b) = calc.abs(a.first() - b.first()) + calc.abs(a.last() - b.last())
#let intersects(a, b, r) = {
  if a == b { return inside(a, r) }
  if a.first() == b.first() {
    r.left < a.first() and a.first() < r.right and calc.min(a.last(), b.last()) < r.bottom and calc.max(a.last(), b.last()) > r.top
  } else {
    assert.eq(a.last(), b.last())
    r.top < a.last() and a.last() < r.bottom and calc.min(a.first(), b.first()) < r.right and calc.max(a.first(), b.first()) > r.left
  }
}
#let directions = ((1, 0), (0, 1), (-1, 0), (0, -1))
#let heading(a, b) = if a.first() < b.first() { 0 } else if a.last() < b.last() { 1 } else if a.first() > b.first() { 2 } else { 3 }
#let opposite(d) = if d == 4 { 4 } else { calc.rem(d + 2, 4) }
#let on-segment(p, a, b) = {
  ((a.first() == b.first() and p.first() == a.first()) or (a.last() == b.last() and p.last() == a.last())) and distance(a, p) + distance(p, b) == distance(a, b)
}
#let advance(stage, a, b, via) = {
  let previous = 0
  while stage < via.len() and on-segment(via.at(stage), a, b) {
    let d = distance(a, via.at(stage))
    if d < previous { break }
    previous = d
    stage += 1
  }
  stage
}
#let less(a, b) = {
  for key in ("f", "g", "serial") {
    if a.at(key) < b.at(key) { return true }
    if a.at(key) > b.at(key) { return false }
  }
  false
}
#let push(heap, value) = {
  heap.push(value)
  let i = heap.len() - 1
  while i > 0 {
    let parent = calc.floor((i - 1) / 2)
    if not less(heap.at(i), heap.at(parent)) { break }
    let old = heap.at(parent); heap.at(parent) = heap.at(i); heap.at(i) = old
    i = parent
  }
  heap
}
#let pop(heap) = {
  let value = heap.first()
  let last = heap.pop()
  if heap.len() > 0 {
    heap.at(0) = last
    let i = 0
    while i * 2 + 1 < heap.len() {
      let child = i * 2 + 1
      if child + 1 < heap.len() and less(heap.at(child + 1), heap.at(child)) { child += 1 }
      if not less(heap.at(child), heap.at(i)) { break }
      let old = heap.at(i); heap.at(i) = heap.at(child); heap.at(child) = old
      i = child
    }
  }
  (heap, value)
}

#let _deixis-avoid(source, target, prepared, via: (), clearance: 4, escape: 4, bend-cost: 12,
  max-cells: 65536, max-expansions: 50000, boundary: none, sources: none, targets: none,
  lanes: none, spacing: 3, weight: 4, policy: "independent", cost-backend: "auto",
  cost-min-lanes: 16, cost-max-rows: 1024, cost-max-checks: 32768, cost-max-entries: 8192,
) = {
  assert((sources == none or sources.len() > 0) and (targets == none or targets.len() > 0)
    and (boundary == none or targets == none), message: "deixis: Internal routing alternatives need nonempty sets and a single boundary target.")
  let grouped = lanes != none
  if not grouped { lanes = () }
  let active = lanes.len() > 0 and (policy == "reserved" or (policy == "soft" and weight > 0))
  assert(cost-backend in ("auto", "scan", "index"))
  let cost-index = (kind: "scan", lanes: lanes, spacing: spacing)
  let surcharge(a, b, index) = {
    if not active or policy != "soft" { return 0 }
    let cost = weight * indexed-exposure(a, b, index)
    assert(cost == cost and calc.abs(cost) < calc.inf,
      message: "deixis: Routing group costs overflow; reduce coordinate magnitudes or weight.")
    cost
  }
  let forbidden(a, b, index) = active and policy == "reserved" and indexed-exposure(a, b, index) > 0
  let multiple = sources != none or targets != none
  let rectangles = prepared.obstacles
  let obstacles = prepared.originals
  let names = obstacles.map(r => r.id)
  let bounds = prepared.bounds
  let fail(status, detail, stats: (:)) = (status: status, detail: detail, points: (), stats: stats)
  if via.len() > 8 { return fail("budget", "waypoint-count") }
  let in-bounds(p) = bounds == none or (bounds.left <= p.first() and p.first() <= bounds.right and bounds.top <= p.last() and p.last() <= bounds.bottom)
  // An owner exemption applies only to a short outward port stub. Routing does
  // not ignore that rectangle everywhere, nor the overlapping foreign shapes.
  let stub(e) = {
    let length = escape
    if e.owner != none {
      assert(e.owner in names and e.normal != none, message: "deixis: Numeric routing owner needs an avoidance node and a cardinal outward normal.")
      let r = obstacles.find(r => r.id == e.owner)
      let gap = e.at("owner-gap", default: 0)
      // The document adapter may retain an outward port gap. Numeric public
      // endpoints keep gap zero and their strict original-border contract.
      let p = e.point
      let d = directions.position(v => v == e.normal)
      let offset = if d == 0 { p.first() - r.right } else if d == 2 { r.left - p.first() }
        else if d == 1 { p.last() - r.bottom } else { r.top - p.last() }
      // Test the outward side directly: subtracting a tiny face coordinate
      // from a larger gap and then reconstructing it loses exact equality.
      let attached = if gap == 0 { offset == 0 } else { gap > 0 and offset >= 0 }
      assert(attached and if d in (0, 2) { r.top <= p.last() and p.last() <= r.bottom }
        else { r.left <= p.first() and p.first() <= r.right },
        message: "deixis: Numeric routing owned point must lie on its node boundary with an outward normal.")
      length = calc.max(length, clearance - gap)
    }
    if e.normal == none { e.point } else { e.point.zip(e.normal).map(pair => pair.first() + pair.last() * length) }
  }
  let starts = (if sources == none { (source,) } else { sources }).enumerate()
    .map(((rank, e)) => (endpoint: e, first: stub(e), rank: rank))
  let first = starts.first().first
  let terminals = if boundary == none { (target,) } else {
    _deixis-boundary-targets(target, first, prepared, boundary, via, escape,
      additional: starts.slice(1).map(s => s.first))
  }
  if targets != none { terminals = targets }
  let goals = terminals.enumerate().map(((rank, e)) =>
    (endpoint: e, last: stub(e), preference: e.at("preference", default: 0), rank: rank,
      direction: if e.normal == none { 4 } else { opposite(directions.position(v => v == e.normal)) }))
  let finite(v) = v == v and calc.abs(v) < calc.inf
  assert((starts.map(s => s.first).flatten() + goals.map(g => g.last).flatten()).all(finite), message: "deixis: Numeric scene endpoint escape overflows; reduce coordinates or escape.")
  let validate(e, end, role) = {
    if not in-bounds(e.point) or not in-bounds(end) { return fail("endpoint-blocked", role + "-bounds") }
    for r in rectangles {
      if r.id != e.owner and (inside(e.point, r) or intersects(e.point, end, r)) { return fail("endpoint-blocked", role + "-obstacle") }
      if inside(end, r) { return fail("endpoint-blocked", role + "-escape") }
    }
    if active and forbidden(e.point, end, cost-index) { return fail("lane-blocked", role + "-stub") }
    none
  }
  let invalid = validate(starts.first().endpoint, first, "source")
  if sources == none and invalid != none { return invalid }
  if sources != none { starts = starts.filter(s => validate(s.endpoint, s.first, "source") == none) }
  if starts.len() == 0 { return invalid }
  if boundary == none and targets == none {
    invalid = validate(target, goals.first().last, "target")
    if invalid != none { return invalid }
  } else {
    invalid = if goals.len() == 0 { none } else { validate(goals.first().endpoint, goals.first().last, "target") }
    goals = goals.filter(g => validate(g.endpoint, g.last, "target") == none)
    if goals.len() == 0 and boundary == none { return invalid }
  }
  if goals.len() == 0 { return fail("endpoint-blocked", "continuation-boundary") }
  for (i, p) in via.enumerate() {
    if not in-bounds(p) or rectangles.any(r => inside(p, r)) { return fail("waypoint-blocked", str(i)) }
  }
  let points = starts.map(s => s.first) + goals.map(g => g.last) + via
  let xs = points.map(p => p.first()) + rectangles.map(r => (r.left, r.right)).flatten()
  let ys = points.map(p => p.last()) + rectangles.map(r => (r.top, r.bottom)).flatten()
  if active {
    let (lane-xs, lane-ys) = tracks(lanes, spacing)
    xs += lane-xs; ys += lane-ys
  }
  // Reversing ports and ordered returns need nearby detour tracks, even in an
  // empty scene. Rectangle boundaries alone can force a detour to the page edge.
  xs += points.map(p => (p.first() - escape, p.first() + escape)).flatten()
  ys += points.map(p => (p.last() - escape, p.last() + escape)).flatten()
  if bounds == none {
    xs += (calc.min(..xs) - escape, calc.max(..xs) + escape)
    ys += (calc.min(..ys) - escape, calc.max(..ys) + escape)
  } else { xs += (bounds.left, bounds.right); ys += (bounds.top, bounds.bottom) }
  assert((xs + ys).all(finite), message: "deixis: Numeric scene search coordinates overflow; reduce coordinate magnitudes or escape.")
  xs = xs.sorted().dedup().filter(x => bounds == none or (bounds.left <= x and x <= bounds.right))
  ys = ys.sorted().dedup().filter(y => bounds == none or (bounds.top <= y and y <= bounds.bottom))
  let nx = xs.len(); let ny = ys.len(); let count = nx * ny
  if count > max-cells { return fail("budget", "grid-cells", stats: (cells: count)) }
  if active and cost-backend != "scan" {
    cost-index = prepare-costs(lanes, spacing, xs, ys,
      min-lanes: if cost-backend == "index" { 0 } else { cost-min-lanes },
      max-rows: cost-max-rows, max-checks: cost-max-checks, max-entries: cost-max-entries)
  }
  // Coordinates are a candidate lattice, but occupancy and edges are never
  // materialized. Reuse scene indexes and test only expanded adjacent edges.
  let position(i) = (xs.at(calc.floor(i / ny)), ys.at(calc.rem(i, ny)))
  let neighbors(i) = {
    let candidates = ()
    if calc.floor(i / ny) > 0 { candidates.push(i - ny) }
    if calc.rem(i, ny) > 0 { candidates.push(i - 1) }
    if calc.floor(i / ny) + 1 < nx { candidates.push(i + ny) }
    if calc.rem(i, ny) + 1 < ny { candidates.push(i + 1) }
    let p = position(i)
    candidates.filter(j => {
      let q = position(j)
      if active and policy == "reserved" and forbidden(p, q, cost-index) { return false }
      if p.first() == q.first() {
        not _deixis-index-blocked(prepared.vertical, p.first(), p.last(), q.last())
      } else { not _deixis-index-blocked(prepared.horizontal, p.last(), p.first(), q.first()) }
    })
  }
  let index(p) = xs.position(v => v == p.first()) * ny + ys.position(v => v == p.last())
  let goal-index = (:)
  for goal in goals {
    let k = str(index(goal.last))
    if k not in goal-index { goal-index.insert(k, ()) }
    goal-index.at(k).push(goal)
  }
  // Boundary targets share one y and normal. Cache the one-dimensional lower
  // bound per lattice column instead of scanning every goal at every expansion.
  let terminal-x = if boundary == none { () } else {
    xs.map(x => calc.min(..goals.map(g => calc.abs(x - g.endpoint.point.first()) + g.preference)))
  }
  // Sliding terminal stubs often share one x or y. Cache their exact Manhattan
  // lower bound along the varying axis, instead of scanning every socket at
  // every expanded state. Ordinary/boundary search keeps its existing policy.
  let line-axis = if boundary != none or targets == none or goals.len() < 2 { none }
    else if goals.all(g => g.last.first() == goals.first().last.first()) { 0 }
    else if goals.all(g => g.last.last() == goals.first().last.last()) { 1 } else { none }
  let line-distance = if line-axis == none { () } else {
    (if line-axis == 0 { ys } else { xs }).map(v => calc.min(..goals.map(g =>
      calc.abs(v - g.last.at(1 - line-axis)) + distance(g.last, g.endpoint.point))))
  }
  let terminal-distance(p) = calc.min(..goals.map(g => distance(p, g.endpoint.point) + g.preference))
  let via-tail = if via.len() == 0 { 0 } else { terminal-distance(via.last()) }
  let heuristic(i, stage) = {
    if stage < via.len() {
      // Remaining visits may lie on the final mandatory stub. Requiring a trip
      // back to that stub's beginning would overestimate the admissible bound.
      let knots = (position(i),) + via.slice(stage)
      return knots.windows(2).map(pair => distance(..pair)).sum() + via-tail
    }
    if boundary == none {
      if line-axis != none {
        return calc.abs(position(i).at(line-axis) - goals.first().last.at(line-axis))
          + line-distance.at(if line-axis == 0 { calc.rem(i, ny) } else { calc.floor(i / ny) })
      }
      return calc.min(..goals.map(g => distance(position(i), g.last) + distance(g.last, g.endpoint.point)))
    }
    terminal-x.at(calc.floor(i / ny)) + calc.abs(position(i).last() - target.point.last())
  }
  let key(node, direction, stage) = str(node) + ":" + str(direction) + ":" + str(stage)
  let costs = (:); let roots = (:); let parents = (:); let locations = (:)
  let heap = (); let serial = -1; let expanded = 0
  for start in starts {
    let begin = index(start.first)
    let direction = if start.endpoint.normal == none { 4 } else { directions.position(v => v == start.endpoint.normal) }
    let stage = advance(0, start.endpoint.point, start.first, via)
    let initial = key(begin, direction, stage)
    let cost = distance(start.endpoint.point, start.first) + if active { surcharge(start.endpoint.point, start.first, cost-index) } else { 0 }
    if cost >= costs.at(initial, default: calc.inf) { continue }
    costs.insert(initial, cost); roots.insert(initial, start.rank); locations.insert(initial, begin)
    serial += 1
    heap = push(heap, (node: begin, direction: direction, stage: stage, root: start.rank,
      g: cost, f: cost + heuristic(begin, stage), serial: serial))
  }
  let best = none; let best-cost = calc.inf; let best-goal = none
  while heap.len() > 0 {
    let item = none
    (heap, item) = pop(heap)
    if (if boundary == none and not multiple { item.f >= best-cost } else { item.f > best-cost }) { break }
    let current = key(item.node, item.direction, item.stage)
    if item.g != costs.at(current) or item.root != roots.at(current) { continue }
    expanded += 1
    if expanded > max-expansions { return fail("budget", "search-expansions", stats: (cells: count, expanded: expanded)) }
    for goal in goal-index.at(str(item.node), default: ()) {
      let final-dir = goal.direction
      if (advance(item.stage, goal.last, goal.endpoint.point, via) == via.len()
        and (final-dir == 4 or item.direction == 4 or item.direction != opposite(final-dir))) {
        let cost = (item.g + distance(goal.last, goal.endpoint.point) + (if active { surcharge(goal.last, goal.endpoint.point, cost-index) } else { 0 }) + goal.preference
          + if final-dir != 4 and item.direction != 4 and final-dir != item.direction { bend-cost } else { 0 })
        let tie = (cost == best-cost and best-goal != none and if boundary != none {
          goal.preference < best-goal.preference or (goal.preference == best-goal.preference
            and (goal.endpoint.point.first() < best-goal.endpoint.point.first()
              or (goal.endpoint.point.first() == best-goal.endpoint.point.first() and item.root < roots.at(best))))
        } else { goal.rank < best-goal.rank or (goal.rank == best-goal.rank and item.root < roots.at(best)) })
        if cost < best-cost or tie { best = current; best-cost = cost; best-goal = goal }
      }
    }
    for j in neighbors(item.node) {
      let direction = heading(position(item.node), position(j))
      if item.direction != 4 and direction == opposite(item.direction) { continue }
      let stage = advance(item.stage, position(item.node), position(j), via)
      let next = key(j, direction, stage)
      let cost = (item.g + distance(position(item.node), position(j)) + (if active { surcharge(position(item.node), position(j), cost-index) } else { 0 })
        + if item.direction != 4 and item.direction != direction { bend-cost } else { 0 })
      if (cost < costs.at(next, default: calc.inf) or (multiple and cost == costs.at(next, default: calc.inf)
        and item.root < roots.at(next, default: calc.inf))) {
        costs.insert(next, cost); parents.insert(next, current); locations.insert(next, j)
        roots.insert(next, item.root)
        serial += 1
        heap = push(heap, (node: j, direction: direction, stage: stage, root: item.root, g: cost, f: cost + heuristic(j, stage), serial: serial))
      }
    }
  }
  let stats = (cells: count, expanded: expanded, queued: serial + 1)
  if best == none { return fail("no-path", "exhausted-graph", stats: stats) }
  let result = ()
  let current = best
  while true {
    result.push(position(locations.at(current)))
    if current not in parents { break }
    current = parents.at(current)
  }
  let selected = starts.find(s => s.rank == roots.at(best)).endpoint
  result = (selected.point,) + result.rev() + (best-goal.endpoint.point,)
  let clean = ()
  for p in result {
    if clean.len() > 0 and clean.last() == p { continue }
    if clean.len() > 1 and clean.last() not in via and on-segment(clean.last(), clean.at(-2), p) { let _ = clean.pop() }
    clean.push(p)
  }
  let length = clean.windows(2).map(pair => distance(..pair)).fold(0, (a, b) => a + b)
  let headings = clean.windows(2).map(pair => heading(..pair))
  let bends = headings.windows(2).filter(pair => pair.first() != pair.last()).len()
  let score = length + bend-cost * bends
  let congestion = if not grouped { 0 } else { clean.windows(2).map(pair => exposure(..pair, lanes, spacing)).sum(default: 0) }
  let weighted-score = score + if active and policy == "soft" { weight * congestion } else { 0 }
  assert(calc.abs(weighted-score + best-goal.preference - best-cost) < 1e-7, message: repr((clean, length, bends, best-cost)))
  let allocation = if boundary == none { (:) } else { (preference: best-goal.preference, allocation-cost: best-cost) }
  let cost-metrics = if grouped { (congestion: congestion, weighted-score: weighted-score) } else { (:) }
  (status: "ok", points: clean, length: length, bends: bends, score: score, stats: stats) + cost-metrics + allocation + if multiple {
    (selection: (source: selected, target: best-goal.endpoint))
  } else { (:) }
}
