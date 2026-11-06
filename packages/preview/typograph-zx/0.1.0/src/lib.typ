// ZX-calculus and continuous-variable ZX-calculus notation, built on the
// `typograph` engine: semantic constructors and appearance.
//
// This module depends only on typograph's public shape/theme contracts;
// typograph does not (and cannot) depend on this module. A document opts in
// explicitly with:
//
//   #import "@preview/typograph:0.1.0" as typ
//   #import "@preview/typograph-zx:0.1.0" as zx
//   #let diagram = typ.diagram.with(theme: zx.theme)

#import "@preview/typograph:0.1.0": theme as make-theme, node-type, edge-type
#import "@preview/typograph:0.1.0" as typ
#let shapes = typ.shapes

/// ZX-calculus semantic node constructors. Geometry and appearance remain in
/// `theme`; these declarations only assign semantic kinds and, for the
/// directional shapes, an orientation default or a `flip:` escape hatch.
/// Every constructor here follows the same one-line `node-type()` model that
/// the wire constructors below follow with `edge-type()` — none needs
/// bespoke wrapper code.
#let z = node-type("z")
#let x = node-type("x")
#let fock = node-type("fock")
#let w = node-type("w", flippable: true)
#let h = node-type("h")
#let mult = node-type("mult", flippable: true)
#let scalar = node-type("scalar")
#let state = node-type("state")
// `effect` is `state`'s shape mirrored, not rotated: the two are opposite
// orientations of the same flat-triangle, so a flip is the more honest
// factory default than a 180deg rotation of an otherwise-identical shape.
#let effect = node-type("effect", base-style: (flip: true))
#let map = node-type("map", flippable: true)

/// ZX wire constructors follow the same declaration model as ZX nodes: each
/// is a thin `edge-type` binding to a named preset in `theme.edge-presets`.
#let plain = edge-type("plain")
#let pauli-z = edge-type("pauli-z")
#let pauli-x = edge-type("pauli-x")
#let pauli-zx = edge-type("pauli-zx")
#let ideal = edge-type("ideal")
#let faulty = edge-type("faulty")
#let classical = edge-type("classical")
#let thick = edge-type("thick")

/// The complete bundled appearance. Supporting values are local bindings;
/// callers receive one atomic theme rather than parallel copies that can
/// drift out of sync.
#let theme = {
  let z-color = rgb("#D6F5D4")
  let x-color = rgb("#FBDCD8")
  let palette = (
    z: z-color,
    x: x-color,
    fock: rgb("#FCE1C8"),
    h-fill: rgb("#FFF3B0"),
    mult: rgb("#DADFE3"),
    pauli-z: z-color,
    pauli-x: x-color,
    white: white,
    black: black,
    ideal: rgb("#9D00FF"),
    faulty: rgb("#F76B15"),
  )
  let spider(fill) = (
    shape: shapes.circle,
    shape-labelled: shapes.stadium,
    fill: fill,
    stroke: 0.6pt + palette.black,
    min-size: 9pt,
    inset: 4pt,
  )
  let state-style = (
    shape: shapes.flat-triangle,
    fill: palette.white,
    stroke: 0.6pt + palette.black,
    min-width: 26pt,
    min-height: 20pt,
    inset: 3pt,
  )
  make-theme(palette: palette, node-presets: (
    z: spider(palette.z),
    x: spider(palette.x),
    fock: spider(palette.fock),
    w: (shape: shapes.triangle, fill: palette.white, stroke: 0.6pt + palette.black, min-size: 17pt, inset: 2pt),
    h: (shape: shapes.square, fill: palette.h-fill, stroke: 0.6pt + palette.black, min-size: 8pt, inset: 2pt),
    mult: (shape: shapes.arrow, fill: palette.mult, stroke: 0.6pt + palette.black, min-size: 11pt, inset: 3pt),
    scalar: (shape: shapes.bare),
    state: state-style,
    effect: state-style,
    map: (
      shape: shapes.trapezoid,
      fill: palette.white,
      stroke: 0.6pt + palette.black,
      min-width: 10pt,
      min-height: 22pt,
      inset: 4pt,
    ),
  ), edge-presets: (
    plain: (:),
    pauli-z: (highlight: palette.pauli-z),
    pauli-x: (highlight: palette.pauli-x),
    pauli-zx: (highlight: (palette.pauli-x, palette.pauli-z)),
    ideal: (stroke: 0.9pt + palette.ideal),
    faulty: (stroke: 0.9pt + palette.faulty),
    classical: (stroke: (paint: palette.black, thickness: 0.9pt, dash: "dashed")),
    thick: (stroke: 1.4pt + palette.black),
  ))
}
