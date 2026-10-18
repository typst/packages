// Shared draw-time helpers for text/label/typst geoms: data-unit nudge
// projection, per-row placements, AABB build, connector routing, and arrow
// rendering. Kept here so the three geoms do not redeclare the same bits.

#import "../deps.typ": cetz
#import "aes-resolve.typ": aes-col
#import "radial.typ": project-point
#import "repel.typ": repel
#import "segment-route.typ": aabb-from-centre, route-segment
#import "types.typ": parse-number

// Names of the geoms that share this draw pipeline. Treated as the single
// source of truth by the renderer's pre-canvas size pass.
#let LABEL-GEOMS = ("text", "label", "typst")

// Renderer-owned key; geoms never reach into the layer dict directly.
#let label-sizes-of(layer) = layer.at("_label-sizes", default: ())

// Convert per-row offsets expressed in data units (`nx`, `ny`) to canvas-cm
// deltas using the trained scales currently in `ctx`. Returns `(0, 0)` when
// the row's anchor or shifted point fail to project.
#let nudge-cm(ctx, x-val, y-val, nx, ny) = {
  if nx == 0 and ny == 0 { return (0.0, 0.0) }
  let base = project-point(ctx, x-val, y-val)
  if base == none { return (0.0, 0.0) }
  let (bx, by) = base
  let dx = 0.0
  let dy = 0.0
  if nx != 0 {
    let shifted = project-point(ctx, x-val + nx, y-val)
    if shifted != none { dx = shifted.at(0) - bx }
  }
  if ny != 0 {
    let shifted = project-point(ctx, x-val, y-val + ny)
    if shifted != none { dy = shifted.at(1) - by }
  }
  (dx, dy)
}

#let _read-num(col, row) = if col == none { 0 } else {
  let v = parse-number(row.at(col, default: none))
  if v == none { 0 } else { v }
}

// Compute per-row anchor + label-centre pairs (canvas-cm) for one layer.
// `placements.at(idx)` is `none` when the row fails to project so callers
// can skip without re-checking inputs.
#let compute-placements(ctx, mapping, data, dx-base, dy-base) = {
  let nudge-x-col = aes-col(mapping.at("nudge-x", default: none))
  let nudge-y-col = aes-col(mapping.at("nudge-y", default: none))
  let needs-nudge = nudge-x-col != none or nudge-y-col != none
  data
    .enumerate()
    .map(((idx, row)) => {
      let xv = row.at(mapping.x, default: none)
      let yv = row.at(mapping.y, default: none)
      let projected = project-point(ctx, xv, yv)
      if projected == none { return none }
      let (cx, cy) = projected
      let (nudge-dx, nudge-dy) = if not needs-nudge {
        (0.0, 0.0)
      } else {
        let xn = parse-number(xv)
        let yn = parse-number(yv)
        if xn == none or yn == none { (0.0, 0.0) } else {
          nudge-cm(
            ctx,
            xn,
            yn,
            _read-num(nudge-x-col, row),
            _read-num(nudge-y-col, row),
          )
        }
      }
      (
        anchor: (cx, cy),
        centre: (cx + nudge-dx + dx-base, cy + nudge-dy + dy-base),
        idx: idx,
      )
    })
}

// Compute placements via the repulsion algorithm. `sizes` is the per-row
// label-size array stashed by the renderer; `repel-params` is the geom's
// repel-related layer params already extracted as a record.
#let compute-repel-placements(ctx, mapping, data, sizes, repel-params) = {
  let live-idx = ()
  let anchors = ()
  let live-sizes = ()
  for (idx, row) in data.enumerate() {
    let xv = row.at(mapping.x, default: none)
    let yv = row.at(mapping.y, default: none)
    let projected = project-point(ctx, xv, yv)
    if projected == none { continue }
    live-idx.push(idx)
    anchors.push(projected)
    live-sizes.push(sizes.at(idx, default: (w: 0.0, h: 0.0)))
  }
  let offsets = repel(anchors, live-sizes, params: repel-params)
  let placements = data.map(_ => none)
  for (i, idx) in live-idx.enumerate() {
    let (ax, ay) = anchors.at(i)
    let (dx, dy) = offsets.at(i)
    placements.at(idx) = (
      anchor: (ax, ay),
      centre: (ax + dx, ay + dy),
      idx: idx,
    )
  }
  placements
}

// Inflate each measured label size into a canvas-cm AABB at the placement's
// label centre. Returns `none` entries where the placement itself was `none`.
#let compute-aabbs(placements, sizes, pad) = placements.map(p => {
  if p == none { return none }
  let s = sizes.at(p.idx, default: (w: 0.0, h: 0.0))
  aabb-from-centre(p.centre, s.w, s.h, pad: pad)
})

// Pull the repel tuning knobs off the layer params dict into the flat
// record `src/utils/repel.typ` expects.
#let repel-params-of(params) = (
  box-padding: params.box-padding,
  point-padding: params.point-padding,
  max-iter: params.max-iter,
  force-pull: params.force-pull,
  force-push: params.force-push,
  force-segment: params.force-segment,
  seed: params.seed,
)

// Pull the connector-related layer params into a flat record. Resolves
// `auto` colour against the theme `ink` so callers do not branch.
#let segment-config(params, theme-colour) = {
  let colour = if params.segment-colour == auto { theme-colour } else {
    params.segment-colour
  }
  let arrow-len = params.arrow-length
  (
    colour: colour,
    stroke: params.segment-stroke,
    min-length: params.min-segment-length,
    arrow: params.arrow,
    arrow-length-cm: if type(arrow-len) == length { arrow-len / 1cm } else {
      arrow-len
    },
  )
}

// Resolve every layer param that drives text/label/typst draw geometry
// into a single record so the geoms do not each repeat the same setup.
#let prepare-draw(layer, ctx, mapping, data, theme-colour) = {
  let dx-base = if type(layer.params.dx) == length {
    layer.params.dx / 1cm
  } else {
    layer.params.dx
  }
  let dy-base = if type(layer.params.dy) == length {
    layer.params.dy / 1cm
  } else {
    layer.params.dy
  }
  let segment-on = layer.params.segment
  let repel-on = layer.params.repel
  let needs-placement = (
    segment-on
      or repel-on
      or (
        mapping.at("nudge-x", default: none) != none
          or mapping.at("nudge-y", default: none) != none
      )
  )
  let sizes = label-sizes-of(layer)
  let placements = if repel-on {
    compute-repel-placements(
      ctx,
      mapping,
      data,
      sizes,
      repel-params-of(layer.params),
    )
  } else if needs-placement {
    compute-placements(ctx, mapping, data, dx-base, dy-base)
  } else { () }
  let aabbs = if segment-on {
    compute-aabbs(placements, sizes, layer.params.box-padding)
  } else { () }
  let seg-cfg = if segment-on {
    segment-config(layer.params, theme-colour)
  }
  (
    segment-on: segment-on,
    repel-on: repel-on,
    needs-placement: needs-placement,
    placements: placements,
    aabbs: aabbs,
    seg-cfg: seg-cfg,
    dx-base: dx-base,
    dy-base: dy-base,
  )
}

// Resolve one row's final label-centre `(cx, cy)` using the placements
// produced by `prepare-draw` when available, falling back to a direct
// `project-point` when neither nudge nor segment is in play.
#let row-centre(state, ctx, mapping, idx, row) = {
  if state.needs-placement {
    let p = state.placements.at(idx)
    if p == none { return none }
    return p.centre
  }
  let projected = project-point(
    ctx,
    row.at(mapping.x, default: none),
    row.at(mapping.y, default: none),
  )
  if projected == none { return none }
  (projected.at(0) + state.dx-base, projected.at(1) + state.dy-base)
}

// Open V-mark at the anchor end of a connector. The two short strokes meet
// at the anchor point and open back toward `towards` at a 25-degree
// half-angle.
#let _draw-arrow-head(anchor, towards, length-cm, colour, thickness) = {
  let (ax, ay) = anchor
  let (tx, ty) = towards
  let dx = tx - ax
  let dy = ty - ay
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 1e-6 { return }
  let ux = dx / len
  let uy = dy / len
  let cos-a = calc.cos(25deg)
  let sin-a = calc.sin(25deg)
  let lx1 = ax + length-cm * (ux * cos-a - uy * sin-a)
  let ly1 = ay + length-cm * (uy * cos-a + ux * sin-a)
  let lx2 = ax + length-cm * (ux * cos-a + uy * sin-a)
  let ly2 = ay + length-cm * (uy * cos-a - ux * sin-a)
  cetz.draw.line(
    (lx1, ly1),
    (ax, ay),
    (lx2, ly2),
    stroke: (paint: colour, thickness: thickness),
  )
}

// Render a routed connector for one row when its label has been moved off
// the anchor by at least `cfg.min-length`. `cfg` carries the resolved
// `(colour, stroke, min-length, arrow, arrow-length-cm)` tuple already
// merged with theme defaults so this loop body stays straight-line.
#let draw-segment(idx, placement, aabbs, cfg) = {
  let own = aabbs.at(idx)
  if own == none { return }
  let (ax, ay) = placement.anchor
  let (lx, ly) = placement.centre
  let dxc = lx - ax
  let dyc = ly - ay
  let dist = calc.sqrt(dxc * dxc + dyc * dyc)
  if dist < cfg.min-length { return }
  let route = route-segment(
    placement.anchor,
    placement.centre,
    own,
    aabbs,
    idx,
  )
  if route == none { return }
  cetz.draw.line(
    ..route,
    stroke: (paint: cfg.colour, thickness: cfg.stroke),
  )
  if cfg.arrow and route.len() >= 2 {
    _draw-arrow-head(
      route.at(0),
      route.at(1),
      cfg.arrow-length-cm,
      cfg.colour,
      cfg.stroke,
    )
  }
}
