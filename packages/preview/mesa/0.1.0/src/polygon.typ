#import "@preview/cetz:0.5.2": draw

#let _at-height(point, height) = (
  point.at(0),
  point.at(1),
  height,
)

#let _horizontal-face(shapes, height, fill) = {
  for shape in shapes {
    draw.compound-path({
      for contour in shape {
        draw.line(
          ..contour.map(point => _at-height(point, height)),
          close: true,
        )
      }
    }, fill: fill, fill-rule: "even-odd", stroke: none)
  }
}

#let _side-faces(shapes, bottom, top, fill) = {
  for shape in shapes {
    for contour in shape {
      for index in range(contour.len()) {
        let current = contour.at(index)
        let next = contour.at(calc.rem(index + 1, contour.len()))
        draw.line(
          _at-height(current, bottom),
          _at-height(next, bottom),
          _at-height(next, top),
          _at-height(current, top),
          close: true,
          fill: fill,
          stroke: none,
        )
      }
    }
  }
}

#let _edges(shapes, bottom, top, stroke, bottom-stroke) = {
  for shape in shapes {
    for contour in shape {
      let bottom-contour = contour.map(point => _at-height(point, bottom))
      let top-contour = contour.map(point => _at-height(point, top))
      if bottom-stroke != none {
        draw.line(..bottom-contour, close: true, stroke: bottom-stroke)
      }
      draw.line(..top-contour, close: true, stroke: stroke)

      for point in contour {
        draw.line(
          _at-height(point, bottom),
          _at-height(point, top),
          stroke: stroke,
        )
      }
    }
  }
}

#let extrude(
  shapes,
  bottom: 0,
  top: 1,
  top-shapes: auto,
  top-fill: rgb("#b8d6ed"),
  side-fill: rgb("#91b4ce"),
  stroke: rgb("#263843") + .5pt,
  bottom-stroke: auto,
) = {
  assert(top > bottom, message: "extrusion top must be above its bottom")
  let bottom-stroke = if bottom-stroke == auto {
    stroke
  } else {
    bottom-stroke
  }
  _side-faces(shapes, bottom, top, side-fill)
  _horizontal-face(
    if top-shapes == auto { shapes } else { top-shapes },
    top,
    top-fill,
  )
  _edges(shapes, bottom, top, stroke, bottom-stroke)
}
