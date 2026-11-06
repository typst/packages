#let vec(x, y) = {
  return (x: x, y: y)
}

#let add(v1, v2) = {
  return vec(
    v1.x + v2.x,
    v1.y + v2.y
  )
}

#let sub(v1, v2) = {
  return vec(
    v1.x - v2.x,
    v1.y - v2.y
  )
}

#let mul(v, f) = {
  return vec(
    v.x * f,
    v.y * f
  )
}

#let div(v, f) = {
  return vec(
    v.x / f,
    v.y / f
  )
}

#let mag(v) = {
  return calc.sqrt(v.x * v.x + v.y * v.y)
}

#let normalize(v) = {
  let m = mag(v)

  if m == 0 {
    return (x: 0, y: 0)
  }
  return div(v, m)
}