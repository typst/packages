// Declarative reaction routes: participant groups, graph placement and connectors.
#import "compound.typ" as compounds
#import "circular-route.typ" as circular

/// One route stage; plus signs are inserted between its participants.
#let reaction-stage(id, ..participants, label: none) = {
  assert(
    type(id) == str and id != "",
    message: "Reaction stage ID must be a nonempty string",
  )
  assert(
    participants.named().len() == 0,
    message: "Unknown reaction-stage option",
  )
  assert(
    participants.pos().len() > 0,
    message: "Reaction stage requires at least one compound",
  )
  (kind: "reaction-stage", id: id, compounds: participants.pos(), label: label)
}

/// A reaction connector with explicit conditions and circular material branches.
#let reaction-step(
  from,
  to,
  above: none,
  below: none,
  equilibrium: false,
  reactants: (),
  products: (),
  branch-curve: auto,
) = (
  kind: "reaction-step",
  from: from,
  to: to,
  above: above,
  below: below,
  equilibrium: equilibrium,
  reactants: reactants,
  products: products,
  "branch-curve": branch-curve,
)

#let measured-stage(
  stage,
  options,
  plus,
  compound-gap,
  name-gap,
  image-height,
  name-height,
) = {
  let cards = stage.cards
  let width = (
    cards.map(card => card.width).sum(default: 0pt)
      + (cards.len() - 1) * (2 * compound-gap + plus.width)
  )
  let caption = if stage.label == none { none } else {
    compounds.label(stage.label, options.font, options.label-size, width: width)
  }
  let height = (
    image-height + name-height + if name-height > 0pt { name-gap } else { 0pt }
  )
  let body = box(
    width: width,
    height: height
      + if caption == none { 0pt } else { caption.height + name-gap },
    {
      let x = 0pt
      for (index, card) in cards.enumerate() {
        place(top + left, dx: x, compounds.paint-compound(
          card,
          image-height,
          name-height,
          name-gap,
        ))
        x += card.width
        if index < cards.len() - 1 {
          place(
            top + left,
            dx: x + compound-gap,
            dy: (image-height - plus.height) / 2,
            plus.body,
          )
          x += 2 * compound-gap + plus.width
        }
      }
      if caption != none {
        place(
          top + left,
          dx: (width - caption.width) / 2,
          dy: height + name-gap,
          caption.body,
        )
      }
    },
  )
  (
    id: stage.id,
    cards: cards,
    body: body,
    width: width,
    height: measure(body).height,
    image-height: image-height,
    rank: 0,
    x: 0pt,
    y: 0pt,
  )
}

#let graph(stages, steps, circular-layout: false) = {
  let ids = stages.map(stage => stage.id)
  assert(
    ids.dedup().len() == ids.len(),
    message: "Reaction stage IDs must be unique",
  )
  let edges = if steps == auto {
    let result = range(stages.len() - 1).map(i => reaction-step(
      ids.at(i),
      ids.at(i + 1),
    ))
    if circular-layout and ids.len() > 1 {
      result.push(reaction-step(ids.last(), ids.first()))
    }
    result
  } else { steps }
  assert(
    type(edges) == array and edges.len() <= 512,
    message: "Route steps must be an array of at most 512 reaction-step values",
  )
  let pairs = ()
  for edge in edges {
    assert(
      type(edge) == dictionary
        and edge.at("kind", default: none) == "reaction-step",
      message: "Expected reaction-step(...)",
    )
    assert(
      edge.from in ids and edge.to in ids,
      message: "Reaction step references an unknown stage",
    )
    assert(
      edge.from != edge.to,
      message: "A reaction step cannot connect a stage to itself",
    )
    assert(
      (edge.from, edge.to) not in pairs,
      message: "Duplicate reaction step",
    )
    pairs.push((edge.from, edge.to))
  }
  let remaining = ids
  let done = ()
  let ranks = (:)
  let order = ()
  if circular-layout {
    return (
      edges: edges,
      ranks: (:),
      order: circular.order(ids, edges),
      linear: false,
    )
  }
  while remaining.len() > 0 {
    let ready = remaining.filter(id => edges
      .filter(edge => edge.to == id)
      .all(edge => edge.from in done))
    assert(
      ready.len() > 0,
      message: "Cyclic reaction routes require layout: circular, or separate repeated stages",
    )
    for id in ready {
      let parents = edges.filter(edge => edge.to == id)
      let rank = parents.map(edge => ranks.at(edge.from) + 1).fold(0, calc.max)
      ranks.insert(id, rank)
      order.push(id)
    }
    done += ready
    remaining = remaining.filter(id => id not in ready)
  }
  let linear = (
    edges.len() == stages.len() - 1
      and ids.all(id => (
        edges.filter(edge => edge.from == id).len() <= 1
          and edges.filter(edge => edge.to == id).len() <= 1
      ))
  )
  (edges: edges, ranks: ranks, order: order, linear: linear)
}

#let extent(nodes) = (
  width: nodes.map(node => node.x + node.width).fold(0pt, calc.max),
  height: nodes.map(node => node.y + node.height).fold(0pt, calc.max),
)

#let layered(nodes, ranks, edge-gap, row-gap, direction) = {
  let along(node) = if direction == "right" { node.width } else { node.height }
  let across(node) = if direction == "right" { node.height } else { node.width }
  let count = ranks.values().fold(0, calc.max) + 1
  let layers = range(count).map(rank => nodes.filter(node => (
    ranks.at(node.id) == rank
  )))
  let sizes = layers.map(layer => layer.map(along).fold(0pt, calc.max))
  let spans = layers.map(layer => (
    layer.map(across).sum(default: 0pt) + calc.max(0, layer.len() - 1) * row-gap
  ))
  let cross-span = spans.fold(0pt, calc.max)
  let result = ()
  let x = 0pt
  for (rank, layer) in layers.enumerate() {
    let y = (cross-span - spans.at(rank)) / 2
    for node in layer {
      node.rank = rank
      node.insert("row", 0)
      node.x = if direction == "right" {
        x + (sizes.at(rank) - node.width) / 2
      } else { y }
      node.y = if direction == "right" { y } else {
        x + (sizes.at(rank) - node.height) / 2
      }
      result.push(node)
      y += across(node) + row-gap
    }
    x += sizes.at(rank) + edge-gap
  }
  result
}

#let wrapped(nodes, order, edge-gap, row-gap, width) = {
  let result = ()
  let x = 0pt
  let y = 0pt
  let row-height = 0pt
  let row = 0
  for (rank, id) in order.enumerate() {
    let node = nodes.find(node => node.id == id)
    assert(
      node.width <= width,
      message: "A reaction stage exceeds max-width; enlarge the available width or reduce atom-size/bond-length for the whole route",
    )
    if x > 0pt and x + node.width > width {
      x = 0pt
      y += row-height + row-gap
      row-height = 0pt
      row += 1
    }
    node.x = x
    node.y = y
    node.rank = rank
    node.insert("row", row)
    result.push(node)
    row-height = calc.max(row-height, node.height)
    x += node.width + edge-gap
  }
  result
}

#let condition(body, options) = if body == none { none } else {
  compounds.label(body, options.font, options.label-size)
}

#let finish(
  nodes,
  connections,
  appearance,
  max-width,
  selected,
  extras: (),
  metadata: (:),
) = {
  let all-points = nodes
    .map(node => (
      (node.x, node.y),
      (node.x + node.width, node.y + node.height),
    ))
    .fold((), (all, points) => all + points)
  all-points += connections
    .map(edge => edge.points + edge.at("extra-points", default: ()))
    .fold((), (all, points) => all + points)
  all-points += extras
  for branch in metadata.at("branches", default: ()) {
    let group = branch.group
    all-points += (
      branch.points
        + (
          (group.x, group.y),
          (group.x + group.width, group.y + group.height),
        )
    )
  }
  for edge in connections {
    for note in edge.notes {
      all-points += (
        (note.x - note.width / 2, note.y - note.height / 2),
        (note.x + note.width / 2, note.y + note.height / 2),
      )
    }
  }
  let low = (
    all-points.map(p => p.at(0)).fold(0pt, calc.min) - appearance.frame,
    all-points.map(p => p.at(1)).fold(0pt, calc.min) - appearance.frame,
  )
  let high = (
    all-points.map(p => p.at(0)).fold(0pt, calc.max) + appearance.frame,
    all-points.map(p => p.at(1)).fold(0pt, calc.max) + appearance.frame,
  )
  if max-width != none {
    assert(
      high.at(0) - low.at(0) <= max-width,
      message: "Route exceeds max-width; enlarge the available width or reduce the shared molecular sizes",
    )
  }
  (
    (
      stages: nodes,
      steps: connections,
      origin: low,
      width: high.at(0) - low.at(0),
      height: high.at(1) - low.at(1),
      direction: selected,
      layout: "layered",
      font: appearance.font,
      "atom-size": appearance.atom-size,
      "label-size": appearance.label-size,
      "arrow-width": appearance.arrow-width,
      "arrow-color": appearance.arrow-color,
      "head-size": appearance.head-size,
    )
      + metadata
  )
}

/// Inspectable route layout. Call inside context; all lengths are physical.
/// Linear routes wrap; circular routes preserve their radius and physical sizes.
#let reaction-route-data(
  ..stages,
  steps: auto,
  font: "Libertinus Serif",
  atom-size: 9pt,
  label-size: 10pt,
  bond-length: 18pt,
  direction: "auto",
  layout: "auto",
  clockwise: true,
  start-angle: -90deg,
  radius: auto,
  center: none,
  branch-curve: "tangent-circle",
  max-width: none,
  gap: 18pt,
  row-gap: 24pt,
  compound-gap: 8pt,
  name-gap: 5pt,
  label-gap: 4pt,
  arrow-length: 36pt,
  arrow-width: 0.7pt,
  arrow-color: black,
  head-size: 4pt,
  molecular-style: (:),
  molecular-layout: (:),
) = {
  assert(stages.named().len() == 0, message: "Unknown reaction-route option")
  let stages = stages.pos()
  assert(
    stages.len() > 0 and stages.len() <= 128,
    message: "Reaction route requires 1..128 stages",
  )
  assert(
    stages.all(stage => (
      type(stage) == dictionary
        and stage.at("kind", default: none) == "reaction-stage"
    )),
    message: "Expected reaction-stage(...)",
  )
  assert(
    stages.map(stage => stage.compounds.len()).sum() <= 256,
    message: "Reaction route exceeds 256 compounds",
  )
  assert(
    direction in ("auto", "right", "down"),
    message: "Route direction must be auto, right, or down",
  )
  assert(
    layout in ("auto", "layered", "circular"),
    message: "Route layout must be auto, layered, or circular",
  )
  assert(
    branch-curve in ("tangent-circle", "bezier"),
    message: "branch-curve must be tangent-circle or bezier",
  )
  assert(
    layout == "circular"
      or (
        radius == auto
          and center == none
          and clockwise == true
          and start-angle == -90deg
          and branch-curve == "tangent-circle"
      ),
    message: "radius, center, clockwise, start-angle, and branch-curve require layout: circular",
  )
  assert(
    layout != "circular" or direction == "auto",
    message: "Circular layout uses clockwise instead of direction",
  )
  assert(
    max-width == none or (type(max-width) == length and max-width > 0pt),
    message: "max-width must be a positive length or none",
  )
  for distance in (gap, row-gap, compound-gap, name-gap, label-gap) {
    assert(
      type(distance) == length and distance >= 0pt,
      message: "Route gaps must be nonnegative lengths",
    )
  }
  for distance in (arrow-length, arrow-width, head-size) {
    assert(
      type(distance) == length and distance > 0pt,
      message: "Arrow dimensions must be positive lengths",
    )
  }
  let options = compounds.settings(
    font,
    atom-size,
    label-size,
    bond-length,
    molecular-style,
    molecular-layout,
  )
  let topology = graph(stages, steps, circular-layout: layout == "circular")
  let participant-count = stages.map(stage => stage.compounds.len()).sum()
  for edge in topology.edges {
    let mode = edge.at("branch-curve", default: auto)
    assert(
      mode in (auto, "tangent-circle", "bezier"),
      message: "Step branch-curve must be auto, tangent-circle, or bezier",
    )
    assert(
      layout == "circular" or mode == auto,
      message: "Step branch-curve requires layout: circular",
    )
    for side in ("reactants", "products") {
      let values = edge.at(side, default: ())
      assert(
        type(values) == array,
        message: side + " must be an array of compounds",
      )
      assert(
        layout == "circular" or values.len() == 0,
        message: "Step reactants and products require layout: circular",
      )
      participant-count += values.len()
    }
  }
  assert(
    participant-count <= 256,
    message: "Reaction route exceeds 256 compounds including step participants",
  )
  let measured = stages.map(stage => {
    stage.insert("cards", stage.compounds.map(
      value => compounds.measure-compound(value, options),
    ))
    stage
  })
  let cards = measured.map(stage => stage.cards).flatten()
  let image-height = cards.map(card => card.image-height).fold(0pt, calc.max)
  let name-height = cards
    .map(card => if card.name == none { 0pt } else { card.name.height })
    .fold(0pt, calc.max)
  let plus = compounds.label("+", font, label-size)
  let nodes = measured.map(stage => measured-stage(
    stage,
    options,
    plus,
    compound-gap,
    name-gap,
    if layout == "circular" {
      stage.cards.map(card => card.image-height).fold(0pt, calc.max)
    } else { image-height },
    if layout == "circular" {
      stage
        .cards
        .map(card => if card.name == none { 0pt } else { card.name.height })
        .fold(0pt, calc.max)
    } else { name-height },
  ))
  let edges = topology.edges.map(edge => {
    edge.insert("above-label", condition(edge.above, options))
    edge.insert("below-label", condition(edge.below, options))
    for side in ("reactants", "products") {
      let values = edge.at(side, default: ())
      let group = none
      if values.len() > 0 {
        let cards = values.map(value => compounds.measure-compound(
          value,
          options,
        ))
        group = measured-stage(
          (id: side, cards: cards, label: none),
          options,
          plus,
          compound-gap,
          name-gap,
          cards.map(card => card.image-height).fold(0pt, calc.max),
          cards
            .map(card => if card.name == none { 0pt } else { card.name.height })
            .fold(0pt, calc.max),
        )
      }
      edge.insert(side + "-group", group)
    }
    edge
  })
  let labels = edges
    .map(edge => (edge.at("above-label"), edge.at("below-label")))
    .flatten()
    .filter(label => label != none)
  let label-width = labels.map(label => label.width).fold(0pt, calc.max)
  let label-height = labels.map(label => label.height).fold(0pt, calc.max)
  let frame = (
    calc.max(head-size, arrow-width / 2)
      + if edges.any(edge => edge.equilibrium) { 3pt } else { 0pt }
  )
  let appearance = (
    font: font,
    "atom-size": atom-size,
    "label-size": label-size,
    "arrow-width": arrow-width,
    "arrow-color": arrow-color,
    "head-size": head-size,
    frame: frame,
  )
  if layout == "circular" {
    let ordered = topology.order.map(id => nodes.find(node => node.id == id))
    let middle = if center == none { none } else {
      (..compounds.label(center, font, label-size), x: 0pt, y: 0pt)
    }
    let ring = circular.arrange(
      ordered,
      edges,
      radius: radius,
      clockwise: clockwise,
      start-angle: start-angle,
      gap: gap,
      label-gap: label-gap,
      arrow-length: arrow-length,
      arrow-width: arrow-width,
      head-size: head-size,
      center: middle,
      branch-curve: branch-curve,
    )
    let extras = if middle == none { () } else {
      (
        (-middle.width / 2, -middle.height / 2),
        (middle.width / 2, middle.height / 2),
      )
    }
    return finish(
      ring.stages,
      ring.steps,
      appearance,
      max-width,
      if clockwise { "clockwise" } else { "counterclockwise" },
      extras: extras,
      metadata: (
        layout: "circular",
        radius: ring.radius,
        center: middle,
        "start-angle": start-angle,
        branches: ring.branches,
        "branch-curve": branch-curve,
      ),
    )
  }
  let cross-gap = calc.max(row-gap, 2 * (label-height + label-gap) + head-size)
  let attachment = head-size
  let edge-gap = calc.max(
    gap + calc.max(arrow-length, 2 * head-size) + 2 * attachment,
    2 * (label-width + 2 * label-gap + attachment),
  )
  let down-gap = calc.max(
    gap + calc.max(arrow-length, 2 * head-size) + 2 * attachment,
    2 * (label-height + 2 * label-gap + attachment),
  )
  let horizontal = layered(nodes, topology.ranks, edge-gap, cross-gap, "right")
  let selected = if direction == "auto" {
    if (
      topology.linear
        or max-width == none
        or extent(horizontal).width + 2 * frame <= max-width
    ) { "right" } else { "down" }
  } else { direction }
  let nodes = if selected == "right" and topology.linear and max-width != none {
    // Reserve outer lanes for continuation arrows between wrapped rows.
    wrapped(
      nodes,
      topology.order,
      edge-gap,
      calc.max(cross-gap, 2 * label-height + 4 * label-gap + 2 * head-size),
      max-width
        - 2 * frame
        - if extent(horizontal).width + 2 * frame > max-width {
          2 * (head-size + label-gap)
        } else { 0pt },
    )
  } else if selected == "right" and topology.linear {
    wrapped(
      nodes,
      topology.order,
      edge-gap,
      cross-gap,
      extent(horizontal).width,
    )
  } else if selected == "right" { horizontal } else {
    layered(
      nodes,
      topology.ranks,
      down-gap,
      calc.max(cross-gap, 2 * label-width + 2 * label-gap),
      "down",
    )
  }
  let size = extent(nodes)
  if max-width != none {
    assert(
      size.width <= max-width,
      message: "Reaction graph is wider than max-width; use a different direction, more width, or smaller shared molecular sizes",
    )
  }
  let connections = ()
  for (index, edge) in edges.enumerate() {
    let from = nodes.find(node => node.id == edge.from)
    let to = nodes.find(node => node.id == edge.to)
    let start = if selected == "right" {
      (from.x + from.width + attachment, from.y + image-height / 2)
    } else { (from.x + from.width / 2, from.y + from.height + attachment) }
    let end = if selected == "right" {
      (to.x - attachment, to.y + image-height / 2)
    } else { (to.x + to.width / 2, to.y - attachment) }
    let points = (start, end)
    let center = start.zip(end).map(((a, b)) => (a + b) / 2)
    let wrapped-edge = (
      selected == "right" and topology.linear and from.row != to.row
    )
    if wrapped-edge {
      let right = size.width + head-size + label-gap
      let left = -head-size - label-gap
      let row-bottom = nodes
        .filter(node => node.row == from.row)
        .map(node => node.y + node.height)
        .fold(0pt, calc.max)
      let between = (row-bottom + to.y) / 2
      points = (
        start,
        (right, start.at(1)),
        (right, between),
        (left, between),
        (left, end.at(1)),
        end,
      )
      center = ((left + right) / 2, between)
    } else if to.rank > from.rank + 1 {
      // Skip edges travel outside intermediate stages rather than through their ink.
      let lane = -(index + 1) * (2 * label-height + 2 * label-gap + head-size)
      if selected == "right" {
        let exit = (
          nodes
            .filter(node => node.rank == from.rank)
            .map(node => node.x + node.width)
            .fold(0pt, calc.max)
            + 2 * attachment
        )
        let entry = (
          nodes
            .filter(node => node.rank == to.rank)
            .map(node => node.x)
            .fold(to.x, calc.min)
            - 2 * attachment
        )
        points = (
          start,
          (exit, start.at(1)),
          (exit, lane),
          (entry, lane),
          (entry, end.at(1)),
          end,
        )
        center = ((start.at(0) + end.at(0)) / 2, lane)
      } else {
        let exit = (
          nodes
            .filter(node => node.rank == from.rank)
            .map(node => node.y + node.height)
            .fold(0pt, calc.max)
            + 2 * attachment
        )
        let entry = (
          nodes
            .filter(node => node.rank == to.rank)
            .map(node => node.y)
            .fold(to.y, calc.min)
            - 2 * attachment
        )
        points = (
          start,
          (start.at(0), exit),
          (lane, exit),
          (lane, entry),
          (end.at(0), entry),
          end,
        )
        center = (lane, (start.at(1) + end.at(1)) / 2)
      }
    } else if selected == "right" and start.at(1) != end.at(1) {
      let lane = (start.at(0) + end.at(0)) / 2
      points = (start, (lane, start.at(1)), (lane, end.at(1)), end)
      center = if edges.filter(other => other.from == edge.from).len() > 1 {
        ((lane + end.at(0)) / 2, end.at(1))
      } else { ((start.at(0) + lane) / 2, start.at(1)) }
    } else if selected == "down" and start.at(0) != end.at(0) {
      let lane = (start.at(1) + end.at(1)) / 2
      points = (start, (start.at(0), lane), (end.at(0), lane), end)
      center = if edges.filter(other => other.from == edge.from).len() > 1 {
        (end.at(0), (lane + end.at(1)) / 2)
      } else { (start.at(0), (start.at(1) + lane) / 2) }
    }
    let notes = ()
    for (sign, label) in (
      (-1, edge.at("above-label")),
      (1, edge.at("below-label")),
    ) {
      if label == none { continue }
      let offset = (
        label-gap
          + arrow-width / 2
          + if selected == "right" {
            label.height / 2
          } else { label.width / 2 }
      )
      notes.push((
        body: label.body,
        width: label.width,
        height: label.height,
        x: center.at(0) + if selected == "down" { sign * offset } else { 0pt },
        y: center.at(1) + if selected == "right" { sign * offset } else { 0pt },
      ))
    }
    connections.push((
      from: edge.from,
      to: edge.to,
      points: points,
      notes: notes,
      equilibrium: edge.equilibrium,
    ))
  }
  finish(nodes, connections, appearance, max-width, selected)
}

#let svg-number(value) = str(value).replace("−", "-")
#let svg-point(point) = (
  svg-number(point.at(0) / 1pt) + " " + svg-number(point.at(1) / 1pt)
)

#let connector-svg(data) = {
  let color = if type(data.arrow-color) == color {
    data.arrow-color.to-hex()
  } else { rgb(data.arrow-color).to-hex() }
  let output = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\""
      + str(data.width / 1pt)
      + "\" height=\""
      + str(data.height / 1pt)
      + "\" viewBox=\""
      + svg-point(data.origin)
      + " "
      + str(data.width / 1pt)
      + " "
      + str(data.height / 1pt)
      + "\">"
  )
  for edge in data.steps + data.at("branches", default: ()) {
    let points = edge.points
    let path = if "curve" in edge { circular.curve-path(edge.curve) } else if (
      "arc" in edge
    ) { circular.path(edge.arc) } else {
      "M " + points.map(svg-point).join(" L ")
    }
    output += (
      "<path d=\""
        + path
        + "\" fill=\"none\" stroke=\""
        + color
        + "\" stroke-width=\""
        + str(data.arrow-width / 1pt)
        + "\" stroke-linejoin=\"round\"/>"
    )
    let end = points.last()
    let previous = if "curve" in edge { edge.curve.at(2) } else if (
      "arc" in edge
    ) {
      circular.tangent(edge.arc, data.head-size)
    } else { points.at(points.len() - 2) }
    let dx = (end.at(0) - previous.at(0)) / 1pt
    let dy = (end.at(1) - previous.at(1)) / 1pt
    let distance = calc.sqrt(dx * dx + dy * dy)
    assert(distance > 0, message: "Reaction connector has zero final length")
    let size = data.head-size
    let base = (
      end.at(0) - dx / distance * size,
      end.at(1) - dy / distance * size,
    )
    let left = (
      base.at(0) - dy / distance * size / 2,
      base.at(1) + dx / distance * size / 2,
    )
    let right = (
      base.at(0) + dy / distance * size / 2,
      base.at(1) - dx / distance * size / 2,
    )
    output += (
      "<polygon points=\""
        + (end, left, if edge.equilibrium { base } else { right })
          .map(svg-point)
          .join(" ")
        + "\" fill=\""
        + color
        + "\"/>"
    )
    if edge.equilibrium {
      // The return arrow shares the authored route and stays visibly offset.
      let shifted = if "reverse-arc" in edge {
        circular.arc-points(edge.at("reverse-arc"))
      } else {
        points
          .rev()
          .map(p => if data.direction == "right" {
            (p.at(0), p.at(1) + 3pt)
          } else { (p.at(0) + 3pt, p.at(1)) })
      }
      let reverse-path = if "reverse-arc" in edge {
        circular.path(edge.at("reverse-arc"))
      } else { "M " + shifted.map(svg-point).join(" L ") }
      output += (
        "<path d=\""
          + reverse-path
          + "\" fill=\"none\" stroke=\""
          + color
          + "\" stroke-width=\""
          + str(data.arrow-width / 1pt)
          + "\"/>"
      )
      let tip = shifted.last()
      let back = if "reverse-arc" in edge {
        circular.tangent(edge.at("reverse-arc"), data.head-size)
      } else { shifted.at(shifted.len() - 2) }
      let dx = (tip.at(0) - back.at(0)) / 1pt
      let dy = (tip.at(1) - back.at(1)) / 1pt
      let distance = calc.sqrt(dx * dx + dy * dy)
      let base = (
        tip.at(0) - dx / distance * size,
        tip.at(1) - dy / distance * size,
      )
      output += (
        "<polygon points=\""
          + (
            tip,
            (
              base.at(0) - dy / distance * size / 2,
              base.at(1) + dx / distance * size / 2,
            ),
            base,
          )
            .map(svg-point)
            .join(" ")
          + "\" fill=\""
          + color
          + "\"/>"
      )
    }
  }
  bytes(output + "</svg>")
}

/// Paint an inspected route without remeasuring or independently scaling compounds.
#let paint-reaction-route(data, padding: 6pt) = {
  assert(padding >= 0pt, message: "Route padding must be nonnegative")
  box(width: data.width + 2 * padding, height: data.height + 2 * padding, {
    place(top + left, dx: padding, dy: padding, image(
      connector-svg(data),
      format: "svg",
      width: data.width,
      height: data.height,
    ))
    for stage in data.stages {
      place(
        top + left,
        dx: stage.x - data.origin.at(0) + padding,
        dy: stage.y - data.origin.at(1) + padding,
        stage.body,
      )
    }
    for branch in data.at("branches", default: ()) {
      let group = branch.group
      place(
        top + left,
        dx: group.x - data.origin.at(0) + padding,
        dy: group.y - data.origin.at(1) + padding,
        group.body,
      )
    }
    for edge in data.steps {
      for note in edge.notes {
        place(
          top + left,
          dx: note.x - note.width / 2 - data.origin.at(0) + padding,
          dy: note.y - note.height / 2 - data.origin.at(1) + padding,
          note.body,
        )
      }
    }
    let center = data.at("center", default: none)
    if center != none {
      place(
        top + left,
        dx: -center.width / 2 - data.origin.at(0) + padding,
        dy: -center.height / 2 - data.origin.at(1) + padding,
        center.body,
      )
    }
  })
}

/// Automatic route template; steps default to a chain in declaration order.
/// Available page width drives wrapping. All compounds retain their physical size.
#let reaction-route(..stages, steps: auto, max-width: auto, padding: 6pt) = {
  // Named options are forwarded to the measured layout API.
  layout(size => {
    assert(
      type(padding) == length and padding >= 0pt,
      message: "Route padding must be a nonnegative length",
    )
    let available = if max-width == auto { size.width } else { max-width }
    let width = if available == none { none } else { available - 2 * padding }
    let data = reaction-route-data(
      ..stages.pos(),
      steps: steps,
      max-width: width,
      ..stages.named(),
    )
    paint-reaction-route(data, padding: padding)
  })
}
