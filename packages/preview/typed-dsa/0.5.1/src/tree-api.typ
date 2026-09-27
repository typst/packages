// Public tree constructors, operations, transition views, and object closures.
//
// Public calls validate before state mutation. Transition rendering coordinates
// validated before-and-after states without owning tree operation semantics.

#import "style.typ": resolve
#import "validate.typ": (
  check-array, check-bool, check-comparable, check-comparable-with,
  check-dictionary, check-enum, check-known-keys, fail, show-list, show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import "transition-view.typ": op-arrow, trans-view
#import "tree-state.typ": (
  _build-search-tree, _check-tree-node, _find-bst-search-path, _insert-avl-node,
  _insert-bst-node, _remove-avl-node, _remove-bst-node,
)
#import "tree-render.typ": _render-tree
#import "tree-validation.typ": (
  _collect-tree-keys, _validate-search-tree-keys, _validate-tree-arguments,
)

// ── Public structure builders ────────────────────────────────────────────────

// Render a hand-composed tree built from `node(...)` and `subtree(...)`.
#let tree(root, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  _check-tree-node("tree()", "root", root)
  _validate-tree-arguments(
    "tree()",
    style,
    edge-customizations,
    node-customizations,
    node-labels,
    root,
  )
  _render-tree(root, resolved-style: resolve(style), edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
}

// ── Operations ───────────────────────────────────────────────────────────────
//
// An operation is a closure `(variant, root) -> (after, mark-before,
// mark-after, label, mids)`. `transition` builds the before-tree, applies the
// operation, and renders before → arrow → ... → after with the marks it
// returns. `mids` is an array (possibly empty) of `(tree:, marks:, label:)`
// panels between before and after (see `insert`'s `rebalance`); `label` is
// the label for the arrow leading *out of* the previous panel *into* this
// one.

// `kind` is a highlight kind string ("new"/"path"/"remove"/"rotate"),
// resolved against the caller's `style:` at draw time by `mark-style` —
// keeping the kind here instead of a resolved color is what lets a per-call
// style override actually reach the mark.
#let _create-value-marks(keys, kind) = {
  let marks = (:)
  for node-key in keys { marks.insert(str(node-key), kind) }
  marks
}

// Every visible schematic part in a rotation: the pivot, the child promoted
// above it, and the roots of T_A/T_B/T_C when those subtrees exist.
#let _rotation-event-keys(event) = {
  let keys = (event.pivot, event.new-top)
  keys += event.subs
  keys
}
#let _rotated-node-keys(rotation-events) = {
  let keys = ()
  for rotation-event in rotation-events {
    keys += _rotation-event-keys(rotation-event)
  }
  keys
}

#let _rotation-label(message-catalog, event) = (
  msg(message-catalog, "tree.rotate-" + event.dir, event.pivot)
)

// `rebalance: (enabled: false, all-steps: false)` — `enabled: true` adds a
// panel for the tree right after the plain BST placement, before any
// rotation straightens it out, when the AVL fixup actually rotates. A BST
// insert, or an AVL insert that never unbalances the tree, ignores it and
// stays 2-panel. `all-steps: true` additionally splits a *double* rotation
// (left-right / right-left) into its own inner-then-outer steps instead of
// collapsing straight from the unrotated tree to the final one; it has no
// effect on a single rotation, since there's only one step to show either way.
// Operations are tagged with the structure family they apply to, so
// `transition` can reject a heap operation aimed at a tree before it reaches
// code that would misread the model.
#let _tree-operation(apply) = (family: "tree", apply: apply)

#let tree-insert(key, rebalance: (:), step-label: none, language: "en", messages: (:), catalog: none) = {
  check-comparable("tree-insert()", "key", (key,), subject: "key")
  check-known-keys("tree-insert()", "rebalance:", rebalance, ("enabled", "all-steps"))
  for (option-name, option-value) in rebalance {
    check-bool("tree-insert()", "rebalance." + option-name, option-value)
  }
  _tree-operation((variant, root) => {
  let existing-keys = _collect-tree-keys(root)
  check-comparable-with("tree-insert()", "key", key, existing-keys)
  if key in existing-keys {
    fail(
      "tree-insert()",
      "key " + show-value(key) + " is already in the tree, so the insert would change nothing",
      expected: "a key that is not present yet",
      fix: "insert a different key, or drop this operation",
    )
  }
  let message-catalog = if catalog != none {
    catalog
  } else {
    resolve-catalog(language: language, messages: messages)
  }
  let default-label = msg(message-catalog, "tree.insert", key)
  let final-step-label = if step-label == none { default-label } else { step-label }
  if variant == "avl" {
    let rebalance-options = (enabled: false, all-steps: false) + rebalance
    let (tree-after-insertion, rotation-events, inner-rotation-snapshot) = (
      _insert-avl-node(root, key)
    )
    let intermediate-panels = ()
    if rebalance-options.enabled and rotation-events.len() > 0 {
      let unbalanced-tree = _insert-bst-node(root, key)
      let new-node-marks = _create-value-marks((key,), "new")
      intermediate-panels.push((
        tree: unbalanced-tree,
        marks: new-node-marks,
        label: default-label,
      ))
      let should-render-inner-rotation = (
        rebalance-options.all-steps
          and rotation-events.len() == 2
          and inner-rotation-snapshot != none
      )
      if should-render-inner-rotation {
        let inner-rotation-marks = (
          new-node-marks
            + _create-value-marks(
              _rotation-event-keys(rotation-events.at(0)),
              "rotate",
            )
        )
        intermediate-panels.push((
          tree: inner-rotation-snapshot,
          marks: inner-rotation-marks,
          label: _rotation-label(message-catalog, rotation-events.at(0)),
        ))
      }
    }
    let should-mark_outer-rotation-only = (
      rebalance-options.enabled
        and rebalance-options.all-steps
        and rotation-events.len() == 2
        and inner-rotation-snapshot != none
    )
    let after-marks = if should-mark_outer-rotation-only {
      _create-value-marks(
        _rotation-event-keys(rotation-events.at(1)),
        "rotate",
      )
    } else {
      (
        _create-value-marks((key,), "new")
          + _create-value-marks(
            _rotated-node-keys(rotation-events),
            "rotate",
          )
      )
    }
    let rotation-summary-label = if intermediate-panels.len() == 2 {
      _rotation-label(message-catalog, rotation-events.at(1))
    } else {
      rotation-events.map(
        event => _rotation-label(message-catalog, event),
      ).join([, ])
    }
    let label = if step-label != none {
      step-label
    } else if rotation-events.len() > 0 {
      rotation-summary-label
    } else {
      default-label
    }
    (
      tree-after-insertion,
      (:),
      after-marks,
      label,
      intermediate-panels,
    )
  } else {
    let before-marks = _create-value-marks(
      _find-bst-search-path(root, key),
      "path",
    )
    (
      _insert-bst-node(root, key),
      before-marks,
      _create-value-marks((key,), "new"),
      final-step-label,
      (),
    )
  }
  })
}

#let tree-delete(key, step-label: none, language: "en", messages: (:), catalog: none) = {
  check-comparable("tree-delete()", "key", (key,), subject: "key")
  _tree-operation((variant, root) => {
  let existing-keys = _collect-tree-keys(root)
  check-comparable-with("tree-delete()", "key", key, existing-keys)
  if key not in existing-keys {
    fail(
      "tree-delete()",
      "key " + show-value(key) + " is not in the tree, so there is nothing to delete",
      expected: "one of the keys in the tree: " + show-list(existing-keys),
      fix: "delete a key the tree holds; use tree-search(key) to show an unsuccessful lookup",
    )
  }
  let message-catalog = if catalog != none {
    catalog
  } else {
    resolve-catalog(language: language, messages: messages)
  }
  let label = if step-label == none {
    msg(message-catalog, "tree.delete", key)
  } else {
    step-label
  }
  let before-marks = (
    _create-value-marks(_find-bst-search-path(root, key), "path")
      + _create-value-marks((key,), "remove")
  )
  if variant == "avl" {
    let (tree-after-deletion, rotation-events) = _remove-avl-node(root, key)
    return (
      tree-after-deletion,
      before-marks,
      _create-value-marks(_rotated-node-keys(rotation-events), "rotate"),
      label,
      (),
    )
  }
  (_remove-bst-node(root, key), before-marks, (:), label, ())
  })
}

// A search that finds nothing is a legitimate result, not an error: the step
// reports it through `found:` and still draws the path that was walked.
#let tree-search(key, step-label: none, language: "en", messages: (:), catalog: none) = {
  check-comparable("tree-search()", "key", (key,), subject: "key")
  _tree-operation((variant, root) => {
  check-comparable-with("tree-search()", "key", key, _collect-tree-keys(root))
  let message-catalog = if catalog != none {
    catalog
  } else {
    resolve-catalog(language: language, messages: messages)
  }
  let search-path-marks = _create-value-marks(
    _find-bst-search-path(root, key),
    "path",
  )
  let label = if step-label == none {
    msg(message-catalog, "tree.search", key)
  } else {
    step-label
  }
  (root, (:), search-path-marks, label, ())
  })
}

// Before → arrow → ... → after, for a step with zero or more extra panels in
// between (an AVL insert with `rebalance: (enabled: true)` that actually
// rotated). `mids` holds the in-between panels as already-rendered content;
// `labels` holds one more entry than `mids` — the arrow leading into each
// mid panel, then the arrow leading into `after`.
#let trans-view-n(before, mids, labels, after, style: (:)) = {
  let transition-parts = (align(horizon, before),)
  for (panel-index, intermediate-panel) in mids.enumerate() {
    transition-parts.push(op-arrow(labels.at(panel-index), style: style))
    transition-parts.push(align(horizon, intermediate-panel))
  }
  transition-parts.push(op-arrow(labels.last(), style: style))
  transition-parts.push(align(horizon, after))
  stack(dir: ltr, spacing: 1.2em, ..transition-parts)
}

// Renders an operation's step diagram, expanding to extra panels when the op
// returns non-empty `mids`.
#let _render-tree-operation-step(
  tree-before-operation,
  before-marks,
  tree-after-operation,
  after-marks,
  label,
  intermediate-panels,
  resolved-style,
  style,
  edge-customizations,
  node-customizations,
  node-labels,
) = {
  let before-diagram = _render-tree(
    tree-before-operation,
    marks: before-marks,
    resolved-style: resolved-style,
    edge-customizations: edge-customizations,
    node-customizations: node-customizations,
    node-labels: node-labels,
  )
  let after-diagram = _render-tree(
    tree-after-operation,
    marks: after-marks,
    resolved-style: resolved-style,
    edge-customizations: edge-customizations,
    node-customizations: node-customizations,
    node-labels: node-labels,
  )
  if intermediate-panels.len() == 0 {
    (
      before: before-diagram,
      after: after-diagram,
      diagram: trans-view(
        before-diagram,
        label,
        after-diagram,
        style: style,
      ),
    )
  } else {
    let intermediate-diagrams = intermediate-panels.map(panel => (
      _render-tree(
        panel.tree,
        marks: panel.marks,
        resolved-style: resolved-style,
        edge-customizations: edge-customizations,
        node-customizations: node-customizations,
        node-labels: node-labels,
      )
    ))
    let transition-labels = intermediate-panels.map(
      panel => panel.label,
    ) + (label,)
    (
      before: before-diagram,
      after: after-diagram,
      diagram: trans-view-n(
        before-diagram,
        intermediate-diagrams,
        transition-labels,
        after-diagram,
        style: style,
      ),
    )
  }
}

// A tree value is both the drawing and the object you operate on: `diagram`
// holds the rendering, and each operation field returns a step `(label,
// before, after, diagram, result)` where `result` is the tree after the
// operation. Typst calls functions stored in dictionaries as `(obj.field)(...)`,
// so examples use that shape instead of `obj.field(...)`.
#let _create-tree-object(variant, root, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:), catalog: default-catalog) = {
  let apply-operation = operation => {
    let (
      tree-after-operation,
      before-marks,
      after-marks,
      label,
      intermediate-panels,
    ) = (operation.apply)(variant, root)
    let rendered-step = _render-tree-operation-step(
      root,
      before-marks,
      tree-after-operation,
      after-marks,
      label,
      intermediate-panels,
      resolve(style),
      style,
      edge-customizations,
      node-customizations,
      node-labels,
    )
    (
      label: label,
      before: rendered-step.before,
      after: rendered-step.after,
      diagram: rendered-step.diagram,
      result: _create-tree-object(
        variant,
        tree-after-operation,
        style: style,
        edge-customizations: edge-customizations,
        node-customizations: node-customizations,
        node-labels: node-labels,
        catalog: catalog,
      ),
    )
  }
  (
    diagram: _render-tree(root, resolved-style: resolve(style), edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels),
    insert: (key, rebalance: (:), step-label: none) => apply-operation(
      tree-insert(
        key,
        rebalance: rebalance,
        step-label: step-label,
        catalog: catalog,
      ),
    ),
    delete: (key, step-label: none) => apply-operation(
      tree-delete(key, step-label: step-label, catalog: catalog),
    ),
    search: (key, step-label: none) => apply-operation(
      tree-search(key, step-label: step-label, catalog: catalog),
    ) + (found: key in _collect-tree-keys(root)),
  )
}

#let _create-search-tree(where, variant, keys, style, edge-customizations, node-customizations, node-labels) = {
  _validate-search-tree-keys(where, keys)
  let root = _build-search-tree(variant, keys)
  _validate-tree-arguments(
    where,
    style,
    edge-customizations,
    node-customizations,
    node-labels,
    root,
  )
  root
}

#let bst(style: (:), edge-customizations: (), node-customizations: (), node-labels: (:), language: "en", messages: (:), ..keys) = _create-tree-object("bst", _create-search-tree("bst()", "bst", keys.pos(), style, edge-customizations, node-customizations, node-labels), style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels, catalog: resolve-catalog(language: language, messages: messages))
#let avl(style: (:), edge-customizations: (), node-customizations: (), node-labels: (:), language: "en", messages: (:), ..keys) = _create-tree-object("avl", _create-search-tree("avl()", "avl", keys.pos(), style, edge-customizations, node-customizations, node-labels), style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels, catalog: resolve-catalog(language: language, messages: messages))

// ── Transition ───────────────────────────────────────────────────────────────

#let transition(variant, keys, op, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  check-array(
    "transition()", "keys", keys,
    fix: "pass the keys as an array, for example transition(\"bst\", (50, 30), tree-insert(40))",
  )
  let tree-before-operation = _create-search-tree(
    "transition()",
    variant,
    keys,
    style,
    edge-customizations,
    node-customizations,
    node-labels,
  )
  let (
    tree-after-operation,
    before-marks,
    after-marks,
    label,
    intermediate-panels,
  ) = (op.apply)(variant, tree-before-operation)
  _render-tree-operation-step(
    tree-before-operation,
    before-marks,
    tree-after-operation,
    after-marks,
    label,
    intermediate-panels,
    resolve(style),
    style,
    edge-customizations,
    node-customizations,
    node-labels,
  ).diagram
}
