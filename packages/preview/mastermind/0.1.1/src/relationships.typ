#let _start-end-anchors(from-rect, to-rect) = {
  let from-center = from-rect.center
  let to-center = to-rect.center

  let dx = to-center.at(0) - from-center.at(0)
  let dy = to-center.at(1) - from-center.at(1)

  let from-side = from-rect.name + ".right"
  let to-side = to-rect.name + ".left"
  if calc.abs(dx) < calc.abs(dy) {
    if dy > 0 {
      from-side = from-rect.name + ".north"
      to-side = to-rect.name + ".south"
    } else {
      from-side = from-rect.name + ".south"
      to-side = to-rect.name + ".north"
    }
  } else {
    if dx > 0 {
      from-side = from-rect.name + ".east"
      to-side = to-rect.name + ".west"
    } else {
      from-side = from-rect.name + ".west"
      to-side = to-rect.name + ".east"
    }
  }

  return (from-side, to-side)
}

#let _relationship(from-rect, to-rect, line: (), start-mark: none, end-mark: none) = {
  let (from-side, to-side) = _start-end-anchors(from-rect, to-rect)

  return (
    start: from-side,
    end: to-side,
    name: from-rect.name + "-" + to-rect.name,
    start-mark: start-mark,
    end-mark: end-mark,
    line: line,
  )
}

#let inheritance(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "triangle",
  )
}

#let dependency(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "triangle",
  )
}

#let association(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "triangle",
  )
}

#let aggregation(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond",
    end-mark: "triangle",
  )
}

#let composition(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond-filled",
    end-mark: "triangle",
  )
}

#let implementation(from-rect, to-rect) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "triangle",
  )
}
