#import "@preview/cetz:0.5.2"
#import "../geometry/lib.typ": add, sub, scale, rotate, polar
#import "styles.typ": default-theme

/// Create a CeTZ canvas configured with the PhysKit drawing defaults.
#let canvas(theme: default-theme, body) = cetz.canvas({
  import cetz.draw: *
  set-style(
    stroke: theme.ink + theme.stroke,
    mark: (transform-shape: false, fill: theme.ink),
    content: (padding: 2pt),
  )
  body
})

/// Draw a line segment.
#let line(start, end, stroke: default-theme.ink + default-theme.stroke) = {
  cetz.draw.line(start, end, stroke: stroke)
}

/// Draw a closed polygonal path.
#let polygon(..points, fill: none, stroke: default-theme.ink + default-theme.stroke) = {
  cetz.draw.line(..points.pos(), close: true, fill: fill, stroke: stroke)
}

/// Draw a circle.
#let circle(center, radius: 0.5, fill: none, stroke: default-theme.ink + default-theme.stroke) = {
  cetz.draw.circle(center, radius: radius, fill: fill, stroke: stroke)
}

/// Draw an arc given its center, radius and angular limits.
#let arc(center, radius, start, stop, stroke: default-theme.ink + default-theme.stroke) = {
  cetz.draw.arc(
    polar(center, radius, start),
    start: start,
    stop: stop,
    radius: radius,
    stroke: stroke,
  )
}

/// Draw arbitrary content at a coordinate.
#let label(at, value, anchor: "center", offset: (0, 0)) = {
  cetz.draw.content(add(at, offset), value, anchor: anchor)
}

/// Draw an arrow between two points.
#let arrow(
  start,
  end,
  label: none,
  color: default-theme.accent,
  stroke: 1.15pt,
  label-position: 55%,
  label-offset: (0, 0.22),
) = {
  cetz.draw.line(
    start,
    end,
    stroke: color + stroke,
    mark: (end: "stealth", fill: color, transform-shape: false),
  )
  if label != none {
    let p = add(start, scale(sub(end, start), label-position / 100%))
    cetz.draw.content(add(p, label-offset), label, anchor: "center")
  }
}

/// Draw a rotated rectangle centered at `center`.
#let rectangle(
  center,
  width: 1.2,
  height: 0.8,
  angle: 0deg,
  fill: default-theme.body-fill,
  stroke: default-theme.ink + 0.75pt,
) = {
  let local = (
    (-width / 2, -height / 2),
    ( width / 2, -height / 2),
    ( width / 2,  height / 2),
    (-width / 2,  height / 2),
  )
  let points = local.map(p => add(center, rotate(p, angle)))
  cetz.draw.line(..points, close: true, fill: fill, stroke: stroke)
}

/// Draw a finite hatched surface.
#let surface(
  start,
  end,
  hatch-side: -1,
  hatch: true,
  color: default-theme.surface-ink,
) = {
  cetz.draw.line(start, end, stroke: color + 0.9pt)
  if hatch {
    let d = sub(end, start)
    let length = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
    let n = calc.floor(length / 0.35)
    if n > 0 {
      let t = scale(d, 1 / length)
      let normal = (-t.at(1) * hatch-side, t.at(0) * hatch-side)
      for i in range(n + 1) {
        let p = add(start, scale(d, i / n))
        let q = add(add(p, scale(t, -0.13)), scale(normal, 0.18))
        cetz.draw.line(p, q, stroke: color + 0.45pt)
      }
    }
  }
}
