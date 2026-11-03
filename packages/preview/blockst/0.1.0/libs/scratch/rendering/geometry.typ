// rendering/geometry.typ — Layout constants and notch/block path definitions
// Contains all geometric primitives for Scratch block shapes.

// ------------------------------------------------
// Notch (puzzle connector) dimensions
// ------------------------------------------------
#let notch-height = 1.5mm              // Vertical height of the notch
#let notch-inner-width = 2.2mm         // Width of the flat middle part
#let notch-curve-control = 0.75mm      // Bézier curve control point for rounding
#let notch-spacing = 1.3mm             // Horizontal spacing before/after notch
#let notch-total-width = notch-inner-width + 2 * (notch-height + notch-curve-control)  // Total width including curves
#let notch-reserved-space = notch-inner-width + notch-spacing  // Reserved space in width calculations (approximation)

// ------------------------------------------------
// Block dimensions
// ------------------------------------------------
#let block-height = 10mm
#let corner-radius = 0.75mm
#let block-offset-y = 1.5mm  // Vertical offset for statement blocks
#let block-left-indent = 5 * corner-radius  // Left indent for notch (≈3.75mm)

// Hat (cap) dimensions for event blocks
#let hat-cp1-x = 4mm
#let hat-cp1-y = 3.1mm
#let hat-cp2-x = 5.2mm

// ------------------------------------------------
// Pill dimensions
// ------------------------------------------------
#let pill-height = 6mm
#let pill-inset-x = 2.5mm
#let pill-inset-y = 1.25mm
#let pill-spacing = pill-inset-x * 0.66

// ------------------------------------------------
// Layout
// ------------------------------------------------
#let content-inset = 5pt

// ------------------------------------------------
// Notch paths (for puzzle connectors below)
// ------------------------------------------------
#let notch-path = (
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, notch-height), (-notch-height - notch-curve-control, notch-height), relative: true),
  curve.line((-notch-inner-width, 0mm), relative: true),
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, -notch-height), (-notch-height - notch-curve-control, -notch-height), relative: true),
)

// Inverted notch paths (for puzzle connectors above)
#let inverted-notch-path = (
  curve.cubic((notch-curve-control, 0mm), (notch-height, notch-height), (notch-height + notch-curve-control, notch-height), relative: true),
  curve.line((notch-inner-width, 0mm), relative: true),
  curve.cubic((notch-curve-control, 0mm), (notch-height, -notch-height), (notch-height + notch-curve-control, -notch-height), relative: true),
)

// ------------------------------------------------
// Block path generator
// ------------------------------------------------
// Returns the curve path segments for a given block type.
// type: "event", "define", "statement", "condition",
//       "loop-header", "loop-footer",
//       "if-header", "if-middle", "if-footer"
#let block-path(height, width, type, top-notch: true, bottom-notch: true) = {
  let paths = (
    event: (
      curve.line((0mm, 0mm), relative: true),
      curve.quad((hat-cp1-x, -hat-cp1-y), (block-height, -hat-cp1-y), relative: true),
      curve.quad((hat-cp2-x, 0mm), (block-height, hat-cp1-y), relative: true),
      curve.line((width - 2 * block-height - corner-radius, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - 2 * corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-spacing + notch-total-width, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    define: (
      curve.quad((0mm, -5 * corner-radius), (5 * corner-radius, -5 * corner-radius), relative: true),
      curve.line((width - 10 * corner-radius, 0mm), relative: true),
      curve.quad((5 * corner-radius, 0mm), (5 * corner-radius, 5 * corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-total-width + notch-spacing, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    statement: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    condition: (
      curve.move((0.5 * height, 0mm)),
      curve.line((width - 0.5 * height, 0mm), relative: true),
      curve.line((0.5 * height, -0.5 * height), relative: true),
      curve.line((-0.5 * height, -0.5 * height), relative: true),
      curve.line((-width + 0.5 * height, 0mm), relative: true),
      curve.line((-0.5 * height, 0.5 * height), relative: true),
      curve.line((0.5 * height, 0.5 * height), relative: true),
    ),
    "loop-header": (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    "loop-footer": (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    "if-header": (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    "if-middle": (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    "if-footer": (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
  )
  return paths.at(type, default: paths.statement)
}
