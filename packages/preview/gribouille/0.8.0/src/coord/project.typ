// The projection entry points geoms call. Each one routes through the coord
// carried in `ctx.coord`, so a geom never asks which coord it is drawn under.

#import "../scale/train.typ": map-axis, map-axis-data, map-position
#import "../utils/errors.typ": fail-enum

// Canvas `(cx, cy)` of a row's `(x, y)`, or `none` when either value does not
// resolve on its trained scale.
#let project-point(ctx, xv, yv) = (ctx.coord.project)(ctx, xv, yv)

// Canvas point of a pair of positions already mapped by `axis-mapper`.
#let to-canvas(ctx, u, v) = (ctx.coord.to-canvas)(ctx, u, v)

// Closure that maps one value of `axis` into the coord's range for that axis.
// The trained scale and the range are read once and captured, for a caller
// that maps many values off one axis. `space` names what the values are:
// `"row"` takes raw row cells and discrete levels (`map-position`), `"stat"`
// takes numbers already in stat space (`map-axis`), and `"data"` takes numbers
// in data space (`map-axis-data`). `range` is `auto` for the coord's range of
// the axis, or an explicit `(lo, hi)` for a caller that measures a canvas
// length off the axis instead.
#let axis-mapper(ctx, axis, space: "row", range: auto) = {
  let map = if space == "row" { map-position } else if space == "stat" {
    map-axis
  } else if space == "data" { map-axis-data } else {
    fail-enum("axis-mapper", "space", space, ("row", "stat", "data"))
  }
  let trained = ctx.trained.at(axis, default: none)
  if trained == none { return value => none }
  let axis-range = if range == auto { (ctx.coord.axis-range)(ctx, axis) } else {
    range
  }
  value => map(trained, value, axis-range)
}

// The `(u, v)` axis positions of `(xv, yv)` pairs, in order, with `none`
// for a pair that does not resolve on either trained scale. A caller that
// carries something per pair keeps it aligned before it drops the `none`s.
// `space` names what the values are, as in `axis-mapper`.
#let path-uvs(ctx, pairs, space: "row") = {
  let map-x = axis-mapper(ctx, "x", space: space)
  let map-y = axis-mapper(ctx, "y", space: space)
  pairs.map(((xv, yv)) => {
    let u = map-x(xv)
    let v = map-y(yv)
    if u == none or v == none { none } else { (u, v) }
  })
}

// Canvas points of a path through `(u, v)` axis positions, with the points
// the coord's `densify` adds so that each edge follows its grid. `closed`
// names the edge from the last point back to the first.
#let project-uvs(ctx, uvs, closed: false) = (ctx.coord.densify)(
  ctx,
  uvs,
  closed: closed,
).map(((u, v)) => (ctx.coord.to-canvas)(ctx, u, v))

// Canvas points of a path through `(xv, yv)` pairs, read in `space` as in
// `axis-mapper`. A pair that does not resolve is dropped, and its neighbours
// join each other directly.
#let project-path(ctx, pairs, closed: false, space: "row") = project-uvs(
  ctx,
  path-uvs(ctx, pairs, space: space).filter(uv => uv != none),
  closed: closed,
)
