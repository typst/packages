// cetz-fields — Coulomb-field diagrams for Typst and CeTZ.
#import "@preview/cetz:0.5.2"
#import "src/fields.typ": draw-charge-diagram, electric-field

// Draw a complete, self-sizing CeTZ canvas.
//
// `setup` may contain CeTZ elements that define named anchors used by charge
// positions. For use in an existing canvas, call `draw-charge-diagram` instead.
#let charge-diagram(
  charges,
  mode: "field-lines",
  domain: ((-4, 4), (-3, 3)),
  setup: none,
  length: 1cm,
  padding: 0.15,
  background: none,
  ..options,
) = cetz.canvas(
  length: length,
  padding: padding,
  background: background,
  {
    // `scope` safely processes a setup array and leaks its named anchors.
    if setup != none { cetz.draw.scope(setup) }
    draw-charge-diagram(
      charges,
      mode: mode,
      domain: domain,
      ..options,
    )
  },
)
