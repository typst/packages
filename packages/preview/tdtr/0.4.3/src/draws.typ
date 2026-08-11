/// pre-defined drawing functions for tidy tree
#import "utils.typ" : collect-metadata, collect-label

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
      ret = arguments(..ret, ..draw-node((name: name, label: label, pos: pos)))
      matched = true
    }
  }
  // default case when no metadata matches
  if not matched {
    let draw-node = shortcut-draw-function(default)
    ret = arguments(..draw-node((name: name, label: label, pos: pos)))
  }
  
  ret
}

#let label-match-draw-node = ((name, label, pos), matches: (:), default: (:)) => {
  let ret = arguments()
  let matched = false
  let keys = matches.keys()
  // check whether any label in node labels matches
  for key in collect-label(label) {
    if keys.contains(key) {
      // support shortcut draw-node
      let draw-node = shortcut-draw-function(matches.at(key))
      ret = arguments(..ret, ..draw-node((name: name, label: label, pos: pos)))
      matched = true
    }
  }
  // default case when no label matches
  if not matched {
    let draw-node = shortcut-draw-function(default)
    ret = arguments(..draw-node((name: name, label: label, pos: pos)))
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
  (
    shape: circle
  )
}

/// draw the tree in horizontal direction
#let horizontal-draw-node = ((name, label, pos)) => {
  (
    pos: (pos.i, pos.x)
  )
}

/// draw a hidden node but affecting the layout
#let hidden-draw-node = ((name, label, pos)) => {
  (
    post: x => none
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
    let draw-edge = shortcut-draw-function(default)
    ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
  }

  ret
}

#let label-match-draw-edge = (from-node, to-node, edge-label, from-matches: (:), to-matches: (:), matches: (:), default: (:)) => {
  let ret = arguments()
  let matched = false
  let keys = matches.keys()
  // check whether any label in edge labels matches
  for key in collect-label(edge-label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }
  let keys = from-matches.keys()
  // check whether any label in from node labels matches
  for key in collect-label(from-node.label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(from-matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }
  let keys = to-matches.keys()
  // check whether any label in to node labels matches
  for key in collect-label(to-node.label) {
    if keys.contains(key) {
      let draw-edge = shortcut-draw-function(to-matches.at(key))
      ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
      matched = true
    }
  }

  // default case when no label matches
  if not matched {
    let draw-edge = shortcut-draw-function(default)
    ret = arguments(..ret, ..draw-edge(from-node, to-node, edge-label))
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

/// draw a hidden edge
#let hidden-draw-edge = (from-node, to-node, edge-label) => {
  (
    post: x => none
  )
}

/// **************************************
/// additional draw functions
/// **************************************

/// default function for drawing additional elements, i.e., no additional drawing
#let default-additional-draw = (..) => ()
