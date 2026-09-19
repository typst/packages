// Contextual layout of data-only position expressions. Outlines are prepared
// independently of placement; an iterative axis graph then resolves positions.
#import "utility.typ": node-key, is-content
#import "position.typ": numeric, axis, linear, point-data, pack-captures, empty-captures
#import "node.typ": node-visual-spec, node-outline, gate-port-on-outline
#import "geometry.typ": absolute-length, num

// Shared by the ordinary edge fast path and deferred node/content placement.
#let port-offset(visual, outline, side, index, unit, rotate: 0deg, port-spacing: auto, size-factor: 1) = {
  assert(visual.port-layout == "box", message: "port() expects a port-capable node such as gate()")
  let count = visual.legs.at(side, default: 0)
  assert(index < count, message: "gate has no port #" + str(index) + " on side \"" + side + "\" (it has " + str(count) + ")")
  let spacing = visual.port-spacing
  if spacing == auto { spacing = port-spacing }
  if spacing != auto { spacing = absolute-length(spacing) * visual.size-scale * size-factor }
  let delta = gate-port-on-outline(outline, visual.legs, side, index, rotate: rotate, port-spacing: spacing)
  (num(delta.at(0)) / num(unit), num(delta.at(1)) / num(unit))
}

#let needs-position-layout(pending, work) = {
  if pending.any(n => not numeric(n.x) or not numeric(n.y)) { return true }
  for item in work {
    if is-content(item) {
      if not numeric(item.x) or not numeric(item.y) { return true }
    } else if item.at("deferred-kind", default: none) != none {
      for wp in item.waypoints {
        if wp.defer != none and (wp.defer.type == "position" or (wp.defer.type == "port" and wp.node == none)) {
          return true
        }
      }
    }
  }
  false
}

// Merge flat capture tables into diagram-local identities. Coordinate trees
// and work items then hold only small integer references, never ancestor DAGs.
#let normalize-captures(pending, work) = {
  let captures = empty-captures
  for node in pending { captures = pack-captures(node, "node", captures).captures }
  let normalized = ()
  for source in work {
    let item = source
    if is-content(item) {
      let x = pack-captures(item.x, "scalar", captures)
      let y = pack-captures(item.y, "scalar", x.captures)
      captures = y.captures
      item.x = x.value
      item.y = y.value
    } else {
      let waypoints = ()
      for source-wp in item.waypoints {
        let wp = source-wp
        if wp.node != none {
          let packed = pack-captures(wp.node, "node", captures)
          captures = packed.captures
          wp.node = packed.value.index
        }
        if wp.clip-to != none {
          let packed = pack-captures(wp.clip-to, "node", captures)
          captures = packed.captures
          wp.clip-to = packed.value.index
        }
        if wp.defer != none and wp.defer.type != "rel" {
          let packed = pack-captures(point-data(wp.defer), "point", captures)
          captures = packed.captures
          wp.defer = (type: wp.defer.type, point: packed.value)
        }
        waypoints.push(wp)
      }
      item.waypoints = waypoints
    }
    normalized.push(item)
  }
  (nodes: captures.nodes, work: normalized)
}

#let prepare-nodes(pending, work, presets: (:), overrides: (:), font-size: auto, size-factor: 1, port-spacing: auto) = {
  let needs-resolution = needs-position-layout(pending, work)
  let normalized = if needs-resolution { normalize-captures(pending, work) } else { (nodes: pending, work: work) }
  let nodes = ()
  let prepared = ()
  let buckets = (:)
  let names = (:)
  for node in normalized.nodes {
    // Capture normalization already interns nodes. Re-deduplicating them
    // wastes work and could invalidate the integer references into that table.
    if not needs-resolution {
      let key = node-key(node)
      let bucket = buckets.at(key, default: ())
      if node in bucket { continue }
      buckets.insert(key, bucket + (node,))
    }
    let index = nodes.len()
    if node.name != none {
      assert(node.name not in names, message: "duplicate node name " + repr(node.name) + " in one diagram")
      names.insert(node.name, index)
    }
    nodes.push(node)
    prepared.push(node-outline(
      node-visual-spec(node), preset: presets.at(node.kind, default: (:)),
      override: overrides.at(node.kind, default: (:)), font-size: font-size,
      size-factor: size-factor, port-spacing: port-spacing,
    ))
  }
  (nodes: nodes, prepared: prepared, names: names, work: normalized.work, needs-resolution: needs-resolution)
}

#let equation(value) = {
  if numeric(value) { (constant: value, terms: ()) }
  else if value.kind == "variable" { (constant: 0, terms: ((1, value.index),)) }
  else { (constant: value.constant, terms: value.terms.map(term => (term.at(0), term.at(1).index))) }
}

#let resolve-positions(collection, unit, port-spacing: auto, size-factor: 1) = {
  if not collection.needs-resolution { return (nodes: collection.nodes, work: collection.work) }
  let work = collection.work
  let nodes = collection.nodes
  let named-index(name) = {
    let hit = collection.names.at(name, default: none)
    if hit == none {
      panic("ref(" + repr(name) + ") found no node with that name in this diagram. Known names: "
        + repr(collection.names.keys()) + ". A named node still has to be emitted.")
    }
    hit
  }

  // Expand expression trees only, never recursively chase another node's
  // position. Node axes become compact integer variables in the graph.
  let compile(value) = {
    if numeric(value) { return value }
    if value.kind == "linear" {
      return linear(value.terms.map(term => (term.at(0), compile(term.at(1)))), constant: value.constant)
    }
    let p = value.point
    let component = value.axis
    if p.kind == "pair" { return compile(p.values.at(component)) }
    if p.kind == "offset" {
      return linear(((1, compile(axis(p.base, component))),), constant: p.delta.at(component))
    }
    let target = if p.kind == "port" { p.target } else { p }
    let index = if target.kind == "index" { target.index } else { named-index(target.name) }
    let variable = (type: "coordinate", kind: "variable", index: 2 * index + component)
    if p.kind != "port" { return variable }
    let delta = port-offset(
      node-visual-spec(nodes.at(index)), collection.prepared.at(index).outline,
      p.side, p.index, unit, rotate: p.rotate, port-spacing: port-spacing, size-factor: size-factor,
    )
    linear(((1, variable),), constant: delta.at(component))
  }
  let equations = nodes.fold((), (out, n) => out + (equation(compile(n.x)), equation(compile(n.y))))
  let count = equations.len()
  let remaining = ()
  let dependents = range(count).map(_ => ())
  let ready = ()
  for (index, eq) in equations.enumerate() {
    remaining.push(eq.terms.len())
    if eq.terms.len() == 0 { ready.push(index) }
    for (_, dependency) in eq.terms { dependents.at(dependency).push(index) }
  }
  let values = range(count).map(_ => none)
  let completed = 0
  while ready.len() > 0 {
    let index = ready.pop()
    let eq = equations.at(index)
    let result = eq.constant
    for (coefficient, dependency) in eq.terms { result += coefficient * values.at(dependency) }
    values.at(index) = result
    completed += 1
    for dependent in dependents.at(index) {
      remaining.at(dependent) -= 1
      if remaining.at(dependent) == 0 { ready.push(dependent) }
    }
  }
  if completed != count {
    let current = values.position(v => v == none)
    let path = ()
    while current not in path {
      path.push(current)
      current = equations.at(current).terms.find(term => values.at(term.at(1)) == none).at(1)
    }
    path = path.slice(path.position(i => i == current)) + (current,)
    let labels = path.map(index => {
      let node-index = calc.floor(index / 2)
      let node = nodes.at(node-index)
      let name = if node.name == none { node.kind + "#" + str(node-index) } else { node.name }
      name + if calc.rem(index, 2) == 0 { ".x" } else { ".y" }
    })
    panic("cyclic position dependency: " + labels.join(" -> "))
  }
  let resolved = nodes.enumerate().map(((index, node)) => {
    node.x = values.at(2 * index)
    node.y = values.at(2 * index + 1)
    node
  })
  let evaluate(value) = {
    let eq = equation(compile(value))
    eq.terms.fold(eq.constant, (out, term) => out + term.at(0) * values.at(term.at(1)))
  }
  let work = work.map(item => {
    if is-content(item) {
      item.x = evaluate(item.x)
      item.y = evaluate(item.y)
    } else {
      let previous = none
      let waypoints = ()
      for source-waypoint in item.waypoints {
        let wp = source-waypoint
        if wp.node != none { wp.node = resolved.at(wp.node) }
        if wp.clip-to != none { wp.clip-to = resolved.at(wp.clip-to) }
        if wp.defer != none {
          if wp.defer.type == "rel" {
            wp.end = (previous.at(0) + wp.defer.dx, previous.at(1) + wp.defer.dy)
          } else {
            let point = wp.defer.point
            wp.end = (evaluate(axis(point, 0)), evaluate(axis(point, 1)))
            if wp.defer.type == "ref" { wp.clip-to = resolved.at(named-index(point.name)) }
          }
          wp.defer = none
        } else { wp.end = wp.end.map(evaluate) }
        previous = wp.end
        waypoints.push(wp)
      }
      item.waypoints = waypoints
      item.deferred-kind = none
    }
    item
  })
  (nodes: resolved, work: work)
}
