// typed-dsa — declarative data-structure diagrams for Typst.
//
// Describe a structure by its keys, or an operation on it, and get a laid-out,
// consistently styled diagram. Operation transitions render the before state,
// an arrow, and the derived after state with the diff highlighted.

#import "tree.typ": bst, avl, tree, node, subtree, transition as _tree-transition, op-arrow, tree-insert, tree-delete, tree-search
#import "linear.typ": linked-list, doubly-linked-list, stack, queue
#import "heap.typ": min-heap, max-heap, _transition as _heap-trans, heap-insert, heap-extract
#import "graph.typ": graph
#import "grid.typ": array-view, matrix, sequence
#import "style.typ": theme, resolve

#let transition(variant, keys, op, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  if variant == "min-heap" { return _heap-trans("min", keys, op, style: style) }
  if variant == "max-heap" { return _heap-trans("max", keys, op, style: style) }
  _tree-transition(variant, keys, op, style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
}
