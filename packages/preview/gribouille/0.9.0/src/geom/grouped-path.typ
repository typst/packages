// Shared scaffolding for line/path/step. Each geom supplies `build-pts`,
// the rows -> screen points transformation that distinguishes it
// (path: input order; line: sort by x; step: sort + stair).

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/arrow.typ": draw-arrow-heads
#import "../utils/level-resolve.typ": discrete-index
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../coord/project.typ": path-uvs, project-uvs
#import "../utils/stair.typ": stair
#import "../utils/flip.typ": user-axes, user-columns
#import "../position/dodge.typ": dodge-geometry, dodge-uv
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

// The `spec` record of line, path, and step: the draw path below reads the
// same keys for all three.
#let spec = (
  reads: ("x", "y", "colour", "alpha", "linewidth", "linetype"),
  extents: none,
)

// Sort rows by their x value: numeric for continuous scales, domain index
// for discrete ones. Drops rows whose x value can't be resolved. Sorts by
// the user's x, which coord-flip draws vertically.
#let sort-rows-by-x(rows, mapping, ctx) = {
  let x-col = user-columns(mapping, ctx).x
  let axes = user-axes(ctx)
  if x-col == none or axes == none { return () }
  let x-trained = axes.x-trained
  rows
    .map(row => {
      let xv = row.at(x-col, default: none)
      let xn = if x-trained.type == "continuous" {
        parse-number(xv)
      } else {
        discrete-index(x-trained, xv)
      }
      (row: row, xn: xn)
    })
    .filter(p => p.xn != none)
    .sorted(key: p => p.xn)
    .map(p => p.row)
}

// Map rows to (cx, cy) screen positions through the coord, which curves each
// edge along its grid (`project-uvs`). Skips rows whose mapped position fails
// to resolve, so their neighbours join directly. A non-`none` `direction`
// (`"hv"` or `"vh"`) steps the mapped positions into a staircase first, so
// under `coord-radial` the treads follow the circles.
//
// `dodge` is the slot `dodge-geometry` answered for the whole layer. It is
// resolved once there and handed down because resolving it costs a pass over
// every row on a continuous category axis, and this runs once a group. Each
// row's mapped position takes its own dodge shift before the staircase and the
// projection, so a corner and the points the coord adds along an edge follow
// the shifted positions.
#let rows-to-points(rows, mapping, ctx, dodge, direction: none) = {
  let uvs = ()
  let mapped = path-uvs(ctx, rows.map(row => (
    row.at(mapping.x, default: none),
    row.at(mapping.y, default: none),
  )))
  for (row, uv) in rows.zip(mapped) {
    if uv == none { continue }
    uvs.push(if dodge == none { uv } else { dodge-uv(dodge, row, uv) })
  }
  if uvs.len() == 0 { return () }
  if direction != none { uvs = stair(uvs, direction) }
  project-uvs(ctx, uvs)
}

#let draw-grouped-paths(layer, ctx, build-pts) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }

  // theme.geom.colour fills in for unmapped lines so a brand colour propagates;
  // resolve-channel("linewidth", ...) folds the auto/theme/per-geom-default
  // cascade for stroke thickness.
  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  // All three are the layer's, not the group's: resolving the slot per group
  // would scan every row of the layer again, and passing the layer itself into
  // a per-group call carries those rows with it.
  let params = layer.params
  // One head per group, at the ends of the whole path rather than each join.
  let arrow-spec = params.at("arrow", default: none)
  let dodge = dodge-geometry(ctx, layer)

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = build-pts(rows, params, mapping, ctx, dodge)
    if pts.len() < 2 { continue }

    let leader = rows.first()
    let final-colour = resolve-channel(
      "colour",
      params,
      mapping,
      ctx,
      leader,
      theme-colour,
    )
    let dash = resolve-channel(
      "linetype",
      params,
      mapping,
      ctx,
      leader,
      none,
    )
    let thickness = resolve-channel(
      "linewidth",
      params,
      mapping,
      ctx,
      leader,
      0.8pt,
    )
    cetz.draw.line(
      ..pts,
      stroke: (paint: final-colour, thickness: thickness, dash: dash),
    )
    draw-arrow-heads(pts, arrow-spec, final-colour, thickness)
  }
}
