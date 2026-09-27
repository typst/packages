#let _relationship(from-rect, to-rect, line: (), start-mark: none, end-mark: none, from-side: none, to-side: none) = {
  return (
    from-rect: from-rect,
    to-rect: to-rect,
    from-side: from-side,
    to-side: to-side,
    name: from-rect + "-" + to-rect,
    start-mark: start-mark,
    end-mark: end-mark,
    line: line,
  )
}

#let inheritance(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "triangle",
    from-side: from-side,
    to-side: to-side,
  )
}

#let dependency(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

#let association(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

#let aggregation(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond",
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

#let composition(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    start-mark: "diamond-filled",
    end-mark: "straight",
    from-side: from-side,
    to-side: to-side,
  )
}

#let implementation(from-rect, to-rect, from-side: none, to-side: none) = {
  return _relationship(
    from-rect,
    to-rect,
    line: (3pt, 3pt),
    end-mark: "triangle",
    from-side: from-side,
    to-side: to-side,
  )
}
