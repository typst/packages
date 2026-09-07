// Binary search trees, AVL trees, hand-composed trees, and operation transitions.
//
// This is the tree domain facade. State transformations, validation, layout,
// rendering, and transition coordination live in focused internal modules.

#import "tree-state.typ": (
  node as _node, subtree as _subtree,
  _create-tree-node as _create-tree-node-impl,
  _build-search-tree as _build-search-tree-impl,
  _calculate-balance-factor as _calculate-balance-factor-impl,
  _remove-bst-node as _remove-bst-node-impl,
  _insert-bst-node as _insert-bst-node-impl,
  _remove-avl-node as _remove-avl-node-impl,
)
#import "tree-render.typ": _render-tree as _render-tree-impl
#import "transition-view.typ": op-arrow as _op-arrow, trans-view as _trans-view
#import "tree-api.typ": (
  tree as _tree, bst as _bst, avl as _avl, transition as _transition,
  tree-insert as _tree-insert,
  tree-delete as _tree-delete, tree-search as _tree-search,
  _create-value-marks as _create-value-marks-impl,
)

#let node = _node
#let subtree = _subtree
#let tree = _tree
#let bst = _bst
#let avl = _avl
#let transition = _transition
#let op-arrow = _op-arrow
#let tree-insert = _tree-insert
#let tree-delete = _tree-delete
#let tree-search = _tree-search

// Internal compatibility exports used by heap, linear, and hash modules.
#let _create-tree-node = _create-tree-node-impl
#let _build-search-tree = _build-search-tree-impl
#let _calculate-balance-factor = _calculate-balance-factor-impl
#let _remove-bst-node = _remove-bst-node-impl
#let _insert-bst-node = _insert-bst-node-impl
#let _remove-avl-node = _remove-avl-node-impl
#let _render-tree = _render-tree-impl
#let _create-value-marks = _create-value-marks-impl
#let trans-view = _trans-view
