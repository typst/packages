// Tree state, generated-tree transformations, and hand-composed node models.
//
// Rotations and search-tree mutations live here because they transform the
// persistent tree model. This module has no layout or rendering dependency.

#import "style.typ": check-fill
#import "validate.typ": check-array, check-positive, fail, show-value

// ── Model: generated BST/AVL ─────────────────────────────────────────────────

#let _create-tree-node(key) = (kind: "node", key: key, left: none, right: none, height: 1)

#let _tree-height(tree-node) = if tree-node == none { 0 } else { tree-node.height }

#let _calculate-balance-factor(tree-node) = (
  _tree-height(tree-node.left) - _tree-height(tree-node.right)
)

#let _update-tree-node-height(tree-node) = {
  tree-node.height = calc.max(
    _tree-height(tree-node.left),
    _tree-height(tree-node.right),
  ) + 1
  tree-node
}

#let _rotate-subtree-left(subtree-root) = {
  let promoted-node = subtree-root.right
  subtree-root.right = promoted-node.left
  promoted-node.left = _update-tree-node-height(subtree-root)
  _update-tree-node-height(promoted-node)
}

#let _rotate-subtree-right(subtree-root) = {
  let promoted-node = subtree-root.left
  subtree-root.left = promoted-node.right
  promoted-node.right = _update-tree-node-height(subtree-root)
  _update-tree-node-height(promoted-node)
}

// Plain BST insert. Duplicate keys are ignored.
#let _insert-bst-node(subtree-root, key) = {
  if subtree-root == none { return _create-tree-node(key) }
  if key < subtree-root.key {
    subtree-root.left = _insert-bst-node(subtree-root.left, key)
  } else if key > subtree-root.key {
    subtree-root.right = _insert-bst-node(subtree-root.right, key)
  }
  subtree-root
}

#let _tree-node-key(tree-node) = if tree-node == none { none } else { tree-node.key }

// Rotation events retain the visible schematic roots so transition panels can
// highlight every node whose parent changes.
#let _create-rotation-event(direction, pivot, promoted-node, left-subtree, middle-subtree, right-subtree) = (
  dir: direction,
  pivot: pivot.key,
  new-top: promoted-node.key,
  subs: (
    _tree-node-key(left-subtree),
    _tree-node-key(middle-subtree),
    _tree-node-key(right-subtree),
  ).filter(subtree-key => subtree-key != none),
)

// AVL insertion returns the balanced subtree, its rotation events, and the
// inner-rotation snapshot used by optional multi-panel transitions.
#let _insert-avl-node(subtree-root, key) = {
  if subtree-root == none { return (_create-tree-node(key), (), none) }
  let rotation-events = ()
  let intermediate-tree = none
  if key < subtree-root.key {
    let (left-subtree, child-events, child-intermediate-tree) = (
      _insert-avl-node(subtree-root.left, key)
    )
    if child-intermediate-tree != none {
      let propagated-intermediate-tree = subtree-root
      propagated-intermediate-tree.left = child-intermediate-tree
      intermediate-tree = propagated-intermediate-tree
    }
    subtree-root.left = left-subtree
    rotation-events += child-events
  } else if key > subtree-root.key {
    let (right-subtree, child-events, child-intermediate-tree) = (
      _insert-avl-node(subtree-root.right, key)
    )
    if child-intermediate-tree != none {
      let propagated-intermediate-tree = subtree-root
      propagated-intermediate-tree.right = child-intermediate-tree
      intermediate-tree = propagated-intermediate-tree
    }
    subtree-root.right = right-subtree
    rotation-events += child-events
  } else {
    return (subtree-root, (), none)
  }
  subtree-root = _update-tree-node-height(subtree-root)
  let balance-factor = _calculate-balance-factor(subtree-root)
  if balance-factor > 1 and key < subtree-root.left.key {
    let rotation-event = _create-rotation-event(
      "right",
      subtree-root,
      subtree-root.left,
      subtree-root.left.left,
      subtree-root.left.right,
      subtree-root.right,
    )
    return (
      _rotate-subtree-right(subtree-root),
      rotation-events + (rotation-event,),
      intermediate-tree,
    )
  }
  if balance-factor < -1 and key > subtree-root.right.key {
    let rotation-event = _create-rotation-event(
      "left",
      subtree-root,
      subtree-root.right,
      subtree-root.left,
      subtree-root.right.left,
      subtree-root.right.right,
    )
    return (
      _rotate-subtree-left(subtree-root),
      rotation-events + (rotation-event,),
      intermediate-tree,
    )
  }
  if balance-factor > 1 and key > subtree-root.left.key {
    let inner-rotation = _create-rotation-event(
      "left",
      subtree-root.left,
      subtree-root.left.right,
      subtree-root.left.left,
      subtree-root.left.right.left,
      subtree-root.left.right.right,
    )
    subtree-root.left = _rotate-subtree-left(subtree-root.left)
    intermediate-tree = subtree-root
    let outer-rotation = _create-rotation-event(
      "right",
      subtree-root,
      subtree-root.left,
      subtree-root.left.left,
      subtree-root.left.right,
      subtree-root.right,
    )
    return (
      _rotate-subtree-right(subtree-root),
      rotation-events + (inner-rotation, outer-rotation),
      intermediate-tree,
    )
  }
  if balance-factor < -1 and key < subtree-root.right.key {
    let inner-rotation = _create-rotation-event(
      "right",
      subtree-root.right,
      subtree-root.right.left,
      subtree-root.right.left.left,
      subtree-root.right.left.right,
      subtree-root.right.right,
    )
    subtree-root.right = _rotate-subtree-right(subtree-root.right)
    intermediate-tree = subtree-root
    let outer-rotation = _create-rotation-event(
      "left",
      subtree-root,
      subtree-root.right,
      subtree-root.left,
      subtree-root.right.left,
      subtree-root.right.right,
    )
    return (
      _rotate-subtree-left(subtree-root),
      rotation-events + (inner-rotation, outer-rotation),
      intermediate-tree,
    )
  }
  (subtree-root, rotation-events, intermediate-tree)
}

#let _find-minimum-bst-key(subtree-root) = {
  while subtree-root.left != none { subtree-root = subtree-root.left }
  subtree-root.key
}

// Standard BST delete using the in-order successor for two-child nodes.
#let _remove-bst-node(subtree-root, key) = {
  if subtree-root == none { return none }
  if key < subtree-root.key {
    subtree-root.left = _remove-bst-node(subtree-root.left, key)
  } else if key > subtree-root.key {
    subtree-root.right = _remove-bst-node(subtree-root.right, key)
  }
  else {
    if subtree-root.left == none { return subtree-root.right }
    if subtree-root.right == none { return subtree-root.left }
    let successor-key = _find-minimum-bst-key(subtree-root.right)
    subtree-root.key = successor-key
    subtree-root.right = _remove-bst-node(subtree-root.right, successor-key)
  }
  subtree-root
}

#let _rebalance-avl-subtree(subtree-root, rotation-events) = {
  subtree-root = _update-tree-node-height(subtree-root)
  let balance-factor = _calculate-balance-factor(subtree-root)
  if balance-factor > 1 {
    if _calculate-balance-factor(subtree-root.left) < 0 {
      let inner-rotation = _create-rotation-event(
        "left",
        subtree-root.left,
        subtree-root.left.right,
        subtree-root.left.left,
        subtree-root.left.right.left,
        subtree-root.left.right.right,
      )
      subtree-root.left = _rotate-subtree-left(subtree-root.left)
      let outer-rotation = _create-rotation-event(
        "right",
        subtree-root,
        subtree-root.left,
        subtree-root.left.left,
        subtree-root.left.right,
        subtree-root.right,
      )
      return (
        _rotate-subtree-right(subtree-root),
        rotation-events + (inner-rotation, outer-rotation),
      )
    }
    let rotation-event = _create-rotation-event(
      "right",
      subtree-root,
      subtree-root.left,
      subtree-root.left.left,
      subtree-root.left.right,
      subtree-root.right,
    )
    return (
      _rotate-subtree-right(subtree-root),
      rotation-events + (rotation-event,),
    )
  }
  if balance-factor < -1 {
    if _calculate-balance-factor(subtree-root.right) > 0 {
      let inner-rotation = _create-rotation-event(
        "right",
        subtree-root.right,
        subtree-root.right.left,
        subtree-root.right.left.left,
        subtree-root.right.left.right,
        subtree-root.right.right,
      )
      subtree-root.right = _rotate-subtree-right(subtree-root.right)
      let outer-rotation = _create-rotation-event(
        "left",
        subtree-root,
        subtree-root.right,
        subtree-root.left,
        subtree-root.right.left,
        subtree-root.right.right,
      )
      return (
        _rotate-subtree-left(subtree-root),
        rotation-events + (inner-rotation, outer-rotation),
      )
    }
    let rotation-event = _create-rotation-event(
      "left",
      subtree-root,
      subtree-root.right,
      subtree-root.left,
      subtree-root.right.left,
      subtree-root.right.right,
    )
    return (
      _rotate-subtree-left(subtree-root),
      rotation-events + (rotation-event,),
    )
  }
  (subtree-root, rotation-events)
}

#let _remove-avl-node(subtree-root, key) = {
  if subtree-root == none { return (none, ()) }
  let rotation-events = ()
  if key < subtree-root.key {
    let (left-subtree, child-events) = _remove-avl-node(subtree-root.left, key)
    subtree-root.left = left-subtree
    rotation-events += child-events
  } else if key > subtree-root.key {
    let (right-subtree, child-events) = _remove-avl-node(subtree-root.right, key)
    subtree-root.right = right-subtree
    rotation-events += child-events
  } else {
    if subtree-root.left == none { return (subtree-root.right, ()) }
    if subtree-root.right == none { return (subtree-root.left, ()) }
    let successor-key = _find-minimum-bst-key(subtree-root.right)
    subtree-root.key = successor-key
    let (right-subtree, child-events) = (
      _remove-avl-node(subtree-root.right, successor-key)
    )
    subtree-root.right = right-subtree
    rotation-events += child-events
  }
  _rebalance-avl-subtree(subtree-root, rotation-events)
}

// Keys visited from the root while searching for `key`, in order.
#let _find-bst-search-path(subtree-root, key) = {
  if subtree-root == none { return () }
  if key == subtree-root.key { return (subtree-root.key,) }
  if key < subtree-root.key {
    return (subtree-root.key,) + _find-bst-search-path(subtree-root.left, key)
  }
  (subtree-root.key,) + _find-bst-search-path(subtree-root.right, key)
}

#let _build-search-tree(variant, keys) = {
  let root = none
  for key in keys {
    if variant == "avl" {
      let (tree-after-insertion, _, _) = _insert-avl-node(root, key)
      root = tree-after-insertion
    } else {
      root = _insert-bst-node(root, key)
    }
  }
  root
}

// ── Model: hand-composed trees ────────────────────────────────────────────────

#let _tree-node-kinds = ("node", "subtree")

#let _is-tree-node(candidate) = (
  type(candidate) == dictionary
    and candidate.at("kind", default: none) in _tree-node-kinds
)

#let _tree-node-id(tree-node) = (
  tree-node.at("key", default: tree-node.at("label", default: none))
)

#let _visible-tree-children(tree-node) = {
  let explicit-children = tree-node.at("children", default: none)
  if explicit-children != none {
    return explicit-children.filter(child => child != none)
  }
  (tree-node.left, tree-node.right).filter(child => child != none)
}

// A child slot holds a `node(...)`, a `subtree(...)`, or nothing. Checking the
// shape here means layout and rendering never meet a bare value where they
// expect a node dictionary.
#let _check-tree-node(where, what, candidate) = {
  if candidate == none or _is-tree-node(candidate) { return }
  fail(
    where,
    what + " is " + show-value(candidate),
    expected: "a node(...) value, a subtree(...) value, or none",
    fix: "wrap it, for example " + what + ": node(" + show-value(candidate) + ")",
  )
}

// A node with an arbitrary content `label`, optional children, and an optional fill tint.
#let node(label, left: none, right: none, children: none, fill: none) = {
  _check-tree-node("node()", "left:", left)
  _check-tree-node("node()", "right:", right)
  if fill != none { check-fill("node()", "fill:", fill) }
  if children != none {
    check-array(
      "node()", "children:", children,
      fix: "pass an array of node(...) values",
    )
    for (child-index, child) in children.enumerate() {
      _check-tree-node("node()", "children: entry " + str(child-index), child)
    }
    if left != none or right != none {
      fail(
        "node()",
        "children: was given together with left:/right:",
        expected: "either children: for an n-ary node, or left:/right: for a binary node",
        fix: "drop one of the two spellings",
      )
    }
  }
  (
    kind: "node", label: label, left: left, right: right,
    children: children,
    fill: fill,
    height: 1,
  )
}

// A triangle leaf standing in for an elided subtree. `height` is an optional
// content label drawn as a side bracket; `scale` resizes the triangle; `fill`
// tints the outline and labels.
#let subtree(label, fill: none, height: none, scale: 1) = {
  if fill != none { check-fill("subtree()", "fill:", fill) }
  check-positive("subtree()", "scale:", scale)
  (
    kind: "subtree", label: label,
    fill: fill,
    h-label: height, tscale: scale,
  )
}
