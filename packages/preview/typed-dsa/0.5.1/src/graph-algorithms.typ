// Graph traversal and shortest-path teaching traces.
//
// Algorithms own traversal semantics and trace construction. They consume the
// graph model and renderer but do not own public graph rendering or layout.

#import "style.typ": resolve
#import "validate.typ": (
  check-bool, check-enum, check-integer, check-reference, fail, is-number,
  show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import "graph-model.typ": (
  _collect-graph-node-ids, _edge-display-label, _edge-target-id,
)
#import "graph-render.typ": (
  _lookup-graph-node-value, _render-graph, _resolve-graph-edge-customization,
  _resolve-graph-node-customization,
)
#import "graph-validation.typ": _validate-graph-arguments

// ── Algorithm traces ────────────────────────────────────────────────────────

#let _collect-graph-neighbors(adjacency, node-id, directed) = {
  let neighbors = ()
  if node-id in adjacency {
    for edge-entry in adjacency.at(node-id) {
      neighbors.push((
        node: _edge-target-id(edge-entry),
        weight: _edge-display-label(edge-entry),
      ))
    }
  }
  if not directed {
    for from-node-id in adjacency.keys() {
      for edge-entry in adjacency.at(from-node-id) {
        let is-incoming-edge = _edge-target-id(edge-entry) == node-id
        let neighbor-is-recorded = neighbors.position(
          neighbor => neighbor.node == from-node-id,
        ) != none
        if is-incoming-edge and not neighbor-is-recorded {
          neighbors.push((
            node: from-node-id,
            weight: _edge-display-label(edge-entry),
          ))
        }
      }
    }
  }
  neighbors
}

#let _build-graph-state-node-customizations(
  base-customizations,
  node-ids,
  visited-node-ids,
  current-node-id,
  frontier-node-ids,
  resolved-style,
) = {
  let state-customizations = ()
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(
      base-customizations,
      node-id,
    )
    if node-customization == none { node-customization = (:) }
    let state-style = if node-id == current-node-id {
      resolved-style.current-style
    } else if node-id in frontier-node-ids {
      resolved-style.queued-style
    } else if node-id in visited-node-ids {
      resolved-style.visited-style
    } else {
      none
    }
    if state-style != none { node-customization += state-style }
    if node-customization.len() > 0 {
      state-customizations.push((node-id, node-customization))
    }
  }
  state-customizations
}

#let _graph-edges-match(
  candidate-from-id,
  candidate-to-id,
  from-node-id,
  to-node-id,
  directed,
) = if directed {
  candidate-from-id == from-node-id and candidate-to-id == to-node-id
} else {
  (
    candidate-from-id == from-node-id and candidate-to-id == to-node-id
  ) or (
    candidate-from-id == to-node-id and candidate-to-id == from-node-id
  )
}

#let _path-to-graph-edges(path) = {
  let path-edges = ()
  for path-index in range(path.len() - 1) {
    path-edges.push((path.at(path-index), path.at(path-index + 1)))
  }
  path-edges
}

#let _build-graph-state-edge-customizations(
  base-customizations,
  active-edge,
  path,
  directed,
  resolved-style,
) = {
  let highlighted-edges = if active-edge == none {
    _path-to-graph-edges(path)
  } else {
    (active-edge,) + _path-to-graph-edges(path)
  }
  if highlighted-edges.len() == 0 { return base-customizations }
  let state-customizations = ()
  for (from-node-id, to-node-id) in highlighted-edges {
    let existing-customization = _resolve-graph-edge-customization(
      base-customizations,
      from-node-id,
      to-node-id,
      directed,
    )
    let highlighted-customization = (
      if existing-customization == none { (:) } else { existing-customization }
    ) + resolved-style.active-edge-style
    state-customizations.push((
      from-node-id,
      to-node-id,
      highlighted-customization,
    ))
  }
  for (from-node-id, to-node-id, customization) in base-customizations {
    let edge-is-highlighted = highlighted-edges.any(edge => (
      _graph-edges-match(
        from-node-id,
        to-node-id,
        edge.at(0),
        edge.at(1),
        directed,
      )
    ))
    if not edge-is-highlighted {
      state-customizations.push((
        from-node-id,
        to-node-id,
        customization,
      ))
    }
  }
  state-customizations
}

#let _build-distance-node-labels(
  node-ids,
  distances,
  supplied-labels,
  resolved-style,
  message-catalog,
) = {
  let distance-labels = ()
  for node-id in node-ids {
    let supplied-label = _lookup-graph-node-value(supplied-labels, node-id)
    let distance-value = if distances.at(node-id) == none {
      $infinity$
    } else {
      distances.at(node-id)
    }
    let label-body = msg(
      message-catalog,
      "graph.distance",
      distance-value,
    )
    let label-customization = (
      color: rgb("#7048E8"),
      weight: "bold",
    )
    let label-defaults = resolved-style.at("node-labels", default: (:))
    if "gap" not in label-defaults { label-customization.gap = 0.5 }
    if type(supplied-label) == dictionary {
      label-customization += supplied-label
    }
    label-customization.content = label-body
    distance-labels.push((node-id, label-customization))
  }
  distance-labels
}

#let _create-graph-algorithm-step(
  label, adjacency, directed, labels, positions, layout, radius,
  edge-customizations, node-customizations, node-labels, style,
  visited, current, queued, active,
  captions, distances: none, path: (), gap: auto, cat: default-catalog,
) = {
  let resolved-style = resolve(style)
  let node-ids = _collect-graph-node-ids(adjacency)
  let state-node-customizations = _build-graph-state-node-customizations(
    node-customizations,
    node-ids,
    visited,
    current,
    queued,
    resolved-style,
  )
  let state-edge-customizations = _build-graph-state-edge-customizations(
    edge-customizations,
    active,
    path,
    directed,
    resolved-style,
  )
  let state-node-labels = if distances == none {
    node-labels
  } else {
    _build-distance-node-labels(
      node-ids,
      distances,
      node-labels,
      resolved-style,
      cat,
    )
  }
  let graph-diagram = _render-graph(
    adjacency,
    directed,
    labels,
    positions,
    layout,
    radius,
    gap,
    state-edge-customizations,
    state-node-customizations,
    state-node-labels,
    resolved-style,
  )
  (
    label: label,
    current: current,
    visited: visited,
    queued: queued,
    active-edge: active,
    path: path,
    diagram: align(center)[
      #if captions [#text(..resolved-style.algorithm-label-text)[#label] #v(0.25em)]
      #graph-diagram
    ],
  ) + if distances == none { (:) } else { (distances: distances,) }
}

#let _create-graph-trace-result(steps, result, columns, row-gap) = (
  steps: steps,
  result: result,
  diagram: grid(columns: columns, column-gutter: row-gap, row-gutter: row-gap, ..steps.map(step => step.diagram)),
)

#let _reconstruct-graph-path(previous, source, target, found) = {
  if target == none or not found { return () }
  let reverse-path = (target,)
  let current-node-id = target
  while current-node-id != source {
    current-node-id = previous.at(current-node-id, default: none)
    if current-node-id == none { return () }
    reverse-path.push(current-node-id)
  }
  reverse-path.rev()
}

// Every trace shares the same argument surface as `graph()`, plus its
// endpoints and presentation options.
#let _validate-graph-traversal(
  where, adjacency, source, target, directed, labels, positions, layout, radius,
  gap, edge-customizations, node-customizations, node-labels, style, columns,
  captions,
) = {
  let node-ids = _validate-graph-arguments(
    where, adjacency, directed, labels, positions, layout, radius, gap,
    edge-customizations, node-customizations, node-labels, style,
  )
  check-integer(where, "columns:", columns, min: 1)
  check-bool(where, "captions:", captions)
  check-reference(where, "source", source, node-ids)
  if target != none {
    check-reference(where, "target:", target, node-ids)
  }
  node-ids
}

// Weights are checked across the whole graph before the search starts, so an
// unusable weight on an edge the search never relaxes still fails at the call.
// An unlabelled edge is weight 1 by definition.
#let _validate-dijkstra-weights(where, adjacency) = {
  for (from-node-id, edge-entries) in adjacency {
    for edge-entry in edge-entries {
      let edge-weight = _edge-display-label(edge-entry)
      if edge-weight == none { continue }
      let to-node-id = _edge-target-id(edge-entry)
      let edge-name = "edge " + from-node-id + " -> " + to-node-id
      if not is-number(edge-weight) {
        fail(
          where,
          edge-name + " has weight " + show-value(edge-weight) + ", which is not a number",
          expected: "a non-negative number, or no label for weight 1",
          fix: "write the weight as a number, for example (\"" + to-node-id + "\", 4)",
        )
      }
      if edge-weight < 0 {
        fail(
          where,
          edge-name + " has weight " + show-value(edge-weight),
          expected: "a non-negative weight; Dijkstra's algorithm requires it",
          fix: "use a non-negative weight, or a different shortest-path algorithm",
        )
      }
    }
  }
}

#let _should-relax-edge(current-distance, edge-weight, neighbor-distance) = (
  neighbor-distance == none or current-distance + edge-weight < neighbor-distance
)

#let _select-closest-unvisited-node(node-ids, distances, visited-node-ids) = {
  let closest-node-id = none
  for node-id in node-ids {
    let node-is-reachable = distances.at(node-id) != none
    if node-id not in visited-node-ids and node-is-reachable {
      let node-is-closer = if closest-node-id == none {
        true
      } else {
        distances.at(node-id) < distances.at(closest-node-id)
      }
      if node-is-closer { closest-node-id = node-id }
    }
  }
  closest-node-id
}

#let bfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  goal-test: "discovery", language: "en", messages: (:),
) = {
  check-enum("bfs()", "goal-test:", goal-test, ("discovery", "expansion"))
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "bfs()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  let queue = (source,)
  let discovered-node-ids = (:)
  discovered-node-ids.insert(source, true)
  let visited-node-ids = ()
  let traversal-order = ()
  let previous-node-by-id = (:)
  let steps = ()
  let create-step(label, state-visited, state-queued, current: none, active: none) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-queued, active, captions,
    gap: gap, cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.queue", source),
    visited-node-ids,
    queue,
  ))
  if target == source {
    traversal-order.push(source)
    visited-node-ids.push(source)
    steps.push(create-step(
      msg(message-catalog, "graph.reached", target),
      visited-node-ids,
      (),
    ))
    return _create-graph-trace-result(
      steps,
      (order: traversal-order, found: true, path: (source,)),
      columns,
      row-gap,
    )
  }
  while queue.len() > 0 {
    let current-node-id = queue.first()
    queue = queue.slice(1)
    steps.push(create-step(
      msg(message-catalog, "graph.visit", current-node-id),
      visited-node-ids,
      queue,
      current: current-node-id,
    ))
    traversal-order.push(current-node-id)
    let reached-target-on-expansion = (
      goal-test == "expansion"
        and target != none
        and current-node-id == target
    )
    if reached-target-on-expansion {
      visited-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.reached", target),
        visited-node-ids,
        queue,
      ))
      break
    }
    let has-discovered-target = false
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      let neighbor-is-new = neighbor-node-id not in discovered-node-ids
      if neighbor-is-new {
        discovered-node-ids.insert(neighbor-node-id, true)
        previous-node-by-id.insert(neighbor-node-id, current-node-id)
        queue.push(neighbor-node-id)
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.inspect",
          current-node-id,
          neighbor-node-id,
        ),
        visited-node-ids,
        queue,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
      let reached-target-on-discovery = (
        goal-test == "discovery"
          and target != none
          and neighbor-is-new
          and neighbor-node-id == target
      )
      if reached-target-on-discovery {
        visited-node-ids.push(current-node-id)
        steps.push(create-step(
          msg(message-catalog, "graph.reached", target),
          visited-node-ids,
          queue,
          current: target,
        ))
        has-discovered-target = true
        break
      }
    }
    if has-discovered-target { break }
    visited-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      visited-node-ids,
      queue,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    target in discovered-node-ids
  }
  _create-graph-trace-result(
    steps,
    (
      order: traversal-order,
      found: found-target,
      path: _reconstruct-graph-path(
        previous-node-by-id,
        source,
        target,
        found-target == true,
      ),
    ),
    columns,
    row-gap,
  )
}

#let dfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "dfs()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  let stack = (source,)
  let discovered-node-ids = (:)
  discovered-node-ids.insert(source, true)
  let visited-node-ids = ()
  let traversal-order = ()
  let previous-node-by-id = (:)
  let steps = ()
  let create-step(label, state-visited, state-frontier, current: none, active: none) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-frontier, active, captions,
    gap: gap, cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.stack", source),
    visited-node-ids,
    stack,
  ))
  while stack.len() > 0 {
    let current-node-id = stack.last()
    stack = stack.slice(0, stack.len() - 1)
    steps.push(create-step(
      msg(message-catalog, "graph.visit", current-node-id),
      visited-node-ids,
      stack,
      current: current-node-id,
    ))
    traversal-order.push(current-node-id)
    if target != none and current-node-id == target {
      visited-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.reached", target),
        visited-node-ids,
        stack,
      ))
      break
    }
    let newly-discovered-node-ids = ()
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      if neighbor-node-id not in discovered-node-ids {
        discovered-node-ids.insert(neighbor-node-id, true)
        previous-node-by-id.insert(neighbor-node-id, current-node-id)
        newly-discovered-node-ids.push(neighbor-node-id)
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.inspect",
          current-node-id,
          neighbor-node-id,
        ),
        visited-node-ids,
        stack + newly-discovered-node-ids,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
    }
    stack += newly-discovered-node-ids.rev()
    visited-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      visited-node-ids,
      stack,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    target in discovered-node-ids
  }
  _create-graph-trace-result(
    steps,
    (
      order: traversal-order,
      found: found-target,
      path: _reconstruct-graph-path(
        previous-node-by-id,
        source,
        target,
        found-target == true,
      ),
    ),
    columns,
    row-gap,
  )
}

#let dijkstra(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "dijkstra()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  _validate-dijkstra-weights("dijkstra()", adjacency)
  let distances = (:)
  for node-id in node-ids {
    distances.insert(node-id, if node-id == source { 0 } else { none })
  }
  let previous-node-by-id = (:)
  let settled-node-ids = ()
  let settlement-order = ()
  let steps = ()
  let frontier-node-ids(state-distances, state-settled, current: none) = (
    node-ids.filter(node-id => (
      state-distances.at(node-id) != none
        and node-id not in state-settled
        and node-id != current
    ))
  )
  let create-step(label, state-settled, state-distances, current: none, active: none, path: ()) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-settled,
    current,
    frontier-node-ids(state-distances, state-settled, current: current),
    active,
    captions,
    distances: state-distances,
    path: path,
    gap: gap,
    cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.distance-init", source),
    settled-node-ids,
    distances,
  ))
  while true {
    let current-node-id = _select-closest-unvisited-node(
      node-ids,
      distances,
      settled-node-ids,
    )
    if current-node-id == none { break }
    steps.push(create-step(
      msg(message-catalog, "graph.settle", current-node-id),
      settled-node-ids,
      distances,
      current: current-node-id,
    ))
    settlement-order.push(current-node-id)
    if target != none and current-node-id == target {
      settled-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.shortest-path", target),
        settled-node-ids,
        distances,
        path: _reconstruct-graph-path(
          previous-node-by-id,
          source,
          target,
          true,
        ),
      ))
      break
    }
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      let edge-weight = if neighbor.weight == none { 1 } else { neighbor.weight }
      if neighbor-node-id not in settled-node-ids {
        let current-distance = distances.at(current-node-id)
        let neighbor-distance = distances.at(neighbor-node-id)
        if _should-relax-edge(
          current-distance,
          edge-weight,
          neighbor-distance,
        ) {
          distances.insert(
            neighbor-node-id,
            current-distance + edge-weight,
          )
          previous-node-by-id.insert(neighbor-node-id, current-node-id)
        }
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.relax",
          current-node-id,
          neighbor-node-id,
        ),
        settled-node-ids,
        distances,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
    }
    settled-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      settled-node-ids,
      distances,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    distances.at(target) != none
  }
  _create-graph-trace-result(steps, (
    distances: distances,
    previous: previous-node-by-id,
    order: settlement-order,
    found: found-target,
    path: _reconstruct-graph-path(
      previous-node-by-id,
      source,
      target,
      found-target == true,
    ),
  ), columns, row-gap)
}
