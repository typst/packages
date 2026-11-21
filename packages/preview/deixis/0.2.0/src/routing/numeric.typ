// This boundary accepts resolved geometry only. Font/percentage lengths, pin
// selectors and document frames belong to document adapters, not this API.
#let _deixis-numeric-length(value) = {
  type(value) == length and value.em == 0 and value.pt() == value.pt() and calc.abs(value.pt()) < calc.inf
}

#let _deixis-numeric-point(value) = {
  assert(type(value) == array and value.len() == 2 and value.all(_deixis-numeric-length),
    message: "deixis: Numeric routing points need two finite absolute lengths; resolve font/percentage lengths and pins first.")
  value
}

#let _deixis-numeric-endpoint(value) = {
  if type(value) == array { return (point: _deixis-numeric-point(value), normal: auto, axis: "none") }
  assert(type(value) == dictionary and "point" in value and value.keys().all(k => k in ("point", "normal")),
    message: "deixis: A numeric routing endpoint is a point or (point: ..., normal: ...).")
  let normal = value.at("normal", default: auto)
  if type(normal) == alignment {
    assert(normal in (left, right, top, bottom),
      message: "deixis: A numeric routing normal alignment must be left, right, top or bottom.")
    normal = (left: (-1, 0), right: (1, 0), top: (0, -1), bottom: (0, 1)).at(repr(normal))
  }
  if normal != auto {
    assert(type(normal) == array and normal.len() == 2
      and normal.all(v => type(v) in (int, float) and v == v and calc.abs(v) < calc.inf)
      and normal != (0, 0),
      message: "deixis: A numeric routing normal needs a nonzero finite numeric vector or a cardinal alignment.")
    // Normalize after rescaling so very large/small finite vectors stay usable.
    let scale = calc.max(..normal.map(calc.abs))
    normal = normal.map(v => v / scale)
    let magnitude = calc.sqrt(normal.map(v => v * v).sum())
    normal = normal.map(v => v / magnitude)
  }
  (point: _deixis-numeric-point(value.point), normal: normal,
    axis: if normal == auto { "none" } else if normal.first() == 0 { "vertical" }
      else if normal.last() == 0 { "horizontal" } else { "none" })
}

