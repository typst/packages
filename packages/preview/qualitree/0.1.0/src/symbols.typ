// Native vector primitives. Coordinates are canvas-local lengths; helpers
// reserve their own bounds so placed strokes never change surrounding flow.

// Every segment has a nonnegative local bounding box, including roof diagonals.
#let _segment(x1, y1, x2, y2, pen) = {
  let x = calc.min(x1, x2)
  let y = calc.min(y1, y2)
  place(top + left, dx: x, dy: y,
    line(start: (x1 - x, y1 - y), end: (x2 - x, y2 - y), stroke: pen))
}

// A single path per contiguous profile preserves dash phase and line joins.
#let _polyline(points, pen) = {
  if points.len() < 2 { return [] }
  let x = calc.min(..points.map(p => p.at(0)))
  let y = calc.min(..points.map(p => p.at(1)))
  let local = points.map(p => (p.at(0) - x, p.at(1) - y))
  place(top + left, dx: x, dy: y,
    curve(stroke: pen, fill: none, curve.move(local.first()),
      ..local.slice(1).map(p => curve.line(p))))
}

#let _frame(x, y, w, h, pen) = place(top + left, dx: x, dy: y,
  rect(width: w, height: h, inset: 0pt, stroke: pen, fill: none))

#let _marker(shape, size, paint, fill: none, thickness: 0.7pt) = {
  let pen = (paint: paint, thickness: thickness, join: "round")
  let drawing = if shape == "circle" {
    circle(radius: size / 2, fill: fill, stroke: pen)
  } else if shape == "square" {
    rect(width: size, height: size, inset: 0pt, fill: fill, stroke: pen)
  } else if shape == "diamond" {
    polygon((size / 2, 0pt), (size, size / 2), (size / 2, size), (0pt, size / 2),
      fill: fill, stroke: pen)
  } else {
    let n = if shape == "triangle" { 3 } else { 5 }
    let vertices = range(n).map(k => {
      let angle = -90deg + k * 360deg / n
      (size / 2 + size / 2 * calc.cos(angle), size / 2 + size / 2 * calc.sin(angle))
    })
    polygon(..vertices, fill: fill, stroke: pen)
  }
  box(width: size, height: size, place(top + left, drawing))
}

#let _relation(value, size, ink, thickness: 0.8pt) = {
  if value == 9 { _marker("circle", size, ink, fill: ink, thickness: thickness) }
  else if value == 3 { _marker("circle", size, ink, fill: none, thickness: thickness) }
  else if value == 1 { _marker("triangle", size * 1.2, ink, fill: none, thickness: thickness) }
  else { [] }
}

// Strong signs use a circle to stay distinct at small print sizes.
#let _sign(value, style: "circled", size: 9pt, ink: black, thickness: 0.9pt) = {
  let strong-sign = value in ("++", "--")
  let positive = value in ("+", "++")
  if style == "text" {
    text(size: size, weight: "bold", fill: ink,
      if value == "-" { "−" } else if value == "--" { "−−" } else { value })
  } else {
    box(width: size, height: size, {
      let pen = (paint: ink, thickness: thickness, cap: "round")
      if strong-sign { circle(radius: size / 2, stroke: pen) }
      _segment(size * 0.2, size / 2, size * 0.8, size / 2, pen)
      if positive { _segment(size / 2, size * 0.2, size / 2, size * 0.8, pen) }
    })
  }
}

#let _direction(value) = {
  if value == "maximize" { [↑] }
  else if value == "minimize" { [↓] }
  else if value == "target" { [◎] } else { [] }
}


