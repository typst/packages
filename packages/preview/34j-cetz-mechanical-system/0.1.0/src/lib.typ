#import "@preview/cetz:0.3.0"

#let get-vec-cross(a, b, width, inverse) = {
  import cetz.draw: *
  let dist = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
  let vec-normalized = ((b.at(0) - a.at(0)) / dist, (b.at(1) - a.at(1)) / dist)
  let vec-cross-normalized = (vec-normalized.at(1), -vec-normalized.at(0))
  if type(width) == ratio {
    width = dist * width / 100%
  }
  let vec-cross = (vec-cross-normalized.at(0) * width, vec-cross-normalized.at(1) * width)
  let vec-cross-inversed = vec-cross
  if inverse {
    vec-cross-inversed = (-vec-cross.at(0), -vec-cross.at(1))
  }
  return (
    "dist": dist,
    "vec-cross": vec-cross,
    "vec-cross-inversed": vec-cross-inversed,
    "vec-normalized": vec-normalized,
    "vec-cross-normalized": vec-cross-normalized,
  )
}

/// Draw a spring between two points.
///
/// - a (cetz.coordinate): The start point.
/// - b (cetz.coordinate): The end point.
/// - width (float, ratio): The width of the spring.
/// - n (integer): The number of coils.
/// - inverse (boolean): Invert the direction of the spring.
/// - name (string): The name of the group.
/// - style (cetz.style): The style.
/// -> none
#let spring(a, b: none, width: 30%, n: 8, inverse: false, name: none, ..style) = {
  import cetz.draw: *
  if b == none {
    b = (a.at(0) + 1, a.at(1))
  }
  let vecs = get-vec-cross(a, b, width, false)
  let vec-cross = vecs.at("vec-cross-inversed")
  let pts = (a,)
  for i in range(n) {
    let r = (i + 0.5) / n
    let direction = if calc.rem(i, 2) == 0 { 1 } else { -1 }
    let x = (a.at(0) * (1 - r) + b.at(0) * r) + vec-cross.at(0) * direction
    let y = (a.at(1) * (1 - r) + b.at(1) * r) + vec-cross.at(1) * direction
    pts.push((x, y))
  }
  pts.push(b)
  group(name: name, ctx => {line(..pts, ..style)
  anchor("a", a)
  anchor("b", b)
  let r = 1.5
  let vec-cross = vecs.at("vec-cross")
  anchor("top", ((a.at(0) + b.at(0)) / 2 - vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 - vec-cross.at(1) * r))
  anchor("bottom", ((a.at(0) + b.at(0)) / 2 + vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 + vec-cross.at(1) * r))
})
}

/// Draw a damper between two points.
///
/// - a (cetz.coordinate): The top (touching the pushing pole) point.
/// - b (cetz.coordinate, none): The bottom (touching the outer lines) point.
/// - width (float, ratio): The width of the damper.
/// - r (float, ratio): The width of the pushing block.
/// - inverse (boolean): Invert the direction of the damper.
/// - name (string): The name of the group.
/// - style (cetz.style): The style.
/// -> none
#let damper(a, b: none, width: 60%, r: 90%, inverse: false, name: none, ..style) = {
  import cetz.draw: *
  if b == none {
    b = (a.at(0) + 0.7, a.at(1))
  }
  let vecsinit = get-vec-cross(a, b, width, inverse)
  if not inverse {
    let tmp = b
    b = a
    a = tmp
  }

  let vecs = get-vec-cross(a, b, width, inverse)
  let vec-cross = vecs.at("vec-cross-inversed")
  if type(r) == ratio {
    r = r / 100%
  }

  // outer lines

  group(name: name, ctx => {line(
    (b.at(0) + vec-cross.at(0), b.at(1) + vec-cross.at(1)),
    (a.at(0) + vec-cross.at(0), a.at(1) + vec-cross.at(1)),
    (a.at(0) - vec-cross.at(0), a.at(1) - vec-cross.at(1)),
    (b.at(0) - vec-cross.at(0), b.at(1) - vec-cross.at(1)),
    ..style,
  )

  // pushing block

  line(
    ((a.at(0) + b.at(0)) / 2 + vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 + vec-cross.at(1) * r),
    ((a.at(0) + b.at(0)) / 2 - vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 - vec-cross.at(1) * r),
    ..style,
  )

  // pushing pole

  line(
    ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2),
    b,
    ..style,
  )
  anchor("a", b)
  anchor("b", a)
  let r = 1.5
  let vec-cross = vecsinit.at("vec-cross")
  anchor("top", ((a.at(0) + b.at(0)) / 2 - vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 - vec-cross.at(1) * r))
  anchor("bottom", ((a.at(0) + b.at(0)) / 2 + vec-cross.at(0) * r, (a.at(1) + b.at(1)) / 2 + vec-cross.at(1) * r))
})
}

/// Draw a wall between two points.
///
/// - a (cetz.coordinate): The start point.
/// - b (cetz.coordinate, none): The end point.
/// - width (float, ratio): The width of the wall shading.
/// - period (float, ratio): The period of the wall shading.
/// - inverse (boolean): Invert which side the shading is on.
/// - inverse-lines (boolean): Invert the direction (up or down) of the shading.
/// - name (string): The name of the group. 
/// - style (cetz.style): The style.
/// -> none
#let wall(a, b: none, width: 0.1, period: 0.2, inverse: false, inverse-lines: false, name: none, ..style) = {
  import cetz.draw: *
  if b == none {
    b = (a.at(0), a.at(1) - 1)
  }
  let vecs = get-vec-cross(a, b, width, inverse)
  let vec-cross = vecs.at("vec-cross-inversed")
  let n = calc.floor(vecs.at("dist") / period)
  let points = (a,)
  for i in range(n) {
    let rstart = (i + 1) / n
    let rend = i / n
    if inverse-lines {
      let tmp = rstart
      rstart = rend
      rend = tmp
    }
    let start = (a.at(0) * (1 - rstart) + b.at(0) * rstart, a.at(1) * (1 - rstart) + b.at(1) * rstart)
    let end = (a.at(0) * (1 - rend) + b.at(0) * rend + vec-cross.at(0), a.at(1) * (1 - rend) + b.at(1) * rend + vec-cross.at(1))
    points.push(start)
    points.push(end)
    points.push(start)
  }
  points.push(b)
  group(name: name, ctx => {line(..points, ..style)})
}
