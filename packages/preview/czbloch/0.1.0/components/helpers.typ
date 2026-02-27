#let arrowtip(color: black) = (end: "stealth", fill: color, stroke: color)

#let neg(point) = {
  point.map(c => -c)
}

#let angle-rem(angle, period) = {
  if angle < period or angle == period {
    return angle
  }

  let n = calc.floor(angle.deg() / period.deg())
  let res = angle - n * period
  if res == 0 {
    return period
  } else {
    return res
  }
}

#let cartesian(r, phi, theta) = {
  import calc: sin, cos
  let x = r * sin(theta) * sin(phi)
  let y = r * cos(theta)
  let z = r * sin(theta) * cos(phi)
  (x, y, z)
}
