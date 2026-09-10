// Coordinate transform utilities.

#let to-cm(v) = if type(v) == length { v.cm() } else { v }

#let merge-segment-runs(segments) = {
  let runs = ()
  let current = ()
  for (p1, p2) in segments {
    if current.len() == 0 {
      current = (p1, p2)
    } else {
      let last = current.last()
      if calc.abs(last.at(0) - p1.at(0)) < 1e-9 and calc.abs(last.at(1) - p1.at(1)) < 1e-9 {
        current.push(p2)
      } else {
        runs.push(current)
        current = (p1, p2)
      }
    }
  }
  if current.len() > 0 { runs.push(current) }
  runs
}

#let clip-segment(p1, p2, xmin, ymin, xmax, ymax) = {
  let (x1, y1) = p1
  let (x2, y2) = p2

  let dx = x2 - x1
  let dy = y2 - y1

  let t0 = 0.0
  let t1 = 1.0

  let edges = (
    (-dx, x1 - xmin),
    (dx, xmax - x1),
    (-dy, y1 - ymin),
    (dy, ymax - y1),
  )

  for (p, q) in edges {
    if p == 0 {
      if q < 0 { return none }
    } else {
      let t = q / p
      if p < 0 {
        t0 = calc.max(t0, t)
      } else {
        t1 = calc.min(t1, t)
      }
      if t0 > t1 { return none }
    }
  }

  let nx1 = x1 + t0 * dx
  let ny1 = y1 + t0 * dy
  let nx2 = x1 + t1 * dx
  let ny2 = y1 + t1 * dy

  ((nx1, ny1), (nx2, ny2))
}

#let clip-segment-ellipse(p1, p2, cx, cy, rx, ry) = {
  let (x1, y1) = p1
  let (x2, y2) = p2
  let dx = x2 - x1
  let dy = y2 - y1

  let is-inside(x, y) = {
    let ex = (x - cx) / rx
    let ey = (y - cy) / ry
    ex * ex + ey * ey <= 1.0001
  }

  let i1 = is-inside(x1, y1)
  let i2 = is-inside(x2, y2)
  if i1 and i2 { return (p1, p2) }

  let A = (dx / rx) * (dx / rx) + (dy / ry) * (dy / ry)
  if A < 1e-10 { return none }

  let ax = x1 - cx
  let ay = y1 - cy
  let B = 2.0 * (ax * dx / (rx * rx) + ay * dy / (ry * ry))
  let C = (ax / rx) * (ax / rx) + (ay / ry) * (ay / ry) - 1.0

  let disc = B * B - 4.0 * A * C
  if disc < 0 { return none }

  let sd = calc.sqrt(disc)
  let ta = (-B - sd) / (2.0 * A)
  let tb = (-B + sd) / (2.0 * A)
  let te = calc.min(ta, tb)
  let tx = calc.max(ta, tb)

  let t0 = if i1 { 0.0 } else { calc.max(0.0, te) }
  let t1 = if i2 { 1.0 } else { calc.min(1.0, tx) }

  if t0 >= t1 or t1 < 0.0 or t0 > 1.0 { return none }
  (
    (x1 + t0 * dx, y1 + t0 * dy),
    (x1 + t1 * dx, y1 + t1 * dy),
  )
}

#let side-to-anchor(side) = {
  if side == none { return none }
  let mapping = (
    "above": "south",
    "below": "north",
    "left": "east",
    "right": "west",
    "above-left": "south-east",
    "above-right": "south-west",
    "below-left": "north-east",
    "below-right": "north-west",
  )
  mapping.at(side, default: side)
}

#let format-number(n, precision: 2) = {
  if calc.abs(n - calc.round(n)) < 0.0001 {
    str(int(calc.round(n)))
  } else {
    let rounded = calc.round(n * calc.pow(10, precision)) / calc.pow(10, precision)
    str(rounded)
  }
}
