// Binary search trees, AVL trees, hand-composed trees, and operation transitions.
//
// A node is a plain dict. Generated trees (`bst`, `avl`) hold `(key, left,
// right, height)`; hand-composed trees use `node(label, left:, right:)` and
// `subtree(label)` leaves drawn as triangles. Layout assigns the in-order
// column index to x and depth to y — the standard textbook BST drawing, which
// never overlaps, so no contour-merging layout pass is needed. Positions are
// written onto the nodes, so labels can be any content.

#import "@preview/cetz:0.5.2"
#import "style.typ": (
  theme, resolve, scaled, resolve-mark-style, edge-mark, edge-stroke, edge-wave,
  wavy-parts, validate-style, check-fill, check-edge-customization-options,
  check-node-customization-options, check-node-label-override,
)
#import "validate.typ": (
  check-array, check-bool, check-comparable, check-comparable-with,
  check-customization-entries, check-dictionary, check-enum,
  check-id-value-references, check-known-keys, check-positive, check-reference,
  check-type, check-unique, fail, normalize-id-value-entries, show-list,
  show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, circle, rect, content, bezier-through

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

// ── Render ───────────────────────────────────────────────────────────────────

#let _tree-node-position(tree-node, resolved-style) = (
  tree-node._col * resolved-style.x-gap,
  -tree-node._depth * resolved-style.y-gap,
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

#let _resolve-tree-edge-customization(customizations, from-node-id, to-node-id) = {
  for (custom-from-id, custom-to-id, options) in customizations {
    if custom-from-id == from-node-id and custom-to-id == to-node-id {
      return options
    }
  }
  none
}

#let _resolve-tree-node-customization(customizations, node-id) = {
  for (custom-node-id, options) in customizations {
    if custom-node-id == node-id { return options }
  }
  none
}

#let _normalize-text-style(style) = {
  let normalized-style = style
  if "color" in normalized-style {
    normalized-style.fill = normalized-style.color
    let _ = normalized-style.remove("color")
  }
  normalized-style
}

#let _lookup-node-value(values, node-id) = {
  if type(values) == dictionary {
    if type(node-id) == str or type(node-id) == int or type(node-id) == float {
      return values.at(str(node-id), default: none)
    }
    return none
  }
  for (candidate-node-id, value) in values {
    if candidate-node-id == node-id { return value }
  }
  none
}

#let _resolve-node-radius(resolved-style, mark: none, custom: none) = {
  if custom != none and "node-radius" in custom { return custom.node-radius }
  if mark != none { return mark.node-radius }
  resolved-style.node-radius
}

#let _resolve-node-shape(resolved-style, mark: none, custom: none) = {
  if custom != none and "shape" in custom { return custom.shape }
  if mark != none { return mark.shape }
  resolved-style.node-shape
}

#let _calculate-shape-boundary-radius(shape, node-radius, unit-x, unit-y) = {
  if shape in ("square", "rounded") {
    return node-radius / calc.max(calc.abs(unit-x), calc.abs(unit-y))
  }
  if shape == "diamond" {
    return node-radius / (calc.abs(unit-x) + calc.abs(unit-y))
  }
  if shape == "capsule" {
    let horizontal-radius-offset = 0.4 * node-radius
    return horizontal-radius-offset * calc.abs(unit-x) + calc.sqrt(
      node-radius * node-radius
        - horizontal-radius-offset * horizontal-radius-offset * unit-y * unit-y,
    )
  }
  node-radius
}

#let _trim-edge-to-shape(from-position, toward-position, shape, node-radius) = {
  let delta-x = toward-position.at(0) - from-position.at(0)
  let delta-y = toward-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if distance == 0 { return from-position }
  let unit-x = delta-x / distance
  let unit-y = delta-y / distance
  let boundary-distance = _calculate-shape-boundary-radius(
    shape,
    node-radius,
    unit-x,
    unit-y,
  )
  (
    from-position.at(0) + unit-x * boundary-distance,
    from-position.at(1) + unit-y * boundary-distance,
  )
}

#let _render-tree-edge(
  from-position,
  to-position,
  from-boundary,
  to-boundary,
  resolved-style,
  customization,
) = {
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if distance == 0 { return }
  let arrow-mark = edge-mark(
    if customization != none and "arrow" in customization {
      customization.arrow
    } else {
      resolved-style.edge-arrow
    },
  )
  let stroke = edge-stroke(resolved-style, custom: customization)
  let bend-direction = if customization != none {
    customization.at("bend", default: false)
  } else {
    false
  }
  if bend-direction != false and bend-direction != none {
    let bend-position = _calculate-edge-bend-point(
      from-position,
      to-position,
      bend-direction,
      customization.at("angle", default: 25deg),
    )
    let trimmed-start = _trim-edge-to-shape(
      from-position,
      bend-position,
      from-boundary.at(0),
      from-boundary.at(1),
    )
    let trimmed-end = _trim-edge-to-shape(
      to-position,
      bend-position,
      to-boundary.at(0),
      to-boundary.at(1),
    )
    bezier-through(
      trimmed-start,
      bend-position,
      trimmed-end,
      stroke: stroke,
      mark: arrow-mark,
    )
  } else {
    let trimmed-start = _trim-edge-to-shape(
      from-position,
      to-position,
      from-boundary.at(0),
      from-boundary.at(1),
    )
    let trimmed-end = _trim-edge-to-shape(
      to-position,
      from-position,
      to-boundary.at(0),
      to-boundary.at(1),
    )
    if edge-wave(resolved-style, custom: customization) {
      let has-start-tip = arrow-mark != none and "start" in arrow-mark
      let has-end-tip = arrow-mark != none and "end" in arrow-mark
      let wave-parts = wavy-parts(
        trimmed-start,
        trimmed-end,
        resolved-style,
        start-tip: has-start-tip,
        end-tip: has-end-tip,
      )
      line(..wave-parts.points, stroke: stroke)
      let arrow-fill = if arrow-mark == none {
        none
      } else {
        arrow-mark.at("fill", default: none)
      }
      if has-start-tip {
        line(
          trimmed-start,
          wave-parts.start-cap,
          stroke: stroke,
          mark: (start: ">", fill: arrow-fill),
        )
      }
      if has-end-tip {
        line(
          wave-parts.end-cap,
          trimmed-end,
          stroke: stroke,
          mark: (end: ">", fill: arrow-fill),
        )
      }
    } else {
      line(trimmed-start, trimmed-end, stroke: stroke, mark: arrow-mark)
    }
  }
}

#let _calculate-edge-bend-point(from-position, to-position, bend-direction, angle) = {
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let distance = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  let midpoint-x = (from-position.at(0) + to-position.at(0)) / 2
  let midpoint-y = (from-position.at(1) + to-position.at(1)) / 2
  if distance == 0 { return (midpoint-x, midpoint-y) }
  let unit-x = delta-x / distance
  let unit-y = delta-y / distance
  let (perpendicular-x, perpendicular-y) = if bend-direction == "left" {
    (-unit-y, unit-x)
  } else {
    (unit-y, -unit-x)
  }
  let sagitta = (distance / 2) * calc.tan(angle)
  (
    midpoint-x + perpendicular-x * sagitta,
    midpoint-y + perpendicular-y * sagitta,
  )
}

#let _resolve-tree-edge-label(resolved-style, custom) = {
  let style = resolved-style.edge-label-text
  let body = none
  if custom != none and "label" in custom {
    let lbl = custom.label
    if type(lbl) == dictionary {
      body = lbl.at("content", default: lbl.at("body", default: none))
      let d = lbl
      let _ = d.remove("content", default: none)
      let _ = d.remove("body", default: none)
      if "color" in d {
        d.fill = d.color
        let _ = d.remove("color")
      }
      style = style + d
    } else {
      body = lbl
    }
  }
  (body: body, style: style)
}

#let _node-label-direction(pos) = {
  if pos == "right" { return (1, 0) }
  if pos == "left" { return (-1, 0) }
  if pos == "top" { return (0, 1) }
  if pos == "bottom" { return (0, -1) }
  if type(pos) == angle { return (calc.cos(pos), calc.sin(pos)) }
  (1, 0)
}

#let _resolve-tree-node-label(resolved-style, node-labels, id) = {
  let raw = _lookup-node-value(node-labels, id)
  if raw == none { return none }
  let body = raw
  let style = resolved-style.label-text
  let defaults = resolved-style.at("node-labels", default: (:))
  let position = defaults.at("position", default: "right")
  let offset = defaults.at("offset", default: (0, 0))
  let gap = defaults.at("gap", default: 0.22)
  let d0 = defaults
  for key in ("position", "offset", "gap", "enabled") {
    if key in d0 { let _ = d0.remove(key) }
  }
  if "color" in d0 {
    d0.fill = d0.color
    let _ = d0.remove("color")
  }
  style = style + d0
  if type(raw) == dictionary {
    body = raw.at("content", default: raw.at("body", default: none))
    let d = raw
    let _ = d.remove("content", default: none)
    let _ = d.remove("body", default: none)
    if "position" in d {
      position = d.position
      let _ = d.remove("position")
    }
    if "offset" in d {
      offset = d.offset
      let _ = d.remove("offset")
    }
    if "gap" in d {
      gap = d.gap
      let _ = d.remove("gap")
    }
    if "color" in d {
      d.fill = d.color
      let _ = d.remove("color")
    }
    style = style + d
  }
  if body == none { return none }
  (body: body, style: style, position: position, offset: offset, gap: gap)
}

#let _render-tree-node-label(node-position, boundary, resolved-style, label) = {
  if label == none { return }
  let label-direction = _node-label-direction(label.position)
  let offset-x = label.offset.at(0)
  let offset-y = label.offset.at(1)
  let label-gap = label.gap
  let boundary-distance = _calculate-shape-boundary-radius(
    boundary.at(0),
    boundary.at(1),
    label-direction.at(0),
    label-direction.at(1),
  )
  let label-position = (
    node-position.at(0)
      + label-direction.at(0) * (boundary-distance + label-gap)
      + offset-x,
    node-position.at(1)
      + label-direction.at(1) * (boundary-distance + label-gap)
      + offset-y,
  )
  let text-style = label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(label-position, text(..text-style)[#label.body], angle: rotation)
}

#let _render-tree-edge-label(p, q, r1, r2, resolved-style, custom) = {
  let lbl = _resolve-tree-edge-label(resolved-style, custom)
  if lbl.body == none { return }
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let ux = dx / len
  let uy = dy / len
  let a = _trim-edge-to-shape(p, q, r1.at(0), r1.at(1))
  let b = _trim-edge-to-shape(q, p, r2.at(0), r2.at(1))
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  let base = if bend == false or bend == none {
    ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  } else {
    _calculate-edge-bend-point(p, q, bend, if custom != none { custom.at("angle", default: 25deg) } else { 25deg })
  }
  let (ox, oy) = if bend == "right" {
    (uy, -ux)
  } else if bend == "left" {
    (-uy, ux)
  } else if dx < 0 {
    (uy, -ux)
  } else {
    (-uy, ux)
  }
  let shift = 0.16
  let text-style = lbl.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  if rotation == "edge" {
    rotation = calc.atan2(dx, dy)
    if dx < 0 { rotation += 180deg }
  }
  content((base.at(0) + ox * shift, base.at(1) + oy * shift), text(..text-style)[#lbl.body], angle: rotation)
}

#let _render-tree-edges(tree-node, resolved-style, edge-customizations, node-customizations) = {
  if tree-node == none or tree-node.kind == "subtree" { return }
  let parent-position = _tree-node-position(tree-node, resolved-style)
  for child-node in _visible-tree-children(tree-node) {
    if child-node != none {
      let child-position = _tree-node-position(child-node, resolved-style)
      let parent-customization = _resolve-tree-node-customization(
        node-customizations,
        _tree-node-id(tree-node),
      )
      let child-customization = _resolve-tree-node-customization(
        node-customizations,
        _tree-node-id(child-node),
      )
      let parent-boundary = (
        _resolve-node-shape(
          resolved-style,
          custom: parent-customization,
        ),
        _resolve-node-radius(
          resolved-style,
          custom: parent-customization,
        ),
      )
      let child-boundary = if child-node.kind == "subtree" {
        ("circle", 0)
      } else {
        (
          _resolve-node-shape(
            resolved-style,
            custom: child-customization,
          ),
          _resolve-node-radius(
            resolved-style,
            custom: child-customization,
          ),
        )
      }
      let edge-customization = _resolve-tree-edge-customization(
        edge-customizations,
        _tree-node-id(tree-node),
        _tree-node-id(child-node),
      )
      _render-tree-edge(
        parent-position,
        child-position,
        parent-boundary,
        child-boundary,
        resolved-style,
        edge-customization,
      )
      _render-tree-edge-label(
        parent-position,
        child-position,
        parent-boundary,
        child-boundary,
        resolved-style,
        edge-customization,
      )
      _render-tree-edges(
        child-node,
        resolved-style,
        edge-customizations,
        node-customizations,
      )
    }
  }
}

// `mark` is `none` (use `resolved-style`'s node defaults and `fill`) or a resolved dict
// from `mark-style`, overriding the shape/stroke/radius/text of this node.
#let _render-tree-node-shape(p, label, resolved-style, fill, mark: none, custom: none) = {
  let shape = _resolve-node-shape(resolved-style, mark: mark, custom: custom)
  let r = _resolve-node-radius(resolved-style, mark: mark, custom: custom)
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else if mark != none { mark.stroke } else { resolved-style.node-stroke }
  let f = if custom != none and "fill" in custom { custom.fill } else if mark != none { mark.fill } else { fill }
  let text-style = if mark != none { mark.text } else { resolved-style.value-text }
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let polygon = pts => line(..pts, close: true, fill: f, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: f, stroke: stroke)
  } else if shape == "rounded" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), radius: 25%, fill: f, stroke: stroke)
  } else if shape == "capsule" {
    rect((p.at(0) - 1.4 * r, p.at(1) - r), (p.at(0) + 1.4 * r, p.at(1) + r), radius: 50%, fill: f, stroke: stroke)
  } else if shape == "diamond" {
    polygon(((p.at(0), p.at(1) + r), (p.at(0) + r, p.at(1)), (p.at(0), p.at(1) - r), (p.at(0) - r, p.at(1))))
  } else if shape == "hexagon" {
    let k = 0.86 * r
    polygon((
      (p.at(0) - r, p.at(1)),
      (p.at(0) - r / 2, p.at(1) + k),
      (p.at(0) + r / 2, p.at(1) + k),
      (p.at(0) + r, p.at(1)),
      (p.at(0) + r / 2, p.at(1) - k),
      (p.at(0) - r / 2, p.at(1) - k),
    ))
  } else {
    circle(p, radius: r, fill: f, stroke: stroke)
  }
  content(p, text(..text-style)[#label], angle: rotation)
}

#let _render-subtree-triangle(subtree-node, resolved-style) = {
  let node-position = _tree-node-position(subtree-node, resolved-style)
  let triangle-scale = subtree-node.tscale
  let half-width = resolved-style.tri-w / 2 * triangle-scale
  let triangle-height = resolved-style.tri-h * triangle-scale
  let fill-tint = subtree-node.fill
  let stroke = if fill-tint == none {
    resolved-style.node-stroke
  } else {
    1pt + fill-tint
  }
  let text-fill = if fill-tint == none { black } else { fill-tint }
  let text-style = resolved-style.value-text + (fill: text-fill)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  line(
    node-position,
    (
      node-position.at(0) - half-width,
      node-position.at(1) - triangle-height,
    ),
    (
      node-position.at(0) + half-width,
      node-position.at(1) - triangle-height,
    ),
    close: true,
    stroke: stroke,
  )
  content(
    (
      node-position.at(0),
      node-position.at(1) - triangle-height * 0.62,
    ),
    text(..text-style, subtree-node.label),
    angle: rotation,
  )
  if subtree-node.h-label != none {
    let bracket-x = node-position.at(0) - half-width - 0.32
    line(
      (bracket-x, node-position.at(1)),
      (bracket-x, node-position.at(1) - triangle-height),
      stroke: stroke,
      mark: (start: ">", end: ">"),
    )
    content(
      (
        bracket-x - 0.3,
        node-position.at(1) - triangle-height / 2,
      ),
      text(..text-style, subtree-node.h-label),
      angle: rotation,
    )
  }
}

#let _render-tree-nodes(tree-node, resolved-style, marks, node-customizations, node-labels) = {
  if tree-node == none { return }
  if tree-node.kind == "subtree" {
    _render-subtree-triangle(tree-node, resolved-style)
    return
  }
  for child-node in _visible-tree-children(tree-node) {
    _render-tree-nodes(
      child-node,
      resolved-style,
      marks,
      node-customizations,
      node-labels,
    )
  }
  let node-key = tree-node.at("key", default: none)
  let fill-tint = tree-node.at("fill", default: none)
  let display-label = tree-node.at("label", default: none)
  if display-label == none { display-label = str(node-key) }
  let node-id = _tree-node-id(tree-node)
  let node-customization = _resolve-tree-node-customization(
    node-customizations,
    node-id,
  )
  // A hand-composed node(fill:) tint takes priority over an operation
  // highlight; generated bst/avl nodes never set `.fill`, so the two never
  // actually collide.
  if fill-tint != none {
    _render-tree-node-shape(
      _tree-node-position(tree-node, resolved-style),
      display-label,
      resolved-style,
      fill-tint,
      custom: node-customization,
    )
  } else {
    let mark-kind = if node-key == none {
      none
    } else {
      marks.at(str(node-key), default: none)
    }
    let mark-style = if mark-kind != none {
      resolve-mark-style(
        resolved-style,
        mark-kind,
        base-fill: resolved-style.node-fill,
      )
    } else {
      none
    }
    _render-tree-node-shape(
      _tree-node-position(tree-node, resolved-style),
      display-label,
      resolved-style,
      resolved-style.node-fill,
      mark: mark-style,
      custom: node-customization,
    )
  }
  let node-boundary = (
    _resolve-node-shape(resolved-style, custom: node-customization),
    _resolve-node-radius(resolved-style, custom: node-customization),
  )
  _render-tree-node-label(
    _tree-node-position(tree-node, resolved-style),
    node-boundary,
    resolved-style,
    _resolve-tree-node-label(resolved-style, node-labels, node-id),
  )
}

// `marks` maps `str(key)` to a highlight kind ("new"/"path"/"remove"/"rotate"),
// resolved against `resolved-style`'s `<kind>-style` via `mark-style` at draw time — so a
// per-call `style:` override actually reaches the mark, not just the theme
// default.
#let _render-tree(root, marks: (:), resolved-style: theme, edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  if root == none { return scaled(resolved-style, cetz.canvas({ circle((0, 0), radius: 0.01, stroke: none) })) }
  let (placed, _) = _calculate-tree-layout(root, 0, 0)
  scaled(resolved-style, cetz.canvas({
    _render-tree-edges(placed, resolved-style, edge-customizations, node-customizations)
    _render-tree-nodes(placed, resolved-style, marks, node-customizations, node-labels)
  }))
}

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

// ── Composable operation views ───────────────────────────────────────────────

#let op-arrow(label, symbol: $arrow.r$, style: (:)) = align(horizon)[
  #validate-style("op-arrow()", style)
  #let resolved-style = resolve(style)
  #set align(center)
  #if label != none [
    #text(..resolved-style.operation-text, label) \
  ]
  #text(size: 1.3em, symbol)
]

// Before → arrow → after row shared by `transition` and operation steps.
#let trans-view(before, label, after, style: (:)) = stack(
  dir: ltr,
  spacing: 1.2em,
  align(horizon, before),
  op-arrow(label, style: style),
  align(horizon, after),
)

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
