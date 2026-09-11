#import "kernel.typ" as _kernel

/// Read boundary polygons and width-aware paths from a named GDS cell.
///
/// `unit` selects the base unit of the returned coordinates. `auto` preserves
/// the GDS user unit; unit strings such as `"nm"`, `"um"`, and `"mm"` convert
/// the coordinates. A positive numeric value specifies the unit size in
/// metres directly.
///
/// `scale` multiplies both planar axes. `scale-x` and `scale-y` apply
/// additional axis-specific factors. Paths are polygonized before scaling.
/// The result records `source-unit-meters`, `unit-meters`, and the final
/// `(x, y)` factors in `scale`.
///
/// `padding` adds empty model space around the transformed GDS geometry. A
/// number applies to every side; `(x: ..., y: ...)` applies per axis; and
/// `(left: ..., right: ..., front: ..., back: ...)` controls each side.
///
/// `path-tolerance` optionally simplifies the path centreline by a fraction of
/// that path's width before generating its two offset rails. For example, `2%`
/// limits the centreline deviation to two percent of the path width. Zero
/// preserves every path vertex.
#let gds(
  data,
  cell: none,
  layers: none,
  path-tolerance: 0,
  unit: auto,
  scale: 1,
  scale-x: 1,
  scale-y: 1,
  padding: 0,
) = {
  assert(type(data) == bytes, message: "gds data must be bytes")
  assert(type(cell) == str, message: "gds cell must be a string")
  assert(type(layers) == dictionary, message: "gds layers must be a dictionary")
  let path-tolerance = if type(path-tolerance) == ratio {
    path-tolerance / 100%
  } else {
    path-tolerance
  }
  assert(
    type(path-tolerance) in (int, float)
      and path-tolerance >= 0
      and path-tolerance <= 1,
    message: "gds path-tolerance must be between 0% and 100%",
  )
  let unit-meters = if unit == auto {
    none
  } else if type(unit) in (int, float) {
    unit * 1.0
  } else {
    assert(
      type(unit) == str,
      message: "gds unit must be auto, a unit name, or metres per unit",
    )
    let normalized = if unit in ("µm", "μm") { "um" } else { unit }
    let units = (
      m: 1.0,
      cm: 1e-2,
      mm: 1e-3,
      um: 1e-6,
      nm: 1e-9,
    )
    assert(
      normalized in units,
      message: "unknown gds unit " + repr(unit),
    )
    units.at(normalized)
  }
  if unit-meters != none {
    assert(
      unit-meters > 0,
      message: "gds unit must be positive",
    )
  }
  for (name, value) in (
    scale: scale,
    scale-x: scale-x,
    scale-y: scale-y,
  ) {
    assert(
      type(value) in (int, float) and value > 0,
      message: "gds " + name + " must be a positive number",
    )
  }
  let padding = if type(padding) in (int, float) {
    (
      left: padding,
      right: padding,
      front: padding,
      back: padding,
    )
  } else {
    assert(
      type(padding) == dictionary,
      message: "gds padding must be a number or dictionary",
    )
    let allowed = ("x", "y", "left", "right", "front", "back")
    for key in padding.keys() {
      assert(
        key in allowed,
        message: "unknown gds padding side " + repr(key),
      )
    }
    let x = padding.at("x", default: 0)
    let y = padding.at("y", default: 0)
    (
      left: padding.at("left", default: x),
      right: padding.at("right", default: x),
      front: padding.at("front", default: y),
      back: padding.at("back", default: y),
    )
  }
  for (name, value) in padding {
    assert(
      type(value) in (int, float) and value >= 0,
      message: "gds padding " + name + " must be a non-negative number",
    )
  }
  padding = (
    left: padding.left * 1.0,
    right: padding.right * 1.0,
    front: padding.front * 1.0,
    back: padding.back * 1.0,
  )
  for (name, layer) in layers {
    assert(
      type(layer) == array
        and layer.len() == 2
        and layer.all(value => type(value) == int),
      message: "gds layer " + name + " must be a (layer, datatype) pair",
    )
  }
  _kernel.gds-layout(
    data,
    cell,
    layers,
    path-tolerance,
    unit-meters,
    scale,
    scale-x,
    scale-y,
    padding,
  )
}
