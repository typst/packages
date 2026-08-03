// typed-dsa — declarative data-structure diagrams for Typst.
//
// Describe a structure by its keys, or an operation on it, and get a laid-out,
// consistently styled diagram. Operation transitions render the before state,
// an arrow, and the derived after state with the diff highlighted.

#import "tree.typ": bst, avl, tree, node, subtree, transition as _tree-transition, op-arrow, tree-insert, tree-delete, tree-search
#import "linear.typ": linked-list, doubly-linked-list, skip-list, default-decision-fn, stack, queue
#import "heap.typ": min-heap, max-heap, _transition as _heap-transition, heap-insert, heap-extract
#import "graph.typ": graph, bfs, dfs, dijkstra
#import "grid.typ": array-view, matrix, sequence, operation-sequence
#import "sorting.typ": merge-sort, merge-operation, partition-step, quick-sort, bubble-sort, insertion-sort, selection-sort, sort-sequence
#import "hash.typ": hash-table
#import "style.typ": theme, themes, theme-preset, resolve, tree-style, heap-style, graph-style, list-style, stack-style, queue-style, array-style, matrix-style, text-style, label-style, node-mark-style, cell-mark-style, node-label-style, indices-style
#import "messages.typ": messages, supported-languages
#import "validate.typ": check-enum, fail, show-list, show-value

// The variants `transition` understands, and the operation family each one
// needs. An operation carries its family, so a heap operation aimed at a tree
// (or the reverse) is refused here instead of misreading the model further in.
#let _transition-variants = (
  "bst": "tree",
  "avl": "tree",
  "min-heap": "heap",
  "max-heap": "heap",
)

#let _transition-operation-builders = (
  "tree": "tree-insert(key), tree-delete(key), or tree-search(key)",
  "heap": "heap-insert(key) or heap-extract",
)

#let _check-transition-operation(variant, op) = {
  let required-family = _transition-variants.at(variant)
  let is-operation = (
    type(op) == dictionary and "family" in op and "apply" in op
  )
  if not is-operation {
    fail(
      "transition()",
      "op is " + show-value(op) + ", which is not an operation",
      expected: "an operation built with " + _transition-operation-builders.at(required-family),
      fix: "call the operation builder, for example transition(\"" + variant + "\", keys, " + _transition-operation-builders.at(required-family).split(",").first() + ")",
    )
  }
  if op.family == required-family { return }
  fail(
    "transition()",
    "variant \"" + variant + "\" was given a " + op.family + " operation",
    expected: "a " + required-family + " operation: " + _transition-operation-builders.at(required-family),
    fix: "use an operation from the same structure family as the variant",
  )
}

#let transition(variant, keys, op, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  check-enum(
    "transition()", "variant", variant, _transition-variants.keys(),
    fix: "pass one of " + show-list(_transition-variants.keys()),
  )
  _check-transition-operation(variant, op)
  if variant == "min-heap" {
    return _heap-transition("min", keys, op, style: style)
  }
  if variant == "max-heap" {
    return _heap-transition("max", keys, op, style: style)
  }
  _tree-transition(variant, keys, op, style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
}
