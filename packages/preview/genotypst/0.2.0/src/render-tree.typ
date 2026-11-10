#import "constants.typ": _medium-gray

/// Tree layout constants.
#let _label-x-offset = 0.3em
#let _auto-height-scale = 1.25em

/// Safely gets node length with a default.
///
/// - node (dictionary): Tree node.
/// - default (float): Default branch length.
/// -> float
#let _node-length(node, default: 0.0) = {
  if node.length != none { node.length } else { default }
}

/// Collects all tip names from a tree.
///
/// - node (dictionary): Tree node.
/// -> array
#let _collect-tip-names(node) = {
  if node.children == none or node.children.len() == 0 {
    if node.name != none { (node.name,) } else { () }
  } else {
    node.children.map(c => _collect-tip-names(c)).flatten()
  }
}

/// Calculates the Y position for a child node.
///
/// - child (dictionary): Child node with offsets.
/// - y-offset (float): Base Y offset.
/// - y-scale (float): Scale factor.
/// -> float
#let _child-y-pos(child, y-offset, y-scale) = {
  y-offset + (child.y-offset + child.child.y-local) * y-scale
}

/// Recursively measures tree dimensions and computes node positions.
///
/// - tree (dictionary): Tree node.
/// -> dictionary
#let _measure-tree(tree) = {
  if tree.children == none or tree.children.len() == 0 {
    // Leaf node
    let len = _node-length(tree, default: 1.0)
    (
      height: 1.0,
      depth: len,
      tree: (
        name: tree.name,
        length: tree.length,
        is-leaf: true,
        children: (),
        y-local: 0.5,
        x-len: len,
      ),
    )
  } else {
    // Internal node: recursively process children
    let processed-children = ()
    let (current-y, max-depth) = (0.0, 0.0)

    for child in tree.children {
      let m = _measure-tree(child)
      processed-children.push((child: m.tree, y-offset: current-y))
      current-y += m.height
      max-depth = calc.max(max-depth, m.depth)
    }

    // Center this node vertically between its first and last child
    let first = processed-children.first()
    let last = processed-children.last()
    let y-center = (first.y-offset + first.child.y-local + last.y-offset + last.child.y-local) / 2.0
    let my-len = _node-length(tree)

    (
      height: current-y,
      depth: max-depth + my-len,
      tree: (
        name: tree.name,
        length: tree.length,
        is-leaf: false,
        children: processed-children,
        y-local: y-center,
        x-len: my-len,
      ),
    )
  }
}

/// Recursively draws a node and its children as positioned shapes.
///
/// Returns a dictionary with `branches` (lines) and `labels` (text) arrays.
///
/// - node (dictionary): Tree node with layout data.
/// - x-offset (float): Base x-offset.
/// - y-offset (float): Base y-offset.
/// - x-scale (float): Horizontal scale factor.
/// - y-scale (float): Vertical scale factor.
/// - style (dictionary): Style configuration.
/// -> dictionary
#let _draw-node(node, x-offset, y-offset, x-scale, y-scale, style) = {
  let branches = ()
  let labels = ()

  // Calculate this node's position
  let len = _node-length(node)
  let my-x = x-offset + len * x-scale
  let my-y = y-offset + node.y-local * y-scale

  // Draw horizontal branch to this node (except for root)
  if not style.is-root and len > 0.0 {
    branches.push(place(top + left, line(start: (x-offset, my-y), end: (my-x, my-y), stroke: style.stroke)))
  }

  // Draw dotted root branch if this is the root node
  if style.is-root {
    let root-stroke = stroke(
      thickness: style.branch-weight,
      paint: style.branch-color,
      dash: "dotted",
      cap: "round",
    )
    branches.push(place(
      top + left,
      line(start: (my-x - style.root-length, my-y), end: (my-x, my-y), stroke: root-stroke),
    ))
  }

  if node.is-leaf {
    // Draw tip label
    labels.push(place(
      top + left,
      dx: my-x + _label-x-offset,
      dy: my-y - style.label-y-offset,
    )[#text(
      size: style.tip-label-size,
      fill: style.tip-label-color,
      style: if style.tip-label-italics { "italic" } else { "normal" },
      node.name,
    )])
  } else {
    // Draw vertical connector between children
    let first = node.children.first()
    let last = node.children.last()
    let y-top = _child-y-pos(first, y-offset, y-scale)
    let y-bottom = _child-y-pos(last, y-offset, y-scale)

    branches.push(place(top + left, line(start: (my-x, y-top), end: (my-x, y-bottom), stroke: style.stroke)))

    // Recursively render children
    for c in node.children {
      let child-style = style
      child-style.is-root = false
      let child-result = _draw-node(
        c.child,
        my-x,
        y-offset + c.y-offset * y-scale,
        x-scale,
        y-scale,
        child-style,
      )
      branches += child-result.branches
      labels += child-result.labels
    }

    // Draw internal node label if it exists (positioned to the left of the node)
    if node.name != none and node.name != "" {
      let label-content = text(
        size: style.internal-label-size,
        fill: style.internal-label-color,
        node.name,
      )
      labels.push(context {
        let label-size = measure(label-content)
        if style.is-vertical {
          // For vertical trees, rotate label 90deg so it appears horizontal after tree rotation
          // Position below and to the left of the node
          place(
            top + left,
            dx: my-x - 0.35em,
            dy: my-y + _label-x-offset,
            rotate(90deg, origin: top + left, label-content),
          )
        } else {
          // For horizontal trees, position label above and to the left of the node
          place(
            top + left,
            dx: my-x - label-size.width - _label-x-offset,
            dy: my-y - label-size.height - 0.35em,
            label-content,
          )
        }
      })
    }
  }
  (branches: branches, labels: labels)
}

/// Calculates margins for root and tip labels based on orientation.
///
/// - tree-data (dictionary): Tree data.
/// - is-vertical (bool): Whether the tree is vertical.
/// - style (dictionary): Style configuration.
/// - metrics (dictionary): Text metrics.
/// -> dictionary
#let _calculate-margins(tree-data, is-vertical, style, metrics) = {
  // tip-label-margin: space needed for the longest tip label.
  let tip-label-margin = metrics.max-tip-width + _label-x-offset

  // root-margin: space needed at the tree's root side.
  // - Horizontal trees: root is on the LEFT. Label is horizontal, so we need its WIDTH.
  // - Vertical trees: after -90deg rotation, root is at the BOTTOM.
  //   The label is rotated 90deg (relative to the pre-rotation layout) to appear horizontal
  //   in the final output. Thus, its extent along the pre-rotation X-axis (Depth) is its HEIGHT.
  let root-margin = if tree-data.name != none and tree-data.name != "" {
    let root-label = text(size: style.internal-label-size, tree-data.name)
    let label-size = measure(root-label)
    let margin-size = if is-vertical { label-size.height } else { label-size.width }
    margin-size + _label-x-offset + style.root-length
  } else if style.is-root {
    style.root-length
  } else {
    0pt
  }

  // y-start: vertical start offset in pre-rotation coords.
  // For vertical trees, we need extra top margin in the pre-rotation layout.
  // This "top" margin becomes the "left" margin after -90deg rotation.
  // We need this space because the tip labels (which are vertical in the final output)
  // extend into this area.
  let y-start = if is-vertical {
    style.label-y-offset + metrics.tip-label-height
  } else {
    style.label-y-offset
  }

  (root: root-margin, tip: tip-label-margin, y-start: y-start)
}

/// Resolves final box and tree dimensions, handling unit resolution and orientation swapping.
///
/// - width (length, fraction): Target width.
/// - height (length, auto): Target height.
/// - margins (dictionary): Margin data.
/// - tree-depth (float): Tree depth.
/// - tree-height (float): Tree height.
/// - is-vertical (bool): Whether the tree is vertical.
/// - layout-size (length): Layout size.
/// -> dictionary
#let _resolve-layout(width, height, margins, tree-depth, tree-height, is-vertical, layout-size) = {
  // 1. Resolve user width (including fractions)
  let resolved-width = if type(width) == fraction {
    if layout-size.width == float.inf * 1em { 30em } else { layout-size.width * (width / 1fr) }
  } else { width }

  // 2. Resolve user height (including auto)
  let resolved-height = if height == auto {
    _auto-height-scale * tree-height
  } else { height }

  // 3. Resolve Box and Tree dimensions based on orientation
  // After -90deg rotation (origin: top+left):
  // - Post-Width  = Pre-Height
  // - Post-Height = Pre-Width
  let (box-width, box-height, tree-w, tree-h) = if is-vertical {
    // Pre-rotation coords:
    // - X-axis (pre-rotation width) = Depth axis = needs root & tip margins
    // - Y-axis (pre-rotation height) = Spread axis = needs y-start margin
    let pre-width = resolved-height // becomes post-rotation height
    let pre-height = resolved-width // becomes post-rotation width
    (
      pre-width,
      pre-height,
      pre-width - margins.root - margins.tip,
      pre-height - margins.y-start,
    )
  } else {
    (
      resolved-width,
      resolved-height,
      resolved-width - margins.root - margins.tip,
      resolved-height - margins.y-start,
    )
  }

  // Map to internal drawing dimensions: x-dim is Depth, y-dim is Spread
  (
    box-width: box-width,
    box-height: box-height,
    x-dim: tree-w,
    y-dim: tree-h,
  )
}

/// Validates the tree data structure.
///
/// - node (dictionary): Tree node.
/// - is-root (bool): Whether this is the root node.
/// -> none
#let _validate-tree-data(node, is-root: true) = {
  assert(type(node) == dictionary, message: "Tree nodes must be dictionaries")
  assert("children" in node, message: "Tree nodes must define children")

  if "name" in node {
    assert(node.name == none or type(node.name) == str, message: "Node name must be a string or none")
  }

  if "length" in node {
    assert(
      node.length == none or type(node.length) == int or type(node.length) == float,
      message: "Node length must be a number or none",
    )
  }

  if is-root and "rooted" in node {
    assert(type(node.rooted) == bool, message: "rooted must be a boolean")
  }

  let children = node.children
  assert(children == none or type(children) == array, message: "children must be an array or none")
  if children != none {
    for child in children {
      _validate-tree-data(child, is-root: false)
    }
  }
}

/// Draws a phylogenetic tree from a parsed tree structure.
///
/// Renders a phylogenetic tree visualization from the parsed tree data.
/// Supports customization of dimensions, styling, and orientation.
///
/// - tree-data (dictionary): The parsed tree structure from `parse-newick`.
/// - width (length, fraction): Width of the tree visualization including labels (default: 25em).
/// - height (length, auto): Height of the tree area (default: 15em).
/// - branch-weight (length): Thickness of tree branches (default: 1pt).
/// - branch-color (color): Color of tree branches (default: black).
/// - tip-label-size (length): Font size of tip labels (default: 1em).
/// - tip-label-color (color): Color of tip labels (default: black).
/// - tip-label-italics (bool): Use italics to draw tip labels (default: false).
/// - internal-label-size (length): Font size of internal node labels (default: 0.85em).
/// - internal-label-color (color): Color of internal node labels (default: medium gray).
/// - root-length (length): Length of the dotted root branch (default: 1.25em).
/// - orientation (str): "horizontal" (root left, tips right) or "vertical" (root bottom, tips up) (default: "horizontal").
/// -> content
#let render-tree(
  tree-data,
  width: 25em,
  height: 15em,
  branch-weight: 1pt,
  branch-color: black,
  tip-label-size: 1em,
  tip-label-color: black,
  tip-label-italics: false,
  internal-label-size: 0.85em,
  internal-label-color: _medium-gray,
  root-length: 1.25em,
  orientation: "horizontal",
) = {
  assert(
    orientation in ("horizontal", "vertical"),
    message: "orientation must be 'horizontal' or 'vertical'",
  )
  _validate-tree-data(tree-data)

  let is-rooted = tree-data.at("rooted", default: false)
  let is-vertical = orientation == "vertical"

  // Bundle styling configuration
  let style = (
    stroke: stroke(thickness: branch-weight, paint: branch-color, cap: "square"),
    branch-color: branch-color,
    branch-weight: branch-weight,
    tip-label-size: tip-label-size,
    tip-label-color: tip-label-color,
    tip-label-italics: tip-label-italics,
    internal-label-size: internal-label-size,
    internal-label-color: internal-label-color,
    root-length: root-length,
    is-root: is-rooted,
    is-vertical: is-vertical,
  )

  // Initial tree measurement
  let tree = (name: tree-data.name, length: tree-data.length, children: tree-data.children)
  let measured = _measure-tree(tree)
  let tip-names = _collect-tip-names(tree-data)

  context {
    // 1. Measure font metrics and element sizes
    let x-height-text = text(size: tip-label-size, top-edge: "x-height", bottom-edge: "baseline", "x")
    let label-y-offset = measure(x-height-text).height

    let max-tip-width = 0pt
    let tip-label-height = 0pt
    for name in tip-names {
      let label = text(
        size: tip-label-size,
        style: if tip-label-italics { "italic" } else { "normal" },
        name,
      )
      let size = measure(label)
      if size.width > max-tip-width { max-tip-width = size.width }
      if size.height > tip-label-height { tip-label-height = size.height }
    }

    // 2. Prepare style with dynamic metrics
    let style = style + (label-y-offset: label-y-offset)
    let metrics = (
      max-tip-width: max-tip-width,
      tip-label-height: tip-label-height,
    )

    // 3. Calculate orientation-aware margins
    let margins = _calculate-margins(tree-data, is-vertical, style, metrics)

    layout(size => {
      // 4. Resolve layout and tree dimensions
      let layout = _resolve-layout(
        width,
        height,
        margins,
        measured.depth,
        measured.height,
        is-vertical,
        size,
      )

      let x-scale = layout.x-dim / calc.max(1e-9, measured.depth)
      let y-scale = layout.y-dim / calc.max(1e-9, measured.height)

      // 5. Render tree shapes
      let result = _draw-node(measured.tree, margins.root, margins.y-start, x-scale, y-scale, style)

      let b = box(width: layout.box-width, height: layout.box-height, {
        for s in result.branches { s }
        for s in result.labels { s }
      })

      if is-vertical {
        rotate(-90deg, origin: top + left, reflow: true, b)
      } else {
        b
      }
    })
  }
}
