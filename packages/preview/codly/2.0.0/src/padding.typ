// Block-edge space is separate from row leading/insets.
#let resolve(value) = {
  let sides = if type(value) == dictionary { value } else { (rest: value) }
  assert(
    sides.keys().all(key => key in ("top", "right", "bottom", "left", "x", "y", "rest")),
    message: "codly: padding accepts only sides, x/y, and rest",
  )
  assert(
    sides.values().all(value => type(value) == length),
    message: "codly: padding values must be lengths",
  )
  let rest = sides.at("rest", default: 0pt)
  let side(name, axis) = sides.at(name, default: sides.at(axis, default: rest)).to-absolute()
  let result = (
    top: side("top", "y"),
    right: side("right", "x"),
    bottom: side("bottom", "y"),
    left: side("left", "x"),
  )
  assert(result.values().all(value => value >= 0pt), message: "codly: padding must be non-negative")
  result
}
