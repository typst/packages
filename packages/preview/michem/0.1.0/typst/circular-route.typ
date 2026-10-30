// Measured circular routes with upright stages and true circular connectors.

#let point(radius, angle) = (radius * calc.cos(angle), radius * calc.sin(angle))
#let arc-point(arc, angle) = {
  let center = arc.at("center", default: (0pt, 0pt))
  let offset = point(arc.radius, angle)
  (center.at(0) + offset.at(0), center.at(1) + offset.at(1))
}
#let bounds(node, margin: 0pt) = (
  min: (node.x - margin, node.y - margin),
  max: (node.x + node.width + margin, node.y + node.height + margin),
)
#let contains(box, p) = (
  box.min.at(0) <= p.at(0)
    and p.at(0) <= box.max.at(0)
    and box.min.at(1) <= p.at(1)
    and p.at(1) <= box.max.at(1)
)
#let overlaps(a, b, gap: 0pt) = (
  a.min.at(0) < b.max.at(0) + gap
    and b.min.at(0) < a.max.at(0) + gap
    and a.min.at(1) < b.max.at(1) + gap
    and b.min.at(1) < a.max.at(1) + gap
)

/// Follow an explicit simple cycle, keeping the first declared stage at the start.
#let order(ids, edges) = {
  if not ids.all(id => (
    edges.filter(edge => edge.from == id).len() == 1
      and edges.filter(edge => edge.to == id).len() == 1
  )) { return ids }
  let result = (ids.first(),)
  for _ in range(ids.len() - 1) {
    let next = edges.find(edge => edge.from == result.last()).to
    if next in result { return ids }
    result.push(next)
  }
  if edges.find(edge => edge.from == result.last()).to == result.first() {
    result
  } else { ids }
}

// Clip by an angular parameter, so endpoints remain on the original circle.
#let exit-fraction(radius, start, sweep, box) = {
  let outside = range(1, 129).find(i => {
    not contains(box, point(radius, start + sweep * i / 128))
  })
  if outside == none { return none }
  let low = (outside - 1) / 128
  let high = outside / 128
  for _ in range(24) {
    let middle = (low + high) / 2
    if contains(box, point(radius, start + sweep * middle)) {
      low = middle
    } else { high = middle }
  }
  high
}

/// Samples bound each chord's deviation from the circle to at most 0.2pt.
#let arc-points(arc) = {
  let step = calc.min(
    3deg,
    2 * calc.acos(calc.clamp(1 - 0.2pt / arc.radius, -1, 1)),
  )
  let count = calc.max(1, calc.ceil(calc.abs(arc.sweep / step)))
  let fractions = range(count + 1).map(i => i / count)
  // Include exact x/y extrema for SVG framing, not just approximate samples.
  let end = arc.start + arc.sweep
  for quadrant in range(
    calc.floor(calc.min(arc.start, end) / 90deg),
    calc.ceil(calc.max(arc.start, end) / 90deg) + 1,
  ) {
    let angle = quadrant * 90deg
    let fraction = (angle - arc.start) / arc.sweep
    if fraction > 0 and fraction < 1 { fractions.push(fraction) }
  }
  fractions.sorted().dedup().map(t => arc-point(arc, arc.start + arc.sweep * t))
}

#let segment-hit(a, b, box) = {
  let enter = 0.0
  let leave = 1.0
  for axis in (0, 1) {
    let delta = (b.at(axis) - a.at(axis)) / 1pt
    if calc.abs(delta) < 0.000000001 {
      if a.at(axis) < box.min.at(axis) or a.at(axis) > box.max.at(axis) {
        return false
      }
    } else {
      let first = (box.min.at(axis) - a.at(axis)) / 1pt / delta
      let last = (box.max.at(axis) - a.at(axis)) / 1pt / delta
      enter = calc.max(enter, calc.min(first, last))
      leave = calc.min(leave, calc.max(first, last))
      if enter > leave { return false }
    }
  }
  true
}

#let note-box(note) = (
  min: (note.x - note.width / 2, note.y - note.height / 2),
  max: (note.x + note.width / 2, note.y + note.height / 2),
)

#let mix(a, b, t) = (
  a.at(0) * (1 - t) + b.at(0) * t,
  a.at(1) * (1 - t) + b.at(1) * t,
)

// Subdivide until the control polygon stays within 0.2pt of its chord.
// Short segments also make conservative connector collision checks practical.
#let curve-points(curve, depth: 0) = {
  let (a, b, c, d) = curve
  let distance(a, b) = (
    calc.sqrt(
      calc.pow((a.at(0) - b.at(0)) / 1pt, 2)
        + calc.pow((a.at(1) - b.at(1)) / 1pt, 2),
    )
      * 1pt
  )
  if (
    depth >= 12
      or (
        distance(a, d) <= 5pt
          and distance(b, mix(a, d, 1 / 3)) <= 0.2pt
          and distance(c, mix(a, d, 2 / 3)) <= 0.2pt
      )
  ) { return (a, d) }
  let ab = mix(a, b, 0.5)
  let bc = mix(b, c, 0.5)
  let cd = mix(c, d, 0.5)
  let abc = mix(ab, bc, 0.5)
  let bcd = mix(bc, cd, 0.5)
  let middle = mix(abc, bcd, 0.5)
  (
    curve-points((a, ab, abc, middle), depth: depth + 1).slice(0, -1)
      + curve-points((middle, bcd, cd, d), depth: depth + 1)
  )
}

#let points-hit(points, box) = (
  points
    .windows(2)
    .any(pair => {
      segment-hit(pair.at(0), pair.at(1), box)
    })
)

#let paths-hit(a, b, clearance) = (
  b
    .windows(2)
    .any(pair => {
      let box = (
        min: (
          calc.min(pair.at(0).at(0), pair.at(1).at(0)) - clearance,
          calc.min(pair.at(0).at(1), pair.at(1).at(1)) - clearance,
        ),
        max: (
          calc.max(pair.at(0).at(0), pair.at(1).at(0)) + clearance,
          calc.max(pair.at(0).at(1), pair.at(1).at(1)) + clearance,
        ),
      )
      points-hit(a, box)
    })
)

// Externally tangent circles share the radial line through their contact point.
// A quarter-circle turns the branch tangent toward the peripheral participant.
#let tangent-branch(
  group,
  track,
  angle,
  branch-sign,
  outgoing,
  gap,
  ink,
  arrow-length,
  extension,
) = {
  let radius = arrow-length + extension
  let center = point(track + radius, angle)
  let arc = (
    center: center,
    radius: radius,
    start: angle + 180deg,
    sweep: -branch-sign * 90deg,
  )
  let end = arc-point(arc, arc.start + arc.sweep)
  let unit = point(1pt, angle).map(v => v / 1pt)
  let reach = calc.min(
    if calc.abs(unit.at(0)) < 0.000001 { 1000000pt } else {
      group.width / 2 / calc.abs(unit.at(0))
    },
    if calc.abs(unit.at(1)) < 0.000001 { 1000000pt } else {
      group.height / 2 / calc.abs(unit.at(1))
    },
  )
  let position = (
    end.at(0) + unit.at(0) * (reach + gap / 2 + ink),
    end.at(1) + unit.at(1) * (reach + gap / 2 + ink),
  )
  let candidate = (
    group
      + (
        x: position.at(0) - group.width / 2,
        y: position.at(1) - group.height / 2,
      )
  )
  if not outgoing {
    arc.start += arc.sweep
    arc.sweep = -arc.sweep
  }
  (group: candidate, arc: arc, points: arc-points(arc))
}

#let bezier-branch(
  group,
  track,
  angle,
  sweep,
  branch-sign,
  outgoing,
  gap,
  ink,
  arrow-length,
  extension,
) = {
  let outside-angle = (
    angle + branch-sign * calc.min(12deg, calc.abs(sweep) / 8)
  )
  let unit = point(1pt, outside-angle).map(v => v / 1pt)
  let support = (
    calc.abs(unit.at(0)) * group.width / 2
      + calc.abs(unit.at(1)) * group.height / 2
  )
  let center-radius = (
    track + arrow-length + extension + support + gap + ink
  )
  let center = point(center-radius, outside-angle)
  let candidate = (
    group
      + (
        x: center.at(0) - group.width / 2,
        y: center.at(1) - group.height / 2,
      )
  )
  // Intersect the center ray with the measured participant rectangle.
  let reach = calc.min(
    if calc.abs(unit.at(0)) < 0.000001 { 1000000pt } else {
      group.width / 2 / calc.abs(unit.at(0))
    },
    if calc.abs(unit.at(1)) < 0.000001 { 1000000pt } else {
      group.height / 2 / calc.abs(unit.at(1))
    },
  )
  let end = point(center-radius - reach - gap / 2 - ink, outside-angle)
  let start = point(track, angle)
  let length = calc.max(
    arrow-length,
    (center-radius - reach - track) * 0.75,
  )
  let control = (
    start.at(0) - branch-sign * calc.sin(angle) * length / 2,
    start.at(1) + branch-sign * calc.cos(angle) * length / 2,
  )
  let before-end = (
    end.at(0) - unit.at(0) * length / 3,
    end.at(1) - unit.at(1) * length / 3,
  )
  let curve = (start, control, before-end, end)
  if not outgoing { curve = curve.rev() }
  (group: candidate, curve: curve, points: curve-points(curve))
}

// Input and output branches merge with / leave the step along its tangent.
#let place-branches(
  nodes,
  edges,
  originals,
  radius,
  gap,
  label-gap,
  arrow-length,
  arrow-width,
  head-size,
  notes,
  branch-curve,
) = {
  let result = ()
  let ink = head-size + arrow-width + 0.25pt
  let occupied = (
    nodes.map(node => bounds(node, margin: gap / 2))
      + notes.map(note => note-box(note))
  )
  for (index, edge) in edges.enumerate() {
    let source = originals.at(index)
    let mode = source.at("branch-curve", default: auto)
    if mode == auto { mode = branch-curve }
    for side in ("reactants", "products") {
      let group = source.at(side + "-group", default: none)
      if group == none { continue }
      let outgoing = side == "products"
      let flow = if edge.arc.sweep > 0deg { 1 } else { -1 }
      let branch-sign = flow * if outgoing { 1 } else { -1 }
      let selected = none
      // Keep the middle of the step available for conditions. Try nearby
      // attachment angles and longer branches before growing the whole ring.
      let fractions = if outgoing { (0.72, 0.82, 0.62) } else {
        (0.28, 0.18, 0.38)
      }
      for extension in (0pt, 18pt, 36pt, 72pt) {
        for fraction in fractions {
          let angle = edge.arc.start + edge.arc.sweep * fraction
          let track = radius + if edge.equilibrium { 3pt } else { 0pt }
          let geometry = if mode == "tangent-circle" {
            tangent-branch(
              group,
              track,
              angle,
              branch-sign,
              outgoing,
              gap,
              ink,
              arrow-length,
              extension,
            )
          } else {
            bezier-branch(
              group,
              track,
              angle,
              edge.arc.sweep,
              branch-sign,
              outgoing,
              gap,
              ink,
              arrow-length,
              extension,
            )
          }
          let candidate = geometry.group
          let points = geometry.points
          let box = bounds(candidate)
          if occupied.any(other => overlaps(box, other, gap: label-gap + ink)) {
            continue
          }
          if result.any(other => points-hit(other.points, bounds(
            candidate,
            margin: ink,
          ))) { continue }
          if occupied.any(other => points-hit(points, (
            min: other.min.map(v => v - ink),
            max: other.max.map(v => v + ink),
          ))) { continue }
          if result.any(other => paths-hit(points, other.points, 2 * ink)) {
            continue
          }
          selected = (
            from: edge.from,
            to: edge.to,
            kind: side,
            ..geometry,
            "branch-curve": mode,
            notes: (),
            equilibrium: false,
          )
          break
        }
        if selected != none { break }
      }
      if selected == none { return none }
      occupied.push(bounds(selected.group, margin: gap / 2))
      result.push(selected)
    }
  }
  // Peripheral groups must also clear all circular connector ink.
  for branch in result {
    let box = bounds(branch.group, margin: ink)
    if edges.any(edge => points-hit(
      edge.points + edge.at("extra-points", default: ()),
      box,
    )) { return none }
  }
  result
}

#let attempt(
  nodes,
  edges,
  radius,
  clockwise,
  start-angle,
  gap,
  label-gap,
  arrow-length,
  arrow-width,
  head-size,
  center,
  branch-curve,
) = {
  let sign = if clockwise { 1 } else { -1 }
  let spacing = sign * 360deg / nodes.len()
  let placed = nodes
    .enumerate()
    .map(((i, node)) => {
      let angle = start-angle + i * spacing
      let p = point(radius, angle)
      node.x = p.at(0) - node.width / 2
      node.y = p.at(1) - node.height / 2
      node.insert("angle", angle)
      node
    })
  for i in range(placed.len()) {
    for j in range(i + 1, placed.len()) {
      if overlaps(bounds(placed.at(i)), bounds(placed.at(j)), gap: gap) {
        return none
      }
    }
  }
  if center != none {
    let half-diagonal = (
      calc.sqrt(
        (center.width / 1pt / 2) * (center.width / 1pt / 2)
          + (center.height / 1pt / 2) * (center.height / 1pt / 2),
      )
        * 1pt
    )
    if half-diagonal + label-gap + arrow-width >= radius { return none }
    if placed.any(node => overlaps(
      bounds(node),
      note-box(center),
      gap: label-gap,
    )) { return none }
  }
  let connections = ()
  let notes = if center == none { () } else { (center,) }
  let ids = placed.map(node => node.id)
  for edge in edges {
    let from = placed.find(node => node.id == edge.from)
    let to = placed.find(node => node.id == edge.to)
    let i = ids.position(id => id == edge.from)
    let j = ids.position(id => id == edge.to)
    let sweep = if j == calc.rem(i + 1, ids.len()) { spacing } else { -spacing }
    let reverse-space = if edge.equilibrium { 3pt } else { 0pt }
    let margin = gap / 2 + head-size + arrow-width + reverse-space + 1pt
    let begin = exit-fraction(radius, from.angle, sweep, bounds(
      from,
      margin: margin,
    ))
    let end = exit-fraction(radius, from.angle + sweep, -sweep, bounds(
      to,
      margin: margin,
    ))
    if begin == none or end == none or begin + end >= 1 { return none }
    let arc = (
      radius: radius,
      start: from.angle + sweep * begin,
      sweep: sweep * (1 - begin - end),
    )
    if (
      radius * calc.abs(arc.sweep / 1rad)
        < calc.max(arrow-length, 2 * head-size)
    ) { return none }
    let points = arc-points(arc)
    for node in placed {
      let box = bounds(node, margin: gap / 2 + arrow-width / 2 + 0.25pt)
      if points
        .windows(2)
        .any(pair => segment-hit(pair.at(0), pair.at(1), box)) { return none }
    }
    let angle = arc.start + arc.sweep / 2
    let edge-notes = ()
    for (side, label) in (
      ("outside", edge.at("above-label")),
      ("inside", edge.at("below-label")),
    ) {
      if label == none { continue }
      let support = (
        calc.abs(calc.cos(angle)) * label.width / 2
          + calc.abs(calc.sin(angle)) * label.height / 2
      )
      let clearance = label-gap + arrow-width / 2 + reverse-space
      let note-radius = radius + support + clearance
      if side == "inside" {
        let diagonal-squared = (
          (label.width / 1pt / 2) * (label.width / 1pt / 2)
            + (label.height / 1pt / 2) * (label.height / 1pt / 2)
        )
        let available = radius - clearance
        let discriminant = (
          (available / 1pt) * (available / 1pt)
            - diagonal-squared
            + (support / 1pt) * (support / 1pt)
        )
        if available <= 0pt or discriminant <= 0 { return none }
        note-radius = calc.sqrt(discriminant) * 1pt - support
        if note-radius <= 0pt { return none }
      }
      let p = point(note-radius, angle)
      let note = (
        body: label.body,
        width: label.width,
        height: label.height,
        x: p.at(0),
        y: p.at(1),
        side: side,
      )
      if placed.any(node => overlaps(
        bounds(node),
        note-box(note),
        gap: label-gap,
      )) { return none }
      if notes.any(other => overlaps(
        note-box(other),
        note-box(note),
        gap: label-gap,
      )) { return none }
      notes.push(note)
      edge-notes.push(note)
    }
    let connection = (
      from: edge.from,
      to: edge.to,
      points: points,
      notes: edge-notes,
      equilibrium: edge.equilibrium,
      arc: arc,
    )
    if edge.equilibrium {
      let reverse = (
        radius: radius + 3pt,
        start: arc.start + arc.sweep,
        sweep: -arc.sweep,
      )
      let reverse-points = arc-points(reverse)
      for node in placed {
        let box = bounds(node, margin: gap / 2 + arrow-width / 2 + 0.25pt)
        if reverse-points
          .windows(2)
          .any(pair => segment-hit(pair.at(0), pair.at(1), box)) { return none }
      }
      connection.insert("reverse-arc", reverse)
      connection.insert("extra-points", reverse-points)
    }
    connections.push(connection)
  }
  let branches = place-branches(
    placed,
    connections,
    edges,
    radius,
    gap,
    label-gap,
    arrow-length,
    arrow-width,
    head-size,
    notes,
    branch-curve,
  )
  if branches == none { return none }
  (
    stages: placed,
    steps: connections,
    branches: branches,
    radius: radius,
    center: center,
  )
}

/// Radius grows until measured stages, conditions and connectors clear each other.
#let arrange(
  nodes,
  edges,
  radius: auto,
  clockwise: true,
  start-angle: -90deg,
  gap: 18pt,
  label-gap: 4pt,
  arrow-length: 36pt,
  arrow-width: 0.7pt,
  head-size: 4pt,
  center: none,
  branch-curve: "tangent-circle",
) = {
  assert(
    nodes.len() >= 2,
    message: "Circular routes require at least two stages",
  )
  assert(type(clockwise) == bool, message: "clockwise must be a boolean")
  assert(
    type(start-angle) == std.angle,
    message: "start-angle must be an angle",
  )
  assert(
    radius == auto
      or (type(radius) == length and radius > 0pt and radius <= 10000pt),
    message: "Circular radius must be auto or a positive length up to 10000pt",
  )
  let ids = nodes.map(node => node.id)
  for edge in edges {
    let i = ids.position(id => id == edge.from)
    let j = ids.position(id => id == edge.to)
    assert(
      j == calc.rem(i + 1, ids.len()) or i == calc.rem(j + 1, ids.len()),
      message: "Circular steps must connect neighboring stages; reorder declarations or use a single connected cycle",
    )
    assert(
      ids.len() == 2
        or not edges.any(other => (
          other.from == edge.to and other.to == edge.from
        )),
      message: "Opposing circular steps share the same arc; use equilibrium: true on one step",
    )
  }
  let start-angle = calc.rem(start-angle / 1deg, 360) * 1deg
  let current = if radius == auto {
    calc.max(
      48pt,
      nodes.map(node => calc.max(node.width, node.height)).fold(0pt, calc.max),
    )
  } else { radius }
  for _ in range(64) {
    if current > 10000pt { break }
    let result = attempt(
      nodes,
      edges,
      current,
      clockwise,
      start-angle,
      gap,
      label-gap,
      arrow-length,
      arrow-width,
      head-size,
      center,
      branch-curve,
    )
    if result != none { return result }
    if radius != auto { break }
    current = current * 1.12 + 4pt
  }
  panic(if radius == auto {
    "Circular layout could not find a clear radius within its search limit"
  } else {
    "Circular radius is too small for the measured stages, conditions, and step participants; increase radius or use auto"
  })
}

#let number(value) = str(value).replace("−", "-")
#let svg-point(p) = number(p.at(0) / 1pt) + " " + number(p.at(1) / 1pt)

#let curve-path(curve) = (
  "M "
    + svg-point(curve.first())
    + " C "
    + curve.slice(1).map(svg-point).join(" ")
)

/// Exact SVG circle arc with a tangent point for arrowhead construction.
#let path(arc) = {
  let start = arc-point(arc, arc.start)
  let end = arc-point(arc, arc.start + arc.sweep)
  (
    "M "
      + svg-point(start)
      + " A "
      + number(arc.radius / 1pt)
      + " "
      + number(arc.radius / 1pt)
      + " 0 "
      + (if calc.abs(arc.sweep) > 180deg { "1" } else { "0" })
      + " "
      + (if arc.sweep > 0deg { "1" } else { "0" })
      + " "
      + svg-point(end)
  )
}

#let tangent(arc, length) = {
  let angle = arc.start + arc.sweep
  let end = arc-point(arc, angle)
  let sign = if arc.sweep > 0deg { 1 } else { -1 }
  (
    end.at(0) + sign * calc.sin(angle) * length,
    end.at(1) - sign * calc.cos(angle) * length,
  )
}
