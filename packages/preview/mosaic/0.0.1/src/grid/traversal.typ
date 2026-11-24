// Grid-tree traversal and structural queries.

#let fold-grid(node, visit-cell, visit-on, visit-branch) = {
  if node.kind == "cell" {
    visit-cell(node)
  } else if node.kind == "on" {
    visit-on(
      node,
      fold-grid(node.child, visit-cell, visit-on, visit-branch),
    )
  } else {
    visit-branch(
      node,
      node.children.map(child => fold-grid(
        child,
        visit-cell,
        visit-on,
        visit-branch,
      )),
    )
  }
}

#let resolve-cell-ids(node) = fold-grid(
  node,
  cell => (cell.id,),
  (node, child) => child,
  (node, children) => children.flatten(),
)

#let resolved-tracks(node) = if node.tracks == auto {
  (1fr,) * node.children.len()
} else {
  node.tracks
}

