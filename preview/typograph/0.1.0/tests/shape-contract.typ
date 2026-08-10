// Function-valued shape API contract, including the standard-library-backed
// shapes, fitted regular polygons, and arbitrary polygon factories.
#import "/src/lib.typ" as typ
#import "/src/node.typ": (
  shape-outline, outline-size, node-visual-spec, node-outline,
)
#import "/src/shape.typ": build-outline

#let approx-length(a, b) = calc.abs(a / 1pt - b / 1pt) < 1e-6
#let measured = (width: 10pt, height: 6pt)
#let style(shape, ..extra) = typ.resolve-node-style(
  "node",
  (:),
  (shape: shape, min-width: 20pt, min-height: 12pt, inset: 2pt)
    + extra.named(),
)
#let outline(shape, label: [x], ..extra) = shape-outline(
  style(shape, ..extra.named()),
  label,
  if label == [] { (width: 0pt, height: 0pt) } else { measured },
)

#for builder in (
  typ.shapes.empty,
  typ.shapes.bare,
  typ.shapes.circle,
  typ.shapes.ellipse,
  typ.shapes.stadium,
  typ.shapes.rect,
  typ.shapes.square,
  typ.shapes.triangle,
  typ.shapes.flat-triangle,
  typ.shapes.trapezoid,
  typ.shapes.arrow,
  typ.shapes.diamond,
  typ.shapes.hexagon,
) {
  assert(type(builder) == function)
}

#assert(outline(typ.shapes.empty).kind == "empty")
#assert(outline(typ.shapes.bare).kind == "bare")
#assert(outline(typ.shapes.circle).kind == "circle")
#assert(outline(typ.shapes.ellipse).kind == "ellipse")
#assert(outline(typ.shapes.rect).kind == "rect")
#assert(outline(typ.shapes.square).kind == "rect")
#assert(outline(typ.shapes.triangle).kind == "polygon")
#assert(outline(typ.shapes.hexagon).points.len() == 6)

#let pill = outline(typ.shapes.stadium)
#assert(pill.kind == "rect")
#assert(pill.radius == calc.min(pill.half-width, pill.half-height))
#let square-outline = outline(typ.shapes.square)
#assert(approx-length(square-outline.half-width, square-outline.half-height))
#let zero-inset = shape-outline(
  typ.resolve-node-style("node", (:), (
    shape: typ.shapes.circle,
    min-size: 9pt,
    inset: 0pt,
  )),
  [],
  (width: 0pt, height: 0pt),
)
#assert(approx-length(2 * zero-inset.radius, 9pt))

// The vertex count is the public edge-count API for regular polygons.
#let heptagon-builder = typ.shapes.regular(vertices: 7, rotate: -90deg)
#let heptagon = outline(heptagon-builder, label: [])
#assert(heptagon.kind == "polygon" and heptagon.points.len() == 7)
#let radii = heptagon.points.map(point => {
  let x = point.at(0) / 1pt
  let y = point.at(1) / 1pt
  calc.sqrt(x * x + y * y)
})
#assert(radii.all(radius => calc.abs(radius - radii.first()) < 1e-6))

// Template validity is scale-invariant; normalized geometry should not be
// rejected merely because its author chose very small unitless coordinates.
#let tiny-triangle = typ.shapes.polygon(
  ((1e-12, 0), (-5e-13, 8.660254e-13), (-5e-13, -8.660254e-13)),
)
#assert(outline(tiny-triangle, label: []).points.len() == 3)

// An arbitrary polygon is normalized about its anchor, scaled uniformly to
// its label box, and exposes accurate bounds after per-node rotation.
#let kite-builder = typ.shapes.polygon(
  ((0, -1), (1, 0), (0.25, 1), (-1, 0.25), (-0.65, -0.6)),
  anchor: (0, 0),
  clearance: (1.2, 1.1),
  label-offset: (0, 0.08),
)
#let kite = outline(kite-builder, rotate: 37deg)
#assert(kite.points.len() == 5)
#assert(kite.points.all(point => calc.abs(point.at(0)) <= kite.half-width))
#assert(kite.points.all(point => calc.abs(point.at(1)) <= kite.half-height))
#assert(kite.label-offset != (0pt, 0pt))

// The low-level escape hatch derives extents from the actual points. Builder
// validation recomputes them too, so a custom builder cannot under-report
// bounds and make clipping/layout unsafe.
#let low = typ.polygon-outline(
  ((-11pt, -3pt), (7pt, -5pt), (9pt, 4pt), (-4pt, 8pt)),
  label-offset: (1pt, -2pt),
)
#assert(low.half-width == 11pt and low.half-height == 8pt)
#assert(low.label-offset == (1pt, -2pt))
#let under-reported(label, pad, style) = (
  kind: "polygon",
  points: ((-12pt, -2pt), (6pt, -4pt), (8pt, 7pt)),
  half-width: 1pt,
  half-height: 1pt,
  label-offset: (0pt, 0pt),
)
#let validated = build-outline(
  under-reported,
  measured,
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  style(under-reported),
)
#assert(validated.half-width == 12pt and validated.half-height == 7pt)

// Opposite inset sums size the outline; their difference positions the label
// in the remaining content area, matching Typst's per-side inset semantics.
#let asymmetric = shape-outline(
  style(typ.shapes.rect, inset: (
    left: 10pt, right: 2pt, top: 7pt, bottom: 1pt,
  )),
  [x],
  measured,
)
#assert(asymmetric.label-offset == (4pt, 3pt))

// A deliberately displaced label participates in diagram bounds instead of
// being cropped at the silhouette or outer diagram edge.
#let shifted-builder(label, pad, style) = typ.polygon-outline(
  ((-5pt, -5pt), (5pt, -5pt), (5pt, 5pt), (-5pt, 5pt)),
  label-offset: (20pt, 0pt),
)
#let shifted = shape-outline(
  style(shifted-builder, inset: 0pt), [wide], measured,
)
#let shifted-bounds = outline-size(shifted, measured)
#assert(shifted-bounds.left == -5pt)
#assert(shifted-bounds.right == 20pt + measured.width / 2)
#assert(shifted-bounds.width == shifted-bounds.right - shifted-bounds.left)

// shape-labelled is also a builder, so users can opt into a different form
// without coupling a node kind to either geometry.
#assert(shape-outline(
  style(typ.shapes.circle, shape-labelled: typ.shapes.stadium),
  [long],
  (width: 22pt, height: 6pt),
).kind == "rect")

// Presence, not content truthiness, selects shape-labelled. An explicit empty
// label still means the caller supplied a label.
#let empty-label-node = typ.node(
  0, 0, label: [],
  base-style: (
    shape: typ.shapes.circle,
    shape-labelled: typ.shapes.stadium,
    min-size: 10pt,
  ),
).first()
#context {
  assert(node-outline(node-visual-spec(empty-label-node)).outline.kind == "rect")
}

// Native Typst shape names remain usable because package builders are
// namespaced under typ.shapes.
#circle(radius: 2pt, fill: black)
#rect(width: 8pt, height: 4pt, fill: gray)
#polygon(fill: silver, (0pt, 0pt), (8pt, 0pt), (4pt, 6pt))

// Rendering exercises all outline kinds through the public neutral facade.
#typ.diagram({
  let builders = (
    typ.shapes.circle,
    typ.shapes.ellipse,
    typ.shapes.stadium,
    typ.shapes.rect,
    typ.shapes.square,
    typ.shapes.regular(vertices: 5),
    kite-builder,
  )
  for (index, builder) in builders.enumerate() {
    typ.node(index * 0.8, 0, label: [#index], style: (
      shape: builder,
      fill: white,
      stroke: 0.5pt + black,
      min-size: 12pt,
      inset: 2pt,
    ))
  }
  typ.node(0, -0.8, label: [A], style: (
    shape: typ.shapes.rect,
    fill: white,
    stroke: 0.5pt + black,
    inset: (left: 10pt, right: 2pt, top: 7pt, bottom: 1pt),
  ))
})
