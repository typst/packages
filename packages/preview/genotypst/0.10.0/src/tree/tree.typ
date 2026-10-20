#import "../common/colors.typ": _medium-gray
#import "./tree_backend.typ": _tree-prepare-layout-backend
#import "./tree_fit.typ": _fit-prepared-tree-plan, _prepare-fit-tree-plan
#import "./tree_primitives.typ": _build-tree-plan
#import "./tree_render.typ": _build-scale-plan, _render-tree-plan

// `render-unrooted-tree` exposes a public `layout` parameter, so we keep a
// distinct handle to Typst's `layout(...)` function for both renderers.
#let _tree-render-layout = layout

/// Default outward spacing for tree labels.
#let _label-gap = 0.31em

/// Vertical gap used for rectangular text internal labels.
#let _internal-text-y-gap = 0.17em
#let _auto-height-scale = 1.9em
#let _rectangular-fit-band-samples = 1
#let _tree-fit-max-bands = 24
#let _tree-content-label-id-prefix = "genotypst-content-label-"

/// Returns whether the public `width` argument is valid.
///
/// - width (length, auto, ratio, relative): Requested rendered width.
/// -> bool
#let _render-tree-width-is-valid(width) = {
  if width == auto {
    true
  } else if type(width) == length {
    width > 0pt
  } else if type(width) == ratio {
    width > 0%
  } else if type(width) == relative {
    width.ratio > 0% or width.length > 0pt
  } else {
    false
  }
}

/// Validates common tree rendering arguments shared by all tree renderers.
///
/// - width (length, auto, ratio, relative): Requested rendered width.
/// - height (length, auto): Requested rendered tree height.
/// - branch-width (length): Branch stroke thickness.
/// - tip-label-size (length): Tip label size.
/// - internal-label-size (length): Internal label size.
/// - hide-internal-labels (bool): Whether internal labels are suppressed.
/// - cladogram (bool): Whether cladogram mode is enabled.
/// -> none
#let _validate-common-tree-args(
  width,
  height,
  branch-width,
  tip-label-size,
  internal-label-size,
  hide-internal-labels,
  cladogram,
) = {
  assert(type(cladogram) == bool, message: "cladogram must be a boolean.")
  assert(branch-width > 0pt, message: "branch-width must be positive.")
  assert(tip-label-size > 0pt, message: "tip-label-size must be positive.")
  assert(
    internal-label-size > 0pt,
    message: "internal-label-size must be positive.",
  )
  assert(
    type(hide-internal-labels) == bool,
    message: "hide-internal-labels must be a boolean.",
  )
  assert(
    _render-tree-width-is-valid(width),
    message: "width must be auto or a positive length, ratio, or relative width.",
  )
  assert(
    height == auto or height > 0pt,
    message: "height must be auto or a positive length.",
  )
}

/// Resolves the canonical rectangular-tree render configuration.
///
/// - width (length, auto, ratio, relative): Requested rendered width.
/// - height (length, auto): Requested rendered tree height.
/// - branch-width (length): Branch stroke thickness.
/// - tip-label-size (length): Tip label size.
/// - internal-label-size (length): Internal label size.
/// - hide-internal-labels (bool): Whether internal labels are suppressed.
/// - root-length (length): Root-edge length.
/// - orientation (str): Tree orientation.
/// - cladogram (bool): Whether cladogram mode is enabled.
/// - scale-bar (bool): Whether scale bar rendering is enabled.
/// - unit (str, none): Optional unit string.
/// - scale-bar-gap (length): Gap between tree and scale bar.
/// - scale-tick-height (length): Scale bar tick height.
/// - scale-label-size (length): Scale bar label size.
/// -> dictionary with keys:
///   - layout-kind (str): Backend layout identifier.
///   - orientation (str): Final render orientation.
///   - suppress-unrooted (bool): Whether the backend suppresses the artificial
///     rooted handle used for unrooted trees.
///   - cladogram (bool): Whether cladogram mode is enabled.
///   - hide-internal-labels (bool): Whether internal labels are omitted.
///   - scale-bar (bool): Whether scale-bar rendering is enabled.
///   - optimize-uniform-rotation (bool): Whether fit may optimize global rotation.
///   - fit-band-samples (int, none): Band samples used by the fit search.
#let _resolve-rectangular-tree-render-config(
  width,
  height,
  branch-width,
  tip-label-size,
  internal-label-size,
  hide-internal-labels,
  root-length,
  orientation,
  cladogram,
  scale-bar,
  unit,
  scale-bar-gap,
  scale-tick-height,
  scale-label-size,
) = {
  _validate-common-tree-args(
    width,
    height,
    branch-width,
    tip-label-size,
    internal-label-size,
    hide-internal-labels,
    cladogram,
  )
  assert(type(scale-bar) == bool, message: "scale-bar must be a boolean.")
  assert(root-length >= 0pt, message: "root-length must be non-negative.")
  assert(
    orientation in ("horizontal", "vertical"),
    message: "orientation must be 'horizontal' or 'vertical'.",
  )
  if scale-bar {
    assert(
      unit == none or type(unit) == str,
      message: "unit must be a string or none.",
    )
    assert(scale-bar-gap >= 0pt, message: "scale-bar-gap must be non-negative.")
    assert(
      scale-tick-height > 0pt,
      message: "scale-tick-height must be positive.",
    )
    assert(
      scale-label-size > 0pt,
      message: "scale-label-size must be positive.",
    )
  }
  (
    layout-kind: "rectangular",
    orientation: orientation,
    suppress-unrooted: false,
    cladogram: cladogram,
    hide-internal-labels: hide-internal-labels,
    scale-bar: scale-bar,
    optimize-uniform-rotation: false,
    // Rectangular occupied span is monotone enough that one sample per band
    // keeps the search cheap without changing the generic solver structure.
    fit-band-samples: _rectangular-fit-band-samples,
  )
}

/// Resolves the canonical unrooted-tree render configuration.
///
/// - width (length, auto, ratio, relative): Requested rendered width.
/// - height (length, auto): Requested rendered tree height.
/// - branch-width (length): Branch stroke thickness.
/// - tip-label-size (length): Tip label size.
/// - internal-label-size (length): Internal label size.
/// - hide-internal-labels (bool): Whether internal labels are suppressed.
/// - cladogram (bool): Whether cladogram mode is enabled.
/// - layout (str): Unrooted layout name.
/// -> dictionary with keys:
///   - layout-kind (str): Backend layout identifier.
///   - orientation (str): Final render orientation.
///   - suppress-unrooted (bool): Whether the backend suppresses the artificial
///     rooted handle used for unrooted trees.
///   - cladogram (bool): Whether cladogram mode is enabled.
///   - hide-internal-labels (bool): Whether internal labels are omitted.
///   - scale-bar (bool): Whether scale-bar rendering is enabled.
///   - optimize-uniform-rotation (bool): Whether fit may optimize global rotation.
///   - fit-band-samples (int, none): Band samples used by the fit search.
#let _resolve-unrooted-tree-render-config(
  width,
  height,
  branch-width,
  tip-label-size,
  internal-label-size,
  hide-internal-labels,
  cladogram,
  layout,
) = {
  _validate-common-tree-args(
    width,
    height,
    branch-width,
    tip-label-size,
    internal-label-size,
    hide-internal-labels,
    cladogram,
  )
  assert(
    layout in ("equal-angle", "daylight"),
    message: "layout must be 'equal-angle' or 'daylight'.",
  )
  (
    layout-kind: layout,
    orientation: "horizontal",
    suppress-unrooted: true,
    cladogram: cladogram,
    hide-internal-labels: hide-internal-labels,
    scale-bar: false,
    optimize-uniform-rotation: true,
    fit-band-samples: none,
  )
}

/// Builds the shared style record for tree rendering and tip-label metrics.
///
/// - branch-width (length): Branch stroke thickness.
/// - branch-color (color): Branch color.
/// - tip-label-size (length): Tip label size.
/// - tip-label-color (color, none): Tip label color.
/// - tip-label-italics (bool): Whether tip labels are italicized.
/// - internal-label-size (length): Internal label size.
/// - internal-label-color (color, none): Internal label color.
/// -> dictionary
#let _build-render-tree-style(
  branch-width,
  branch-color,
  tip-label-size,
  tip-label-color,
  tip-label-italics,
  internal-label-size,
  internal-label-color,
) = {
  let tip-label-style = if tip-label-italics { "italic" } else { "normal" }
  let ascender-to-baseline = measure(text(
    size: tip-label-size,
    style: tip-label-style,
    top-edge: "ascender",
    bottom-edge: "baseline",
    "x",
  )).height
  let x-height-span = measure(text(
    size: tip-label-size,
    style: tip-label-style,
    top-edge: "x-height",
    bottom-edge: "baseline",
    "x",
  )).height
  let full-height = measure(text(
    size: tip-label-size,
    style: tip-label-style,
    top-edge: "ascender",
    bottom-edge: "descender",
    "x",
  )).height
  (
    branch-stroke: stroke(
      thickness: branch-width,
      paint: branch-color,
      cap: "square",
    ),
    branch-width: branch-width,
    tip-label-size: tip-label-size,
    tip-label-color: tip-label-color,
    tip-label-italics: tip-label-italics,
    internal-label-size: internal-label-size,
    internal-label-color: internal-label-color,
    label-gap: _label-gap,
    internal-text-y-gap: _internal-text-y-gap,
    auto-height-scale: _auto-height-scale,
    tip-label-metrics: (
      // Rectangular and unrooted tip labels intentionally use the same
      // branch/text intersection height.
      branch-midpoint: ascender-to-baseline - x-height-span / 2,
      full-height: full-height,
    ),
  )
}

/// Builds the rectangular-tree style record.
///
/// - branch-width (length): Branch stroke thickness.
/// - branch-color (color): Branch color.
/// - tip-label-size (length): Tip label size.
/// - tip-label-color (color, none): Tip label color.
/// - tip-label-italics (bool): Whether tip labels are italicized.
/// - internal-label-size (length): Internal label size.
/// - internal-label-color (color, none): Internal label color.
/// - root-length (length): Rendered root-edge length.
/// -> dictionary
#let _build-rectangular-tree-style(
  branch-width,
  branch-color,
  tip-label-size,
  tip-label-color,
  tip-label-italics,
  internal-label-size,
  internal-label-color,
  root-length,
) = {
  let style = _build-render-tree-style(
    branch-width,
    branch-color,
    tip-label-size,
    tip-label-color,
    tip-label-italics,
    internal-label-size,
    internal-label-color,
  )
  style.insert("root-length", root-length)
  style
}

/// Rewrites manual tree labels into a backend-safe representation.
///
/// String labels pass through unchanged. Empty content labels are normalized to
/// `none`, and non-empty content labels are replaced with a private `label-id`
/// so the Rust backend never has to serialize Typst `content` values.
///
/// - tree-data (dictionary): Parsed or manually constructed tree data.
/// -> dictionary with keys:
///   - backend-tree (dictionary): Backend-safe tree data.
///   - content-labels (dictionary): `label-id` to original content.
#let _prepare-tree-data-for-layout(tree-data) = {
  assert(
    type(tree-data) == dictionary,
    message: "tree-data must be a dictionary.",
  )

  let visit(node, next-label-id) = {
    assert(
      type(node) == dictionary,
      message: "tree nodes must be dictionaries.",
    )
    let prepared = (:)
    let next-id = next-label-id
    let content-labels = (:)

    for (key, value) in node.pairs() {
      if key == "label-id" {
        // Private backend channel; user input should not override it.
      } else if key == "name" {
        if value == none or type(value) == str {
          prepared.insert("name", value)
        } else if type(value) == content {
          if value == [] {
            // Empty content renders nothing and should not affect layout.
            prepared.insert("name", none)
          } else {
            let label-id = _tree-content-label-id-prefix + str(next-id)
            next-id += 1
            prepared.insert("name", none)
            prepared.insert("label-id", label-id)
            content-labels.insert(label-id, value)
          }
        } else {
          assert(
            false,
            message: "manual tree node name must be a string, content, or none.",
          )
        }
      } else if key == "children" {
        assert(
          value == none or type(value) == array,
          message: "children must be an array or none.",
        )
        if value == none {
          prepared.insert("children", none)
        } else {
          let children = ()
          for child in value {
            let prepared-child = visit(child, next-id)
            next-id = prepared-child.next-label-id
            content-labels += prepared-child.content-labels
            children.push(prepared-child.node)
          }
          prepared.insert("children", children)
        }
      } else {
        prepared.insert(key, value)
      }
    }

    (
      node: prepared,
      content-labels: content-labels,
      next-label-id: next-id,
    )
  }

  let prepared-root = visit(tree-data, 0)

  (
    backend-tree: prepared-root.node,
    content-labels: prepared-root.content-labels,
  )
}

/// Restores content-backed labels onto the prepared layout tree.
///
/// - layout-tree (dictionary): Backend-prepared normalized tree layout.
/// - content-labels (dictionary): `label-id` to original content.
/// -> dictionary
#let _hydrate-layout-tree-label-bodies(layout-tree, content-labels) = {
  let nodes = ()
  for node in layout-tree.nodes {
    let label-id = node.at("label-id", default: none)
    let label-body = if label-id != none {
      assert(
        label-id in content-labels,
        message: "Internal tree label hydration failed.",
      )
      content-labels.at(label-id)
    } else {
      node.label-text
    }
    nodes.push((
      ..node,
      label-body: label-body,
    ))
  }
  (
    ..layout-tree,
    nodes: nodes,
  )
}

/// Prepares a tree render from the resolved mode config.
///
/// - tree-data (dictionary): Parsed or manually constructed tree data.
/// - style (dictionary): Tree style record.
/// - config (dictionary): Canonical tree render config from one of the
///   `_resolve-*-tree-render-config(...)` helpers.
/// -> dictionary with keys:
///   - style (dictionary): Tree style record passed into the helper.
///   - prepared-fit-plan (dictionary): Prepared fit payload for the tree-fitting
///     stage.
#let _prepare-tree-render(tree-data, style, config) = {
  let prepared-tree-data = _prepare-tree-data-for-layout(tree-data)
  let layout-tree = _tree-prepare-layout-backend(
    prepared-tree-data.backend-tree,
    cladogram: config.cladogram,
    suppress-unrooted: config.suppress-unrooted,
    hide-internal-labels: config.hide-internal-labels,
    layout-kind: config.layout-kind,
  )
  if config.scale-bar {
    assert(
      not layout-tree.effective-cladogram,
      message: "scale-bar cannot be used when the tree has no branch length information or when it is rendered as a cladogram.",
    )
  }
  let tree-plan = _build-tree-plan(
    _hydrate-layout-tree-label-bodies(
      layout-tree,
      prepared-tree-data.content-labels,
    ),
    style,
    orientation: config.orientation,
  )
  (
    style: style,
    prepared-fit-plan: _prepare-fit-tree-plan(tree-plan),
  )
}

/// Renders a rectangular phylogenetic tree from parsed or manual tree data.
///
/// Supports customization of dimensions, styling, and orientation.
///
/// - tree-data (dictionary): Parsed or manually constructed tree data. Manual
///   node dictionaries accept `name: str`, `name: content`, or `name: none`.
///   Trees returned by `parse-newick(...)` remain string-labeled.
/// - width (length, auto, ratio, relative): Width of the tree visualization
///   including labels (default: 100%).
/// - height (length, auto): Height of the tree area (default: auto).
/// - branch-width (length): Thickness of tree branches (default: 1pt).
/// - branch-color (color): Color of tree branches (default: black).
/// - tip-label-size (length): Font size of tip labels (default: 1em).
/// - tip-label-color (color, none): Color of tip labels (default: none, inherits from the document).
/// - tip-label-italics (bool): Whether to use italics for tip labels (default: false).
/// - internal-label-size (length): Font size of internal node labels (default: 0.85em).
/// - internal-label-color (color, none): Color of internal node labels (default: medium gray; `none` inherits from the document).
/// - hide-internal-labels (bool): Whether to hide all non-leaf labels
///   (default: false).
/// - root-length (length): Length of the rendered root edge (default: 1.2em).
/// - orientation (str): "horizontal" (root left, tips right) or "vertical" (root bottom, tips up) (default: "horizontal").
/// - cladogram (bool): Whether to draw the tree as a cladogram with equal branch lengths (default: false).
/// - scale-bar (bool): Whether to draw a branch-length scale bar below the tree (default: false).
///   Scale bars are unavailable for cladograms and for trees that fall back to
///   cladogram rendering because they lack branch length information.
///   In vertical orientation, the scale bar can use the full rendered row width.
/// - scale-length (auto, int, float): Scale-bar length in branch-length units. Positive when specified (default: auto).
/// - unit (str, none): Optional scale-bar unit suffix (default: none).
/// - min-auto-bar-width (length): Minimum auto-selected scale-bar width when space allows (default: 2.5em).
/// - scale-bar-gap (length): Gap between tree and scale bar (default: 0.6em).
/// - scale-tick-height (length): Scale-bar tick height (default: 4.25pt).
/// - scale-label-size (length): Scale-bar label size (default: 0.8em).
/// -> content
#let render-rectangular-tree(
  tree-data,
  width: 100%,
  height: auto,
  branch-width: 1pt,
  branch-color: black,
  tip-label-size: 1em,
  tip-label-color: none,
  tip-label-italics: false,
  internal-label-size: 0.85em,
  internal-label-color: _medium-gray,
  hide-internal-labels: false,
  root-length: 1.2em,
  orientation: "horizontal",
  cladogram: false,
  scale-bar: false,
  scale-length: auto,
  unit: none,
  min-auto-bar-width: 2.5em,
  scale-bar-gap: 0.6em,
  scale-tick-height: 4.25pt,
  scale-label-size: 0.8em,
) = {
  let config = _resolve-rectangular-tree-render-config(
    width,
    height,
    branch-width,
    tip-label-size,
    internal-label-size,
    hide-internal-labels,
    root-length,
    orientation,
    cladogram,
    scale-bar,
    unit,
    scale-bar-gap,
    scale-tick-height,
    scale-label-size,
  )
  block(width: width)[
    #context {
      let style = _build-rectangular-tree-style(
        branch-width,
        branch-color,
        tip-label-size,
        tip-label-color,
        tip-label-italics,
        internal-label-size,
        internal-label-color,
        root-length,
      )
      let prepared = _prepare-tree-render(
        tree-data,
        style,
        config,
      )
      _tree-render-layout(size => context {
        let fitted-plan = _fit-prepared-tree-plan(
          prepared.prepared-fit-plan,
          prepared.style,
          config.orientation,
          width,
          height,
          size,
          _tree-fit-max-bands,
          fit-band-samples: config.fit-band-samples,
          optimize-uniform-rotation: config.optimize-uniform-rotation,
        )
        let scale-plan = if (
          config.scale-bar and not fitted-plan.width-unresolved
        ) {
          _build-scale-plan(
            fitted-plan,
            branch-color,
            branch-width,
            scale-length,
            unit,
            min-auto-bar-width,
            scale-tick-height,
            scale-label-size,
          )
        } else {
          none
        }
        _render-tree-plan(
          fitted-plan,
          scale-plan,
          scale-bar-gap,
        )
      })
    }
  ]
}

/// Renders an unrooted phylogenetic tree using an equal-angle or daylight layout.
///
/// - tree-data (dictionary): Parsed or manually constructed tree data. Manual
///   node dictionaries accept `name: str`, `name: content`, or `name: none`.
///   Trees returned by `parse-newick(...)` remain string-labeled.
/// - width (length, auto, ratio, relative): Width of the tree visualization including labels (default: 100%).
/// - height (length, auto): Height of the tree area (default: auto).
/// - branch-width (length): Thickness of tree branches (default: 1pt).
/// - branch-color (color): Color of tree branches (default: black).
/// - tip-label-size (length): Font size of tip labels (default: 1em).
/// - tip-label-color (color, none): Color of tip labels (default: none, inherits from the document).
/// - tip-label-italics (bool): Whether to use italics for tip labels (default: false).
/// - internal-label-size (length): Font size of internal node labels (default: 0.85em).
/// - internal-label-color (color, none): Color of internal node labels (default: medium gray; `none` inherits from the document).
/// - hide-internal-labels (bool): Whether to hide all non-leaf labels
///   (default: false).
/// - cladogram (bool): Whether to draw the tree as a cladogram with equal branch lengths (default: false).
/// - layout (str): "equal-angle" or "daylight" (default: "equal-angle").
/// -> content
#let render-unrooted-tree(
  tree-data,
  width: 100%,
  height: auto,
  branch-width: 1pt,
  branch-color: black,
  tip-label-size: 1em,
  tip-label-color: none,
  tip-label-italics: false,
  internal-label-size: 0.85em,
  internal-label-color: _medium-gray,
  hide-internal-labels: false,
  cladogram: false,
  layout: "equal-angle",
) = {
  let config = _resolve-unrooted-tree-render-config(
    width,
    height,
    branch-width,
    tip-label-size,
    internal-label-size,
    hide-internal-labels,
    cladogram,
    layout,
  )
  block(width: width)[
    #context {
      let style = _build-render-tree-style(
        branch-width,
        branch-color,
        tip-label-size,
        tip-label-color,
        tip-label-italics,
        internal-label-size,
        internal-label-color,
      )
      let prepared = _prepare-tree-render(
        tree-data,
        style,
        config,
      )
      _tree-render-layout(size => context {
        let fitted-plan = _fit-prepared-tree-plan(
          prepared.prepared-fit-plan,
          prepared.style,
          config.orientation,
          width,
          height,
          size,
          _tree-fit-max-bands,
          fit-band-samples: config.fit-band-samples,
          optimize-uniform-rotation: config.optimize-uniform-rotation,
        )
        _render-tree-plan(
          fitted-plan,
          none,
          0pt,
        )
      })
    }
  ]
}
