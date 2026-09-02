// Data-only coordinate expressions. No layout context or callable values are
// captured here: constructors, reusable fragments, and equality stay pure.
#import "utility.typ": unwrap-node, node-key

#let numeric(value) = type(value) in (int, float)
#let coordinate(value) = numeric(value) or (
  type(value) == dictionary and value.at("type", default: none) == "coordinate"
)
#let position-pair(value) = type(value) == array and value.len() == 2 and value.all(coordinate)
#let axis(point, index) = (type: "coordinate", kind: "axis", point: point, axis: index)
#let axes(point) = if point.kind == "pair" { point.values } else { (axis(point, 0), axis(point, 1)) }
#let projected-point(pair) = {
  let (x, y) = pair
  if (not numeric(x) and not numeric(y) and x.kind == "axis" and y.kind == "axis"
    and x.axis == 0 and y.axis == 1 and x.point == y.point) { x.point } else { none }
}

// Captures are flat, topologically ordered snapshots with local integer
// references. Embedding complete ancestors into both .x and .y would double
// the graph at every node (including Typst's memoization/equality work).
#let empty-captures = (nodes: (), buckets: (:))
#let remap-captures(value, kind, mapping) = {
  if kind == "node" {
    value.x = remap-captures(value.x, "scalar", mapping)
    value.y = remap-captures(value.y, "scalar", mapping)
  } else if kind == "scalar" {
    if numeric(value) { return value }
    if value.kind == "linear" {
      value.terms = value.terms.map(term => (term.at(0), remap-captures(term.at(1), "scalar", mapping)))
    } else { value.point = remap-captures(value.point, "point", mapping) }
  } else if value.kind == "index" { value.index = mapping.at(value.index) }
  else if value.kind == "port" { value.target = remap-captures(value.target, "point", mapping) }
  else if value.kind == "offset" { value.base = remap-captures(value.base, "point", mapping) }
  else if value.kind == "pair" { value.values = value.values.map(v => remap-captures(v, "scalar", mapping)) }
  value
}
#let intern-node(node, captures) = {
  let key = node-key(node)
  let bucket = captures.buckets.at(key, default: ())
  for index in bucket {
    if captures.nodes.at(index) == node { return (value: (kind: "index", index: index), captures: captures) }
  }
  let index = captures.nodes.len()
  captures.nodes.push(node)
  captures.buckets.insert(key, bucket + (index,))
  (value: (kind: "index", index: index), captures: captures)
}
#let pack-captures(value, kind, captures) = {
  if kind == "node" {
    let packed = pack-captures((value.x, value.y), "pair", captures)
    value.x = packed.value.at(0)
    value.y = packed.value.at(1)
    return intern-node(value, packed.captures)
  }
  if kind == "pair" {
    // .x and .y commonly share an entire capture table. Import it once,
    // instead of rebasing and interning every ancestor again for the y axis.
    let point = projected-point(value)
    if point != none {
      let packed = pack-captures(point, "point", captures)
      return (value: axes(packed.value), captures: packed.captures)
    }
    let x = pack-captures(value.at(0), "scalar", captures)
    let y = pack-captures(value.at(1), "scalar", x.captures)
    return (value: (x.value, y.value), captures: y.captures)
  }
  if kind == "scalar" {
    if numeric(value) { return (value: value, captures: captures) }
    if value.kind == "linear" {
      let terms = ()
      for (coefficient, term) in value.terms {
        let packed = pack-captures(term, "scalar", captures)
        captures = packed.captures
        terms.push((coefficient, packed.value))
      }
      value.terms = terms
    } else {
      let packed = pack-captures(value.point, "point", captures)
      captures = packed.captures
      value.point = packed.value
    }
  } else if value.kind == "bundle" {
    let mapping = ()
    for node in value.nodes {
      let packed = intern-node(remap-captures(node, "node", mapping), captures)
      captures = packed.captures
      mapping.push(packed.value.index)
    }
    value = remap-captures(value.point, "point", mapping)
  } else if value.kind == "node" { return pack-captures(value.node, "node", captures) }
  else if value.kind == "port" {
    let packed = pack-captures(value.target, "point", captures)
    captures = packed.captures
    value.target = packed.value
  } else if value.kind == "offset" {
    let packed = pack-captures(value.base, "point", captures)
    captures = packed.captures
    value.base = packed.value
  } else if value.kind == "pair" {
    let packed = pack-captures(value.values, "pair", captures)
    captures = packed.captures
    value.values = packed.value
  }
  (value: value, captures: captures)
}
#let bundle(point) = {
  let packed = pack-captures(point, "point", empty-captures)
  if packed.captures.nodes.len() == 0 { packed.value }
  else { (kind: "bundle", nodes: packed.captures.nodes, point: packed.value) }
}

#let point-data(value) = {
  let node = unwrap-node(value)
  if node != none { return bundle((kind: "node", node: node)) }
  if position-pair(value) { return bundle((kind: "pair", values: value)) }
  let tag = if type(value) == dictionary { value.at("type", default: none) } else { none }
  if tag == "position" { return value.point }
  if tag == "ref" { return (kind: "ref", name: value.name) }
  if tag == "port" {
    return bundle((
      kind: "port", target: point-data(value.node), side: value.side,
      index: value.index, rotate: value.at("rotate", default: 0deg),
    ))
  }
  panic("position must be a coordinate pair, node, port, or ref; rel() is only an edge waypoint")
}

#let with-coordinates(value) = {
  let pair = axes(point-data(value))
  value + (x: pair.at(0), y: pair.at(1))
}
#let point-value(point) = with-coordinates((type: "position", point: bundle(point)))

// Keep composed offsets at constant expression depth, including when the
// anchor owns a capture table. A zero delta remains an explicit point (not
// a node endpoint requesting clipping).
#let offset-point(point, delta) = {
  if point.kind == "bundle" {
    point.point = offset-point(point.point, delta)
    point
  } else if point.kind == "offset" {
    point + (delta: (point.delta.at(0) + delta.at(0), point.delta.at(1) + delta.at(1)))
  } else { (kind: "offset", base: point, delta: delta) }
}

/// Offsets an explicit point in numeric diagram units. Unlike rel(), this
/// does not depend on a preceding edge waypoint. Its .x/.y stay deferred.
#let offset(point, dx, dy) = {
  assert(numeric(dx) and numeric(dy), message: "offset() dx/dy must be numbers in diagram units")
  point-value(offset-point(point-data(point), (dx, dy)))
}

// A trailing positional label/body is deliberately parsed separately from
// coordinates, preserving gate(x, y, label) and place(x, y, body).
#let position-args(args, source: "node", trailing: 0, allow-extra: false) = {
  if not allow-extra {
    assert(args.named().len() == 0, message: "unexpected named argument(s): " + repr(args.named()))
  }
  let values = args.pos()
  assert(
    values.len() in (1 + trailing, 2 + trailing),
    message: source + " expects a point or x, y" + if trailing == 1 { ", followed by a label/body" } else { "" },
  )
  let count = values.len() - trailing
  let pair = if count == 1 { axes(point-data(values.first())) } else { values.slice(0, 2) }
  assert(pair.all(coordinate), message: source + " coordinates must be numbers or deferred coordinates")
  (position: pair, tail: values.slice(count))
}

// Canonical affine scalar expressions make nested transforms compact. Merge
// equal terms, but only round cancellation noise, not genuinely small terms.
#let linear(terms, constant: 0) = {
  let flat = ()
  for (coefficient, value) in terms {
    if coefficient == 0 { continue }
    if numeric(value) { constant += coefficient * value }
    else if value.kind == "linear" {
      constant += coefficient * value.constant
      flat += value.terms.map(term => (coefficient * term.at(0), term.at(1)))
    } else { flat.push((coefficient, value)) }
  }
  let merged = ()
  for (coefficient, value) in flat {
    let hit = merged.position(term => term.at(1) == value)
    if hit == none { merged.push((coefficient, value)) }
    else {
      let previous = merged.at(hit).at(0)
      let total = previous + coefficient
      if previous * coefficient < 0 and calc.abs(total) < 1e-14 * calc.max(calc.abs(previous), calc.abs(coefficient)) {
        total = 0
      }
      merged.at(hit) = (total, value)
    }
  }
  merged = merged.filter(term => term.at(0) != 0)
  if merged.len() == 0 { constant }
  else if merged.len() == 1 and merged.first().at(0) == 1 and constant == 0 { merged.first().at(1) }
  else { (type: "coordinate", kind: "linear", terms: merged, constant: constant) }
}

#let affine(pair, matrix) = {
  let (a, b, c, d, tx, ty) = matrix
  (
    linear(((a, pair.at(0)), (b, pair.at(1))), constant: tx),
    linear(((c, pair.at(0)), (d, pair.at(1))), constant: ty),
  )
}

// Rebase coordinate projections into the old local frame around transformed
// anchors, then apply the fragment transform. This conjugation preserves
// partial-axis constraints while full points follow the same ports as edges.
#let transform-value(value, kind, matrix, rotate, scale) = {
  let (a, b, c, d, tx, ty) = matrix
  if kind == "node" {
    let pair = transform-value((value.x, value.y), "pair", matrix, rotate, scale)
    value.x = pair.at(0)
    value.y = pair.at(1)
    value.size-scale *= scale
    return value
  }
  if kind == "pair" {
    if value.all(numeric) { return affine(value, matrix) }
    let point = projected-point(value)
    if point != none {
      return axes(transform-value(point, "point", matrix, rotate, scale))
    }
    return affine(value.map(v => transform-value(v, "scalar", matrix, rotate, scale)), matrix)
  }
  if kind == "scalar" {
    if numeric(value) { return value }
    if value.kind == "linear" {
      return linear(value.terms.map(term => (
        term.at(0), transform-value(term.at(1), "scalar", matrix, rotate, scale),
      )), constant: value.constant)
    }
    let pair = axes(transform-value(value.point, "point", matrix, rotate, scale))
    let det = a * d - b * c
    let inverse = (d / det, -b / det, -c / det, a / det,
      (b * ty - d * tx) / det, (c * tx - a * ty) / det)
    return affine(pair, inverse).at(value.axis)
  }
  if value.kind == "bundle" {
    value.nodes = value.nodes.map(n => transform-value(n, "node", matrix, rotate, scale))
    value.point = transform-value(value.point, "point", matrix, rotate, scale)
  } else if value.kind == "node" {
    value.node = transform-value(value.node, "node", matrix, rotate, scale)
  } else if value.kind == "port" {
    value.target = transform-value(value.target, "point", matrix, rotate, scale)
    value.rotate += rotate
  } else if value.kind == "offset" {
    value.base = transform-value(value.base, "point", matrix, rotate, scale)
    value.delta = affine(value.delta, (a, b, c, d, 0, 0))
  } else if value.kind == "pair" {
    value.values = transform-value(value.values, "pair", matrix, rotate, scale)
  }
  // Named refs are diagram-global, just like existing named edge endpoints.
  value
}
