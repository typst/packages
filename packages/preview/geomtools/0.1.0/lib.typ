// ===========================================================================
//  geomtools — drawing instruments for Typst, in clean or hand-drawn mode.
//
//  A port of Cédric Pierquet's `OutilsGeomTikZ` (LPPL 1.3c): the pen, ruler,
//  set square, protractor and compasses a maths teacher puts on a figure.
//
//    #import "@preview/geomtools:0.1.0": *
//
//    #geom(mode: "rough", {
//      ruler(length: 10)
//      pencil(at: (3, 2), rotate: -20deg)
//    })
//
//  Every tool is described ONCE, as geometry. `geom` then renders it crisp or
//  wobbly. That is the whole point of the design: writing each instrument
//  twice, once per mode, would guarantee the two drift apart.
// ===========================================================================

#import "src/canvas.typ": (
  // geometry helpers, useful when composing your own figures
  vadd, vsub, vmul, vnorm, dist, vangle, xform,
  arc-pts, circle-pts, rect-pts,
  // the primitive constructors, for extending the set
  p-poly, p-line, p-circle, p-arc, p-label,
  render,
)

#import "src/tools.typ": (
  placed,
  pencil, pencil-tip, ruler, set-square, mini-square, mini-ruler, ruler-square,
  right-angle,
  protractor, percent-dial, protractor-square, compass,
)

// ---------------------------------------------------------------------------
//  the drawing surface
// ---------------------------------------------------------------------------

/// Draw one or more instruments.
///
///   mode       "clean" (crisp, like the LaTeX original) or "rough"
///   roughness  how heavy the wobble is; 0 is effectively clean
///   seed       same seed, same wobble, every compile
///   colour     the default ink for tools that do not override it
///   frame      ((x0, x1, y0, y1)) to fix the extent instead of fitting
///
/// The body may be a primitive list (what a tool returns) or a block that
/// evaluates to one, so both of these work:
///
///   #geom(ruler(length: 8))
///   #geom({ ruler(length: 8); pencil(at: (2, 1)) })
#let geom(
  body,
  mode: "clean",
  roughness: 1.0,
  seed: 1,
  colour: black,
  frame: none,
  padding: 0.25,
) = {
  let prims = if type(body) == array { body } else { () }
  render(prims, mode: mode, colour: colour, roughness: roughness,
    seed: seed, box-size: frame, padding: padding)
}

/// Shorthand: the same, already in rough mode.
#let geom-rough(body, ..a) = geom(body, mode: "rough", ..a)
