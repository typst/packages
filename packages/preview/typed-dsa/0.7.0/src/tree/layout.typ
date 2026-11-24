// Tree layout calculations.
//
// Layout consumes tree state and annotates a copy with drawing coordinates.
// It does not validate public arguments or render CeTZ content.

#import "state.typ": _visible-tree-children

// ── Layout ───────────────────────────────────────────────────────────────────

// Writes `_col` and `_depth` onto each node and returns the next free column.
// Leaves consume a column left to right; a node is centered over its children so
// the two child edges stay symmetric regardless of how lopsided the subtrees
// are. A missing child still reserves a phantom column, so a lone child keeps its
// left/right slant and siblings can never overlap. Subtree triangles claim two
// columns so neighbours stay clear.
#let _calculate-tree-layout(tree-node, depth, next-column) = {
  if tree-node == none { return (none, next-column) }
  tree-node._depth = depth
  if tree-node.kind == "subtree" {
    tree-node._col = next-column
    return (tree-node, next-column + 2)
  }
  let explicit-children = tree-node.at("children", default: none)
  if explicit-children != none {
    if explicit-children.len() == 0 {
      tree-node._col = next-column
      return (tree-node, next-column + 1)
    }
    let laid-out-children = ()
    let child-column = next-column
    for child in explicit-children {
      let (laid-out-child, next-child-column) = (
        _calculate-tree-layout(child, depth + 1, child-column)
      )
      laid-out-children.push(laid-out-child)
      child-column = next-child-column
    }
    tree-node.children = laid-out-children
    tree-node._col = (
      laid-out-children.first()._col + laid-out-children.last()._col
    ) / 2
    return (tree-node, child-column)
  }
  let has-left-child = tree-node.left != none
  let has-right-child = tree-node.right != none
  if not has-left-child and not has-right-child {
    tree-node._col = next-column
    return (tree-node, next-column + 1)
  }
  if has-left-child and has-right-child {
    let (left-child, next-right-column) = (
      _calculate-tree-layout(tree-node.left, depth + 1, next-column)
    )
    tree-node.left = left-child
    let (right-child, column-after-children) = (
      _calculate-tree-layout(tree-node.right, depth + 1, next-right-column)
    )
    tree-node.right = right-child
    tree-node._col = (left-child._col + right-child._col) / 2
    (tree-node, column-after-children)
  } else if has-left-child {
    // Phantom right child occupies the next column.
    let (left-child, phantom-right-column) = (
      _calculate-tree-layout(tree-node.left, depth + 1, next-column)
    )
    tree-node.left = left-child
    tree-node._col = (left-child._col + phantom-right-column) / 2
    (tree-node, phantom-right-column + 1)
  } else {
    // Phantom left child occupies this column; the real right child follows.
    let (right-child, column-after-right-child) = (
      _calculate-tree-layout(tree-node.right, depth + 1, next-column + 1)
    )
    tree-node.right = right-child
    tree-node._col = (next-column + right-child._col) / 2
    (tree-node, column-after-right-child)
  }
}

// ── Tidy layout ──────────────────────────────────────────────────────────────
//
// Reingold–Tilford style placement. Each subtree is laid out on its own, then
// siblings are pushed apart only until their left and right contours (the
// outermost occupied column at every depth) clear each other. A parent is
// centered over its first and last child; a lone binary child leans half a
// column away from its parent so left and right stay distinguishable. Column
// widths come from the drawn node and triangle sizes, so wide triangles keep
// their clearance.

// Replaces the visible children of a node, in order, preserving which binary
// slot (left or right) each one occupies.
#let _replace-visible-tree-children(tree-node, replacement-children) = {
  if tree-node.at("children", default: none) != none {
    tree-node.children = replacement-children
    return tree-node
  }
  let remaining-children = replacement-children
  if tree-node.left != none {
    tree-node.left = remaining-children.first()
    remaining-children = remaining-children.slice(1)
  }
  if tree-node.right != none { tree-node.right = remaining-children.first() }
  tree-node
}

#let _calculate-column-half-width(tree-node, resolved-style) = {
  let drawn-half-width = if tree-node.kind == "subtree" {
    resolved-style.tri-w / 2 * tree-node.tscale
  } else {
    resolved-style.node-radius
  }
  calc.max(0.5, drawn-half-width / resolved-style.x-gap)
}

// A subtree triangle hangs below its row; it blocks every row whose nodes
// would reach into the triangle's height.
#let _calculate-triangle-row-count(subtree-node, resolved-style) = {
  let triangle-height = resolved-style.tri-h * subtree-node.tscale
  calc.ceil(
    (triangle-height + resolved-style.node-radius) / resolved-style.y-gap,
  )
}

// Smallest shift of the right-hand subtree that keeps its left contour clear
// of the accumulated right contour at every shared depth.
#let _calculate-contour-clearance-shift(accumulated-right-contour, subtree-left-contour) = {
  let shared-depth-count = calc.min(
    accumulated-right-contour.len(),
    subtree-left-contour.len(),
  )
  calc.max(..range(shared-depth-count).map(depth => (
    accumulated-right-contour.at(depth) - subtree-left-contour.at(depth)
  )))
}

#let _has-lone-binary-child(tree-node) = (
  tree-node.at("children", default: none) == none
    and (tree-node.left == none) != (tree-node.right == none)
)

// Returns the node with `_col` set relative to its parent, plus its left and
// right contours relative to its own column (index 0 is the node's own row).
#let _place-tidy-subtree(tree-node, resolved-style) = {
  let half-width = _calculate-column-half-width(tree-node, resolved-style)
  let child-nodes = if tree-node.kind == "subtree" {
    ()
  } else {
    _visible-tree-children(tree-node)
  }
  if child-nodes.len() == 0 {
    tree-node._col = 0
    let occupied-row-count = if tree-node.kind == "subtree" {
      _calculate-triangle-row-count(tree-node, resolved-style)
    } else {
      1
    }
    return (
      tree-node,
      (-half-width,) * occupied-row-count,
      (half-width,) * occupied-row-count,
    )
  }

  let placed-children = child-nodes.map(child => (
    _place-tidy-subtree(child, resolved-style)
  ))
  let (_, merged-left-contour, merged-right-contour) = placed-children.first()
  let child-offsets = (0,)
  for (_, child-left-contour, child-right-contour) in placed-children.slice(1) {
    let child-offset = _calculate-contour-clearance-shift(
      merged-right-contour,
      child-left-contour,
    )
    child-offsets.push(child-offset)
    let deeper-left-contour = child-left-contour.slice(
      calc.min(merged-left-contour.len(), child-left-contour.len()),
    )
    let deeper-right-contour = merged-right-contour.slice(
      calc.min(child-right-contour.len(), merged-right-contour.len()),
    )
    merged-left-contour += deeper-left-contour.map(column => column + child-offset)
    merged-right-contour = (
      child-right-contour.map(column => column + child-offset)
        + deeper-right-contour
    )
  }

  let parent-offset = if _has-lone-binary-child(tree-node) {
    if tree-node.left != none { 0.5 } else { -0.5 }
  } else {
    child-offsets.last() / 2
  }
  let positioned-children = placed-children.enumerate().map(((index, placed)) => {
    let positioned-child = placed.first()
    positioned-child._col = child-offsets.at(index) - parent-offset
    positioned-child
  })
  tree-node = _replace-visible-tree-children(tree-node, positioned-children)
  tree-node._col = 0
  (
    tree-node,
    (-half-width,) + merged-left-contour.map(column => column - parent-offset),
    (half-width,) + merged-right-contour.map(column => column - parent-offset),
  )
}

// Converts parent-relative columns into absolute columns and records depths.
#let _resolve-tidy-columns(tree-node, depth, parent-column) = {
  tree-node._depth = depth
  tree-node._col = parent-column + tree-node._col
  if tree-node.kind == "subtree" { return tree-node }
  _replace-visible-tree-children(
    tree-node,
    _visible-tree-children(tree-node).map(child => (
      _resolve-tidy-columns(child, depth + 1, tree-node._col)
    )),
  )
}

#let _calculate-tidy-tree-layout(root, resolved-style) = {
  let (placed-root, _, _) = _place-tidy-subtree(root, resolved-style)
  _resolve-tidy-columns(placed-root, 0, 0)
}
