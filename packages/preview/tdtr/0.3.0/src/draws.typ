/// pre-defined drawing functions for tidy tree
#import "utils.typ" : collect-metadata

/// process the input draw-function to a valid draw-function
#let shortcut-draw-function(draw-function) = {
  let typ = type(draw-function)
  if typ == function {
    return draw-function
  } else if typ == arguments or typ == dictionary or typ == array {
    return (..) => draw-function
  } else {
    error("Invalid draw-function type: " + str(typ))
  }
}

/*
  compose multiple draw-function functions sequentially
  - input:
    - `draw-functions`: array of draw-function functions
      - see `tidy-tree-elements` for the format
  - output:
    - `ret`: a composed draw-function function
*/
#let sequential-draw-function(..draw-functions) = {
  let func = (..) => arguments()
  for draw-function in draw-functions.pos() {
    draw-function = shortcut-draw-function(draw-function)
    func = (..info) => arguments(..func(..info), ..draw-function(..info))
  }
  return func
}

/// **************************************
/// draw-node functions
/// **************************************

/// default function for drawing a node
#let default-draw-node = ((name, label, pos)) => {
  (
    pos: (pos.x, pos.i), 
    label: [#label], 
    name: name, 
    shape: rect
  )
}

/// draw a node with metadata matching
#let metadata-match-draw-node = ((name, label, pos), matches: (:), default: (:)) => {
  let ret = arguments()
  let matched = false
  let keys = matches.keys()
  // check whether any metadata in node labels matches
  for key in collect-metadata(label) {
    if keys.contains(key) {
      // support shortcut draw-node
      let draw-node = shortcut-draw-function(matches.at(key))
      ret = arguments(..ret, ..draw-node((name, label, pos)))
      matched = true
    }
  }
  // default case when no metadata matches
  if not matched {
    ret = arguments(..default)
  }
  
  ret
}

/// draw a node with specified width and height
#let size-draw-node = ((name, label, pos), width: auto, height: auto) => {
  (
    width: width,
    height: height
  )
}

/// draw a node as a circle
#let circle-draw-node = ((name, label, pos)) => {
  default-draw-node((name, label, pos)) + (
    shape: circle
  )
}

/// **************************************
/// draw-edge functions
/// **************************************

/// default function for drawing an edge
#let default-draw-edge = (from-node, to-node, edge-label) => {
  (
    vertices: (from-node.name, to-node.name), 
    marks: "-|>"
  )
  if edge-label != none {
    (
      label: box(fill: white, inset: 2pt)[#edge-label], 
      label-sep: 0pt, 
      label-anchor: "center"
    )
  }
}

/// draw an edge with metadata matching
#let metadata-match-draw-edge = (from-node, to-node, edge-label, from-matches: (:), to-matches: (:), matches: (:), default: (:)) => {
  let ret = arguments()
  let matched = false
  let keys = matches.keys()
  // check whether any metadata in edge labels matches
  for key in collect-metadata(edge-label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }
  let keys = from-matches.keys()
  // check whether any metadata in from node labels matches
  for key in collect-metadata(from-node.label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(from-matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }
  let keys = to-matches.keys()
  // check whether any metadata in to node labels matches
  for key in collect-metadata(to-node.label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(to-matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }

  // default case when no metadata matches
  if not matched {
    ret = arguments(..default)
  }

  ret
}

/// draw an edge in reversed direction
#let reversed-draw-edge = (from-node, to-node, edge-label) => {
  default-draw-edge(to-node, from-node, edge-label)
}

/// draw an edge with horizontal-vertical style
#let horizontal-vertical-draw-edge = (from-node, to-node, edge-label) => {
  let from-anchor = (name: from-node.name, anchor: "south")
  let to-anchor = (name: to-node.name, anchor: "north")
  let middle-anchor = (from-anchor, 50%, to-anchor)
  if from-node.pos.x == to-node.pos.x {
    (
      vertices: (from-anchor, to-anchor), 
      marks: "-|>",
      label: edge-label
    )
  } else {
    (
      vertices: (
        from-anchor,
        ((), "|-", middle-anchor),
        ((), "-|", to-anchor),
        to-anchor
      ),
      marks: "-|>",
      label: edge-label
    )
  }
}

/// **************************************
/// draw-graph functions
/// **************************************

/// default function for drawing a graph
#let default-draw-graph = (args, elements, ..) => {
  arguments(..args, ..elements)
}
