// The user's x/y axes under coord-flip. The renderer swaps the mapping keys
// and the trained scales, so a geom that draws in the user's x/y space reads
// its columns and scales through these helpers and swaps each canvas point
// back: the user's x runs vertically and the user's y horizontally.

#import "../coord/project.typ": project-path, project-point

#let _flipped(ctx) = ctx.at("flipped", default: false)

// The user's x, y, ymin, and ymax columns, read from the mapping keys that
// hold them on the drawn axes.
#let user-columns(mapping, ctx) = {
  let (x, y) = if _flipped(ctx) { ("y", "x") } else { ("x", "y") }
  (
    x: mapping.at(x, default: none),
    y: mapping.at(y, default: none),
    ymin: mapping.at(y + "min", default: none),
    ymax: mapping.at(y + "max", default: none),
  )
}

// The mapping and trained key, `"x"` or `"y"`, that holds the user's `axis`.
#let user-axis-key(axis, ctx) = if not _flipped(ctx) { axis } else {
  if axis == "x" { "y" } else { "x" }
}

// Trained scales and canvas ranges of the user's x and y axes, or `none`
// when either scale is missing.
#let user-axes(ctx) = {
  let (x, y) = if _flipped(ctx) { ("y", "x") } else { ("x", "y") }
  let x-trained = ctx.trained.at(x, default: none)
  let y-trained = ctx.trained.at(y, default: none)
  if x-trained == none or y-trained == none { return none }
  (
    x-trained: x-trained,
    y-trained: y-trained,
    x-range: (ctx.coord.axis-range)(ctx, x),
    y-range: (ctx.coord.axis-range)(ctx, y),
  )
}

// The pair `(ux, uy)` along the user's x and y axes, in the canvas axis order:
// swapped under flip.
#let user-point(ctx, ux, uy) = if _flipped(ctx) { (uy, ux) } else {
  (ux, uy)
}

// Canvas point of the data point `(ux, uy)` in the user's x/y space.
#let project-user-point(ctx, ux, uy) = if _flipped(ctx) {
  project-point(ctx, uy, ux)
} else {
  project-point(ctx, ux, uy)
}

// Canvas points of a path through data points `(ux, uy)` in the user's x/y
// space, with the points the coord adds along each edge.
#let project-user-path(ctx, pairs) = project-path(
  ctx,
  if _flipped(ctx) { pairs.map(((ux, uy)) => (uy, ux)) } else { pairs },
)

// Canvas stair direction for a direction given in the user's x/y space:
// under flip the user's x runs vertically, so `"hv"` becomes `"vh"`.
#let user-stair-direction(direction, ctx) = if (
  not _flipped(ctx) or direction == none
) { direction } else if direction == "hv" { "vh" } else { "hv" }
