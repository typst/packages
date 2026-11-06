// =====================================================
// DSA (Data Structures & Algorithms) - Object-Oriented
// =====================================================
// Combined module for CS data structures and Algorithms

// =====================================================
// CS: ARRAY
// =====================================================

/// Create an array visualization object
/// Parameters:
/// - items: Array of data items
/// - highlight: Indices to highlight
/// - pointers: Dictionary of {index: label}
/// - separators: List of indices for gaps
/// - show-index: Show indices (default: true)
/// - label: Overall label
/// - origin: Position
/// - style: Style overrides
#let cs-array(
  items,
  highlight: (),
  pointers: (:),
  separators: (),
  show-index: true,
  label: none,
  origin: (0, 0),
  style: auto,
) = (
  type: "cs-array",
  items: items,
  highlight: highlight,
  pointers: pointers,
  separators: separators,
  show-index: show-index,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// CS: STACK
// =====================================================

/// Create a stack visualization object
/// Parameters:
/// - items: Stack content (bottom to top)
/// - limit: Max capacity
/// - incoming: Push item
/// - outgoing: Pop item
/// - show-index: Show indices (default: false)
/// - label: Label
/// - origin: Bottom-center position
/// - style: Style overrides
#let cs-stack(
  items,
  limit: none,
  incoming: none,
  outgoing: none,
  show-index: false,
  label: "Stack",
  origin: (0, 0),
  style: auto,
) = (
  type: "cs-stack",
  items: items,
  limit: limit,
  incoming: incoming,
  outgoing: outgoing,
  show-index: show-index,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// CS: QUEUE
// =====================================================

/// Create a queue visualization object
/// Parameters:
/// - items: Queue content (front to back)
/// - limit: Max capacity
/// - incoming: Enqueue item
/// - outgoing: Dequeue item
/// - show-index: Show indices (default: false)
/// - label: Label
/// - origin: Center position
/// - style: Style overrides
#let cs-queue(
  items,
  limit: none,
  incoming: none,
  outgoing: none,
  show-index: false,
  label: "Queue",
  origin: (0, 0),
  style: auto,
) = (
  type: "cs-queue",
  items: items,
  limit: limit,
  incoming: incoming,
  outgoing: outgoing,
  show-index: show-index,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// CS: LINKED LIST
// =====================================================

/// Create a linked list visualization object
/// Parameters:
/// - items: List content
/// - highlight: Indices to highlight
/// - pointers: {index: label} pointers
/// - show-index: Show indices (default: false)
/// - label: Label
/// - origin: Position
/// - style: Style overrides
#let cs-linked-list(
  items,
  highlight: (),
  pointers: (:),
  show-index: false,
  label: none,
  origin: (0, 0),
  style: auto,
) = (
  type: "cs-linked-list",
  items: items,
  highlight: highlight,
  pointers: pointers,
  show-index: show-index,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// ALGO: GRAPH NODE
// =====================================================

/// Create a graph node
#let graph-node(
  value,
  pos: (0, 0),
  name: auto,
  display: auto,
  style: (:),
) = (
  type: "graph-node",
  value: value,
  pos: pos,
  name: name,
  display: display,
  style: style,
)

// =====================================================
// ALGO: GRAPH EDGE
// =====================================================

/// Create a graph edge
#let graph-edge(
  from,
  to,
  weight: none,
  directed: false,
  curved: 0,
  label-pos: 0.5,
  style: (:),
) = (
  type: "graph-edge",
  from: from,
  to: to,
  weight: weight,
  directed: directed,
  curved: curved,
  label-pos: label-pos,
  style: style,
)

// =====================================================
// ALGO: GRAPH
// =====================================================

/// Create a graph visualization object
/// Parameters:
/// - nodes: List of graph-node
/// - edges: List of graph-edge
/// - highlight-path: List of node names
/// - highlight-nodes: List of node names
/// - highlight-edges: List of (from, to) pairs
/// - style: Style overrides
#let free-graph(
  nodes,
  edges,
  highlight-path: (),
  highlight-nodes: (),
  highlight-edges: (),
  origin: (0, 0),
  style: auto,
) = (
  type: "free-graph",
  nodes: nodes,
  edges: edges,
  highlight-path: highlight-path,
  highlight-nodes: highlight-nodes,
  highlight-edges: highlight-edges,
  origin: origin,
  style: style,
)

// =====================================================
// ALGO: GRID WORLD
// =====================================================

/// Create a grid world visualization
/// Parameters:
/// - rows, cols: Dimensions
/// - walls: List of (c, r)
/// - path: List of (c, r)
/// - visited: List of (c, r)
/// - start, target: (c, r)
/// - label: Label
/// - origin: Position
/// - style: Style overrides
#let grid-world(
  rows,
  cols,
  walls: (),
  path: (),
  visited: (),
  start: none,
  target: none,
  label: none,
  origin: (0, 0),
  style: auto,
) = (
  type: "grid-world",
  rows: rows,
  cols: cols,
  walls: walls,
  path: path,
  visited: visited,
  start: start,
  target: target,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// ALGO: ADJACENCY MATRIX
// =====================================================

/// Create an adjacency matrix visualization
/// Parameters:
/// - matrix: 2D array
/// - labels: Row/Col headers
/// - highlight-cells: List of (r, c)
/// - label: Label
/// - origin: Position
/// - style: Style overrides
#let adjacency-matrix(
  matrix,
  labels: (),
  highlight-cells: (),
  label: none,
  origin: (0, 0),
  style: auto,
) = (
  type: "adjacency-matrix",
  matrix: matrix,
  labels: labels,
  highlight-cells: highlight-cells,
  label: label,
  origin: origin,
  style: style,
)

// =====================================================
// TYPE CHECKERS
// =====================================================

#let is-cs-array(obj) = type(obj) == dictionary and obj.at("type", default: none) == "cs-array"
#let is-cs-stack(obj) = type(obj) == dictionary and obj.at("type", default: none) == "cs-stack"
#let is-cs-queue(obj) = type(obj) == dictionary and obj.at("type", default: none) == "cs-queue"
#let is-cs-linked-list(obj) = type(obj) == dictionary and obj.at("type", default: none) == "cs-linked-list"

#let is-graph-node(obj) = type(obj) == dictionary and obj.at("type", default: none) == "graph-node"
#let is-graph-edge(obj) = type(obj) == dictionary and obj.at("type", default: none) == "graph-edge"
#let is-free-graph(obj) = type(obj) == dictionary and obj.at("type", default: none) == "free-graph"
#let is-grid-world(obj) = type(obj) == dictionary and obj.at("type", default: none) == "grid-world"
#let is-adjacency-matrix(obj) = type(obj) == dictionary and obj.at("type", default: none) == "adjacency-matrix"

#let is-dsa-obj(obj) = {
  (
    is-cs-array(obj)
      or is-cs-stack(obj)
      or is-cs-queue(obj)
      or is-cs-linked-list(obj)
      or is-free-graph(obj)
      or is-grid-world(obj)
      or is-adjacency-matrix(obj)
  )
}
