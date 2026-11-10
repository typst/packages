// Binary heaps (min and max), array-backed complete binary trees.
//
// A heap is stored as an array; an entry at `heap-index` has children at
// `2 * heap-index + 1` and `2 * heap-index + 2`. Rendering converts that array
// into the binary-tree model shared with `tree.typ`.

#import "style.typ": resolve, validate-style
#import "tree.typ": _create-tree-node, _render-tree, _create-value-marks, trans-view
#import "validate.typ": check-array, check-comparable, check-comparable-with, fail
#import "messages.typ": default-catalog, resolve-catalog, msg

#let _convert-heap-array-to-tree(heap-values, heap-index) = {
  if heap-index >= heap-values.len() { return none }
  let tree-node = _create-tree-node(heap-index)
  tree-node.label = heap-values.at(heap-index)
  tree-node.left = _convert-heap-array-to-tree(heap-values, 2 * heap-index + 1)
  tree-node.right = _convert-heap-array-to-tree(heap-values, 2 * heap-index + 2)
  tree-node
}

#let _heap-value-has-priority(variant) = if variant == "max" {
  (node-value, parent-value) => node-value > parent-value
} else {
  (node-value, parent-value) => node-value < parent-value
}

// Sifts the last element up until the heap property holds. Returns the
// indices visited, root first, so the caller can mark the swap path.
#let _restore-heap-order-upward(heap-values, variant) = {
  let has-priority = _heap-value-has-priority(variant)
  let heap-index = heap-values.len() - 1
  let visited-indices = (heap-index,)
  while heap-index > 0 {
    let parent-index = calc.floor((heap-index - 1) / 2)
    let node-value = heap-values.at(heap-index)
    let parent-value = heap-values.at(parent-index)
    if not has-priority(node-value, parent-value) { break }
    heap-values.at(parent-index) = node-value
    heap-values.at(heap-index) = parent-value
    heap-index = parent-index
    visited-indices.push(heap-index)
  }
  (heap-values, visited-indices)
}

// Sifts the root down until the heap property holds. Returns the indices
// visited, root first.
#let _restore-heap-order-downward(heap-values, variant) = {
  let has-priority = _heap-value-has-priority(variant)
  let heap-size = heap-values.len()
  let heap-index = 0
  let visited-indices = (0,)
  while true {
    let left-child-index = 2 * heap-index + 1
    let right-child-index = 2 * heap-index + 2
    let swap-child-index = heap-index
    if left-child-index < heap-size and has-priority(
      heap-values.at(left-child-index),
      heap-values.at(swap-child-index),
    ) {
      swap-child-index = left-child-index
    }
    if right-child-index < heap-size and has-priority(
      heap-values.at(right-child-index),
      heap-values.at(swap-child-index),
    ) {
      swap-child-index = right-child-index
    }
    if swap-child-index == heap-index { break }
    let node-value = heap-values.at(heap-index)
    heap-values.at(heap-index) = heap-values.at(swap-child-index)
    heap-values.at(swap-child-index) = node-value
    heap-index = swap-child-index
    visited-indices.push(heap-index)
  }
  (heap-values, visited-indices)
}

#let _build-heap(variant, keys) = {
  let heap-values = ()
  for key in keys {
    heap-values.push(key)
    let (heap-after-insertion, _) = _restore-heap-order-upward(heap-values, variant)
    heap-values = heap-after-insertion
  }
  heap-values
}

// ── Operations ───────────────────────────────────────────────────────────────
//
// A binary heap only supports inserting and extracting the root efficiently,
// so — unlike `bst`/`avl` — there is no key-based `delete` or `search`.
// Named `heap-insert`/`heap-extract` (rather than `insert`/`delete`) to avoid
// colliding with the tree operations when both are imported.

// Heap operation marks use array indices because the tree conversion uses each
// index as node identity while displaying the corresponding heap value.
#let _create-heap-index-marks(visited-indices, kind) = (
  _create-value-marks(visited-indices, kind)
)

// Heap operations are tagged like tree operations so a transition can tell
// which structure family an operation was built for.
#let _heap-operation(apply) = (family: "heap", apply: apply)

#let heap-insert(key, step-label: none, language: "en", messages: (:), catalog: none) = {
  check-comparable("heap-insert()", "key", (key,), subject: "key")
  _heap-operation((variant, arr) => {
  let heap-values = arr
  check-comparable-with("heap-insert()", "key", key, heap-values)
  let message-catalog = if catalog != none {
    catalog
  } else {
    resolve-catalog(language: language, messages: messages)
  }
  let heap-with-new-value = heap-values + (key,)
  let (heap-after-insertion, visited-indices) = _restore-heap-order-upward(
    heap-with-new-value,
    variant,
  )
  let inserted-index = visited-indices.last()
  let after-marks = (
    _create-heap-index-marks(visited-indices, "path")
    + _create-heap-index-marks((inserted-index,), "new")
  )
  let label = if step-label == none {
    msg(message-catalog, "heap.insert", key)
  } else {
    step-label
  }
  (heap-after-insertion, (:), after-marks, label)
  })
}

// Removes and returns the root: the smallest key for a min-heap, largest for
// a max-heap.
#let _create-heap-extract-operation(step-label: none, language: "en", messages: (:), catalog: none) = _heap-operation((variant, heap-values) => {
  if heap-values.len() == 0 {
    fail(
      "heap-extract",
      "the heap is empty, so there is no root to extract",
      expected: "a heap with at least one key",
      fix: "insert a key first, or drop this operation",
    )
  }
  let message-catalog = if catalog != none {
    catalog
  } else {
    resolve-catalog(language: language, messages: messages)
  }
  let label = if step-label == none {
    msg(message-catalog, "heap.extract")
  } else {
    step-label
  }
  let before-marks = _create-heap-index-marks((0,), "remove")
  if heap-values.len() <= 1 { return ((), before-marks, (:), label) }
  let heap-without-root = heap-values
  heap-without-root.at(0) = heap-without-root.at(heap-without-root.len() - 1)
  heap-without-root = heap-without-root.slice(0, heap-without-root.len() - 1)
  let (heap-after-extraction, visited-indices) = _restore-heap-order-downward(
    heap-without-root,
    variant,
  )
  (
    heap-after-extraction,
    before-marks,
    _create-heap-index-marks(visited-indices, "path"),
    label,
  )
})

#let heap-extract = _create-heap-extract-operation()

// ── Public object ────────────────────────────────────────────────────────────

#let _create-heap-object(variant, heap-values, style: (:), catalog: default-catalog) = {
  let render-heap(values, marks) = _render-tree(
    _convert-heap-array-to-tree(values, 0),
    marks: marks,
    resolved-style: resolve(style),
  )
  let apply-operation(operation) = {
    let (values-after-operation, before-marks, after-marks, label) = (
      (operation.apply)(variant, heap-values)
    )
    let before-diagram = render-heap(heap-values, before-marks)
    let after-diagram = render-heap(values-after-operation, after-marks)
    (
      label: label,
      before: before-diagram,
      after: after-diagram,
      diagram: trans-view(before-diagram, label, after-diagram, style: style),
      result: _create-heap-object(variant, values-after-operation, style: style, catalog: catalog),
    )
  }
  (
    diagram: render-heap(heap-values, (:)),
    insert: (key, step-label: none) => apply-operation(
      heap-insert(key, step-label: step-label, catalog: catalog),
    ),
    extract: (step-label: none) => apply-operation(
      _create-heap-extract-operation(step-label: step-label, catalog: catalog),
    ),
  )
}

// A heap orders its keys against each other, so they must be mutually
// comparable. Duplicates are allowed: unlike a search tree, a heap stores them.
#let _create-heap-values(where, variant, keys, style) = {
  check-comparable(where, "keys", keys, subject: "key")
  validate-style(where, style)
  _build-heap(variant, keys)
}

#let min-heap(style: (:), language: "en", messages: (:), ..keys) = _create-heap-object("min", _create-heap-values("min-heap()", "min", keys.pos(), style), style: style, catalog: resolve-catalog(language: language, messages: messages))
#let max-heap(style: (:), language: "en", messages: (:), ..keys) = _create-heap-object("max", _create-heap-values("max-heap()", "max", keys.pos(), style), style: style, catalog: resolve-catalog(language: language, messages: messages))

// ── Transition ───────────────────────────────────────────────────────────────

#let _transition(variant, keys, op, style: (:)) = {
  check-array(
    "transition()", "keys", keys,
    fix: "pass the keys as an array, for example transition(\"min-heap\", (5, 3), heap-insert(1))",
  )
  let resolved-style = resolve(style)
  let heap-before-operation = _create-heap-values("transition()", variant, keys, style)
  let (heap-after-operation, before-marks, after-marks, label) = (
    (op.apply)(variant, heap-before-operation)
  )
  trans-view(
    _render-tree(
      _convert-heap-array-to-tree(heap-before-operation, 0),
      marks: before-marks,
      resolved-style: resolved-style,
    ),
    label,
    _render-tree(
      _convert-heap-array-to-tree(heap-after-operation, 0),
      marks: after-marks,
      resolved-style: resolved-style,
    ),
    style: style,
  )
}
