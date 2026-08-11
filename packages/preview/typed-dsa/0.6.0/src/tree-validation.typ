// Tree-specific structure and reference validation.
//
// Generic diagnostic formatting and schema primitives remain in validate.typ;
// checks that understand tree nodes and edges stay with the tree domain.

#import "style.typ": (
  validate-style, check-edge-customization-options,
  check-node-customization-options, check-node-label-override,
)
#import "validate.typ": (
  check-comparable, check-customization-entries, check-id-value-references,
  check-reference, check-unique, fail, normalize-id-value-entries, show-list,
  show-value,
)
#import "tree-state.typ": (
  _is-tree-node, _tree-node-id, _visible-tree-children,
)

// ── Validation ───────────────────────────────────────────────────────────────
//
// Customizations are checked against the structure the caller described, at
// the call that described it. Objects derived by an operation inherit the
// same customizations without re-checking, because a rotation or a deletion
// may legitimately remove an edge the caller styled on the original tree.

#let _collect-tree-node-ids(tree-node) = {
  if tree-node == none { return () }
  let node-ids = (_tree-node-id(tree-node),)
  if tree-node.kind == "subtree" { return node-ids }
  for child-node in _visible-tree-children(tree-node) {
    node-ids += _collect-tree-node-ids(child-node)
  }
  node-ids
}

#let _collect-tree-edges(tree-node) = {
  if tree-node == none or tree-node.kind == "subtree" { return () }
  let edges = ()
  for child-node in _visible-tree-children(tree-node) {
    edges.push((_tree-node-id(tree-node), _tree-node-id(child-node)))
    edges += _collect-tree-edges(child-node)
  }
  edges
}

#let _show-tree-edges(edges) = if edges.len() == 0 {
  "(the tree has no edges)"
} else {
  edges.map(
    edge => show-value(edge.at(0)) + " -> " + show-value(edge.at(1)),
  ).join(", ")
}

#let _validate-tree-references(
  where,
  root,
  edge-customizations,
  node-customizations,
  node-labels,
) = {
  let node-ids = _collect-tree-node-ids(root)
  check-customization-entries(
    where,
    "node-customizations:",
    node-customizations,
    2,
    check-node-customization-options,
  )
  for (node-id, _) in node-customizations {
    check-reference(where, "node-customizations:", node-id, node-ids)
  }
  check-customization-entries(
    where,
    "edge-customizations:",
    edge-customizations,
    3,
    check-edge-customization-options.with(require-label-content: true),
  )
  let tree-edges = _collect-tree-edges(root)
  for (from-node-id, to-node-id, _) in edge-customizations {
    if (from-node-id, to-node-id) in tree-edges { continue }
    fail(
      where,
      "edge-customizations: refers to edge "
        + show-value(from-node-id) + " -> " + show-value(to-node-id)
        + ", which is not a parent/child pair in this tree",
      expected: "one of the edges: " + _show-tree-edges(tree-edges),
      fix: "name the parent first and its direct child second",
    )
  }
  check-id-value-references(where, "node-labels:", node-labels, node-ids)
  for (_, label-value) in normalize-id-value-entries(
    where,
    "node-labels:",
    node-labels,
  ) {
    check-node-label-override(where, "node-labels: entry", label-value)
  }
}

// Shared by every tree builder: the arguments that do not depend on the
// structure are checked first, then the structure, then the references into it.
#let _validate-tree-arguments(
  where,
  style,
  edge-customizations,
  node-customizations,
  node-labels,
  root,
) = {
  validate-style(where, style)
  _validate-tree-references(
    where,
    root,
    edge-customizations,
    node-customizations,
    node-labels,
  )
}

#let _validate-search-tree-keys(where, keys) = {
  check-comparable(where, "keys", keys, subject: "key")
  check-unique(where, "keys", keys, subject: "key")
}

#let _collect-tree-keys(tree-node) = if tree-node == none {
  ()
} else {
  _collect-tree-keys(tree-node.left) + (tree-node.key,) + _collect-tree-keys(tree-node.right)
}
