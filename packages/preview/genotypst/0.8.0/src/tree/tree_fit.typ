#import "../common/layout_math.typ": _resolve-length
#import "./tree_backend.typ": _tree-fit
#import "./tree_primitives.typ": _build-tree-label-content

/// Measures all label primitives using the final label-construction helper.
///
/// - tree-plan (dictionary): Tree primitive plan.
/// -> dictionary
#let _measure-tree-primitives(tree-plan) = {
  let measured-primitives = ()
  for primitive in tree-plan.tree-primitives {
    if primitive.kind == "label" {
      let label-content = _build-tree-label-content(primitive)
      let label-size = measure(label-content)
      primitive.insert("content", label-content)
      primitive.insert("measure-width", label-size.width)
      primitive.insert("measure-height", label-size.height)
      measured-primitives.push(primitive)
    } else {
      measured-primitives.push(primitive)
    }
  }
  tree-plan.insert("tree-primitives", measured-primitives)
  tree-plan
}

/// Resolves one possibly signed length.
///
/// - value (length): Length to resolve.
/// -> length
#let _resolve-signed-length(value) = {
  if value < 0pt {
    -_resolve-length(-value)
  } else {
    _resolve-length(value)
  }
}

/// Resolves primitive geometry into absolute fit inputs.
///
/// - tree-plan (dictionary): Measured tree primitive plan.
/// -> dictionary
#let _prepare-fit-inputs(tree-plan) = {
  let prepared-lines = ()
  let prepared-labels = ()
  for primitive in tree-plan.tree-primitives {
    if primitive.kind == "line" {
      let start-page = primitive.start-anchor.page
      let end-page = primitive.end-anchor.page
      prepared-lines.push((
        start-anchor: (
          tree: primitive.start-anchor.tree,
          page: (
            x: _resolve-signed-length(start-page.x),
            y: _resolve-signed-length(start-page.y),
          ),
        ),
        end-anchor: (
          tree: primitive.end-anchor.tree,
          page: (
            x: _resolve-signed-length(end-page.x),
            y: _resolve-signed-length(end-page.y),
          ),
        ),
        half-stroke: _resolve-length(primitive.stroke-thickness) / 2,
        stroke: primitive.stroke,
      ))
    } else {
      prepared-labels.push((
        placement-role: primitive.placement-role,
        anchor-tree: primitive.anchor-tree,
        anchor-page: (
          x: _resolve-signed-length(primitive.anchor-page.x),
          y: _resolve-signed-length(primitive.anchor-page.y),
        ),
        x-align: primitive.x-align,
        y-align: primitive.y-align,
        x-gap: _resolve-signed-length(primitive.x-gap),
        y-gap: _resolve-signed-length(primitive.y-gap),
        rotation: primitive.rotation,
        placement-frame: primitive.placement-frame,
        branch-angle-half-turn: primitive.branch-angle-half-turn,
        placement-angle-half-turn: primitive.placement-angle-half-turn,
        measure-width: primitive.measure-width,
        measure-height: primitive.measure-height,
        content: primitive.content,
      ))
    }
  }
  let root = tree-plan.nodes.at(tree-plan.root-id)
  (
    prepared-lines: prepared-lines,
    prepared-labels: prepared-labels,
    root-tree-point: (x: root.x-unit, y: root.y-unit),
    // `tree-depth` / `tree-height` come from the layout layer. Rectangular
    // trees exclude the separately rendered root edge from `tree-depth`, while
    // non-rectangular layouts store their layout extents here.
    tree-depth: tree-plan.tree-depth,
    tree-height: tree-plan.tree-height,
  )
}

/// Returns whether a public width value is still provisional.
///
/// - width (length, auto, ratio, relative): Requested rendered width.
/// - raw-width (length): Measured width.
/// -> bool
#let _tree-width-is-unresolved(width, raw-width) = {
  if width == auto {
    raw-width == float.inf * 1pt
  } else if type(width) == ratio {
    width != 0% and raw-width == 0pt
  } else if type(width) == relative {
    width.ratio != 0% and raw-width == _resolve-length(width.length)
  } else {
    false
  }
}

/// Builds the prepared fit payload for tree fitting.
///
/// - tree-plan (dictionary): Tree primitive plan.
/// -> dictionary
#let _prepare-fit-tree-plan(tree-plan) = {
  let measured-plan = _measure-tree-primitives(tree-plan)
  let fit-inputs = _prepare-fit-inputs(measured-plan)
  (
    fit-mode: measured-plan.fit-mode,
    layout-kind: measured-plan.layout-kind,
    prepared-lines: fit-inputs.prepared-lines,
    prepared-labels: fit-inputs.prepared-labels,
    backend-prepared-lines: fit-inputs.prepared-lines.map(primitive => (
      start-anchor: primitive.start-anchor,
      end-anchor: primitive.end-anchor,
      half-stroke: primitive.half-stroke,
    )),
    backend-prepared-labels: fit-inputs.prepared-labels.map(primitive => (
      anchor-tree: primitive.anchor-tree,
      anchor-page: primitive.anchor-page,
      x-align: primitive.x-align,
      y-align: primitive.y-align,
      x-gap: primitive.x-gap,
      y-gap: primitive.y-gap,
      rotation: primitive.rotation,
      placement-frame: primitive.placement-frame,
      branch-angle-half-turn: primitive.branch-angle-half-turn,
      placement-angle-half-turn: primitive.placement-angle-half-turn,
      measure-width: primitive.measure-width,
      measure-height: primitive.measure-height,
    )),
    root-tree-point: fit-inputs.root-tree-point,
    tree-depth: fit-inputs.tree-depth,
    tree-height: fit-inputs.tree-height,
  )
}

/// Fits the prepared fit payload into the available viewport.
///
/// - prepared-fit-plan (dictionary): Prepared fit payload used by the tree
///   fitting step.
/// - style (dictionary): Tree style record.
/// - orientation (str): Tree orientation.
/// - width (length, auto, ratio, relative): Original rendered width argument.
/// - height (length, auto): Target rendered tree height.
/// - layout-size (dictionary): Available layout size.
/// - fit-max-bands (int): Maximum number of exponentially growing bands.
/// - fit-band-samples (int, none): Number of samples evaluated per fit band for independent-axis fitting.
/// - optimize-uniform-rotation (bool): Whether uniform-fit layouts may search global rotations.
/// -> dictionary
#let _fit-prepared-tree-plan(
  prepared-fit-plan,
  style,
  orientation,
  width,
  height,
  layout-size,
  fit-max-bands,
  fit-band-samples: none,
  optimize-uniform-rotation: false,
) = {
  let raw-width = layout-size.width
  let provisional-width = _tree-width-is-unresolved(width, raw-width)
  let width-mode = if width == auto {
    "auto"
  } else if provisional-width {
    "provisional"
  } else {
    "resolved"
  }
  let height-mode = if height == auto { "auto" } else { "resolved" }
  let fit-result = _tree-fit((
    fit-mode: prepared-fit-plan.fit-mode,
    layout-kind: prepared-fit-plan.layout-kind,
    orientation: orientation,
    prepared-lines: prepared-fit-plan.backend-prepared-lines,
    prepared-labels: prepared-fit-plan.backend-prepared-labels,
    root-tree-point: prepared-fit-plan.root-tree-point,
    tree-depth: prepared-fit-plan.tree-depth,
    tree-height: prepared-fit-plan.tree-height,
    width-mode: width-mode,
    viewport-width: if width-mode == "resolved" {
      _resolve-length(raw-width)
    } else {
      none
    },
    height-mode: height-mode,
    viewport-height: if height-mode == "resolved" {
      _resolve-length(height)
    } else {
      none
    },
    auto-height-floor: _resolve-length(
      style.auto-height-scale * prepared-fit-plan.tree-height,
    ),
    fit-band-samples: fit-band-samples,
    fit-max-bands: fit-max-bands,
    optimize-uniform-rotation: optimize-uniform-rotation,
  ))
  (
    tree-lines: fit-result.tree-lines.map(entry => (
      start: entry.start,
      end: entry.end,
      stroke: prepared-fit-plan.prepared-lines.at(entry.line-index).stroke,
    )),
    tree-labels: fit-result.tree-labels.map(entry => (
      origin: entry.origin,
      rotation: entry.rotation,
      content: prepared-fit-plan.prepared-labels.at(entry.label-index).content,
    )),
    tree-translation: fit-result.tree-translation,
    tree-occupied-bounds: fit-result.tree-occupied-bounds,
    width-unresolved: fit-result.width-unresolved,
    root-position: fit-result.root-position,
    tree-depth: prepared-fit-plan.tree-depth,
    x-scale: fit-result.x-scale,
    y-scale: fit-result.y-scale,
    orientation: orientation,
    tree-viewport-width: fit-result.tree-viewport-width,
    tree-viewport-height: fit-result.tree-viewport-height,
    tree-depth-span: fit-result.x-scale * prepared-fit-plan.tree-depth,
  )
}
