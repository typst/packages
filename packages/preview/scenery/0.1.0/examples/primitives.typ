// Primitive showcase: one annotated scene exercising every primitive kind —
// spheres, a bond segment, wireframe edges, an arrow, a translucent face and
// text labels — all depth-sorted through the same pipeline.
//
// Examples import the working tree via the package-root path `/lib.typ`
// (compiled with `--root .`); published documents use the `@preview` import
// shown in the README quickstart instead.
#import "/lib.typ": sphere, seg, edge, arrow, face, label, build-scene
#import "/lib.typ": camera, render-scene

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "New Computer Modern", size: 10pt)

#let blue = rgb("#4477aa")
#let orange = rgb("#cc8963")
#let charcoal = rgb("#4d5358")

// The four corners of a ground tile at z = 0.
#let c = ((-2.2, -2.2, 0), (2.2, -2.2, 0), (2.2, 2.2, 0), (-2.2, 2.2, 0))

#let scene = build-scene(
  // face — a translucent ground plane, flat-shaded from the theme light.
  face(c, color: blue, fill-opacity: 72%),
  // edge — the four wireframe rims of the tile.
  edge(c.at(0), c.at(1)), edge(c.at(1), c.at(2)),
  edge(c.at(2), c.at(3)), edge(c.at(3), c.at(0)),
  // sphere — two shaded balls floating above the plane.
  sphere((-1.1, -1.0, 1.2), 0.6, color: orange),
  sphere((1.2, 1.1, 1.5), 0.5, color: blue),
  // seg — a thick round-capped bond joining the two balls.
  seg((-1.1, -1.0, 1.2), (1.2, 1.1, 1.5), color: charcoal),
  // arrow — a vertical normal rising out of the tile centre.
  arrow((0, 0, 0), (0, 0, 2.6), color: charcoal),
  // label — text anchored in 3D, always painted on top.
  label((-1.1, -1.0, 2.0), [A]),
  label((1.2, 1.1, 2.3), [B]),
  label((0.35, 0, 2.7), [n]),
)

#render-scene(
  scene,
  camera(azimuth: 30deg, elevation: 20deg),
  width: 9cm,
  axes: (vectors: ((1, 0, 0), (0, 1, 0), (0, 0, 1)), names: ($x$, $y$, $z$)),
)
