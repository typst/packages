#let _zero-point = (x: 0pt, y: 0pt)
#let _space-content-func = content.func(text[ ])
#let _styled-content-func = content.func(text(fill: black)[x])
#let _sequence-content-func = content.func([x#linebreak()y])

/// Builds a label content element from a tree label primitive.
///
/// - label-primitive (dictionary): Label primitive metadata.
/// -> content
#let _build-tree-label-content(label-primitive) = {
  let label-content = text(
    size: label-primitive.text-size,
    ..if label-primitive.text-fill != none {
      (fill: label-primitive.text-fill)
    },
    style: label-primitive.text-style,
    // Tree labels must include their full vertical text extents so fit and
    // collision checks see the same inked box that gets rendered.
    top-edge: "ascender",
    bottom-edge: "descender",
  )[#label-primitive.label-body]
  label-content
}

/// Returns whether a raw tree label body should keep text-metric placement.
///
/// Labels are classified before `_build-tree-label-content(...)` wraps them in
/// `text(...)`, so the decision reflects the original user-provided content.
///
/// - label-body (str, content, none): Raw hydrated label body.
/// -> bool
#let _tree-label-body-is-text-like(label-body) = {
  if label-body == none {
    return false
  }
  if type(label-body) == str {
    return true
  }
  if type(label-body) != content {
    return false
  }

  let func = content.func(label-body)
  if (
    func == text
      or func == raw
      or func == _space-content-func
      or func == linebreak
  ) {
    return true
  }
  if (
    func == emph
      or func == strong
      or func == highlight
      or func == underline
      or func == overline
      or func == strike
      or func == link
      or func == smallcaps
      or func == sub
      or func == super
  ) {
    return _tree-label-body-is-text-like(label-body.at("body", default: none))
  }
  if func == _styled-content-func {
    return _tree-label-body-is-text-like(label-body.at("child", default: none))
  }
  if func == _sequence-content-func {
    let children = label-body.at("children", default: ())
    return children.all(child => _tree-label-body-is-text-like(child))
  }

  false
}

/// Returns the horizontal and vertical gaps for one rectangular internal label.
///
/// Text-like internal labels keep a tighter vertical text gap. Content
/// internal labels use the larger gap on both axes so shapes do not look
/// vertically cramped.
///
/// - label-body-is-text-like (bool): Whether the raw hydrated label body should
///   keep text-metric placement.
/// - style (dictionary): Tree style record.
/// -> dictionary with `x-gap` and `y-gap`
#let _tree-rectangular-internal-label-gaps(label-body-is-text-like, style) = {
  if label-body-is-text-like {
    (
      x-gap: style.label-gap,
      y-gap: style.internal-text-y-gap,
    )
  } else {
    let uniform-gap = calc.max(
      style.label-gap,
      style.internal-text-y-gap,
    )
    (
      x-gap: uniform-gap,
      y-gap: uniform-gap,
    )
  }
}

/// Builds one label primitive with explicit geometry metadata.
///
/// - placement-role (str): Semantic label role.
/// - anchor-tree (dictionary): Tree-space anchor point.
/// - x-align (str): Horizontal box alignment.
/// - y-align (str): Vertical box alignment.
/// - x-gap (length): Horizontal gap in the active placement frame.
/// - y-gap (length): Vertical gap in the active placement frame.
/// - rotation (angle): Final label rotation.
/// - label-body (str, content): Label content.
/// - text-size (length): Label size.
/// - text-fill (color, none): Label fill.
/// - text-style (str): Label style.
/// - label-body-is-text-like (bool, auto): Cached text-like classification for
///   the raw hydrated label body.
/// - placement-frame (str): Either "screen" or "local".
/// - branch-angle-half-turn (float, none): Raw tip direction for radial labels.
/// - placement-angle-half-turn (float, none): Geometry direction used to place
///   horizontal screen-frame labels that should track global layout rotation.
/// -> dictionary
#let _tree-label-primitive(
  placement-role,
  anchor-tree,
  x-align,
  y-align,
  x-gap,
  y-gap,
  rotation,
  label-body,
  text-size,
  text-fill,
  text-style,
  label-body-is-text-like: auto,
  placement-frame: "screen",
  branch-angle-half-turn: none,
  placement-angle-half-turn: none,
) = {
  let resolved-label-body-is-text-like = if label-body-is-text-like == auto {
    _tree-label-body-is-text-like(label-body)
  } else {
    label-body-is-text-like
  }
  (
    kind: "label",
    placement-role: placement-role,
    anchor-tree: anchor-tree,
    anchor-page: _zero-point,
    x-align: x-align,
    y-align: y-align,
    x-gap: x-gap,
    y-gap: y-gap,
    rotation: rotation,
    placement-frame: placement-frame,
    branch-angle-half-turn: branch-angle-half-turn,
    placement-angle-half-turn: placement-angle-half-turn,
    label-body: label-body,
    label-body-is-text-like: resolved-label-body-is-text-like,
    text-size: text-size,
    text-fill: text-fill,
    text-style: text-style,
  )
}

/// Returns the upright radial tip-label placement for a branch direction.
///
/// - branch-angle-half-turn (float): Raw branch angle in half-turn units.
/// -> dictionary with `rotation`, `x-align`, `y-align`, `gap-sign`,
///   and `branch-angle-half-turn`
#let _radial-tip-label-placement(branch-angle-half-turn) = {
  let raw-angle-half-turn = calc.rem-euclid(branch-angle-half-turn, 2.0)
  let left-facing = raw-angle-half-turn >= 0.5 and raw-angle-half-turn <= 1.5
  (
    rotation: if left-facing {
      calc.rem-euclid(raw-angle-half-turn + 1.0, 2.0) * 180deg
    } else {
      raw-angle-half-turn * 180deg
    },
    x-align: if left-facing { "right" } else { "left" },
    y-align: "center",
    gap-sign: if left-facing { -1 } else { 1 },
    branch-angle-half-turn: raw-angle-half-turn,
  )
}

/// Returns the screen-frame placement for a horizontal label direction.
///
/// - direction-angle-half-turn (float): Placement direction in half-turn units.
/// -> dictionary with `x-align`, `y-align`, and `placement-angle-half-turn`
#let _horizontal-label-placement(direction-angle-half-turn) = {
  let placement-angle-half-turn = calc.rem-euclid(
    direction-angle-half-turn,
    2.0,
  )
  let theta = placement-angle-half-turn * 180deg
  let dx = calc.cos(theta)
  let dy = calc.sin(theta)
  (
    x-align: if dx >= 0.0 { "left" } else { "right" },
    y-align: if dy < 0.0 { "bottom" } else { "top" },
    placement-angle-half-turn: placement-angle-half-turn,
  )
}

/// Returns the preferred internal-label placement for one unrooted node.
///
/// - nodes (array): Node table in id order.
/// - node (dictionary): Internal node record.
/// -> dictionary with `x-align`, `y-align`, and `placement-angle-half-turn`
#let _unrooted-internal-label-placement(nodes, node) = {
  let incident-angles = ()
  if not node.is-root {
    incident-angles.push(calc.rem-euclid(node.branch-angle + 1.0, 2.0))
  }
  for child-id in node.children-ids {
    let child = nodes.at(child-id)
    incident-angles.push(calc.rem-euclid(child.branch-angle, 2.0))
  }

  if incident-angles.len() == 0 {
    return _horizontal-label-placement(0.25)
  }
  if incident-angles.len() == 1 {
    return _horizontal-label-placement(incident-angles.first() + 1.0)
  }

  let sorted-angles = incident-angles.sorted()
  let best-gap = -1.0
  let best-midpoint = 0.25
  let best-dx = -float.inf
  let best-dy = float.inf

  for index in range(sorted-angles.len()) {
    let start = sorted-angles.at(index)
    let end = if index + 1 == sorted-angles.len() {
      sorted-angles.first() + 2.0
    } else {
      sorted-angles.at(index + 1)
    }
    let gap = end - start
    let midpoint = calc.rem-euclid(start + gap / 2.0, 2.0)
    let theta = midpoint * 180deg
    let dx = calc.cos(theta)
    let dy = calc.sin(theta)
    let gap-better = gap > best-gap + 1e-9
    let tie-break-better = (
      calc.abs(gap - best-gap) <= 1e-9
        and (
          dx > best-dx + 1e-9
            or (calc.abs(dx - best-dx) <= 1e-9 and dy < best-dy - 1e-9)
        )
    )

    if gap-better or tie-break-better {
      best-gap = gap
      best-midpoint = midpoint
      best-dx = dx
      best-dy = dy
    }
  }

  _horizontal-label-placement(best-midpoint)
}

/// Builds explicit tree primitives from a laid-out normalized tree.
///
/// - layout-tree (dictionary): Backend-prepared normalized tree layout.
/// - style (dictionary): Tree style record.
/// - orientation (str): Tree orientation.
/// -> dictionary
#let _build-tree-plan(layout-tree, style, orientation: "horizontal") = {
  let primitives = ()
  let nodes = layout-tree.nodes
  let root = nodes.at(layout-tree.root-id)
  let rectangular = layout-tree.primitive-mode == "rectangular"
  let tip-label-style = if style.tip-label-italics { "italic" } else {
    "normal"
  }

  if rectangular and root.input-rooted {
    primitives.push((
      kind: "line",
      stroke: style.branch-stroke,
      stroke-thickness: style.branch-width,
      start-anchor: (
        tree: (x: root.x-unit, y: root.y-unit),
        page: (x: -style.root-length, y: 0pt),
      ),
      end-anchor: (
        tree: (x: root.x-unit, y: root.y-unit),
        page: _zero-point,
      ),
    ))
  }

  for id in range(layout-tree.node-count) {
    let node = nodes.at(id)
    let node-point = (x: node.x-unit, y: node.y-unit)

    if not node.is-root {
      let parent = nodes.at(node.parent-id)
      primitives.push((
        kind: "line",
        stroke: style.branch-stroke,
        stroke-thickness: style.branch-width,
        start-anchor: if rectangular {
          (
            tree: (x: parent.x-unit, y: node.y-unit),
            page: _zero-point,
          )
        } else {
          (
            tree: (x: parent.x-unit, y: parent.y-unit),
            page: _zero-point,
          )
        },
        end-anchor: (tree: node-point, page: _zero-point),
      ))
    }

    if node.is-leaf {
      if node.label-body != none {
        if rectangular {
          let cross-offset = style.tip-label-metrics.branch-midpoint
          primitives.push(_tree-label-primitive(
            "tip-label",
            node-point,
            "left",
            if orientation == "vertical" { "bottom" } else { "top" },
            if orientation == "vertical" {
              -cross-offset
            } else {
              style.label-gap
            },
            if orientation == "vertical" {
              style.label-gap
            } else {
              -cross-offset
            },
            if orientation == "vertical" { -90deg } else { 0deg },
            node.label-body,
            style.tip-label-size,
            style.tip-label-color,
            tip-label-style,
          ))
        } else {
          let radial-placement = _radial-tip-label-placement(node.branch-angle)
          let tip-metrics = style.tip-label-metrics
          let local-y-gap = (
            tip-metrics.full-height / 2 - tip-metrics.branch-midpoint
          )
          primitives.push(_tree-label-primitive(
            "tip-label",
            node-point,
            radial-placement.x-align,
            radial-placement.y-align,
            style.label-gap * radial-placement.gap-sign,
            local-y-gap,
            radial-placement.rotation,
            node.label-body,
            style.tip-label-size,
            style.tip-label-color,
            tip-label-style,
            placement-frame: "local",
            branch-angle-half-turn: radial-placement.branch-angle-half-turn,
          ))
        }
      }
    } else if rectangular {
      let first-child = nodes.at(node.children-ids.first())
      let last-child = nodes.at(node.children-ids.last())
      primitives.push((
        kind: "line",
        stroke: style.branch-stroke,
        stroke-thickness: style.branch-width,
        start-anchor: (
          tree: (x: node.x-unit, y: first-child.y-unit),
          page: _zero-point,
        ),
        end-anchor: (
          tree: (x: node.x-unit, y: last-child.y-unit),
          page: _zero-point,
        ),
      ))

      if node.label-body != none {
        let label-body-is-text-like = _tree-label-body-is-text-like(
          node.label-body,
        )
        let internal-label-gaps = _tree-rectangular-internal-label-gaps(
          label-body-is-text-like,
          style,
        )
        primitives.push(_tree-label-primitive(
          "internal-label",
          node-point,
          if orientation == "vertical" { "left" } else { "right" },
          if orientation == "vertical" { "top" } else { "bottom" },
          internal-label-gaps.x-gap,
          internal-label-gaps.y-gap,
          0deg,
          node.label-body,
          style.internal-label-size,
          style.internal-label-color,
          "normal",
          label-body-is-text-like: label-body-is-text-like,
        ))
      }
    } else if node.label-body != none {
      let internal-placement = _unrooted-internal-label-placement(nodes, node)
      primitives.push(_tree-label-primitive(
        "internal-label",
        node-point,
        internal-placement.x-align,
        internal-placement.y-align,
        style.label-gap,
        style.label-gap,
        0deg,
        node.label-body,
        style.internal-label-size,
        style.internal-label-color,
        "normal",
        placement-angle-half-turn: internal-placement.placement-angle-half-turn,
      ))
    }
  }

  layout-tree.insert("tree-primitives", primitives)
  layout-tree
}
