// Drawing of binary-shaped trees (binary trees, BSTs, AVL trees, heaps, treaps).

#import "colors.typ": palette, style
#import "tree.typ": key-of

#let radius = 0.3cm // node radius (half the height of a pill)
#let gap = 0.5cm // horizontal space between two nodes on one level
#let inset = 0.15cm // space left and right of a pill's label
#let dy = 1cm // vertical distance between levels
#let pad = 0.1cm // space around the drawing, so strokes are not clipped
#let font-size = 9pt
#let note-width = 0.35cm // room right of the rightmost node for its note

// In-order layout: x = position in the in-order sequence, depth = level.
// A parent always lies between its children and nothing overlaps.
// Returns the number of nodes, the placed nodes (with their subtree and their
// level-order index: root 0, children of `i` at `2i + 1` and `2i + 2`), the
// edges and the root's x.
#let layout(tree, depth, x0, index) = {
  if tree == none { return (count: 0, nodes: (), edges: (), x: none) }
  let (key, left, right) = tree
  let l = layout(left, depth + 1, x0, 2 * index + 1)
  let x = x0 + l.count
  let r = layout(right, depth + 1, x + 1, 2 * index + 2)
  let edges = l.edges + r.edges
  if left != none { edges.push(((x, depth), (l.x, depth + 1))) }
  if right != none { edges.push(((x, depth), (r.x, depth + 1))) }
  (
    count: l.count + 1 + r.count,
    nodes: l.nodes + ((key: key, tree: tree, index: index, x: x, depth: depth),) + r.nodes,
    edges: edges,
    x: x,
  )
}

// Draws a binary tree in long form. Keys in `marked` get the marked color,
// keys in `errors` the error color (which wins over `marked`).
// `note`, if given, maps a placed node (`n.tree` its subtree, `n.index` its
// level-order index) to content shown right of the node, by default in the
// marked color.
// `label`, if given, maps a node's value to its content; the nodes are then
// pills as wide as the widest label instead of circles.
#let draw(tree, marked: (), errors: (), note: none, label: none) = {
  if tree == none { return text(size: font-size)[∅] }

  let l = layout(tree, 0, 0, 0)
  let max-x = calc.max(..l.nodes.map(n => n.x))
  let max-depth = calc.max(..l.nodes.map(n => n.depth))
  let shown(n) = text(size: font-size, if label == none [#n.key] else { label(n.key) })

  context {
    let c = palette()
    let width = if label == none { 2 * radius } else {
      calc.max(..l.nodes.map(n => measure(shown(n)).width)) + 2 * inset
    }
    // two nodes on one level have their common ancestor between them in
    // in-order, so they are at least 2 dx apart
    let dx = (width + gap) / 2
    let pos((x, depth)) = (pad + width / 2 + x * dx, pad + radius + depth * dy)

    block(
      width: 2 * pad + width + max-x * dx + if note != none { note-width } else { 0pt },
      height: 2 * (pad + radius) + max-depth * dy,
      breakable: false,
      {
        // edges first, so the nodes cover their ends
        for (from, to) in l.edges {
          place(top + left, line(start: pos(from), end: pos(to), stroke: 0.6pt + c.border))
        }
        for n in l.nodes {
          let (stroke, fill) = style(c, error: key-of(n.key) in errors, marked: key-of(n.key) in marked)
          let body = align(center + horizon, shown(n))
          let (x, y) = pos((n.x, n.depth))
          place(top + left, dx: x - width / 2, dy: y - radius, if label == none {
            circle(radius: radius, inset: 0pt, fill: fill, stroke: stroke, body)
          } else {
            rect(width: width, height: 2 * radius, radius: radius, inset: 0pt, fill: fill, stroke: stroke, body)
          })
          if note != none {
            // vertically centred: the edges leave the node diagonally
            place(top + left, dx: x + width / 2 + 1.5pt, dy: y - 5pt, text(size: 8pt, fill: c.marked)[#note(n)])
          }
        }
      },
    )
  }
}
