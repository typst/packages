#import "../common/axis_scale.typ": (
  _default-scale-label-gap, _draw-horizontal-segment, _draw-line,
  _draw-scale-bar-row, _draw-vertical-segment, _format-scale-label,
  _resolve-scale-bar-length,
)

/// Numeric tolerance used when fitting trees into a viewport.
#let _fit-tolerance = 0.1pt

/// Builds the optional scale-bar row.
///
/// - fitted-plan (dictionary): Fitted tree data with viewport geometry and
///   positioned primitives.
/// - config (dictionary): Canonical tree render config. Reads `scale-stroke`,
///   `scale-length`, `unit`, `min-auto-bar-width`, `scale-tick-height`, and
///   `scale-label-size`.
/// -> content
#let _build-scale-plan(fitted-plan, config) = {
  let (
    scale-stroke,
    scale-length,
    unit,
    min-auto-bar-width,
    scale-tick-height,
    scale-label-size,
    ..,
  ) = config

  let row-width = fitted-plan.tree-viewport-width
  let root-position = fitted-plan.root-position
  let bar-left = if fitted-plan.orientation == "vertical" { 0pt } else {
    root-position.x
  }
  let max-bar-width = if fitted-plan.orientation == "vertical" {
    row-width
  } else {
    calc.max(0pt, fitted-plan.tree-depth-span)
  }
  let resolved-scale = _resolve-scale-bar-length(
    scale-length,
    // `tree-depth` reflects descendant branch lengths only; the visible root
    // stub is controlled separately by `root-length`.
    fitted-plan.tree-depth,
    fitted-plan.x-scale,
    max-bar-width,
    min-auto-bar-width: min-auto-bar-width,
    zero-length-message: "Cannot render scale bar for zero-depth tree.",
  )
  let scale-label = _format-scale-label(resolved-scale.length, unit)
  _draw-scale-bar-row(
    row-width,
    0pt,
    bar-left,
    resolved-scale.width,
    scale-tick-height,
    _default-scale-label-gap,
    scale-label-size,
    scale-label,
    scale-stroke,
  )
}

/// Renders a fitted tree plan and optional scale-bar row.
///
/// - fitted-plan (dictionary): Fitted tree data with viewport geometry and
///   positioned primitives.
/// - scale-plan (content, none): Optional scale row.
/// - scale-bar-gap (length): Gap between tree and scale bar.
/// -> content
#let _render-tree-plan(fitted-plan, scale-plan, scale-bar-gap) = {
  let tree-translation = fitted-plan.tree-translation
  let tree-box = box(
    width: fitted-plan.tree-viewport-width,
    height: fitted-plan.tree-viewport-height,
    {
      for primitive in fitted-plan.tree-lines {
        if primitive.stroke == none {
          continue
        }
        let start = (
          x: primitive.start.x + tree-translation.x,
          y: primitive.start.y + tree-translation.y,
        )
        let end = (
          x: primitive.end.x + tree-translation.x,
          y: primitive.end.y + tree-translation.y,
        )
        let dx = calc.abs(end.x - start.x)
        let dy = calc.abs(end.y - start.y)
        if dy <= _fit-tolerance {
          _draw-horizontal-segment(
            calc.min(start.x, end.x),
            start.y,
            dx,
            primitive.stroke,
          )
        } else if dx <= _fit-tolerance {
          _draw-vertical-segment(
            start.x,
            calc.min(start.y, end.y),
            dy,
            primitive.stroke,
          )
        } else {
          _draw-line(
            (start.x, start.y),
            (end.x, end.y),
            primitive.stroke,
          )
        }
      }
      for primitive in fitted-plan.tree-labels {
        let origin = (
          x: primitive.origin.x + tree-translation.x,
          y: primitive.origin.y + tree-translation.y,
        )
        place(
          top + left,
          dx: origin.x,
          dy: origin.y,
          if primitive.rotation == 0deg {
            primitive.content
          } else {
            rotate(primitive.rotation, origin: top + left, primitive.content)
          },
        )
      }
    },
  )

  if scale-plan == none {
    tree-box
  } else {
    block(breakable: false, stack(
      spacing: scale-bar-gap,
      tree-box,
      scale-plan,
    ))
  }
}
