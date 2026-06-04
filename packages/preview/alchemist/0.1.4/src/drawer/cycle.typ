#import "@preview/cetz:0.3.2"
#import "../utils/utils.typ"
#import "../utils/angles.typ"
#import "../utils/context.typ" as context_

#let max-int = 9223372036854775807

/// Insert missing vertices in the cycle
#let missing-vertices(ctx, vertex, cetz-ctx) = {
  let atom-sep = utils.convert-length(cetz-ctx, ctx.config.atom-sep)
  for i in range(ctx.cycle-faces - vertex.len()) {
    let (x, y, _) = vertex.last()
    vertex.push((
      x + atom-sep * calc.cos(ctx.relative-angle + ctx.cycle-step-angle * (i + 1)),
      y + atom-sep * calc.sin(ctx.relative-angle + ctx.cycle-step-angle * (i + 1)),
      0,
    ))
  }
  vertex
}

/// extrapolate the center and the radius of the cycle
#let cycle-center-radius(ctx, cetz-ctx, vertex) = {
  let min-radius = max-int
  let center = (0, 0)
  let faces = ctx.cycle-faces
  let odd = calc.rem(faces, 2) == 1
	let debug = ()
  for (i, v) in vertex.enumerate() {
    if (ctx.config.debug) {
      debug += cetz.draw.circle(v, radius: .1em, fill: blue, stroke: blue)
    }
    let (x, y, _) = v
    center = (center.at(0) + x, center.at(1) + y)
    if odd {
      let opposite1 = calc.rem-euclid(i + calc.div-euclid(faces, 2), faces)
      let opposite2 = calc.rem-euclid(i + calc.div-euclid(faces, 2) + 1, faces)
      let (ox1, oy1, _) = vertex.at(opposite1)
      let (ox2, oy2, _) = vertex.at(opposite2)
      let radius = utils.distance-between(cetz-ctx, (x, y), ((ox1 + ox2) / 2, (oy1 + oy2) / 2)) / 2
      if radius < min-radius {
        min-radius = radius
      }
    } else {
      let opposite = calc.rem-euclid(i + calc.div-euclid(faces, 2), faces)
      let (ox, oy, _) = vertex.at(opposite)
      let radius = utils.distance-between(cetz-ctx, (x, y), (ox, oy)) / 2
      if radius < min-radius {
        min-radius = radius
      }
    }
  }
  ((center.at(0) / vertex.len(), center.at(1) / vertex.len()), min-radius, debug)
}

#let draw-cycle-center-arc(ctx, name, center-arc) = {
	import cetz.draw: *
  let faces = ctx.cycle-faces
  let vertex = ctx.vertex-anchors
  get-ctx(cetz-ctx => {
    let (cetz-ctx, ..vertex) = cetz.coordinate.resolve(cetz-ctx, ..vertex)
    if vertex.len() < faces {
      vertex = missing-vertices(ctx, cetz-ctx)
    }
    let (center, min-radius, debug) = cycle-center-radius(ctx, cetz-ctx, vertex)
		debug
    if name != none {
      group(
        name: name,
        {
          anchor("default", center)
        },
      )
    }
    if center-arc != none {
      if min-radius == max-int {
        panic("The cycle has no opposite vertices")
      }
      if ctx.cycle-faces > 4 {
        min-radius *= center-arc.at("radius", default: 0.7)
      } else {
        min-radius *= center-arc.at("radius", default: 0.5)
      }
      let start = center-arc.at("start", default: 0deg)
      let end = center-arc.at("end", default: 360deg)
      let delta = center-arc.at("delta", default: end - start)
      center = (
        center.at(0) + min-radius * calc.cos(start),
        center.at(1) + min-radius * calc.sin(start),
      )
      arc(
        center,
        ..center-arc,
        radius: min-radius,
        start: start,
        delta: delta,
      )
    }
  })
}

#let draw-cycle(cycle, ctx, draw-molecules-and-link) = {
  let cycle-step-angle = 360deg / cycle.faces
  let angle = angles.angle-from-ctx(ctx, cycle.args, none)
  if angle == none {
    if ctx.in-cycle {
      angle = ctx.relative-angle - (180deg - cycle-step-angle)
      if ctx.faces-count != 0 {
        angle += ctx.cycle-step-angle
      }
    } else if (
      ctx.relative-angle == 0deg
        and ctx.angle == 0deg
        and not cycle.args.at(
          "align",
          default: false,
        )
    ) {
      angle = cycle-step-angle - 90deg
    } else {
      angle = ctx.relative-angle - (180deg - cycle-step-angle) / 2
    }
  }
  let first-molecule = none
  if ctx.last-anchor.type == "molecule" {
    first-molecule = ctx.last-anchor.name
    if first-molecule not in ctx.hooks {
      ctx.hooks.insert(first-molecule, ctx.last-anchor)
    }
  }
  let name = none
  let record-vertex = false
  if "name" in cycle.args {
    name = cycle.args.at("name")
    record-vertex = true
  } else if "arc" in cycle.args {
    record-vertex = true
  }
  let (cycle-ctx, drawing, parenthesis-drawing-rec, cetz-rec) = draw-molecules-and-link(
    (
      ..ctx,
      in-cycle: true,
      cycle-faces: cycle.faces,
      faces-count: 0,
      first-branch: true,
      cycle-step-angle: cycle-step-angle,
      relative-angle: angle,
      first-molecule: first-molecule,
      angle: angle,
      record-vertex: record-vertex,
      vertex-anchors: (),
    ),
    cycle.body,
  )
  ctx = context_.update-parent-context(ctx, cycle-ctx)
  if record-vertex {
    drawing += draw-cycle-center-arc(cycle-ctx, name, cycle.args.at("arc", default: none))
  }
	(ctx, drawing, parenthesis-drawing-rec, cetz-rec)
}
