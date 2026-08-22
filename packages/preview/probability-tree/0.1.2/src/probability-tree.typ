/// Probability trees n×p, growing from left to right.
///
/// This module provides [`proba-tree`] to draw a probability tree,
/// and [`sp`] / [`sn`] to finely tune a probability or a node
/// (placement, sloped, local text style…).
///
/// Each node of `data` is an array `(label, proba, ..children)`; the label
/// and the proba can be raw content (`$A$`, `$p$`) or a local setting via
/// [`sn`] / [`sp`].
///
/// Text styles — bold (`weight`), italic (`style`), small caps (`smallcaps`),
/// highlight (`highlight`), custom function (`function`) — are set globally
/// via `proba-style` / `node-style`, or locally via `sp(style:)` / `sn(style:)`.
///
/// Depends on CeTZ: `@preview/cetz:0.5.2`.
///
/// ```example
/// #proba-tree(data: (
///   [$Omega$],
///   (sn($A$, style: (fill: green)), $p$, ([$B$], $$), ([$overline(B)$], $1-q$)),
///   ([$overline(A)$], $1-p$, ([$B$], $q$), ([$overline(B)$], $1-q$)),
/// ))
/// ```

#import "@preview/cetz:0.5.2": canvas, coordinate, draw, tree, process

// --- Placement vocabulary (identifiers, not free strings) ---
#let above = "above"
#let below = "below"
#let on = "on"
#let hybrid = "hybrid" // above if the branch rises, below if it descends

/// Locally sets a probability: value and display options.
///
/// Used as the proba of a node in `data`, e.g.
/// `([$A$], sp($p$, style: (weight: "bold")), ([$B$], $q$))`. Any omitted
/// parameter falls back to the global settings of [`proba-tree`].
///
/// ```example
/// #proba-tree(data: (
///   [$Omega$],
///   (sn($A$, style: (fill: green)), sp($p$, style: (fill: red, weight: "bold")), ([$B$], $1$)),
///   ([$overline(A)$], $1-p$, ),
/// ))
/// ```
///
/// -> dictionary
#let sp(
  /// The displayed probability (e.g. `$p$`, `1-p`).
  /// -> content
  content,

  /// Placement: `above`, `below`, `on` or `hybrid`.
  /// -> string
  position: auto,

  /// Aligns the probability along the edge (« sloped »).
  /// -> bool
  sloped: auto,

  /// Distance of the label from the edge.
  /// -> number
  distance: auto,

  /// Local style applied via `#text`, merged with `proba-style`.
  ///
  /// Keys: `size`, `fill`, `weight`, `style`, `smallcaps`, `highlight`,
  ///
  /// `function` + all `#text` parameters.
  /// -> dictionary
  style: auto,
) = (
  proba: content,
  position: position,
  sloped: sloped,
  distance: distance,
  style: style,
)

/// Locally sets a node: text and style.
///
/// Used as the label of a node in `data`, e.g.
/// `(sn($A$, style: (fill: green)), $p$, ...)`. Any omitted parameter falls
/// back to the global settings of [`proba-tree`].
///
/// ```example
/// #proba-tree(data: (
///   [$Omega$],
///   (sn($A$, style: (fill: green, weight: "bold")), $p$, ([$B$], $1$)),
///   ([$overline(A)$], $1-p$),
/// ))
/// ```
///
/// -> dictionary
#let sn(
  /// The node text (e.g. `$A$`, `[A]`, `"A"`).
  /// -> content
  content,

  /// Local style applied via `#text`, merged with `node-style`.
  ///
  /// Keys: `size`, `fill`, `weight`, `style`, `smallcaps`, `highlight`,
  /// `function` + all `#text` parameters.
  /// -> dictionary
  style: auto,
) = (
  label: content,
  style: style,
)

// --- Default tree: Ω root, A/Ā (p/1-p), B/B̄ (q/1-q) ---
#let default-tree = (
  [$Omega$],
  ([$A$], $p$, ([$B$], $q$), ([$overline(B)$], $1-q$)),
  ([$overline(A)$], $1-p$, ([$B$], $q$), ([$overline(B)$], $1-q$)),
)

// --- Merge of the global style with a local style ---
// Local keys override global ones; the others are kept.
#let merge-style(global, local) = {
  if local == none or local == auto {
    global
  } else if global == none {
    local
  } else {
    (:..global, ..local)
  }
}

// --- Normalization of a "proba" slot: raw content or result of sp() ---
#let normalize-proba(slot, default-position, default-distance, default-sloped) = {
  if type(slot) == dictionary {
    (
      proba: slot.proba,
      position: if slot.position == auto { default-position } else { slot.position },
      distance: if slot.distance == auto { default-distance } else { slot.distance },
      sloped: if slot.sloped == auto { default-sloped } else { slot.sloped },
      style: slot.style, // brut, sera mergé une seule fois dans draw-edge
    )
  } else {
    (
      proba: slot,
      position: default-position,
      distance: default-distance,
      sloped: default-sloped,
      style: none, // aucun style local -> merge-style gérera le none proprement
    )
  }
}

// --- Normalization of a node label: raw content or result of sn() ---
#let normalize-node(slot, default-style) = {
  if type(slot) == dictionary {
    (
      label: slot.label,
      style: merge-style(default-style, slot.style),
    )
  } else {
    (label: slot, style: default-style)
  }
}

// --- Recursive conversion of our (label, proba, ..children) tuple
//     to the tuple expected by cetz.tree, keeping the proba metadata
//     in the node "content" so that draw-edge can read them.
#let convert-node(
  node,
  is-root: false,
  default-position,
  default-distance,
  default-sloped,
  default-style,
  default-node-style,
  reverse-children,
  path: "root", // <- nouveau paramètre
  level: 0,
) = {
  let label-info = normalize-node(node.at(0), default-node-style)
  let rest = node.slice(1)
  
  let proba-info = none
  let raw-children = rest
  
  if not is-root {
    assert(
      rest.len() >= 1,
      message: "proba-tree: non root node without probability — the expected format is (label, proba, ..children). Node received : "
        + repr(node),
    )
    proba-info = normalize-proba(rest.at(0), default-position, default-distance, default-sloped)
    raw-children = rest.slice(1)
  }
  
  let node-content = (
    label: label-info.label,
    proba: proba-info,
    style: label-info.style,
    path: path,
    level: level + 1, // 1-indexé, racine = niveau 1
  )

  let ordered-children = if reverse-children {
    raw-children.rev()
  } else {
    raw-children
  }
  
  // enumerate() pour avoir l'index i et construire le chemin
  let converted-children = ordered-children
    .enumerate()
    .map(((i, e)) => convert-node(
      e,
      is-root: false,
      default-position,
      default-distance,
      default-sloped,
      default-style,
      default-node-style,
      reverse-children,
      path: path + "-" + str(i),
      level: level + 1,
    ))
  
  if converted-children.len() == 0 {
    node-content
  } else {
    (node-content, ..converted-children)
  }
}

// --- Real position of a node on the canvas ---
// Left-to-right growth (standard for probability trees): cetz.tree
// transforms the raw layout coordinates (x, y) into (y, x) on screen.
#let node-position(node) = (node.y, node.x)

// --- Application of a style (dictionary of #text parameters) to content ---
// Supported keys: all #text parameters (weight, style, size, fill,
// background, …) + special keys: `smallcaps` (bool -> smcp), `highlight`
// (color -> background box) and `function` (content -> content function,
// applied last).
#let apply-style(style, content) = {
  if style == none {
    content
  } else {
    // Mutable working copy (insert/remove act in place)
    let style = (:..style)
    // A `size` ratio (e.g. 80%) is converted to a relative length (0.8em)
    let _ = if "size" in style and type(style.size) == ratio {
      style.insert("size", style.size * 1em)
    }
    // Small caps: not a #text parameter -> OpenType smcp feature
    let small-caps = style.at("smallcaps", default: false)
    let _ = if "smallcaps" in style { style.remove("smallcaps") }
    let _ = if small-caps {
      let f = (..style.at("features", default: (:)), smcp: 1)
      style.insert("features", f)
    }
    // Highlight: special key removed from the #text style
    let highlight = style.at("highlight", default: none)
    let _ = if "highlight" in style { style.remove("highlight") }
    // Custom function (content -> content), applied last
    let function = style.at("function", default: none)
    let _ = if "function" in style { style.remove("function") }
    // Application
    let content = text(..style)[#content]
    let content = if highlight == none {
      content
    } else {
      // `#highlight` renders NO background with equations (math). We thus
      // cover the whole real frame of the content (`bounds` on both sides,
      // which also captures tall math) and align the box baseline on the
      // horizon to avoid shifting the text.
      box(baseline: horizon, fill: highlight, inset: 2pt, radius: 1.5pt)[
        #text(top-edge: "bounds", bottom-edge: "bounds")[
          #content
        ]
      ]
    }
    if function == none { content } else { function(content) }
  }
}

// --- Intersection of two segments (a,b) and (c,d), if any ---
// Returns the intersection point or `none` (parallel or disjoint).
#let segment-intersection(a, b, c, d) = {
  let (ax, ay) = a
  let (bx, by) = b
  let (cx, cy) = c
  let (dx, dy) = d
  let rx = bx - ax
  let ry = by - ay
  let sx = dx - cx
  let sy = dy - cy
  let denom = rx * sy - ry * sx
  if calc.abs(denom) < 1e-9 { return none }
  let qx = cx - ax
  let qy = cy - ay
  let t = (qx * sy - qy * sx) / denom
  let u = (qx * ry - qy * rx) / denom
  if t < 0 or t > 1 or u < 0 or u > 1 { return none }
  (ax + t * rx, ay + t * ry)
}

// --- Rendering of an edge: edge shortened at both ends (node-padding)
//     to leave a gap around node letters -- no colored background needed,
//     the edge is simply never drawn there.
//     The probability label is placed at the real geometric middle of the
//     segment, offset perpendicularly for above/below/hybrid, possibly
//     aligned along the edge (sloped).
//     In "on" position, the edge is not drawn under the label: it is cut
//     into two segments, collinear to (p1,p2), at the intersections of the
//     line with the real bbox of the proba (rotation included) -- no
//     background, transparency preserved.
#let draw-edge(from, to, node-padding, proba-style, proba-padding) = {
  import draw: *

  let info = to.content.proba
  let distance = if info.distance == auto { 0.35 } else { info.distance }

  // Real positions on the canvas (left-to-right growth)
  let (from-x, from-y) = node-position(from)
  let (to-x, to-y) = node-position(to)

  let dx = to-x - from-x
  let dy = to-y - from-y
  let dist = calc.sqrt(dx * dx + dy * dy)
  let ux = dx / dist
  let uy = dy / dist

  // Shortened anchor points
  let p1 = (from-x + ux * node-padding, from-y + uy * node-padding)
  let p2 = (to-x - ux * node-padding, to-y - uy * node-padding)

  // Real geometric middle (independent of node-padding, hence stable)
  let mx = (from-x + to-x) / 2
  let my = (from-y + to-y) / 2

  // Unit normal to the edge, for the perpendicular offset
  let nx = -uy
  let ny = ux

  let effective-position = if info.position == hybrid {
    if dy > 0 { above } else { below }
  } else {
    info.position
  }

  // Effective style: global (proba-style) + local sp(style:) merged
  let effective-style = merge-style(proba-style, info.style)
  let rendered-proba = apply-style(effective-style, info.proba)

  // "sloped": proba aligned along the edge, same direction
  // calc.atan2(x, y) directly returns the angle in degrees
  let angle = if info.sloped {
    calc.atan2(dx, dy)
  } else {
    0deg
  }

  if effective-position == on {
    // "on": the proba lies on the edge, which is not drawn underneath.
    // We place the (named) label, read its real bbox (4 corners,
    // rotation included) and cut the edge at the intersections of the
    // line (p1,p2) with that bbox: both segments stay collinear to
    // (p1,p2) -- no change of direction. No background, so transparency
    // is preserved.
    let name = "proba-" + to.content.path
    // proba-padding: transparent CeTZ padding that enlarges the bbox
    // (hence the nw/ne/sw/se anchors) in all directions -> gap between
    // the cut edge and the proba. No background.
    content((mx, my), rendered-proba, angle: angle, name: name, padding: proba-padding)
    get-ctx(ctx => {
      let (_, nw) = coordinate.resolve(ctx, name + ".north-west")
      let (_, ne) = coordinate.resolve(ctx, name + ".north-east")
      let (_, sw) = coordinate.resolve(ctx, name + ".south-west")
      let (_, se) = coordinate.resolve(ctx, name + ".south-east")
      let corners = (
        (nw.at(0), nw.at(1)),
        (ne.at(0), ne.at(1)),
        (se.at(0), se.at(1)),
        (sw.at(0), sw.at(1)),
      )
      let pts = ()
      for i in range(0, 4) {
        let p = segment-intersection(p1, p2, corners.at(i), corners.at(calc.rem(i + 1, 4)))
        if p != none { pts.push(p) }
      }
      // Deduplication: if the line passes exactly through a corner, we can
      // get two identical intersections on two adjacent sides.
      let unique-pts = ()
      for p in pts {
        let duplicate = unique-pts.any(q => {
          calc.abs(q.at(0) - p.at(0)) < 1e-6 and calc.abs(q.at(1) - p.at(1)) < 1e-6
        })
        if not duplicate { unique-pts.push(p) }
      }
      if unique-pts.len() >= 2 {
        let sorted-pts = unique-pts.sorted(key: pt => {
          let ex = pt.at(0) - p1.at(0)
          let ey = pt.at(1) - p1.at(1)
          ex * ex + ey * ey
        })
        line(p1, sorted-pts.at(0))
        line(sorted-pts.at(sorted-pts.len() - 1), p2)
      } else {
        line(p1, p2)
      }
    })
  } else {
    line(p1, p2)
    // Label position (offset perpendicular to the edge)
    let sign = if effective-position == below { -1 } else { 1 }
    let px = mx + sign * nx * distance
    let py = my + sign * ny * distance
    content((px, py), rendered-proba, angle: angle)
  }
}

// --- Compute the exact canvas position of each node ---
// Replicates cetz.tree's measurement + layout so that the returned
// positions match EXACTLY where the tree nodes are rendered. The result is
// a dictionary `N<level><index>` -> `(x, y)` in canvas units.
#let compute-node-positions(ctx, structure, grow, spread) = {
  // Replicate cetz.tree's build-node: render each node label to measure it.
  let build-node(tree, depth: 0, sibling: 0) = {
    let children = ()
    let content = none
    if type(tree) == array {
      children = tree.slice(1).enumerate().map(((n, c)) => build-node(c, depth: depth + 1, sibling: n))
      content = tree.at(0)
    } else {
      content = tree
    }
    let node = (height: 0.0, width: 0.0, n: sibling, depth: depth, children: children, content: content)
    let (ctx: _, drawables: _, bounds) = process.many(ctx, {
      draw.set-origin((0, 0))
      draw.content((0, 0), apply-style(node.content.style, node.content.label))
    })
    if bounds != none {
      (node.width, node.height, ..) = (
        bounds.high.at(0) - bounds.low.at(0),
        bounds.high.at(1) - bounds.low.at(1),
      )
    }
    node
  }
  let root = build-node(structure)
  let laid = tree.layout-node(root, float(grow), float(spread))
  // Typst passes dicts by value to function params, so we thread the
  // accumulated dicts through the recursion by returning them. The index is
  // global per level (depth-first order = visual top-to-bottom order).
  let rec(node, positions, counts) = {
    let lvl = str(node.content.level)
    let idx = counts.at(lvl, default: 0) + 1
    counts.insert(lvl, idx)
    positions.insert("N" + lvl + str(idx), (node.y, node.x))
    // cetz.tree lays children out bottom-to-top in the node array, so we
    // iterate in reverse to number them top-to-bottom (visual order).
    for child in node.children.rev() {
      (positions, counts) = rec(child, positions, counts)
    }
    (positions, counts)
  }
  let (positions, _) = rec(laid, (:), (:))
  positions
}

/// Draws a probability tree, growing from left to right.
///
/// Each node of `data` is an array `(label, proba, ..children)`; the label
/// and the proba can be raw content (`$A$`, `$p$`) or a local setting via
/// [`sn`] / [`sp`].
///
/// ```example
/// #proba-tree(data: (
///   [$Omega$],
///   (sn($A$, style: (fill: green)), sp($p$, style: (fill: green)), ([$B$], sp($1$, position: "above"))),
///   ([$overline(A)$], $1-p$, ([$B$], $q$), ([$overline(B)$], $1-q$)),
/// ))
/// ```
///
/// ```example
/// #proba-tree(proba-position: "on", proba-padding: 5pt)
/// ```
///
/// -> content
#let proba-tree(
  /// Horizontal extension of the edges (default: 2).
  /// -> float
  h: 2.0,

  /// Vertical spread between branches (default: 0.8).
  /// -> float
  v: 0.8,

  /// Placement of the probabilities: `above`, `below`, `on` or `hybrid` (default: `hybrid`).
  /// -> string
  proba-position: hybrid,

  /// Distance of the label from the edge (default: 0.35).
  /// -> float
  proba-distance: 0.3,

  /// Aligns the probabilities along the edge, « sloped » (default: `false`).
  /// -> bool
  proba-sloped: false,

  /// In `on` mode, gap between the cut edge and the proba bbox (default: 3pt).
  /// -> length
  proba-padding: 3pt,

  /// Global style of the probabilities. The `80%` size is ALWAYS kept as the
  /// base, unless redefined here.
  ///
  /// Keys: `size`, `fill`, `weight`, `style`,
  /// `smallcaps`, `highlight`, `function` + `#text` params.
  /// -> dictionary
  proba-style: (size: 80%),

  /// Global style of the node texts, e.g. `(size: 11pt, fill: blue)` (default: `none`).
  ///
  /// Keys: `size`, `fill`, `weight`, `style`, `smallcaps`, `highlight`, `function` + `#text` params.
  /// -> dictionary
  node-style: none,

  /// 1st listed child at the top, left-to-right tree (default: `true`).
  /// -> bool
  first-child-top: true,

  /// Radius of the « hole » left around each letter (default: 0.3).
  /// -> float
  node-padding: 0.3,

  /// The tree to draw (last argument). Default: Ω root, A/Ā (p/1-p), B/B̄ (q/1-q).
  /// -> array
  data: default-tree,

  /// Callback drawn inside the canvas after the tree. It receives the
  /// node positions as a dictionary keyed `N<level><index>` (1-indexed),
  /// e.g. `N11` = root, `N41` = 1st leaf of a 4-level tree, plus the cetz
  /// `draw` namespace. Each position is a `(x, y)` pair in canvas units.
  ///
  /// Indices are numbered in visual top-to-bottom order, whatever the value
  /// of `first-child-top`.
  ///
  /// ```example
  /// #proba-tree(
  ///   data: (
  ///     [$Omega$],
  ///     ([$A$], $$, ([$A A$], $$), ([$A B$], $$)),
  ///     ([$B$], $$, ([$B A$], $$), ([$B B$], $$)),
  ///   ),
  ///   extra: (pos, draw) => {
  ///     for k in ("N31", "N32", "N33", "N34") {
  ///       let p = pos.at(k)
  ///       draw.content((p.at(0) + 0.3, p.at(1)), anchor: "west", [#h(1em) $arrow.r$ #k])
  ///     }
  ///   },
  /// )
  /// ```
  ///
  /// -> function
  extra: none,
) = {
  canvas(length: 1cm, {
    import draw: *

    // cetz.tree places the 1st child at the bottom; we reverse for a
    // natural top-to-bottom reading.
    let reverse-children = first-child-top

    // The default size (80%) is ALWAYS the global base of the probabilities;
    // `proba-style` can redefine it or add other settings (fill, …).
    let effective-proba-style = merge-style((size: 80%), proba-style)

    let structure = convert-node(
      data,
      is-root: true,
      proba-position,
      proba-distance,
      proba-sloped,
      effective-proba-style,
      node-style,
      reverse-children,
    )

    tree.tree(
      structure,
      direction: "right", // probability trees are drawn from left to right
      spread: v,
      grow: h,
      draw-node: (node, ..) => {
        content((0, 0), apply-style(node.content.style, node.content.label))
      },
      draw-edge: (from, to, ..) => {
        draw-edge(from, to, node-padding, effective-proba-style, proba-padding)
      },
    )

    // User overlay drawn in the same canvas. Positions are computed from the
    // same layout cetz.tree uses, so labels align exactly with the nodes.
    if extra != none {
      get-ctx(ctx => {
        let positions = compute-node-positions(ctx, structure, h, v)
        extra(positions, draw)
      })
    }
  })
}
