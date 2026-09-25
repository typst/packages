// Graph adjacency state and identity helpers.
//
// Node identity and normalized edge records are independent of layout and
// rendering, and are shared by validation and graph algorithms.

// Adjacency entries are either `"to"` or `("to", label)`.
#let _edge-target-id(entry) = if type(entry) == array { entry.at(0) } else { entry }
#let _edge-display-label(entry) = if type(entry) == array and entry.len() > 1 { entry.at(1) } else { none }

// Every key, plus every neighbor not already a key, in first-seen order.
#let _collect-graph-node-ids(adjacency) = {
  let seen-node-ids = (:)
  let node-ids = ()
  for adjacency-key in adjacency.keys() {
    if adjacency-key not in seen-node-ids {
      seen-node-ids.insert(adjacency-key, true)
      node-ids.push(adjacency-key)
    }
  }
  for adjacency-key in adjacency.keys() {
    for edge-entry in adjacency.at(adjacency-key) {
      let target-node-id = _edge-target-id(edge-entry)
      if target-node-id not in seen-node-ids {
        seen-node-ids.insert(target-node-id, true)
        node-ids.push(target-node-id)
      }
    }
  }
  node-ids
}

// A key for an unordered pair, so an undirected "a","b" and "b","a" match.
#let _normalize-undirected-edge-key(from-node-id, to-node-id) = if from-node-id < to-node-id {
  from-node-id + "\u{0}" + to-node-id
} else {
  to-node-id + "\u{0}" + from-node-id
}

// Directed edges keep every declared (from, to) pair as its own arrow.
// Undirected edges collapse a reciprocal pair (both "a": ("b",) and
// "b": ("a",)) into the single line it represents.
#let _collect-graph-edges(adjacency, directed) = {
  let graph-edges = ()
  let seen-edge-keys = (:)
  for from-node-id in adjacency.keys() {
    for edge-entry in adjacency.at(from-node-id) {
      let to-node-id = _edge-target-id(edge-entry)
      let edge-label = _edge-display-label(edge-entry)
      if directed {
        graph-edges.push((from-node-id, to-node-id, edge-label))
      } else {
        let edge-key = _normalize-undirected-edge-key(
          from-node-id,
          to-node-id,
        )
        if edge-key not in seen-edge-keys {
          seen-edge-keys.insert(edge-key, true)
          graph-edges.push((from-node-id, to-node-id, edge-label))
        }
      }
    }
  }
  graph-edges
}

// Connected components ignore arrow direction because layout treats every
// declared edge as a physical connection between its endpoints.
#let _collect-graph-connected-components(adjacency) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let graph-edges = _collect-graph-edges(adjacency, false)
  let discovered-node-ids = (:)
  let components = ()
  for start-node-id in node-ids {
    if start-node-id in discovered-node-ids { continue }
    let component-node-ids = ()
    let frontier-node-ids = (start-node-id,)
    discovered-node-ids.insert(start-node-id, true)
    while frontier-node-ids.len() > 0 {
      let current-node-id = frontier-node-ids.first()
      frontier-node-ids = frontier-node-ids.slice(1)
      component-node-ids.push(current-node-id)
      for (from-node-id, to-node-id, _) in graph-edges {
        let neighbor-node-id = if from-node-id == current-node-id {
          to-node-id
        } else if to-node-id == current-node-id {
          from-node-id
        } else {
          none
        }
        if neighbor-node-id != none and neighbor-node-id not in discovered-node-ids {
          discovered-node-ids.insert(neighbor-node-id, true)
          frontier-node-ids.push(neighbor-node-id)
        }
      }
    }
    components.push(component-node-ids)
  }
  components
}

// Kahn's algorithm uses declared node order whenever several nodes are ready.
// A cyclic graph returns `none` because no complete topological order exists.
#let _topologically-order-graph-nodes(adjacency) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let incoming-edge-counts = (:)
  for node-id in node-ids { incoming-edge-counts.insert(node-id, 0) }
  for from-node-id in adjacency.keys() {
    for edge-entry in adjacency.at(from-node-id) {
      let to-node-id = _edge-target-id(edge-entry)
      incoming-edge-counts.insert(
        to-node-id,
        incoming-edge-counts.at(to-node-id) + 1,
      )
    }
  }

  let ordered-node-ids = ()
  let emitted-node-ids = (:)
  while ordered-node-ids.len() < node-ids.len() {
    let next-node-id = none
    for node-id in node-ids {
      if node-id not in emitted-node-ids and incoming-edge-counts.at(node-id) == 0 {
        next-node-id = node-id
        break
      }
    }
    if next-node-id == none { return none }
    ordered-node-ids.push(next-node-id)
    emitted-node-ids.insert(next-node-id, true)
    if next-node-id in adjacency {
      for edge-entry in adjacency.at(next-node-id) {
        let to-node-id = _edge-target-id(edge-entry)
        incoming-edge-counts.insert(
          to-node-id,
          incoming-edge-counts.at(to-node-id) - 1,
        )
      }
    }
  }
  ordered-node-ids
}
