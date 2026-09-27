
#import "@preview/cetz:0.4.2"
#import "dsa.typ": *

// =====================================================
// DSA DRAW FUNCTIONS
// =====================================================
// Combined drawing functions for CS and Algo objects

// -----------------------------------------------------
// CS: ARRAY
// -----------------------------------------------------

#let draw-cs-array(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let highlight = obj.at("highlight", default: ())
  if type(highlight) != array { highlight = (highlight,) }
  let pointers = obj.at("pointers", default: (:))
  let separators = obj.at("separators", default: ())
  let show-index = obj.at("show-index", default: true)
  let label = obj.at("label", default: none)
  let origin = obj.at("origin", default: (0, 0))

  let box-width = 0.8
  let box-height = 0.8
  let gap = 0.0
  let sep-gap = 0.4

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  let n = items.len()

  // Pre-calculate positions
  let x-positions = ()
  let current-x = ox
  for i in range(n) {
    x-positions.push(current-x)
    current-x += box-width + gap
    if separators.contains(i) {
      current-x += sep-gap
    }
  }

  let total-width = current-x - ox - gap

  for i in range(n) {
    let x = x-positions.at(i)
    let y = oy

    let is-highlighted = highlight.contains(i)

    // Box
    rect(
      (x, y),
      (x + box-width, y + box-height),
      fill: if is-highlighted { highlight-col.lighten(70%) } else { bg-col },
      stroke: if is-highlighted { (paint: highlight-col, thickness: 1.5pt) } else { stroke-col },
    )

    // Item
    content(
      (x + box-width / 2, y + box-height / 2),
      text(fill: stroke-col, weight: "bold", str(items.at(i))),
      anchor: "center",
    )

    // Index
    if show-index {
      content(
        (x + box-width / 2, y - 0.2),
        text(fill: stroke-col.lighten(40%), size: 8pt, str(i)),
        anchor: "north",
      )
    }

    // Pointers
    let k = str(i)
    if k in pointers {
      let ptr-label = pointers.at(k)
      line((x + box-width / 2, y - 0.9), (x + box-width / 2, y - 0.45), mark: (end: ">"), stroke: highlight-col)
      content(
        (x + box-width / 2, y - 1.05),
        text(fill: highlight-col, size: 9pt, weight: "bold", ptr-label),
        anchor: "north",
      )
    }
  }

  if label != none {
    content(
      (ox + total-width / 2, oy + box-height + 0.3),
      text(fill: stroke-col, weight: "bold", label),
      anchor: "south",
    )
  }
}

// -----------------------------------------------------
// CS: STACK
// -----------------------------------------------------

#let draw-cs-stack(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let limit = obj.at("limit", default: none)
  let incoming = obj.at("incoming", default: none)
  let outgoing = obj.at("outgoing", default: none)
  let show-index = obj.at("show-index", default: false)
  let label = obj.at("label", default: none)
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let item-fill = theme.at("plot", default: (:)).at("highlight", default: blue)

  let width = 1.2
  let item-height = 0.6
  let display-limit = if limit != none { limit } else { calc.max(5, items.len() + 1) }
  let height = display-limit * item-height + 0.2

  // Container
  let x-left = ox - width / 2
  let x-right = ox + width / 2

  line(
    (x-left, oy + height),
    (x-left, oy),
    (x-right, oy),
    (x-right, oy + height),
    stroke: (paint: stroke-col, thickness: 1.5pt),
  )

  // Items
  for (i, item) in items.enumerate() {
    let y = oy + 0.1 + i * item-height
    rect(
      (x-left + 0.1, y),
      (x-right - 0.1, y + item-height - 0.05),
      fill: item-fill.lighten(60%),
      stroke: stroke-col,
    )
    content(
      (ox, y + item-height / 2),
      text(fill: stroke-col, str(item)),
      anchor: "center",
    )
    if show-index {
      content(
        (x-left - 0.3, y + item-height / 2),
        text(fill: stroke-col.lighten(40%), size: 8pt, str(i)),
        anchor: "east",
      )
    }
  }

  // Incoming
  if incoming != none {
    let y-in = oy + height + 0.5
    rect(
      (x-left + 0.1, y-in),
      (x-right - 0.1, y-in + item-height - 0.05),
      fill: item-fill.lighten(30%),
      stroke: (paint: item-fill, thickness: 1pt, dash: "dashed"),
    )
    content(
      (ox, y-in + item-height / 2),
      text(fill: item-fill, weight: "bold", str(incoming)),
      anchor: "center",
    )
    line((ox, y-in - 0.1), (ox, oy + height - 0.1), mark: (end: ">"), stroke: item-fill)
  }

  // Outgoing
  if outgoing != none {
    let y-out = oy + height
    let x-out = x-right + 0.8
    let width-real = width - 0.2

    rect(
      (x-out, y-out),
      (x-out + width-real, y-out + item-height - 0.05),
      fill: item-fill.lighten(30%),
      stroke: (paint: item-fill, thickness: 1pt, dash: "dashed"),
    )
    content(
      (x-out + width-real / 2, y-out + item-height / 2),
      text(fill: item-fill, weight: "bold", str(outgoing)),
      anchor: "center",
    )

    let start = (ox, oy + height - 0.1)
    let target-x = x-out + width-real / 2
    let target-y = y-out + item-height
    let end = (target-x, target-y + 0.05)

    let c1 = (ox, oy + height + 1.0)
    let c2 = (target-x - 0.2, target-y + 1.2)

    bezier(start, end, c1, c2, mark: (end: ">"), stroke: item-fill)
  }

  if label != none {
    content((ox, oy - 0.4), text(fill: stroke-col, weight: "bold", label), anchor: "north")
  }
}

// -----------------------------------------------------
// CS: QUEUE
// -----------------------------------------------------

#let draw-cs-queue(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let limit = obj.at("limit", default: none)
  let incoming = obj.at("incoming", default: none)
  let outgoing = obj.at("outgoing", default: none)
  let show-index = obj.at("show-index", default: false)
  let label = obj.at("label", default: none)
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let item-fill = theme.at("plot", default: (:)).at("highlight", default: blue)

  let item-width = 0.8
  let height = 1.2
  let display-limit = if limit != none { limit } else { calc.max(5, items.len() + 1) }
  let width = display-limit * item-width + 0.2

  let x-start = ox - width / 2
  let x-end = ox + width / 2

  line((x-start, oy + height / 2), (x-end, oy + height / 2), stroke: stroke-col)
  line((x-start, oy - height / 2), (x-end, oy - height / 2), stroke: stroke-col)

  for i in range(display-limit + 1) {
    let dx = x-start + 0.1 + i * item-width
    line((dx, oy + height / 2), (dx, oy + height / 2 - 0.1), stroke: stroke-col)
    line((dx, oy - height / 2), (dx, oy - height / 2 + 0.1), stroke: stroke-col)
  }

  for (i, item) in items.enumerate() {
    let x = x-start + 0.1 + i * item-width
    let w = item-width - 0.05
    let item-h = 0.6

    rect(
      (x, oy - item-h / 2),
      (x + w, oy + item-h / 2),
      fill: item-fill.lighten(60%),
      stroke: stroke-col,
    )
    content(
      (x + w / 2, oy),
      text(fill: stroke-col, str(item)),
      anchor: "center",
    )
    if show-index {
      content(
        (x + w / 2, oy - height / 2 - 0.2),
        text(fill: stroke-col.lighten(40%), size: 8pt, str(i)),
        anchor: "north",
      )
    }
  }

  if incoming != none {
    let x-in = x-end + 1.2
    let w = item-width - 0.05
    let item-h = 0.6
    rect(
      (x-in, oy - item-h / 2),
      (x-in + w, oy + item-h / 2),
      fill: item-fill.lighten(30%),
      stroke: (paint: item-fill, thickness: 1pt, dash: "dashed"),
    )
    content(
      (x-in + w / 2, oy),
      text(fill: item-fill, weight: "bold", str(incoming)),
      anchor: "center",
    )
    line((x-in - 0.1, oy), (x-end + 0.05, oy), mark: (end: ">"), stroke: item-fill)
  }

  if outgoing != none {
    let x-out = x-start - 1.2 - item-width
    let w = item-width - 0.05
    let item-h = 0.6
    rect(
      (x-out, oy - item-h / 2),
      (x-out + w, oy + item-h / 2),
      fill: item-fill.lighten(30%),
      stroke: (paint: item-fill, thickness: 1pt, dash: "dashed"),
    )
    content(
      (x-out + w / 2, oy),
      text(fill: item-fill, weight: "bold", str(outgoing)),
      anchor: "center",
    )
    line((x-start - 0.05, oy), (x-out + w + 0.1, oy), mark: (end: ">"), stroke: item-fill)
  }

  if label != none {
    // Calculate visual bounds to center label
    let v-min-x = x-start
    let v-max-x = x-end

    if incoming != none {
      v-max-x = x-end + 1.2 + (item-width - 0.05)
    }
    if outgoing != none {
      v-min-x = x-start - 1.2 - item-width
    }

    let center-x = (v-min-x + v-max-x) / 2
    content((center-x, oy - height / 2 - 0.8), text(fill: stroke-col, weight: "bold", label), anchor: "north")
  }
}

// -----------------------------------------------------
// CS: LINKED LIST
// -----------------------------------------------------

#let draw-cs-linked-list(obj, theme) = {
  import cetz.draw: *

  let items = obj.items
  let highlight = obj.at("highlight", default: ())
  if type(highlight) != array { highlight = (highlight,) }
  let pointers = obj.at("pointers", default: (:))
  let show-index = obj.at("show-index", default: false)
  let label = obj.at("label", default: none)
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  let node-width = 0.8
  let node-height = 0.6
  let ptr-width = 0.3
  let gap = 0.4
  let total-node-width = node-width + ptr-width

  let n = items.len()
  let total-width = n * total-node-width + (n - 1) * gap
  let start-x = ox - total-width / 2

  for (i, item) in items.enumerate() {
    let x = start-x + i * (total-node-width + gap)
    let y = oy

    let is-highlighted = highlight.contains(i)
    let fill-style = if is-highlighted { highlight-col.lighten(70%) } else { bg-col }
    let stroke-style = if is-highlighted { (paint: highlight-col, thickness: 1.5pt) } else { stroke-col }

    rect(
      (x, y),
      (x + node-width, y + node-height),
      fill: fill-style,
      stroke: stroke-style,
    )
    content(
      (x + node-width / 2, y + node-height / 2),
      text(fill: if is-highlighted { highlight-col } else { stroke-col }, weight: "bold", str(item)),
      anchor: "center",
    )

    if show-index {
      content(
        (x + node-width / 2, y - 0.2),
        text(fill: stroke-col.lighten(40%), size: 8pt, str(i)),
        anchor: "north",
      )
    }

    rect(
      (x + node-width, y),
      (x + total-node-width, y + node-height),
      fill: fill-style,
      stroke: stroke-style,
    )
    circle(
      (x + node-width + ptr-width / 2, y + node-height / 2),
      radius: 0.05,
      fill: stroke-col,
    )

    if i < items.len() - 1 {
      let start = (x + total-node-width, y + node-height / 2)
      let end = (x + total-node-width + gap, y + node-height / 2)
      line(start, end, mark: (end: ">"), stroke: stroke-col)
    } else {
      let px = x + node-width + ptr-width / 2
      let py = y + node-height / 2
      line((px - 0.1, py - 0.1), (px + 0.1, py + 0.1), stroke: stroke-col)
    }

    let k = str(i)
    if k in pointers {
      let ptr-label = pointers.at(k)
      let px = x + total-node-width / 2
      let ptr-y-start = y + node-height + 0.7
      let ptr-y-end = y + node-height + 0.2
      line((px, ptr-y-start), (px, ptr-y-end), mark: (end: ">"), stroke: highlight-col)
      content(
        (px, ptr-y-start + 0.15),
        text(fill: highlight-col, size: 9pt, weight: "bold", ptr-label),
        anchor: "south",
      )
    }
  }

  if label != none {
    content((ox, oy - 0.6), text(fill: stroke-col, weight: "bold", label), anchor: "north")
  }
}

// -----------------------------------------------------
// ALGO: FREE GRAPH
// -----------------------------------------------------

#let draw-free-graph(obj, theme) = {
  import cetz.draw: *

  let nodes = obj.nodes
  let edges = obj.edges
  let highlight-path = obj.highlight-path
  let highlight-nodes = obj.highlight-nodes
  let highlight-custom-edges = obj.at("highlight-edges", default: ())
  let origin = obj.at("origin", default: (0, 0))
  let style = obj.at("style", default: auto)
  if type(style) != dictionary { style = (:) }
  let label = style.at("label", default: none)

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let bg-col = theme.at("page-fill", default: white)

  // Node radius constant
  let node-radius = 0.4

  // Check if ALL nodes have non-default positions
  // Default position is (0, 0), so we check if all nodes have the same position
  let all-positions-specified = nodes.len() > 0
  if nodes.len() > 1 {
    let first-pos = nodes.first().pos
    let all-same = true
    for n in nodes {
      if n.pos != first-pos {
        all-same = false
        break
      }
    }
    // If all positions are the same (likely default), auto-position
    if all-same {
      all-positions-specified = false
    }
  } else if nodes.len() == 1 {
    // Single node, no need for auto-positioning logic
    all-positions-specified = true
  }

  // Calculate Node Map and Bounds with auto-positioning if needed
  let node-map = (:)
  let n-count = nodes.len()

  // Polygon radius for auto-positioning
  let poly-radius = 1.5

  let min-x = 0
  let max-x = 0
  let min-y = 0
  let max-y = 0

  for (i, n) in nodes.enumerate() {
    let name = if n.name == auto { str(n.value) } else { n.name }

    let px = 0
    let py = 0

    if all-positions-specified {
      // Use specified positions
      px = n.pos.at(0)
      py = n.pos.at(1)
    } else {
      // Auto-position on regular n-polygon
      // Start from top and go clockwise
      let angle = 90deg - (360deg / n-count) * i
      px = poly-radius * calc.cos(angle)
      py = poly-radius * calc.sin(angle)
    }

    node-map.insert(name, (x: px + ox, y: py + oy))

    if i == 0 {
      min-x = px
      max-x = px
      min-y = py
      max-y = py
    } else {
      if px < min-x { min-x = px }
      if px > max-x { max-x = px }
      if py < min-y { min-y = py }
      if py > max-y { max-y = py }
    }
  }

  // Draw Edges FIRST (so nodes are drawn on top)
  for e in edges {
    if e.from in node-map and e.to in node-map {
      let p1 = node-map.at(e.from)
      let p2 = node-map.at(e.to)

      // Check if edge is highlighted
      let is-path-edge = false
      if highlight-path.len() >= 2 {
        let idx-from = highlight-path.position(x => x == e.from)
        let idx-to = highlight-path.position(x => x == e.to)
        if idx-from != none and idx-to != none and calc.abs(idx-from - idx-to) == 1 {
          is-path-edge = true
        }
      }

      // Custom edge highlight
      let is-custom-hl = false
      for pair in highlight-custom-edges {
        if pair.at(0) == e.from and pair.at(1) == e.to { is-custom-hl = true }
      }

      let edge-color = if is-path-edge or is-custom-hl { highlight-col } else { stroke-col }
      let thickness = if is-path-edge or is-custom-hl { 2pt } else { 1pt }

      // Draw from center to center (nodes will be drawn on top later)
      let start = (p1.x, p1.y)
      let end = (p2.x, p2.y)

      // Calculate angle for label positioning
      let angle = calc.atan2(p2.y - p1.y, p2.x - p1.x)

      // Curvature
      if e.curved != 0 {
        let mid-x = (start.at(0) + end.at(0)) / 2
        let mid-y = (start.at(1) + end.at(1)) / 2
        let dx = end.at(0) - start.at(0)
        let dy = end.at(1) - start.at(1)
        // Perpendicular vector (-dy, dx)
        let perp-x = -dy
        let perp-y = dx

        // Control point
        let cp-x = mid-x + perp-x * e.curved * 0.5
        let cp-y = mid-y + perp-y * e.curved * 0.5

        bezier(
          start,
          end,
          (cp-x, cp-y),
          (cp-x, cp-y),
          stroke: (paint: edge-color, thickness: thickness),
          mark: if e.directed { (end: ">") } else { none },
        )

        // Label position (approx) with background
        if e.weight != none {
          // Calculate pill width based on text length
          let weight-str = str(e.weight)
          let pill-half-width = calc.max(0.2, weight-str.len() * 0.08 + 0.1)
          // Draw background pill for weight
          rect(
            (cp-x - pill-half-width, cp-y - 0.15),
            (cp-x + pill-half-width, cp-y + 0.15),
            fill: bg-col,
            stroke: (paint: edge-color, thickness: 0.5pt),
            radius: 0.1,
          )
          content((cp-x, cp-y), text(fill: edge-color, size: 8pt, weight: "bold", weight-str), anchor: "center")
        }
      } else {
        line(start, end, stroke: (paint: edge-color, thickness: thickness), mark: if e.directed { (end: ">") } else {
          none
        })

        if e.weight != none {
          // Place label at the midpoint of the edge
          let label-x = start.at(0) + (end.at(0) - start.at(0)) * e.label-pos
          let label-y = start.at(1) + (end.at(1) - start.at(1)) * e.label-pos
          // Calculate pill width based on text length
          let weight-str = str(e.weight)
          let pill-half-width = calc.max(0.2, weight-str.len() * 0.08 + 0.1)
          // Draw background pill for weight (covers the edge line)
          rect(
            (label-x - pill-half-width, label-y - 0.15),
            (label-x + pill-half-width, label-y + 0.15),
            fill: bg-col,
            stroke: (paint: edge-color, thickness: 0.5pt),
            radius: 0.1,
          )
          content(
            (label-x, label-y),
            text(fill: edge-color, size: 8pt, weight: "bold", weight-str),
            anchor: "center",
          )
        }
      }
    }
  }

  // Draw Nodes AFTER edges (so nodes cover the edge lines)
  for n in nodes {
    let name = if n.name == auto { str(n.value) } else { n.name }
    if name in node-map {
      let pos = node-map.at(name)
      let is-hl = highlight-nodes.contains(name) or highlight-path.contains(name)

      circle(
        pos,
        radius: node-radius,
        fill: if is-hl { highlight-col.lighten(80%) } else { bg-col },
        stroke: if is-hl { (paint: highlight-col, thickness: 1.5pt) } else { stroke-col },
      )
      content(
        pos,
        text(fill: if is-hl { highlight-col } else { stroke-col }, weight: "bold", str(n.value)),
        anchor: "center",
      )
    }
  }

  if label != none {
    // Bounds-based centering
    let center-x = ox + (min-x + max-x) / 2
    let bottom-y = oy + min-y - 0.8
    content((center-x, bottom-y), text(fill: stroke-col, weight: "bold", label), anchor: "north")
  }
}

// -----------------------------------------------------
// ALGO: GRID WORLD
// -----------------------------------------------------

#let draw-grid-world(obj, theme) = {
  import cetz.draw: *

  let rows = obj.rows
  let cols = obj.cols
  let walls = obj.walls
  let path = obj.path
  let visited = obj.visited
  let start = obj.start
  let target = obj.target
  let label = obj.label
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let cell-size = 0.8
  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  // Draw Grid
  for r in range(rows) {
    for c in range(cols) {
      let x = ox + c * cell-size
      let y = oy + (rows - 1 - r) * cell-size

      let fill-col = white
      let is-wall = walls.contains((c, r))

      if is-wall { fill-col = gray.lighten(50%) } else if (c, r) == start { fill-col = green.lighten(60%) } else if (
        (c, r) == target
      ) { fill-col = red.lighten(60%) } else if path.contains((c, r)) {
        fill-col = highlight-col.lighten(60%)
      } else if visited.contains((c, r)) { fill-col = highlight-col.lighten(90%) }

      rect((x, y), (x + cell-size, y + cell-size), fill: fill-col, stroke: stroke-col)

      // Content
      if (c, r) == start { content((x + cell-size / 2, y + cell-size / 2), text(size: 8pt, "S")) }
      if (c, r) == target { content((x + cell-size / 2, y + cell-size / 2), text(size: 8pt, "T")) }
    }
  }

  if label != none {
    content((ox + (cols * cell-size) / 2, oy - 0.4), text(weight: "bold", label), anchor: "north")
  }
}

// -----------------------------------------------------
// ALGO: ADJACENCY MATRIX
// -----------------------------------------------------

#let draw-adjacency-matrix(obj, theme) = {
  import cetz.draw: *

  let matrix = obj.matrix
  let labels = obj.labels
  let highlight-cells = obj.highlight-cells
  let label = obj.label
  let origin = obj.at("origin", default: (0, 0))

  let ox = if type(origin) == array { origin.at(0) } else { origin.x }
  let oy = if type(origin) == array { origin.at(1) } else { origin.y }

  let cell-size = 0.8
  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let highlight-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let rows = matrix.len()
  let cols = if rows > 0 { matrix.at(0).len() } else { 0 }

  // Draw Matrix
  for r in range(rows) {
    for c in range(cols) {
      let x = ox + (c + 1) * cell-size // Shift for headers
      let y = oy + (rows - r) * cell-size // Shift for headers

      let is-hl = highlight-cells.contains((r, c))
      let val = matrix.at(r).at(c)
      let val-str = if val == none { "∞" } else { str(val) }

      rect(
        (x, y),
        (x + cell-size, y + cell-size),
        fill: if is-hl { highlight-col.lighten(70%) } else { white },
        stroke: stroke-col,
      )
      content((x + cell-size / 2, y + cell-size / 2), text(weight: if is-hl { "bold" } else { "regular" }, val-str))
    }
  }

  // Headers
  if labels.len() > 0 {
    for i in range(rows) {
      let lbl = labels.at(i)
      // Row Header (Left)
      content((ox + cell-size / 2, oy + (rows - i) * cell-size + cell-size / 2), text(weight: "bold", lbl))
      // Col Header (Top)
      content((ox + (i + 1) * cell-size + cell-size / 2, oy + (rows + 1) * cell-size + cell-size / 2), text(
        weight: "bold",
        lbl,
      ))
    }
  }

  if label != none {
    content((ox + (cols + 1) * cell-size / 2, oy + 0.2), text(weight: "bold", label), anchor: "north")
  }
}


// =====================================================
// DISPATCHER
// =====================================================

#let draw-dsa(obj, theme) = {
  let t = obj.at("type", default: none)

  if t == "cs-array" { draw-cs-array(obj, theme) } else if t == "cs-stack" { draw-cs-stack(obj, theme) } else if (
    t == "cs-queue"
  ) { draw-cs-queue(obj, theme) } else if t == "cs-linked-list" { draw-cs-linked-list(obj, theme) } else if (
    t == "free-graph"
  ) { draw-free-graph(obj, theme) } else if t == "grid-world" { draw-grid-world(obj, theme) } else if (
    t == "adjacency-matrix"
  ) { draw-adjacency-matrix(obj, theme) }
}
