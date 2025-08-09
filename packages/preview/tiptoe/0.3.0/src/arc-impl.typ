#let sub(p, q) = p.zip(q).map(((a, b)) => a - b)
#import "assert.typ": assert-dict-keys

#let bezier-arc(
  origin: (0pt, 0pt),
  angle: 0deg,
  arc: 45deg,
  radius: 1cm,
  width: auto,
  height: auto
) = {
  
  if arc == 0deg { return () }
  if width == auto { width = 2 * radius }
  if height == auto { height = 2 * radius }
  if calc.abs(arc) > 360deg { arc = 360deg }
  let num-curves = int(calc.ceil(calc.abs(arc/90deg)))
  let a = arc / num-curves

  let y0 = calc.sin(a / 2)
  let x0 = calc.cos(a / 2)
  let tx = (1 - x0) * 4/3
  let ty = y0 - tx*x0 / (y0 + 0.0001)
  let px = (x0, x0 + tx, x0 + tx, x0)
  let py = (-y0, -ty, ty, y0)

  let sn = calc.sin(angle + a / 2)
  let cs = calc.cos(angle + a / 2)
  let points = ()
  points.push((
    origin.at(0) + 0.5 * width * (px.at(0)*cs - py.at(0)*sn),
    origin.at(1) + 0.5 * height * (px.at(0)*sn + py.at(0)*cs)
  ))

  for i in range(num-curves) {
    let astart = angle + a * i
    let sn = calc.sin(astart + a / 2)
    let cs = calc.cos(astart + a / 2)
    for j in range(1, 4) {
      points.push((
        origin.at(0) + 0.5 * width * (px.at(j)*cs - py.at(j)*sn),
        origin.at(1) + 0.5 * height * (px.at(j)*sn + py.at(j)*cs)
      ))
    }
  }
  let coords = (
    (points.at(0), (0pt, 0pt), sub(points.at(1), points.at(0))), ..points.slice(1).chunks(3).map(
    ((a, b, c)) => {
      (c, sub(b, c))
    }
  ))
  coords.last().push((0pt, 0pt))
  coords
}

#let bezier-arc2(
  origin: (0pt, 0pt),
  angle: 0deg,
  arc: 45deg,
  radius: 1cm,
  width: auto,
  height: auto
) = {
  
  if arc == 0deg { return () }
  if width == auto { width = 2 * radius }
  if height == auto { height = 2 * radius }
  if calc.abs(arc) > 360deg { arc = 360deg }
  let num-curves = int(calc.ceil(calc.abs(arc/90deg)))
  let a = arc / num-curves

  let y0 = calc.sin(a / 2)
  let x0 = calc.cos(a / 2)
  let tx = (1 - x0) * 4/3
  let ty = y0 - tx*x0 / (y0 + 0.0001)
  let px = (x0, x0 + tx, x0 + tx, x0)
  let py = (-y0, -ty, ty, y0)

  let sn = calc.sin(angle + a / 2)
  let cs = calc.cos(angle + a / 2)
  let points = ()
  points.push((
    origin.at(0) + 0.5 * width * (px.at(0)*cs - py.at(0)*sn),
    origin.at(1) + 0.5 * height * (px.at(0)*sn + py.at(0)*cs)
  ))

  for i in range(num-curves) {
    let astart = angle + a * i
    let sn = calc.sin(astart + a / 2)
    let cs = calc.cos(astart + a / 2)
    for j in range(1, 4) {
      points.push((
        origin.at(0) + 0.5 * width * (px.at(j)*cs - py.at(j)*sn),
        origin.at(1) + 0.5 * height * (px.at(j)*sn + py.at(j)*cs)
      ))
    }
  }
  let coords = (
    curve.move(points.at(0)),
    // ..points.slice(1).map(curve.line)
    ..points.slice(1).chunks(3).map(x => curve.cubic(..x, relative: false))
  )

  coords
}


#let arc-impl(
  origin: (0pt, 0pt),
  angle: 0deg,
  arc: 6rad,
  radius: 1cm,
  stroke: 1pt + black
) = {
  curve(
    stroke: stroke,
    ..bezier-arc2(
      origin: origin,
      angle: angle, 
      arc: arc,
      radius: radius
    )
  )
}


