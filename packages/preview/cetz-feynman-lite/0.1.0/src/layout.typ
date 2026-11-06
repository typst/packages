#import "geometry.typ": point
#import "paths.typ": distance, sub
#import "constraints.typ": check-layout, constrain, main-edges, bridge-path

// Topology uses undirected, distinct neighbours: loops and multiplicity do not
// change whether a component is a chain or a simple cycle.
#let neighbours(graph, id, ids) = {
  let edges = graph.edges.filter(e => e.from != e.to and (e.from == id or e.to == id))
  edges.map(e => if e.from == id {e.to} else {e.from}).filter(id => ids.contains(id)).dedup().sorted()
}
#let internal-positions(graph, external-gap: 2.4) = {
  let ids = graph.vertices.filter(v => v.role == "interaction").map(v => v.id).sorted()
  let incoming = graph.vertices.filter(v => v.role == "incoming").map(v => v.id)
  let outgoing = graph.vertices.filter(v => v.role == "outgoing").map(v => v.id)
  let remaining = ids
  let positions = (:)
  let cursor = 0
  while remaining.len() > 0 {
    let component = (remaining.first(),)
    let index = 0
    while index < component.len() {
      for id in neighbours(graph, component.at(index), ids) {
        if not component.contains(id) { component.push(id) }
      }
      index += 1
    }
    component = component.sorted()
    remaining = remaining.filter(id => not component.contains(id))
    let ends = component.filter(id => neighbours(graph, id, ids).len() == 1)
    let chain = component.len() == 1 or (ends.len() == 2 and component.all(id => neighbours(graph, id, ids).len() <= 2))
    let cycle = component.len() >= 3 and component.all(id => neighbours(graph, id, ids).len() == 2)
    let order = component
    if chain or cycle {
      let first = if ends.len() > 0 {ends.first()} else {component.first()}
      order = (first,)
      while order.len() < component.len() {
        let next = neighbours(graph, order.last(), ids).find(id => not order.contains(id))
        order.push(next)
      }
      if chain {
        // Prefer incoming attachments on the left and outgoing on the right.
        let score = order.enumerate().fold(0, (sum, item) => {
          let (i, id) = item
          let external = neighbours(graph, id, graph.vertices.filter(v => v.role != "interaction").map(v => v.id))
          let balance = external.fold(0, (n, name) => n + if graph.vertices.find(v => v.id == name).role == "incoming" {1} else {-1})
          sum + (2*i - (order.len()-1))*balance
        })
        if score > 0 { order = order.rev() }
      }
    }
    // A chain of exchange vertices is not necessarily a left-to-right time
    // chain. Multiple vertices with both incoming and outgoing legs represent
    // separate scattering rows. This uses roles/connectivity, not particle names
    // or fermion-arrow directions (which differ for antiparticles).
    let through = component.filter(id => neighbours(graph, id, incoming).len() > 0 and neighbours(graph, id, outgoing).len() > 0)
    let stacked = chain and through.len() >= 2
    let fan = component.map(id => calc.max(neighbours(graph, id, incoming).len(), neighbours(graph, id, outgoing).len()))
    let row-gap = calc.max(2.8, (calc.max(..fan)-1)*external-gap+1.3)
    let radius = calc.max(1.6, component.len()*2.8/(2*calc.pi))
    let width = if stacked {0} else if chain {(component.len()-1)*2.8} else {2*radius}
    let local = (:)
    for (i, id) in order.enumerate() {
      local.insert(id, if stacked {(cursor, ((order.len()-1)/2 - i)*row-gap)} else if chain {(cursor+i*2.8, 0)} else {
        let angle = 180deg - i*360deg/order.len()
        (cursor+radius+radius*calc.cos(angle), radius*calc.sin(angle))
      })
    }
    // A fixed vertex anchors the template. Further fixed vertices override it.
    let anchors = graph.vertices.filter(v => component.contains(v.id) and v.at != auto).sorted(key: v => v.id)
    let shift = if anchors.len() > 0 {sub(anchors.first().at, local.at(anchors.first().id))} else {(0, 0)}
    for id in order {
      let p = local.at(id)
      positions.insert(id, (p.at(0)+shift.at(0), p.at(1)+shift.at(1)))
    }
    cursor += width + 3.2
  }
  if ids.len() > 0 and not graph.vertices.any(v => v.role == "interaction" and v.at != auto) {
    let xs = positions.values().map(p => p.at(0))
    let center = (calc.min(..xs)+calc.max(..xs))/2
    for id in ids { let p = positions.at(id); positions.insert(id, (p.at(0)-center, p.at(1))) }
  }
  positions
}
#let arc-path(a, b, bend) = {
  if bend == 0 { return (kind: "line", points: (a, b)) }
  let dx = b.at(0)-a.at(0)
  let dy = b.at(1)-a.at(1)
  let d = distance(a, b)
  (kind: "arc", points: (a, b), radius: d*(1+bend*bend)/(4*calc.abs(bend)),
    start: calc.atan2(dx, dy) + (if bend > 0 {90deg} else {-90deg}) + 2*calc.atan(bend),
    delta: -4*calc.atan(bend))
}
// Distance to each sampled segment, not just sample points, catches even a
// small vertex lying between two samples. This checks centerlines, not labels.
#let hits(path, edge, vertices, positions) = {
  let others = vertices.filter(v => v.id != edge.from and v.id != edge.to)
  if others.len() == 0 { return () }
  let samples = range(193).map(i => point(path, i/192))
  others.filter(v => {
    let p = positions.at(v.id)
    let radius = calc.max(0.06, if v.marker == "none" {0} else if v.marker == "cross" {v.size*calc.sqrt(2)} else {v.size})
    range(192).any(i => {
      let a = samples.at(i)
      let b = samples.at(i+1)
      let d = sub(b, a)
      let square = d.at(0)*d.at(0)+d.at(1)*d.at(1)
      let t = if square == 0 {0} else {calc.min(1, calc.max(0, ((p.at(0)-a.at(0))*d.at(0)+(p.at(1)-a.at(1))*d.at(1))/square))}
      distance(p, (a.at(0)+t*d.at(0), a.at(1)+t*d.at(1))) < radius
    })
  }).map(v => v.id)
}
// All paths run from the declared edge.from to edge.to. No ID-based arrow sign.
#let layout(graph, options: (:)) = {
  let constraints = check-layout(graph, options)
  let positions = internal-positions(graph, external-gap: constraints.external-gap)
  let vs = graph.vertices
  for v in vs.filter(v => v.at != auto) { positions.insert(v.id, v.at) }
  let internal = vs.filter(v => v.role == "interaction").map(v => v.id)
  let attachment(v) = neighbours(graph, v.id, internal)
  // Reserve all explicit coordinates first; only automatically placed vertices
  // may move when a template or an external fan lands on another vertex.
  let placed = vs.filter(v => v.at != auto).map(v => v.id)
  let automatic = vs.filter(v => v.at == auto).sorted(key: v => (if v.role == "interaction" {"0"} else {"1"}) + v.id)
  for v in automatic {
    if v.role != "interaction" {
      let attached = attachment(v)
      let peers = vs.filter(w => w.role == v.role and attachment(w) == attached).sorted(key: w => w.id)
      let i = peers.position(w => w.id == v.id)
      let anchor = if attached.len() > 0 {positions.at(attached.first())} else {(0, 0)}
      positions.insert(v.id, (anchor.at(0) + if v.role == "incoming" {-2.8} else {2.8},
        anchor.at(1)+(i - (peers.len()-1)/2)*constraints.external-gap))
    }
    let base = positions.at(v.id)
    let free(p) = placed.all(id => {
      let other = vs.find(w => w.id == id)
      distance(p, positions.at(id)) > v.size+other.size+0.15
    })
    let p = base
    let step = 0
    while not free(p) and step < 64 {
      step += 1
      p = (base.at(0), base.at(1)+calc.ceil(step/2)*0.75*if calc.rem(step, 2) == 1 {1} else {-1})
    }
    assert(free(p), message: "cannot place vertex " + v.id + "; set explicit at coordinates")
    positions.insert(v.id, p)
    placed.push(v.id)
  }
  if constraints.main-lines.len() > 0 or constraints.incoming-order.len() > 0 or constraints.outgoing-order.len() > 0 {
    positions = constrain(graph, positions, constraints)
  }
  let backbone = main-edges(graph, constraints)
  let routes = graph.edges.map(e => {
    let a = positions.at(e.from)
    let b = positions.at(e.to)
    let pair = (e.from, e.to).sorted()
    let group = graph.edges.filter(f => (f.from, f.to).sorted() == pair).sorted(key: f => f.id)
    let k = group.position(f => f.id == e.id)
    let path = if e.from == e.to {
      (kind: "loop", origin: a, size: e.loop-size, aspect: e.loop-aspect,
        angle: if e.loop-angle == auto {90deg + k*360deg/group.len()} else {e.loop-angle})
    } else {
      assert(a != b, message: "distinct endpoints have coincident coordinates")
      if e.route != none { bridge-path(a, b, e.route) }
      else if e.controls != none {
        (kind: "cubic", points: (a, ..e.controls, b))
      } else {
        let bend = if e.bend != auto {e.bend} else if backbone.contains(e.id) {0} else {
          let value = if group.len() <= 3 {(k - (group.len()-1)/2)*0.6} else {2*k/(group.len()-1)-1}
          value * if e.from == pair.first() {1} else {-1}
        }
        arc-path(a, b, bend)
      }
    }
    (..e, path: path)
  })
  let adjusted = (:)
  let automatic-path(e) = if e.from == e.to {e.loop-angle == auto} else {e.bend == auto and e.controls == none and e.route == none and not backbone.contains(e.id)}
  // Reserve explicit geometry before allocating automatic paths, regardless of
  // edge ID or declaration order. Two explicit paths may intentionally overlap.
  for e in routes.sorted(key: e => (if automatic-path(e) {"1"} else {"0"}) + e.id) {
    let a = positions.at(e.from)
    let b = positions.at(e.to)
    let path = e.path
    let blocked = hits(path, e, vs, positions)
    let siblings = routes.filter(r => r.id != e.id and (r.from, r.to).sorted() == (e.from, e.to).sorted())
    let available(p) = siblings.all(r =>
      distance(point(p, 0.5), point(adjusted.at(r.id, default: r.path), 0.5)) > 0.05)
    if blocked.len() > 0 or (automatic-path(e) and not available(path)) {
      let candidates = if e.from == e.to and e.loop-angle == auto {
        let count = calc.max(12, (siblings.len()+1)*4)
        range(1, count).map(i => (..path, angle: path.angle+i*360deg/count))
      } else if e.from != e.to and automatic-path(e) {
        let count = siblings.len()+1
        let slots = range(count).map(k => if count <= 3 {(k - (count - 1)/2)*0.6} else {2*k/(count - 1)-1})
        let resolution = calc.max(10, count*4)
        let extra = range(resolution+1).map(i => -1+2*i/resolution)
        // Compare physical sides in a canonical endpoint direction. Public bend
        // and all arrows retain the user's declared from -> to semantics.
        let sign = if e.from == (e.from, e.to).sorted().first() {1} else {-1}
        (slots + (0.2, -0.2, 0.4, -0.4, 0.6, -0.6, 0.8, -0.8, 1, -1) + extra).dedup().map(bend => arc-path(a, b, bend*sign))
      } else {()}
      let clear = candidates.find(p => available(p) and hits(p, e, vs, positions).len() == 0)
      assert(clear != none, message: if blocked.len() > 0 {
        "edge " + e.id + " passes through non-endpoint vertex " + blocked.join(", ") + "; set vertex at or edge bend/controls/loop-angle"
      } else {"cannot allocate distinct parallel path for edge " + e.id + "; set vertex at or edge bend/controls/loop-angle"})
      path = clear
    }
    adjusted.insert(e.id, path)
  }
  routes = routes.map(e => (..e, path: adjusted.at(e.id)))
  (..graph, positions: positions, routes: routes)
}
