#import "model.typ": keys, number
#import "paths.typ": distance

#let check-layout(graph, options) = {
  keys(options, ("main-lines", "incoming-order", "outgoing-order", "external-gap"), "layout")
  let result = (main-lines: (), incoming-order: (), outgoing-order: (), external-gap: 2.4, ..options)
  assert(number(result.external-gap) and result.external-gap > 0, message: "external-gap must be finite and positive")
  let ids = graph.vertices.map(v => v.id)
  assert(type(result.main-lines) == array, message: "main-lines must be an array")
  for line in result.main-lines {
    assert(type(line) == array and line.len() >= 2, message: "main-line needs at least two vertices")
    assert(line.all(id => ids.contains(id)), message: "unknown main-line vertex")
    for (i, id) in line.enumerate() {
      let role = graph.vertices.find(v => v.id == id).role
      assert(role == "interaction" or (role == "incoming" and i == 0) or (role == "outgoing" and i == line.len()-1),
        message: "external main-line vertex must be incoming first or outgoing last: " + id)
    }
    for i in range(line.len()-1) {
      assert(graph.edges.any(e => (e.from, e.to).sorted() == (line.at(i), line.at(i+1)).sorted()),
        message: "main-line vertices are not connected: " + line.at(i) + ", " + line.at(i+1))
    }
  }
  let members = result.main-lines.flatten()
  assert(members.dedup().len() == members.len(), message: "main-lines cannot repeat or share vertices")
  for role in ("incoming", "outgoing") {
    let order = result.at(role + "-order")
    assert(type(order) == array, message: role + "-order must be an array")
    let external = graph.vertices.filter(v => v.role == role).map(v => v.id)
    assert(order.len() == 0 or (order.len() == external.len() and order.dedup().len() == order.len() and order.all(id => external.contains(id))),
      message: role + "-order must list every " + role + " vertex exactly once")
  }
  result
}

// Increasing scalar coordinates, with exact anchors and ordered interpolation.
// Negative y turns top-to-bottom row/leg order into the same problem as x order.
#let ordered-axis(count, anchors, step, origin, description) = {
  let fixed = anchors.keys().map(int).sorted()
  for i in range(calc.max(0, fixed.len()-1)) {
    assert(anchors.at(str(fixed.at(i))) < anchors.at(str(fixed.at(i+1))) - 0.000001,
      message: "conflicting " + description + ": fixed positions violate order")
  }
  range(count).map(i => {
    if str(i) in anchors { anchors.at(str(i)) }
    else if fixed.len() == 0 {origin+i*step}
    else {
      let right = fixed.find(j => j > i)
      let left = fixed.rev().find(j => j < i)
      if left == none {anchors.at(str(right))-(right - i)*step}
      else if right == none {anchors.at(str(left))+(i - left)*step}
      else {anchors.at(str(left))+(anchors.at(str(right))-anchors.at(str(left)))*(i - left)/(right - left)}
    }
  })
}

#let constrain(graph, positions, options) = {
  let lines = options.main-lines
  let members = lines.flatten()
  let explicit = graph.vertices.filter(v => v.at != auto).map(v => v.id)
  let locked = (explicit + members).dedup()
  let row-anchors = (:)
  for (row, line) in lines.enumerate() {
    let fixed = line.filter(id => explicit.contains(id))
    if fixed.len() > 0 {
      let y = positions.at(fixed.first()).at(1)
      assert(fixed.all(id => calc.abs(positions.at(id).at(1)-y) < 0.000001),
        message: "conflicting main-line alignment: " + line.join(", "))
      row-anchors.insert(str(row), -y)
    }
  }
  let rows = ordered-axis(lines.len(), row-anchors, 3.2, -(lines.len()-1)*1.6, "main-line row order")
  let width = if lines.len() == 0 {0} else {(calc.max(..lines.map(line => line.len()))-1)*2.2}
  for (row, line) in lines.enumerate() {
    let anchors = (:)
    for (i, id) in line.enumerate() {
      if explicit.contains(id) { anchors.insert(str(i), positions.at(id).at(0)) }
    }
    let xs = ordered-axis(line.len(), anchors, width/(line.len()-1), -width/2, "main-line " + line.join(", "))
    for (i, id) in line.enumerate() {
      if not explicit.contains(id) { positions.insert(id, (xs.at(i), -rows.at(row))) }
    }
  }

  let internal = graph.vertices.filter(v => v.role == "interaction").map(v => v.id)
  let adjacent(id) = {
    let edges = graph.edges.filter(e => e.from != e.to and (e.from == id or e.to == id))
    edges.map(e => if e.from == id {e.to} else {e.from}).dedup().sorted()
  }
  // Small components outside the main lines live locally above their anchors.
  // This also accommodates a vacuum-polarization insertion without coordinates.
  let remaining = internal.filter(id => not members.contains(id)).sorted()
  let component-index = 0
  if lines.len() > 0 {
    while remaining.len() > 0 {
      let component = (remaining.first(),)
      let i = 0
      while i < component.len() {
        for id in adjacent(component.at(i)).filter(id => remaining.contains(id)) {
          if not component.contains(id) { component.push(id) }
        }
        i += 1
      }
      component = component.sorted()
      remaining = remaining.filter(id => not component.contains(id))
      let attached = component.map(adjacent).flatten().filter(id => members.contains(id)).dedup()
      if attached.len() > 0 {
        let xs = attached.map(id => positions.at(id).at(0))
        let top = calc.max(..attached.map(id => positions.at(id).at(1)))
        let lo = calc.min(..xs)
        let hi = calc.max(..xs)
        for (i, id) in component.enumerate() {
          if not explicit.contains(id) {
            let x = if hi - lo < 0.01 {lo+(i - (component.len()-1)/2)*2.2} else {lo+(hi - lo)*(i+1)/(component.len()+1)}
            positions.insert(id, (x, top+1.8+component-index*1.8))
          }
        }
        component-index += 1
      }
    }
  }

  for role in ("incoming", "outgoing") {
    let external = graph.vertices.filter(v => v.role == role)
    let requested = options.at(role + "-order")
    if lines.len() > 0 {
      let xs = internal.map(id => positions.at(id).at(0))
      for v in external.filter(v => not locked.contains(v.id)) {
        let attached = adjacent(v.id).filter(id => internal.contains(id))
        let y = if attached.len() == 0 {0} else {attached.fold(0, (sum, id) => sum+positions.at(id).at(1))/attached.len()}
        let x = if xs.len() == 0 {if role == "incoming" {-2.8} else {2.8}} else if role == "incoming" {calc.min(..xs)-2.2} else {calc.max(..xs)+2.2}
        positions.insert(v.id, (x, y))
      }
    }
    if requested.len() > 0 or lines.len() > 0 {
      let order = if requested.len() > 0 {requested} else {external.sorted(key: v => v.id).sorted(key: v => -positions.at(v.id).at(1)).map(v => v.id)}
      let anchors = (:)
      for (i, id) in order.enumerate() {
        if locked.contains(id) { anchors.insert(str(i), -positions.at(id).at(1)) }
      }
      let center = if order.len() == 0 {0} else {order.fold(0, (sum, id) => sum - positions.at(id).at(1))/order.len()}
      let ys = ordered-axis(order.len(), anchors, options.external-gap, center - (order.len()-1)*options.external-gap/2, role + "-order")
      for (i, id) in order.enumerate() {
        if not locked.contains(id) { positions.insert(id, (positions.at(id).at(0), -ys.at(i))) }
      }
    }
  }
  // Never silently displace constrained vertices to repair a collision.
  for (i, a) in graph.vertices.enumerate() {
    for b in graph.vertices.slice(i+1) {
      assert(distance(positions.at(a.id), positions.at(b.id)) > calc.max(0.06, a.size+b.size),
        message: "layout constraints overlap vertices " + a.id + ", " + b.id + "; adjust main-lines, external order or at")
    }
  }
  positions
}

#let main-edges(graph, options) = {
  let selected = ()
  for line in options.main-lines {
    for i in range(line.len()-1) {
      let pair = (line.at(i), line.at(i+1)).sorted()
      let group = graph.edges.filter(e => (e.from, e.to).sorted() == pair and e.route == none).sorted(key: e => e.id)
      if group.len() > 0 { selected.push(group.first().id) }
    }
  }
  selected.dedup()
}

#let bridge-path(a, b, route) = {
  assert(calc.abs(a.at(0)-b.at(0)) > 0.000001, message: "route above/below requires horizontally separated endpoints")
  let height = route.level*0.85*if route.side == "above" {1} else {-1}
  let dx = b.at(0)-a.at(0)
  let dy = b.at(1)-a.at(1)
  (kind: "cubic", points: (a, (a.at(0)+dx/3, a.at(1)+dy/3+4*height/3),
    (a.at(0)+2*dx/3, a.at(1)+2*dy/3+4*height/3), b))
}
