// Layout engine v2
//
// Renders a grid of images (or arbitrary content) that fills an available box
// while preserving every element's aspect ratio and keeping uniform gaps.
//
// ── Usage ─────────────────────────────────────────────────────────────────────
//
// Describe the layout as a nested array and render it inside a layout callback:
//
//   #context {
//     let cd = resolve-aspect(parse-content-tree(
//       (
//         image("a.jpg"),                          // leaf, aspect auto-measured
//         image("b.jpg"),
//         (                                        // sub-group, axis alternates
//           image("c.jpg"),
//           (body: [caption], aspect: 1.0),        // leaf with explicit aspect
//         ),
//       ),
//       axis: "horizontal",   // top-level axis
//       gap: 0.5em,
//     ))
//     box(width: 100%, height: 5cm)[
//       #layout(size => fit-content-dict(cd, size))
//     ]
//   }
//
// For more control, build the tree manually with make-content-dict /
// add-body-to-content-dict, then resolve-aspect, then resolve-stretchable
// (passing the top-level axis), then fit-content-dict.
//
// ── Model ─────────────────────────────────────────────────────────────────────
//
// Every element (leaf or group) satisfies the same linear model:
//
//   w = a*(h - c_h) + c_w      [width as function of height]
//   h = (w - c_w)/a + c_h      [height as function of width]
//
// Parameters:
//   a   — aspect-like slope  (width change per unit height change)
//   c_h — height offset      ("minimum height"; w = c_w when h = c_h)
//   c_w — width offset       ("minimum width";  h = c_h when w = c_w)
//
// Leaf:  a = measured_aspect_ratio,  c_h = 0,  c_w = 0
//
// Horizontal group (n children side-by-side, all at height H):
//   A   = sum(a_i)
//   C_h = 0
//   C_w = gap*(n-1) + sum(c_w_i - a_i*c_h_i)
//
// Vertical group (n children stacked, all at width W):
//   A   = 1/sum(1/a_i)
//   C_h = gap*(n-1) + sum(c_h_i - c_w_i/a_i)
//   C_w = 0
//
// The alternating-axis constraint (horizontal parent → vertical/leaf children,
// vertical parent → horizontal/leaf children) keeps the recursion consistent:
// make-row passes each child its WIDTH, make-col passes each child its HEIGHT,
// and those are exactly the dimensions children expect as their `dimension` arg.

// ── Construction ──────────────────────────────────────────────────────────────

/// Create a leaf (1 body) or group (2+ bodies) content-dict.
///
/// A single body becomes a leaf with `_a = aspect ratio, _c_h = 0, _c_w = 0`.
/// Multiple bodies are each wrapped in a leaf and collected into a group whose
/// `(_a, _c_h, _c_w)` are left as `auto` until `resolve-aspect` is called.
/// Must be called inside a `context` block (needed for `measure`).
///
/// - aspect (float, auto): Aspect ratio `w/h`. `0` means constant-size: the element
///   occupies exactly `c_w` in a horizontal row or `c_h` in a vertical stack.
/// - c_h (length): Fixed height for `aspect: 0` elements in a vertical stack.
/// - c_w (length): Fixed width for `aspect: 0` elements in a horizontal row.
/// - layout-axis (string): `"horizontal"` (side-by-side) or `"vertical"` (stacked).
///   Only relevant for groups.
/// - gap (length): Gutter between children. Only relevant for groups.
/// - stretchable_ (bool): If `true`, this leaf absorbs leftover space in its parent's
///   axis direction after `resolve-stretchable` is called. Only meaningful on leaves.
///
/// -> dictionary
#let make-content-dict(..body-args, aspect: auto, c_h: 0pt, c_w: 0pt, layout-axis: "horizontal", gap: 1em, stretchable_: false) = {
  let bodies = body-args.pos()

  if bodies.len() == 1 {
    let body = bodies.at(0)
    let a = if aspect != auto {
      aspect
    } else if type(body) == content {
      let sz = measure(body)
      if sz.height != 0pt { sz.width / sz.height } else { 1.0 }
    } else {
      panic("Cannot auto-detect aspect for non-content body; pass aspect explicitly")
    }
    return (bodies: bodies, gap: 0pt, _a: a, _c_h: c_h, _c_w: c_w, _layout-axis: none, stretchable_: stretchable_, _h-stretchable: 0, _v-stretchable: 0)
  }

  // Group: wrap each raw-content body in a leaf dict
  let children = bodies.map(it => make-content-dict(it))
  return (
    bodies: children,
    gap: gap,
    _a: auto,
    _c_h: auto,
    _c_w: auto,
    _layout-axis: layout-axis,
    _h-stretchable: 0,
    _v-stretchable: 0,
  )
}

/// Append a pre-built content-dict `child` to `parent`'s body list.
///
/// Use this when the child was constructed separately (different gap, axis, or
/// nested structure) and cannot be passed directly to `make-content-dict`.
/// Panics if parent and child share the same layout-axis (axes must alternate).
///
/// - parent (dictionary): A group content-dict (layout-axis ≠ none).
/// - child (dictionary): Any content-dict with a different layout-axis.
///
/// -> dictionary
#let add-body-to-content-dict(parent, child) = {
  assert(
    parent._layout-axis != child._layout-axis,
    message: "Parent and child cannot share the same layout-axis",
  )
  parent.bodies = parent.bodies + (child,)
  return parent
}

// ── Resolution ────────────────────────────────────────────────────────────────

/// Recursively compute `(_a, _c_h, _c_w)` for every group in the tree.
///
/// Call once after the full tree is built with `make-content-dict` /
/// `add-body-to-content-dict`, before passing to `fit-content-dict`.
///
/// - cd (dictionary): A content-dict (leaf or group).
///
/// -> dictionary
#let resolve-aspect(cd) = {
  assert(type(cd) == dictionary, message: "Expected a content-dict dictionary")
  assert(cd.bodies.len() > 0, message: "Content-dict must have at least one body")

  if cd._layout-axis == none {
    assert(cd._a != auto, message: "Leaf must have a concrete aspect before resolve-aspect")
    return cd
  }

  cd.bodies = cd.bodies.map(resolve-aspect)

  let layout-axis = cd._layout-axis
  let n = cd.bodies.len()

  for body in cd.bodies {
    if body._layout-axis == layout-axis {
      panic("Child has the same layout-axis as parent (" + layout-axis + "); axes must alternate")
    }
  }

  if layout-axis == "horizontal" {
    let A = 0.0
    let C_w = cd.gap * (n - 1)
    for body in cd.bodies {
      A   = A   + body._a
      C_w = C_w + body._c_w - body._a * body._c_h
    }
    cd._a   = A
    cd._c_h = 0pt
    cd._c_w = C_w

  } else if layout-axis == "vertical" {
    let inv_A = 0.0
    let C_h = cd.gap * (n - 1)
    for body in cd.bodies {
      if body._a != 0 {
        inv_A = inv_A + 1.0 / body._a
        C_h   = C_h + body._c_h - body._c_w / body._a
      } else {
        C_h = C_h + body._c_h
      }
    }
    cd._a   = 1.0 / inv_A
    cd._c_h = C_h
    cd._c_w = 0pt

  } else {
    panic("Unknown layout-axis: " + str(layout-axis))
  }

  return cd
}

// ── Stretchability ────────────────────────────────────────────────────────────

/// Precompute `_h-stretchable` and `_v-stretchable` counts on every node.
///
/// Must be called after `resolve-aspect` and before `fit-content-dict`.
/// `display-content-tree` calls this automatically (passing the top-level axis).
///
/// Each count is the number of direct or indirect children that will absorb budget
/// along that axis, enabling `render-content-dict` to split the budget correctly via
/// `budget / count`. A count of 0 means not stretchable in that direction.
///
/// Propagation rules (bottom-up):
/// - Leaf with `stretchable_: true`: registers 1 in its *parent's* axis direction only.
/// - Horizontal group: `_h-stretchable` = sum of children's counts (each h-stretchable
///   child absorbs its own share); `_v-stretchable` = 1 if all children are v-stretchable
///   (shared height means everyone must grow together), else 0.
/// - Vertical group: symmetric — `_v-stretchable` = sum, `_h-stretchable` = 0-or-1.
///
/// - cd (dictionary): A resolved content-dict.
/// - parent-layout-axis (string): The layout axis of cd's parent (`"horizontal"` or
///   `"vertical"`). Pass the top-level axis for the root node.
///
/// -> dictionary
#let resolve-stretchable(cd, parent-layout-axis) = {
  cd._h-stretchable = 0
  cd._v-stretchable = 0

  // leaf elements can only be stretchable in the direction of their parent layout
  if cd._layout-axis == none {
    if parent-layout-axis == "horizontal" and cd.at("stretchable_", default: false) {
      cd._h-stretchable = 1
    }
    if parent-layout-axis == "vertical" and cd.at("stretchable_", default: false) {
      cd._v-stretchable = 1
    }
    return cd
  }
  cd.bodies = cd.bodies.map(it => resolve-stretchable(it, cd._layout-axis))

  if cd._layout-axis == "horizontal" {
    cd._h-stretchable = cd.bodies.fold(0, (acc, it) => acc + it._h-stretchable)
    cd._v-stretchable = if cd.bodies.all(it => it._v-stretchable > 0) { 1 } else { 0 }
  } else if cd._layout-axis == "vertical" {
    cd._v-stretchable = cd.bodies.fold(0, (acc, it) => acc + it._v-stretchable)
    cd._h-stretchable = if cd.bodies.all(it => it._h-stretchable > 0) { 1 } else { 0 }
  }
  return cd
}

// ── Rendering ─────────────────────────────────────────────────────────────────

/// Render a resolved content-dict at a fixed dimension (height for horizontal
/// groups, width for vertical groups). Prefer `fit-content-dict` for top-level use.
///
/// Both budgets propagate down the full tree simultaneously. Each group zeroes out
/// a budget if its count for that direction is 0, preventing spurious stretching.
///
/// - h-budget (length): Extra horizontal space to distribute. In a horizontal group,
///   split among h-stretchable direct children; the group also grows taller by the
///   v-budget if v-stretchable. In a vertical group, passed as the shared width increase.
/// - v-budget (length): Extra vertical space to distribute. Symmetric to h-budget.
///
/// -> content
#let render-content-dict(cd, dimension, h-budget: 0pt, v-budget: 0pt) = {
  if cd._layout-axis == none {
    return cd.bodies.at(0)
  }

  let make-row(cd, height, h-budget, v-budget) = {
    let base_widths = cd.bodies.map(it => it._a * (height - it._c_h) + it._c_w)
    if base_widths.sum().to-absolute() < 0.0mm {
      panic("Negative width calculated for content dict with given dimension and gap")
    }
    
    if cd._h-stretchable == 0 {
      h-budget = 0pt
    }
    if cd._v-stretchable == 0 {
      v-budget = 0pt
    }

    // calculate extra 
    let extra = if cd._h-stretchable > 0 { h-budget / cd._h-stretchable } else { 0pt }
    let extra_per_body = cd.bodies.map(it => extra * ( if it._h-stretchable > 0 { 1 } else { 0 }))

    let widths = base_widths.zip(extra_per_body).map(it => {
      it.at(0) + it.at(1)
    })

    grid(
      rows: height + v-budget,
      columns: widths,
      gutter: cd.gap,
      ..cd.bodies.zip(base_widths, extra_per_body).map(it => {
        let body = it.at(0)
        let width = it.at(1)
        let extra_width = it.at(2)
        box(width: 100%, height: 100%)[
          #set image(width: 100%, height: 100%)
          #render-content-dict(body, width, h-budget: extra_width, v-budget: v-budget)
        ]
      }),
    )
  }

  let make-col(cd, width, h-budget, v-budget) = {
    let base_heights = cd.bodies.map(it =>
      if it._a == 0 { it._c_h } else { (width - it._c_w) / it._a + it._c_h }
    )
    if base_heights.sum().to-absolute() < 0.0mm {
      panic("Negative height calculated for content dict with given dimension and gap")
    }

    if cd._h-stretchable == 0 {
      h-budget = 0pt
    }
    if cd._v-stretchable == 0 {
      v-budget = 0pt
    }

    let extra = if cd._v-stretchable > 0 { v-budget / cd._v-stretchable } else { 0pt }
    let extra_per_body = cd.bodies.map(it => extra * ( if it._v-stretchable > 0 { 1 } else { 0 }))

    let heights = base_heights.zip(extra_per_body).map(it => {
      it.at(0) + it.at(1)
    })
    
    grid(
      rows: heights,
      columns: width + h-budget,
      gutter: cd.gap,
      ..cd.bodies.zip(base_heights, extra_per_body).map(it => {
        let body = it.at(0)
        let height = it.at(1)
        let extra_height = it.at(2)
        box(width: 100%, height: 100%)[
          #set image(width: 100%, height: 100%)
          #render-content-dict(body, height, h-budget: h-budget, v-budget: extra_height)
        ]
      }),
    )
  }

  if cd._layout-axis == "horizontal" {
    make-row(cd, dimension, h-budget, v-budget)
    // place(center+top, text(fill: red)[#cd._h-stretchable])
  } else if cd._layout-axis == "vertical" {
    make-col(cd, dimension, h-budget, v-budget)
    // place(left+horizon, text(fill: red)[#cd._h-stretchable])
  }
}

// ── Fitting ───────────────────────────────────────────────────────────────────

/// Fit a resolved content-dict into `size`, choosing height- or width-constrained
/// rendering automatically. Intended for use inside a `layout` callback.
///
/// Example:
///
/// ```typst
/// #context {
///   let cd = make-content-dict(image("a.jpg"), image("b.jpg"), gap: 0.5em)
///   let cd = resolve-aspect(cd)
///   box(width: 100%, height: 5cm)[
///     #layout(size => fit-content-dict(cd, size))
///   ]
/// }
/// ```
///
/// - cd (dictionary): A resolved content-dict (output of `resolve-aspect`).
/// - size (dictionary): Available space, e.g. from a `layout` callback.
///
/// -> content
#let fit-content-dict(cd, size) = {
  if cd._a == 0 {
    if cd._layout-axis == "horizontal" { render-content-dict(cd, size.height) }
    else { render-content-dict(cd, size.width) }
  } else {
    let height = size.height.to-absolute()
    let width  = (cd._a * (height - cd._c_h) + cd._c_w).to-absolute()

    if width > size.width {
      width  = size.width.to-absolute()
      height = ((width - cd._c_w) / cd._a + cd._c_h).to-absolute()
      
      let v-budget = size.height - height
      let h-budget = size.width - width

      if cd._layout-axis == "horizontal" {
        render-content-dict(cd, height, h-budget: h-budget, v-budget: v-budget) 
      } else { 
        render-content-dict(cd, width, h-budget: h-budget, v-budget: v-budget)
     }

    } else {
      let v-budget = size.height - height
      let h-budget = size.width - width

      if cd._layout-axis == "horizontal" { 
        render-content-dict(cd, height, h-budget: h-budget, v-budget: v-budget)
      }
      else { 
        render-content-dict(cd, width, h-budget: h-budget, v-budget: v-budget) 
      }
    }
  }
}

// ── Tree parsing ──────────────────────────────────────────────────────────────

/// Build a content-dict tree from a nested array.
///
/// Each element may be:
/// - `content` — leaf with auto-measured aspect ratio
/// - `(body: ..., aspect: float)` dict — leaf with explicit aspect
/// - `(body: ..., aspect: 0, constant-size: length)` dict — fixed-dimension leaf;
///   `constant-size` becomes the width in a horizontal row or the height in a vertical stack
/// - `(body: ..., aspect: ..., stretchable_: true)` dict — leaf that absorbs leftover
///   space in its parent's axis direction (combinable with `constant-size` to provide a minimum size)
/// - `array` — sub-group; its axis alternates from the parent
///
/// Sub-group axes alternate automatically starting from `axis`.
/// A single-element array unwraps to its child (no wrapper group).
///
/// - items (array): Nested content structure.
/// - axis (string): Layout axis for this level (`"horizontal"` or `"vertical"`).
/// - gap (length): Uniform gap applied at every level.
///
/// -> dictionary
#let parse-content-tree(items, axis: "horizontal", gap: 0.5em) = {
  let opposite = if axis == "horizontal" { "vertical" } else { "horizontal" }

  let children = items.map(it => {
    if type(it) == array {
      parse-content-tree(it, axis: opposite, gap: gap)
    } else if type(it) == dictionary {
      let s = it.at("constant-size", default: 0pt)
      let c_w = if axis == "horizontal" { s } else { 0pt }
      let c_h = if axis == "vertical"   { s } else { 0pt }
      make-content-dict(it.body, aspect: it.at("aspect", default: auto), c_h: c_h, c_w: c_w, stretchable_: it.at("stretchable_", default: false))
    } else {
      make-content-dict(it)
    }
  })

  if children.len() == 1 { return children.at(0) }

  return (bodies: children, gap: gap, _a: auto, _c_h: auto, _c_w: auto, _layout-axis: axis, stretchable_: false, _h-stretchable: 0, _v-stretchable: 0)
}


/// Display a content-dict tree maximally filling the available space while preserving
/// aspect ratios and gaps. Needs context to measure aspect ratios of the the contents.
///
/// Automatically calls `resolve-aspect` then `resolve-stretchable` before rendering,
/// so stretchable elements declared with `stretchable_: true` in the tree work without
/// any extra setup.
///
/// Example — two images side by side with a caption column that fills remaining width:
///
/// ```typst
/// #context {
///   box(width: 100%, height: 2cm)[
///     #display-content-tree(
///       (
///         image("a.jpg"),
///         (body: align(horizon)[Caption], aspect: 0, constant-size: 2cm, stretchable_: true),
///         image("b.jpg"),
///       ),
///       axis: "horizontal",
///       gap: 0.5em,
///     )
///   ]
/// }
/// ```
///
/// - items (array): The nested content structure.
/// - axis (string): The layout axis for this level (`"horizontal"` or `"vertical"`).
/// - gap (length): The uniform gap applied at every level.
///
/// -> content
#let display-content-tree(items, axis: "horizontal", gap: 0.5em) = {
  let cd = resolve-aspect(parse-content-tree(
    items,
    axis: axis,
    gap: gap,
  ))
  let cd_s = resolve-stretchable(cd, axis)
  layout(size => fit-content-dict(cd_s, size))
}

