#let add(a, b) = (
  a.at(0) + b.at(0),
  a.at(1) + b.at(1),
  a.at(2) + b.at(2),
)

#let subtract(a, b) = (
  a.at(0) - b.at(0),
  a.at(1) - b.at(1),
  a.at(2) - b.at(2),
)

#let scale(vector, factor) = (
  vector.at(0) * factor,
  vector.at(1) * factor,
  vector.at(2) * factor,
)

#let dot(a, b) = (
  a.at(0) * b.at(0)
  + a.at(1) * b.at(1)
  + a.at(2) * b.at(2)
)

#let cross(a, b) = (
  a.at(1) * b.at(2) - a.at(2) * b.at(1),
  a.at(2) * b.at(0) - a.at(0) * b.at(2),
  a.at(0) * b.at(1) - a.at(1) * b.at(0),
)

#let unit(vector) = {
  let length = calc.sqrt(dot(vector, vector))
  if length == 0 {
    vector
  } else {
    vector.map(component => component / length)
  }
}

#let clip-polygon(points, distance, epsilon: 1e-6) = {
  if points.len() == 0 {
    return ()
  }

  let result = ()
  let previous = points.last()
  let previous-distance = distance(previous)
  let previous-inside = previous-distance > epsilon

  for current in points {
    let current-distance = distance(current)
    let current-inside = current-distance > epsilon
    if current-inside != previous-inside {
      let amount = (
        (epsilon - previous-distance)
        / (current-distance - previous-distance)
      )
      result.push(add(
        previous,
        scale(subtract(current, previous), amount),
      ))
    }
    if current-inside {
      result.push(current)
    }
    previous = current
    previous-distance = current-distance
    previous-inside = current-inside
  }
  result
}

#let signed-polygon-area(points) = {
  if points.len() < 3 {
    return 0
  }
  let twice-area = 0
  for index in range(points.len()) {
    let current = points.at(index)
    let next = points.at(calc.rem(index + 1, points.len()))
    let cross = current.at(0) * next.at(1) - current.at(1) * next.at(0)
    twice-area += cross
  }
  twice-area / 2
}

#let polygon-area(points) = calc.abs(signed-polygon-area(points))

#let cross-2d(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)

#let point-in-convex(point, polygon, epsilon: 1e-6) = {
  for index in range(polygon.len()) {
    let start = polygon.at(index)
    let end = polygon.at(calc.rem(index + 1, polygon.len()))
    if cross-2d(
      subtract(end, start),
      subtract(point, start),
    ) < -epsilon {
      return false
    }
  }
  true
}

#let dot-2d(a, b) = (
  a.at(0) * b.at(0)
  + a.at(1) * b.at(1)
)

#let center-2d(points) = (
  points.map(point => point.at(0)).sum() / points.len(),
  points.map(point => point.at(1)).sum() / points.len(),
)
