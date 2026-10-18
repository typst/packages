// Tree layout calculations.
//
// Layout consumes tree state and annotates a copy with drawing coordinates.
// It does not validate public arguments or render CeTZ content.

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
