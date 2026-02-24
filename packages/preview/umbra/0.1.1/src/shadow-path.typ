// Gets the length of an arbitrary vector
#let _norm(p) = calc.sqrt(p.map(x => calc.pow(x.pt(), 2)).sum()) * 1pt
// Adds any number of arbitrary vectors
#let _add(..ps) = ps.pos().fold(
  none,
  (acc, x) => if acc == none { x } else { acc.zip(x).map(((y, z)) => y + z) },
)
// Takes the first vector and subtracts all subsequent vectors from it
#let _sub(..ps) = ps.pos().fold(
  none,
  (acc, x) => if acc == none { x } else { acc.zip(x).map(((y, z)) => y - z) },
)
// Rotates a 2D vector by the given angle
#let _rot(p, angle) = (
  p.first() * calc.cos(angle) - p.last() * calc.sin(angle),
  p.first() * calc.sin(angle) + p.last() * calc.cos(angle),
)
// Multiply (scale) a vector by some number
#let _mult(p, x) = p.map(y => x * y)
// Roll a vector by count positions, moving the overflow at the end back to the start
#let _roll(arr, count) = (arr.slice(count) + arr).slice(0, arr.len())

#let shadow-path(
  fill: none,
  stroke: none,
  closed: false,
  shadow-radius: 0.5cm,
  shadow-stops: (gray, white),
  // A small correction is required otherwise there is a white line between shadow sections
  correction: 5deg,
  ..vertices,
) = {
  let vertices = vertices.pos()
  assert(
    vertices.all(x => x.len() == 2 and x.all(y => type(y) != array)),
    message: "paths with Bezier control points not supported",
  )
  layout(
    size => {
      let vertices = vertices.map(((x, y)) => (
        if type(x) == ratio { x * size.width } else { x },
        if type(y) == ratio { y * size.height } else { y },
      ))

      let groups = vertices.zip(_roll(vertices, 1), _roll(vertices, 2), _roll(vertices, 3))
      if not closed {
        groups = _roll(groups, -1).slice(0, -1)
      }

      // Setup edge shadows
      for (p0, p1, p2, p3) in groups {
        let angle0 = calc.atan2(.._sub(p1, p0).map(x => x.pt()))
        angle0 += if angle0 > 0deg { 0deg } else { 360deg }
        let angle1 = calc.atan2(.._sub(p2, p1).map(x => x.pt()))
        angle1 += if angle1 > 0deg { 0deg } else { 360deg }
        let angle2 = calc.atan2(.._sub(p3, p2).map(x => x.pt()))
        angle2 += if angle2 > 0deg { 0deg } else { 360deg }

        let width = shadow-radius
        let height = _norm(_sub(p1, p2))
        let d0 = 0pt
        let d1 = 0pt

        let da0 = angle1 - angle0
        let da1 = angle2 - angle1
        if da0 < 0deg or da0 > 180deg {
          da0 = 0
        }
        if da1 < 0deg or da1 > 180deg {
          da1 = 0
        }
        place(top + left, dx: p2.first(), dy: p2.last(), rotate(
          calc.atan2(.._sub(p1, p2).map(x => x.pt())) + 90deg + 180deg,
          origin: top + left,
          polygon(
            fill: gradient.linear(..shadow-stops),
            (0pt, 0pt),
            _rot((width, 0pt), da1 / 2),
            _add((0pt, height), _rot((width, 0pt), -da0 / 2)),
            (0pt, height),
          ),
        ))
      }

      // Setup corner shadows
      if not closed {
        groups = groups.slice(1)
      }

      for (p0, p1, p2, p3) in groups {
        let angle0 = calc.atan2(.._sub(p1, p0).map(x => x.pt()))
        angle0 += if angle0 > 0deg { 0deg } else { 360deg }
        let angle1 = calc.atan2(.._sub(p2, p1).map(x => x.pt()))
        angle1 += if angle1 > 0deg { 0deg } else { 360deg }

        let da = angle1 - angle0
        if da < 0deg or da > 180deg {
          da = calc.abs(da)
          let d0 = _rot((shadow-radius, 0pt), angle0 + 90deg + correction)
          let d1 = _rot((shadow-radius, 0pt), angle1 + 90deg - correction)
          // Must be placed in the correct location, otherwise the gradient is based on the size of the whole box
          place(
            top + left,
            dx: p1.first() - shadow-radius,
            dy: p1.last() - shadow-radius,
            box(
              // A fixed size box is required to make radial gradient work. For PDF, the gradient doesn't actually have to be contained by the box, but this breaks with PNG, hence the extra complexity
              width: 2 * shadow-radius,
              height: 2 * shadow-radius,
              place(
                top + left,
                dx: 50%,
                dy: 50%,
                curve(
                  fill: gradient.radial(..shadow-stops, center: (50%, 50%), radius: 50%, relative: "parent"),
                  curve.move((0pt, 0pt)),
                  curve.line(d1),
                  curve.cubic(
                    _add(d1, _mult(_rot(d1, 90deg), calc.sin(da / 2))),
                    _add(d0, _mult(_rot(d0, -90deg), calc.sin(da / 2))),
                    d0,
                  ),
                  curve.close(mode: "straight"),
                ),
              ),
            ),
          )
        }
      }

      if fill != none or stroke != none {
        curve(fill: fill, stroke: stroke,
          curve.move(vertices.first()),
          ..vertices.slice(1).map(curve.line),
          ..if closed {
            (curve.close(),)
          },
        )
      }
    },
  )
}

#let shadow-circle(
  radius: 0pt,
  width: auto,
  height: auto,
  fill: none,
  stroke: none,
  inset: 5pt,
  outset: (:),
  shadow-radius: 0.5cm,
  shadow-stops: (gray, white),
  // A small correction factor to avoid a line between the shadow and the fill
  correction: 0.00001%,
  ..body,
) = {
  assert(
    (radius, width, height).filter(it => it == 0pt or it == auto or it == none).len() >= 2,
    message: "radius, width and height are mutually exclusive",
  )
  layout(
    size => {
      // Replicate the built in optional positional body argument
      assert(
        body.named().len() == 0 and body.pos().len() <= 1,
        message: "unexpected argument",
      )
      let body = if body.pos().len() == 1 { body.pos().first() } else { none }

      // Width and height seem to only be to allow for sizing relative to parent
      let radius = radius
      if not (width == 0pt or width == auto or width == none) {
        if type(width) == ratio {
          radius = width * size.width
        } else {
          radius = width
        }
      } else if not (height == 0pt or height == auto or height == none) {
        if type(height) == ratio {
          radius = height * size.height
        } else {
          radius = height
        }
      }

      // Avoid an unnecessary place
      let inner = circle(
        radius: radius + shadow-radius,
        fill: gradient.radial(
          // Making it transparent doesn't actually do anything yet since gradients
          // can't handle transparency
          (shadow-stops.last().transparentize(100%), 0%),
          (
            shadow-stops.last().transparentize(100%),
            radius / (radius + shadow-radius) * 100% - correction,
          ),
          ..shadow-stops.enumerate().map(
            ((i, stop)) => (
              stop,
              (radius + shadow-radius * i / (shadow-stops.len() - 1)) / (radius + shadow-radius) * 100%,
            ),
          ),
        ),
        stroke: none,
        inset: inset,
        outset: outset,
      )

      if fill != none or stroke != none or body != none {
        place(inner)
        place(dx: shadow-radius, dy: shadow-radius, circle(
          radius: radius,
          fill: fill,
          stroke: stroke,
          inset: inset,
          outset: outset,
          body,
        ))
      } else {
        inner
      }
    },
  )
}
