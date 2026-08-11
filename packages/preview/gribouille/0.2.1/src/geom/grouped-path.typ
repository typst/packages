// Shared scaffolding for line/path/step. Each geom supplies `build-pts`,
// the rows -> screen points transformation that distinguishes it
// (path: input order; line: sort by x; step: sort + stair).

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

// Sort rows by their x value: numeric for continuous scales, domain index
// for discrete ones. Drops rows whose x value can't be resolved.
#let sort-rows-by-x(rows, mapping, x-trained) = {
  rows
    .map(row => {
      let xv = row.at(mapping.x, default: none)
      let xn = if x-trained.type == "continuous" {
        parse-number(xv)
      } else {
        x-trained.domain.position(v => v == str(xv))
      }
      (row: row, xn: xn)
    })
    .filter(p => p.xn != none)
    .sorted(key: p => p.xn)
    .map(p => p.row)
}

// Map rows to (cx, cy) screen positions via `project-point`, which routes
// through `ctx.radial` when active. Skips rows whose mapped position fails
// to resolve.
#let rows-to-points(rows, mapping, ctx) = {
  let pts = ()
  for row in rows {
    let p = project-point(
      ctx,
      row.at(mapping.x, default: none),
      row.at(mapping.y, default: none),
    )
    if p == none { continue }
    pts.push(p)
  }
  pts
}

#let draw-grouped-paths(layer, ctx, build-pts) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  if x-trained == none { return }

  // theme.geom.colour fills in for unmapped lines so a brand colour propagates;
  // resolve-channel("linewidth", ...) folds the auto/theme/per-geom-default
  // cascade for stroke thickness.
  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = build-pts(rows, layer, mapping, x-trained, ctx)
    if pts.len() < 2 { continue }

    let leader = rows.first()
    let final-colour = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      leader,
      theme-colour,
    )
    let dash = resolve-channel("linetype", layer, mapping, ctx, leader, none)
    let thickness = resolve-channel(
      "linewidth",
      layer,
      mapping,
      ctx,
      leader,
      0.8pt,
    )
    cetz.draw.line(
      ..pts,
      stroke: (paint: final-colour, thickness: thickness, dash: dash),
    )
  }
}
