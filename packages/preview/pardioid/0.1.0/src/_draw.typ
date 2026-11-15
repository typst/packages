#import "header.typ": *
#import "curve-process.typ": get-curve-components
#import "utils.typ": *


/// This function avoids zero-length `std.curve.line`.
/// It can be removed once #link("https://github.com/typst/typst/issues/8894")[#8894] is fixed.
///
/// The reproduction condition is not yet clear.
#let _offset(pair) = {
  let (x, y) = pair
  return (x + epsilon-for-algo, y)
  // return (x, y)
}

// viewport is of type Rect
#let cartesian-to-screen(coord, origin: (auto, auto), scale: (20pt, -20pt), viewport: Rect) = {
  assert.ne(viewport, Rect)
  // range is axis range
  let resolve-axis-origin(axis-origin, axis-range: none, axis-scale: none) = {
    assert.ne(axis-range, none)
    assert.ne(axis-scale, none)
    let scale = axis-scale
    let (min, max) = axis-range
    return if axis-origin == auto {
      -calc.min(min * scale, max * scale)
    } else {
      axis-origin
    }
  }
  let dims = ("x", "y")
  if origin == auto { origin = (auto,) * dims.len() }
  let d-origin = dims.zip(origin, exact: true).to-dict()
  let d-scale = dims.zip(scale, exact: true).to-dict()
  let d-coord = dims.zip(coord, exact: true).to-dict()
  return dims.map(
    dim => {
      let (min, max) = viewport.at(dim)
      if type(min) == array { panic(viewport) }
      // (ox + x * sx, oy + y * sy)
      (
        resolve-axis-origin(d-origin.at(dim), axis-range: viewport.at(dim), axis-scale: d-scale.at(dim))
          + d-coord.at(dim) * d-scale.at(dim)
      )
    },
  )
}


// Note that it returns an array.
#let _gen-draw(render: Function, bounds: Rect) = {
  assert.ne(render, Function)
  assert.ne(bounds, Rect)
  // type Element
  return (
    Element(
      bounds: bounds,
      render: render, // type drawable
    ),
  )
}
