#import calc: acos, cos, pow, sin, sqrt

/// Converts spherical coordinates into cartesian coordinates
///
/// -> array
#let spherical-to-cartesian(
  /// The magnitude
  /// -> float
  r,
  /// Theta angle from the Z axis
  /// -> angle
  theta,
  /// Phi angle from the X axis
  /// -> angle
  phi,
) = {
  let x = r * sin(theta) * cos(phi)
  let y = r * sin(theta) * sin(phi)
  let z = r * cos(theta)
  (x, y, z)
}


/// Converts cartesian coordinates into spherical coordinates
///
/// -> array
#let cartesian-to-spherical(
  /// -> float
  x,
  /// -> float
  y,
  /// -> float
  z,
) = {
  let r = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
  let theta = acos(z / r)
  let phi = y.signum() * acos(x / sqrt(pow(x, 2) + pow(y, 2)))
  (r, theta, phi)
}

#let linspace(start, end, num) = {
  if num <= 1 { return (start,) }
  let step = (end - start) / (num - 1)
  range(num).map(i => start + i * step)
}

#let dot-prod(a, b) = {
  if a.len() != b.len() {
    panic("Both vector must be of same length")
  }
  let sum = 0
  for i in range(a.len()) {
    sum += a.at(i) * b.at(i)
  }
  sum
}

#let scalar-prod(arr, scalar) = {
  let res = arr.map(i => i * scalar)
  res
}

#let cross-prod(a, b) = {
  (
    a.at(1) * b.at(2) - a.at(2) * b.at(1),
    a.at(2) * b.at(0) - a.at(0) * b.at(2),
    a.at(0) * b.at(1) - a.at(1) * b.at(0),
  )
}

#let add-vec(a, b) = {
  if a.len() != b.len() {
    panic("Both vector must be of same length")
  }
  let res = ()
  for i in range(a.len()) {
    res.push(a.at(i) + b.at(i))
  }
  res
}

#let normalize-vec(arr) = {
  let norm = 0
  for i in range(arr.len()) {
    norm += pow(arr.at(i), 2)
  }
  let norm = sqrt(norm)
  arr.map(i => i / norm)
}

#let spherical-linear-interpolation(start, end, num) = {
  if num < 2 {
    panic("Must be at least 2 to return start and end")
  }
  if start.at(0) != end.at(0) {
    panic("Both vectors must be of same magnitude")
  }
  let start-cartesian = normalize-vec(spherical-to-cartesian(..start))
  let end-cartesian = normalize-vec(spherical-to-cartesian(..end))
  let angle-between = acos(dot-prod(start-cartesian, end-cartesian))
  let res = range(num).map(i => {
    let i = i / (num - 1)
    add-vec(
      scalar-prod(start-cartesian, sin((1 - i) * angle-between) / sin(angle-between)),
      scalar-prod(end-cartesian, sin(angle-between * i) / sin(angle-between)),
    )
  })
  res.map(elem => scalar-prod(elem, start.at(0)))
}

#let rotate-around-axis(v, axis, angle) = {
  let n = normalize-vec(spherical-to-cartesian(..axis))
  let term1 = scalar-prod(v, cos(angle))
  let term2 = scalar-prod(cross-prod(n, v), sin(angle))
  let term3 = scalar-prod(n, dot-prod(n, v) * (1 - cos(angle)))
  add-vec(add-vec(term1, term2), term3)
}

#let axis-rotation-interpolation(start, axis, total-angle, num) = {
  let start-cartesian = spherical-to-cartesian(..start)
  range(num).map(i => {
    let t = i / (num - 1)
    let angle = t * total-angle
    rotate-around-axis(start-cartesian, axis, angle)
  })
}
