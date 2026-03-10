// ctz-euclide/src/drawing/polygons.typ
// Polygon and shape drawing functions

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"

/// Internal key for drawn line segments (for label avoidance)
#let _drawn-lines-key = "ctz-drawn-lines"

// =============================================================================
// POLYGON DRAWING
// =============================================================================

/// Draw a polygon from named points
/// Usage: draw-polygon(cetz-draw, pt, "A", "B", "C", "D", stroke: black, fill: none)
#let draw-polygon(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let style = args.named()
  let stroke-style = style.at("stroke", default: black)
  let fill-style = style.at("fill", default: none)
  let close = style.at("close", default: true)

  cetz-draw.get-ctx(ctx => {
    let coords = names.map(name => {
      let (_, c) = cetz.coordinate.resolve(ctx, pt-func(name))
      c
    })

    // Manually close by concatenating first point at end
    if close and coords.len() > 0 {
      coords = coords + (coords.at(0),)
    }

    // Track drawn segments for label avoidance
    if coords.len() >= 2 {
      let drawn = ctx.shared-state.at(_drawn-lines-key, default: ())
      for i in range(0, coords.len() - 1) {
        drawn.push((coords.at(i), coords.at(i + 1)))
      }
      ctx.shared-state.insert(_drawn-lines-key, drawn)
    }

    cetz-draw.line(..coords, stroke: stroke-style, fill: fill-style)
  })
}

/// Fill a polygon (no stroke by default)
/// Usage: fill-polygon(cetz-draw, pt, "A", "B", "C", color: blue.lighten(80%), opacity: 0.5)
#let fill-polygon(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let style = args.named()
  let fill-color = style.at("color", default: gray.lighten(50%))
  let opacity = style.at("opacity", default: 1)
  let stroke-style = style.at("stroke", default: none)

  cetz-draw.get-ctx(ctx => {
    let coords = names.map(name => {
      let (_, c) = cetz.coordinate.resolve(ctx, pt-func(name))
      c
    })

    let actual-fill = if opacity < 1 {
      fill-color.transparentize((1 - opacity) * 100%)
    } else {
      fill-color
    }

    cetz-draw.line(..coords, close: true, stroke: stroke-style, fill: actual-fill)
  })
}

// =============================================================================
// CIRCLE DRAWING
// =============================================================================

/// Draw a circle with explicit radius (R option)
/// Usage: draw-circle-r(cetz-draw, "O", 3, stroke: black, fill: none)
#let draw-circle-r(cetz-draw, center, radius, stroke: black, fill: none) = {
  cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
}

/// Draw a circle through a point
/// Usage: draw-circle-through(cetz-draw, pt, "O", "A", stroke: black)
#let draw-circle-through(cetz-draw, pt-func, center-name, through-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, pt-func(center-name))
    let (_, t) = cetz.coordinate.resolve(ctx, pt-func(through-name))
    let radius = util.dist(c, t)
    cetz-draw.circle(c, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw a circle by diameter
/// Usage: draw-circle-diameter(cetz-draw, pt, "A", "B", stroke: black)
#let draw-circle-diameter(cetz-draw, pt-func, p1-name, p2-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))
    let center = util.midpoint(c1, c2)
    let radius = util.dist(c1, c2) / 2
    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw circumcircle of triangle
/// Usage: draw-circumcircle(cetz-draw, pt, "A", "B", "C", stroke: black)
#let draw-circumcircle(cetz-draw, pt-func, a-name, b-name, c-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pb) = cetz.coordinate.resolve(ctx, pt-func(b-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    // Calculate circumcenter
    let (pb1-p1, pb1-p2, mid-ab) = util.perpendicular-bisector(pa, pb)
    let (pb2-p1, pb2-p2, mid-ac) = util.perpendicular-bisector(pa, pc)

    let dx1 = pb1-p2.at(0) - pb1-p1.at(0)
    let dy1 = pb1-p2.at(1) - pb1-p1.at(1)
    let dx2 = pb2-p2.at(0) - pb2-p1.at(0)
    let dy2 = pb2-p2.at(1) - pb2-p1.at(1)

    let denom = dx1 * dy2 - dy1 * dx2
    if calc.abs(denom) < util.eps { return }

    let t = ((pb2-p1.at(0) - pb1-p1.at(0)) * dy2 - (pb2-p1.at(1) - pb1-p1.at(1)) * dx2) / denom
    let center = (pb1-p1.at(0) + t * dx1, pb1-p1.at(1) + t * dy1)
    let radius = util.dist(center, pa)

    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw incircle of triangle
/// Usage: draw-incircle(cetz-draw, pt, "A", "B", "C", stroke: black)
#let draw-incircle(cetz-draw, pt-func, a-name, b-name, c-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pb) = cetz.coordinate.resolve(ctx, pt-func(b-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    // Side lengths
    let la = util.dist(pb, pc)
    let lb = util.dist(pa, pc)
    let lc = util.dist(pa, pb)
    let total = la + lb + lc

    if total < util.eps { return }

    // Incenter
    let center = (
      (la * pa.at(0) + lb * pb.at(0) + lc * pc.at(0)) / total,
      (la * pa.at(1) + lb * pb.at(1) + lc * pc.at(1)) / total,
    )

    // Inradius = Area / s
    let abx = pb.at(0) - pa.at(0)
    let aby = pb.at(1) - pa.at(1)
    let acx = pc.at(0) - pa.at(0)
    let acy = pc.at(1) - pa.at(1)
    let area = calc.abs(abx * acy - aby * acx) / 2
    let s = total / 2
    let radius = area / s

    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw a semicircle with diameter AB
/// Usage: draw-semicircle(cetz-draw, pt, "A", "B", stroke: black, above: true)
#let draw-semicircle(cetz-draw, pt-func, p1-name, p2-name, stroke: black, fill: none, above: true) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))
    let center = util.midpoint(c1, c2)
    let radius = util.dist(c1, c2) / 2

    // Calculate start angle from p1
    let angle-rad = calc.atan2(c1.at(1) - center.at(1), c1.at(0) - center.at(0))
    // calc.atan2() returns an angle type, convert to degrees
    let start-deg = angle-rad / 1rad * 180deg / calc.pi

    if above {
      cetz-draw.arc(center, start: start-deg, stop: start-deg + 180deg, radius: radius, stroke: stroke, fill: fill)
    } else {
      cetz-draw.arc(center, start: start-deg, stop: start-deg - 180deg, radius: radius, stroke: stroke, fill: fill)
    }
  })
}

/// Draw a circular sector
/// Usage: draw-sector(cetz-draw, pt, "O", "A", "B", stroke: black, fill: blue.lighten(80%))
#let draw-sector(cetz-draw, pt-func, center-name, start-name, end-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, pt-func(center-name))
    let (_, s) = cetz.coordinate.resolve(ctx, pt-func(start-name))
    let (_, e) = cetz.coordinate.resolve(ctx, pt-func(end-name))

    let radius = util.dist(c, s)
    let start-angle = calc.atan2(s.at(1) - c.at(1), s.at(0) - c.at(0))
    let end-angle = calc.atan2(e.at(1) - c.at(1), e.at(0) - c.at(0))

    let start-deg = util.to-angle(if type(start-angle) == angle { start-angle / 1deg } else { start-angle * 180 / calc.pi })
    let end-deg = util.to-angle(if type(end-angle) == angle { end-angle / 1deg } else { end-angle * 180 / calc.pi })

    // Draw arc and lines to center to form sector
    cetz-draw.line(c, s, stroke: stroke)
    cetz-draw.arc(c, start: start-deg, stop: end-deg, radius: radius, stroke: stroke)
    cetz-draw.line(e, c, stroke: stroke)

    // Fill if requested - draw filled arc sector
    if fill != none {
      // Create a path for the filled sector
      let n-steps = 36
      let angle-diff = end-deg - start-deg
      let points = (c,)
      for i in range(n-steps + 1) {
        let angle = start-deg + angle-diff * i / n-steps
        points.push((c.at(0) + radius * calc.cos(angle), c.at(1) + radius * calc.sin(angle)))
      }
      cetz-draw.line(..points, close: true, fill: fill, stroke: none)
    }
  })
}
