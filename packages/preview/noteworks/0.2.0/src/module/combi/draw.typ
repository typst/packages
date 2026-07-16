// =====================================================
// COMBINATORICS DRAW FUNCTIONS
// =====================================================
// Drawing functions for combinatorics objects

#import "@preview/cetz:0.4.2"

// =====================================================
// DRAW LINEAR PERMUTATION
// =====================================================

#let draw-linear-perm(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let labels = obj.at("labels", default: none)
  let highlight = obj.at("highlight", default: ())
  let origin = obj.at("origin", default: (0, 0))

  let box-size = 0.8
  let gap = 0.15
  let n = items.len()

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  for i in range(n) {
    let x = ox + i * (box-size + gap)
    let is-highlighted = highlight.contains(i)

    // Box
    rect(
      (x, oy),
      (x + box-size, oy + box-size),
      fill: if is-highlighted { highlight-col.lighten(70%) } else { bg-col },
      stroke: if is-highlighted { highlight-col } else { stroke-col },
    )

    // Item
    let item = items.at(i)
    let item-content = if type(item) == str or type(item) == int { str(item) } else { item }
    content(
      (x + box-size / 2, oy + box-size / 2),
      text(fill: stroke-col, size: 12pt, weight: "bold", item-content),
      anchor: "center",
    )

    // Position label below
    if labels != none and i < labels.len() {
      content(
        (x + box-size / 2, oy - 0.3),
        text(fill: stroke-col.lighten(30%), size: 8pt, labels.at(i)),
        anchor: "north",
      )
    }
  }
}

// =====================================================
// DRAW CIRCULAR PERMUTATION
// =====================================================

#let draw-circular-perm(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let labels = obj.at("labels", default: none)
  let radius = obj.at("radius", default: 1.5)
  let highlight = obj.at("highlight", default: ())
  let show-arrows = obj.at("show-arrows", default: false)
  let origin = obj.at("origin", default: (0, 0))

  let n = items.len()
  let item-radius = 0.35
  let label-offset = 0.55

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  // Center circle (guide)
  circle((ox, oy), radius: radius, stroke: (paint: stroke-col.lighten(60%), dash: "dashed"))

  for i in range(n) {
    let angle = 90deg - i * 360deg / n
    let x = ox + radius * calc.cos(angle)
    let y = oy + radius * calc.sin(angle)
    let is-highlighted = highlight.contains(i)

    // Item circle
    circle(
      (x, y),
      radius: item-radius,
      fill: if is-highlighted { highlight-col.lighten(70%) } else { bg-col },
      stroke: if is-highlighted { highlight-col } else { stroke-col },
    )

    // Item content
    let item = items.at(i)
    let item-content = if type(item) == str or type(item) == int { str(item) } else { item }
    content(
      (x, y),
      text(fill: stroke-col, size: 11pt, weight: "bold", item-content),
      anchor: "center",
    )

    // Position label outside the circle
    if labels != none and i < labels.len() {
      let lx = ox + (radius + item-radius + label-offset) * calc.cos(angle)
      let ly = oy + (radius + item-radius + label-offset) * calc.sin(angle)
      content(
        (lx, ly),
        text(fill: stroke-col.lighten(30%), size: 8pt, labels.at(i)),
        anchor: "center",
      )
    }
  }
}

// =====================================================
// DRAW BALLS AND BOXES
// =====================================================

#let draw-balls-boxes(obj, theme) = {
  import cetz.draw: *

  let n-balls = obj.n-balls
  let n-boxes = obj.n-boxes
  let distribution = obj.at("distribution", default: none)
  let balls-identical = obj.at("balls-identical", default: false)
  let boxes-identical = obj.at("boxes-identical", default: false)
  let ball-labels = obj.at("ball-labels", default: auto)
  let box-labels = obj.at("box-labels", default: auto)
  let origin = obj.at("origin", default: (0, 0))

  let box-width = 1.2
  let box-height = 1.5
  let gap = 0.4
  let ball-radius = 0.15

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  // Default ball labels
  let b-labels = if ball-labels == auto {
    if balls-identical { range(n-balls).map(i => "") } else { range(n-balls).map(i => str(i + 1)) }
  } else { ball-labels }

  // Default box labels
  let bx-labels = if box-labels == auto {
    if boxes-identical { range(n-boxes).map(i => "") } else { range(n-boxes).map(i => str(i + 1)) }
  } else { box-labels }

  // Default distribution
  let dist = if distribution != none {
    distribution
  } else {
    let base = int(n-balls / n-boxes)
    let extra = calc.rem(n-balls, n-boxes)
    range(n-boxes).map(i => if i < extra { base + 1 } else { base })
  }

  let ball-idx = 0

  for i in range(n-boxes) {
    let x = ox + i * (box-width + gap)

    // Box (open top - U shape)
    line((x, oy), (x, oy + box-height), stroke: stroke-col)
    line((x, oy), (x + box-width, oy), stroke: stroke-col)
    line((x + box-width, oy), (x + box-width, oy + box-height), stroke: stroke-col)

    // Box label
    if i < bx-labels.len() and bx-labels.at(i) != "" {
      content(
        (x + box-width / 2, oy - 0.25),
        text(fill: stroke-col, size: 9pt, bx-labels.at(i)),
        anchor: "north",
      )
    }

    // Balls in this box
    let balls-in-box = if i < dist.len() { dist.at(i) } else { 0 }

    for j in range(balls-in-box) {
      let cols-per-row = calc.max(1, int(box-width / (ball-radius * 3)))
      let col = calc.rem(j, cols-per-row)
      let row = int(j / cols-per-row)
      let bx = x + 0.3 + col * ball-radius * 2.8
      let by = oy + 0.25 + row * ball-radius * 2.5

      // Ball color
      let ball-fill = if balls-identical {
        highlight-col.lighten(40%)
      } else {
        let colors = (
          rgb("#e41a1c"),
          rgb("#377eb8"),
          rgb("#4daf4a"),
          rgb("#984ea3"),
          rgb("#ff7f00"),
          rgb("#a65628"),
        )
        colors.at(calc.rem(ball-idx, colors.len()))
      }

      circle(
        (bx, by),
        radius: ball-radius,
        fill: ball-fill,
        stroke: stroke-col,
      )

      // Ball label
      if ball-idx < b-labels.len() and b-labels.at(ball-idx) != "" {
        content(
          (bx, by),
          text(fill: white, size: 7pt, weight: "bold", b-labels.at(ball-idx)),
          anchor: "center",
        )
      }

      ball-idx += 1
    }
  }
}

// =====================================================
// DRAW SUBSET VISUALIZATION
// =====================================================

#let draw-subset-vis(obj, theme) = {
  import cetz.draw: *

  let elements = obj.elements
  let subset = obj.at("subset", default: ())
  let set-label = obj.at("set-label", default: none)
  let subset-label = obj.at("subset-label", default: none)
  let origin = obj.at("origin", default: (0, 0))

  let n = elements.len()
  let radius = 0.28
  let cols = calc.min(n, 5)
  let spacing = 0.75

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  for i in range(n) {
    let col = calc.rem(i, cols)
    let row = int(i / cols)
    let x = ox + col * spacing
    let y = oy - row * spacing
    let is-in-subset = subset.contains(i)

    // Element circle
    circle(
      (x, y),
      radius: radius,
      fill: if is-in-subset { highlight-col.lighten(50%) } else { bg-col },
      stroke: if is-in-subset { (paint: highlight-col, thickness: 2pt) } else { stroke-col },
    )

    // Element content
    let elem = elements.at(i)
    let elem-content = if type(elem) == str or type(elem) == int { str(elem) } else { elem }
    content(
      (x, y),
      text(
        fill: if is-in-subset { highlight-col.darken(20%) } else { stroke-col },
        size: 10pt,
        weight: if is-in-subset { "bold" } else { "regular" },
        elem-content,
      ),
      anchor: "center",
    )
  }
}

// =====================================================
// DRAW COUNTING TREE
// =====================================================

// Helper to calculate total vertical extent occupied by a node at a given level
#let calc-extent(level-idx, levels, base-v-spacing) = {
  if level-idx >= levels.len() - 1 {
    // Leaf node occupies base spacing
    return base-v-spacing
  }

  let children-count = levels.at(level-idx + 1).len()
  let next-level-extent = calc-extent(level-idx + 1, levels, base-v-spacing)

  // Total extent is sum of extents of all children
  // Each child needs 'next-level-extent' of space
  return children-count * next-level-extent
}

#let layout-node(level-idx, ox, oy, levels, base-v-spacing, h-spacing, objects) = {
  // Recursion base case
  if level-idx >= levels.len() - 1 { return objects }

  let next-level = levels.at(level-idx + 1)
  let n = next-level.len()

  // Calculate extent needed for ONE child
  let child-extent = calc-extent(level-idx + 1, levels, base-v-spacing)

  let new-objects = objects

  // Total height covers center-to-center distance from first to last child
  // If each child occupies 'child-extent', and we pack them tightly:
  // Top of box is oy + total_extent/2
  // Center of first child is Top - child_extent/2
  // Center of last child is Bottom + child_extent/2
  // Distance first-to-last center = (N-1) * child-extent

  let layout-height = (n - 1) * child-extent

  for i in range(n) {
    let y = oy + layout-height / 2 - i * child-extent
    let x = ox + h-spacing

    // Line to child
    new-objects.lines.push(((ox, oy), (x, y)))

    // Child node
    new-objects.nodes.push((
      pos: (x, y),
      label: str(next-level.at(i)),
      radius: 0.28,
      text-size: 10pt,
    ))

    // Recursively layout grandchildren
    new-objects = layout-node(level-idx + 1, x, y, levels, base-v-spacing, h-spacing, new-objects)
  }

  return new-objects
}

#let draw-counting-tree(obj, theme) = {
  import cetz.draw: *

  let levels = obj.levels
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let h-spacing = 2.0
  let base-v-spacing = 0.8 // Space for a leaf (node diam 0.56 + gap)

  // Object collection
  let objects = (lines: (), nodes: ())

  // Add Root Node
  objects.nodes.push((
    pos: (ox, oy),
    label: "",
    radius: 0.1,
    text-size: 0pt, // Root is small dot
  ))

  // Start recursion if we have levels
  if levels.len() > 0 {
    // Process Level 0 manually
    let first-level = levels.at(0)
    let n1 = first-level.len()

    // Similar logic to layout-node
    let child-extent = calc-extent(0, levels, base-v-spacing)
    let layout-height = (n1 - 1) * child-extent

    for i in range(n1) {
      let y = oy + layout-height / 2 - i * child-extent
      let x = ox + h-spacing

      objects.lines.push(((ox, oy), (x, y)))
      objects.nodes.push((
        pos: (x, y),
        label: str(first-level.at(i)),
        radius: 0.28,
        text-size: 10pt,
      ))

      objects = layout-node(0, x, y, levels, base-v-spacing, h-spacing, objects)
    }
  }

  // DRAW PASS 1: LINES
  for line-seg in objects.lines {
    line(line-seg.at(0), line-seg.at(1), stroke: stroke-col)
  }

  // DRAW PASS 2: NODES
  for node in objects.nodes {
    let fill-col = if node.label == "" { stroke-col } else { highlight-col.lighten(70%) }
    let stroke-style = stroke-col

    // Special handling for root dot
    if node.label == "" {
      circle(node.pos, radius: node.radius, fill: fill-col)
    } else {
      circle(node.pos, radius: node.radius, fill: fill-col, stroke: stroke-style)
      content(
        node.pos,
        text(fill: stroke-col, size: node.text-size, weight: "bold", node.label),
        anchor: "center",
      )
    }
  }
}
// =====================================================
// DRAW PARTITION (Ferrers Diagram)
// =====================================================

#let draw-partition-vis(obj, theme) = {
  import cetz.draw: *

  let partition = obj.partition
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let cell-size = 0.4
  let gap = 0.05

  // Sort in descending order
  let sorted = partition.sorted().rev()

  for row in range(sorted.len()) {
    let count = sorted.at(row)
    let y = oy - row * (cell-size + gap)

    for col in range(count) {
      let x = ox + col * (cell-size + gap)

      rect(
        (x, y - cell-size),
        (x + cell-size, y),
        fill: highlight-col.lighten(60%),
        stroke: stroke-col,
      )
    }
  }
}

// =====================================================
// DRAW PIGEONHOLE
// =====================================================

#let draw-pigeonhole(obj, theme) = {
  import cetz.draw: *

  let n-pigeons = obj.n-pigeons
  let n-holes = obj.n-holes
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let hole-width = 0.8
  let hole-height = 1.0
  let gap = 0.2
  let pigeon-radius = 0.12

  // Distribute pigeons: put extras in first holes
  let base = int(n-pigeons / n-holes)
  let extra = calc.rem(n-pigeons, n-holes)

  for i in range(n-holes) {
    let x = ox + i * (hole-width + gap)
    let count = if i < extra { base + 1 } else { base }

    // Hole (box)
    rect(
      (x, oy),
      (x + hole-width, oy + hole-height),
      fill: none,
      stroke: stroke-col,
    )

    // Pigeons
    for j in range(count) {
      let px = x + hole-width / 2
      let py = oy + 0.2 + j * pigeon-radius * 2.2

      circle(
        (px, py),
        radius: pigeon-radius,
        fill: if count > 1 { highlight-col } else { highlight-col.lighten(50%) },
        stroke: stroke-col,
      )
    }
  }

  // Highlight if pigeonhole principle applies
  if n-pigeons > n-holes {
    content(
      (ox + n-holes * (hole-width + gap) / 2, oy + hole-height + 0.3),
      text(fill: highlight-col, size: 8pt, "At least one hole has 2+"),
      anchor: "south",
    )
  }
}

// =====================================================
// DISPATCHER
// =====================================================

#let draw-combi(obj, theme) = {
  let t = obj.at("type", default: none)

  if t == "linear-perm" { draw-linear-perm(obj, theme) } else if t == "circular-perm" {
    draw-circular-perm(obj, theme)
  } else if t == "balls-boxes" { draw-balls-boxes(obj, theme) } else if t == "subset-vis" {
    draw-subset-vis(obj, theme)
  } else if t == "counting-tree" { draw-counting-tree(obj, theme) } else if t == "partition-vis" {
    draw-partition-vis(obj, theme)
  } else if t == "pigeonhole" { draw-pigeonhole(obj, theme) }
}
