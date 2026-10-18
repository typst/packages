// =====================================================
// TREE DRAW FUNCTIONS
// =====================================================
// Drawing functions for tree objects

#import "@preview/cetz:0.4.2"

// =====================================================
// HELPER: LAYOUT
// =====================================================

// Calculate subtree extent (width for vertical tree, height for horizontal tree)
#let calc-subtree-extent(node, spacing) = {
  if node.children.len() == 0 {
    return spacing // Leaf occupies one unit of spacing
  }

  let children-extent = 0
  for child in node.children {
    children-extent += calc-subtree-extent(child, spacing)
  }
  return children-extent
}

// Recursive layout function
// Returns list of nodes with absolute positions: (value, pos, name, style, is-highlighted, is-path)
// and list of edges: (from-pos, to-pos, is-path)
#let layout-node(
  node,
  x,
  y,
  direction,
  spacing-x,
  spacing-y,
  highlight-items,
  highlight-path,
  objects,
) = {
  let new-objects = objects
  let name = if node.at("name", default: auto) == auto { str(node.value) } else { node.name }

  // Layout children
  let children = node.children
  let n = children.len()
  let children-positions = ()

  if n > 0 {
    let child-extents = children.map(c => calc-subtree-extent(c, if direction == "vertical" { spacing-x } else {
      spacing-y
    }))
    let total-extent = child-extents.sum()

    // Start position for children (centered below/right of parent)
    let current-pos = -total-extent / 2

    for (i, child) in children.enumerate() {
      let child-extent = child-extents.at(i)
      let center-offset = current-pos + child-extent / 2

      let child-x = if direction == "vertical" { x + center-offset } else { x + spacing-x }
      let child-y = if direction == "vertical" { y - spacing-y } else { y + center-offset }

      children-positions.push((child-x, child-y))

      // Determine if edge is strictly part of the highlight path
      // Logic: If current node AND child node are both in highlight-path, highlight edge?
      // Simplified: We usually highlight edge if child is in highlight path.
      // Actually strictly, if path is A->B->C, edge A-B is highlighted.
      // We will check: is 'name' in path AND child's name in path?
      // But we need to know child's name.
      let child-name = if child.at("name", default: auto) == auto { str(child.value) } else { child.name }
      let edge-highlight = highlight-path.contains(name) and highlight-path.contains(child-name)

      // Add edge
      new-objects.edges.push((
        from: (x, y),
        to: (child-x, child-y),
        highlight: edge-highlight,
      ))

      // Recurse
      new-objects = layout-node(
        child,
        child-x,
        child-y,
        direction,
        spacing-x,
        spacing-y,
        highlight-items,
        highlight-path,
        new-objects,
      )

      current-pos += child-extent
    }
  }

  // Add current node
  new-objects.nodes.push((
    pos: (x, y),
    value: node.value,
    name: name,
    style: node.style,
    highlight: highlight-items.contains(name) or highlight-path.contains(name),
    path-highlight: highlight-path.contains(name),
  ))

  return new-objects
}

// =====================================================
// DRAW TREE
// =====================================================

#let draw-tree(obj, theme) = {
  import cetz.draw: *

  let root = obj.root
  let direction = obj.at("direction", default: "vertical")
  let highlight-items = obj.at("highlight-items", default: ())
  let highlight-path = obj.at("highlight-path", default: ())
  let origin = obj.at("origin", default: (0, 0))
  let obj-style = obj.at("style", default: auto)

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  // Theme colors
  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  // Spacing parameters
  let spacing-x = if direction == "vertical" { 1.5 } else { 2.0 }
  let spacing-y = if direction == "vertical" { 2.0 } else { 1.5 }

  // Collect objects
  let layout-data = layout-node(
    root,
    ox,
    oy,
    direction,
    spacing-x,
    spacing-y,
    highlight-items,
    highlight-path,
    (nodes: (), edges: ()),
  )

  // Draw Edges first (so they are behind nodes)
  for edge in layout-data.edges {
    let edge-stroke = if edge.highlight {
      (paint: highlight-col, thickness: 2pt)
    } else {
      (paint: stroke-col, thickness: 1pt)
    }

    // Draw straight lines for now. Could do curves later.
    line(edge.from, edge.to, stroke: edge-stroke)
  }

  // Draw Nodes
  for node in layout-data.nodes {
    let is-highlighted = node.highlight
    let node-color = if is-highlighted { highlight-col } else { stroke-col }
    let fill-color = if is-highlighted { highlight-col.lighten(70%) } else { bg-col }
    let stroke-style = if is-highlighted { (paint: highlight-col, thickness: 1.5pt) } else {
      (paint: stroke-col, thickness: 1pt)
    }

    // Merge custom style
    if node.style != (:) {
      // Allow overriding colors via node style if needed
      // (Simplified implementation for now)
    }

    let radius = 0.35

    circle(
      node.pos,
      radius: radius,
      fill: fill-color,
      stroke: stroke-style,
    )

    content(
      node.pos,
      text(
        fill: node-color,
        size: 10pt,
        weight: "bold",
        str(node.value),
      ),
      anchor: "center",
    )
  }
}
