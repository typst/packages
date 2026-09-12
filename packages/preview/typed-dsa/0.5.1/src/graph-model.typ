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
