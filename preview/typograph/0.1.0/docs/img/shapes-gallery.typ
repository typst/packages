// Generates docs/img/shapes-gallery.svg — every built-in shape builder.
//   typst compile --root . --ignore-system-fonts docs/img/shapes-gallery.typ docs/img/shapes-gallery.svg
#import "../../src/lib.typ" as typ
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 7pt)

#let swatch(name, shape) = {
  let node = typ.node(0, 0, label: [A], style: (
    shape: shape,
    fill: rgb("#eef3ff"),
    stroke: 0.6pt + navy,
    min-size: 15pt,
    inset: 3pt,
  ))
  align(center, stack(spacing: 3pt, typ.diagram(scale: 1cm, node), raw(name)))
}

#grid(
  columns: 6, column-gutter: 12pt, row-gutter: 12pt,
  swatch("circle", typ.shapes.circle),
  swatch("ellipse", typ.shapes.ellipse),
  swatch("stadium", typ.shapes.stadium),
  swatch("rect", typ.shapes.rect),
  swatch("square", typ.shapes.square),
  swatch("bare", typ.shapes.bare),
  swatch("triangle", typ.shapes.triangle),
  swatch("flat-triangle", typ.shapes.flat-triangle),
  swatch("trapezoid", typ.shapes.trapezoid),
  swatch("arrow", typ.shapes.arrow),
  swatch("diamond", typ.shapes.diamond),
  swatch("hexagon", typ.shapes.hexagon),
  swatch("regular(5)", typ.shapes.regular(vertices: 5)),
  swatch("regular(8)", typ.shapes.regular(vertices: 8, rotate: 22.5deg)),
  swatch("polygon(..)", typ.shapes.polygon(
    ((-1, -1), (1, -1), (0.35, 0), (1, 1), (-1, 1)),
    anchor: (-0.2, 0),
    clearance: (1.25, 1.1),
  )),
)
