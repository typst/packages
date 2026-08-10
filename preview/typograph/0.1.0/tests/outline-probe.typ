// Emits each shape builder's computed outline size as machine-readable lines.
//
// The package test runner compares these lines with a checked-in expectation,
// so an outline-size change is explicit rather than merely compile-clean.
#import "/src/node.typ": node-outline, outline-size
#import "/src/shape.typ" as shapes
#set page(width: 400pt, height: auto, margin: 4pt)
#set text(size: 11pt)

#let preset(shape, ..style) = (shape: shape, min-size: 12pt, inset: 3pt, ..style.named())
#let node-presets = (
  circle: preset(shapes.circle),
  ellipse: preset(shapes.ellipse),
  stadium: preset(shapes.stadium),
  rect: preset(shapes.rect),
  square: preset(shapes.square),
  triangle: preset(shapes.triangle),
  flat-triangle: preset(shapes.flat-triangle),
  trapezoid: preset(shapes.trapezoid),
  arrow: preset(shapes.arrow),
  diamond: preset(shapes.diamond),
  hexagon: preset(shapes.hexagon),
  bare: preset(shapes.bare),
)

#let probe(kind, label) = context {
  let n = (
    type: "node", kind: kind, x: 0, y: 0, label: label, name: none,
    style: (:), base-style: (:), size-scale: 1,
  )
  let prep = node-outline(n, preset: node-presets.at(kind, default: (:)), override: (:))
  let s = outline-size(prep.outline, prep.measured)
  raw(kind + "|" + (if label == none { "-" } else { "L" }) + "|"
      + str(calc.round(s.width / 1pt, digits: 3)) + "|"
      + str(calc.round(s.height / 1pt, digits: 3)))
  linebreak()
}

#let kinds = ("circle", "ellipse", "stadium", "rect", "square", "triangle", "flat-triangle", "trapezoid", "arrow", "diamond", "hexagon", "bare")
#for k in kinds {
  probe(k, none)
}
#for k in kinds {
  probe(k, [Ab])
}
