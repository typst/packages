// Visibility regression: one changing-depth arrow crosses an opaque plane and
// an opaque sphere. Its rear interval is removed, its foreground interval stays
// visible, and exactly one arrowhead remains.
#import "/lib.typ": sphere, arrow, face, edge, label, build-scene
#import "/lib.typ": camera, render-scene

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "New Computer Modern", size: 9pt)

#let plane = (
  (-1.1, 0, -0.8), (1.1, 0, -0.8),
  (1.1, 0, 0.8), (-1.1, 0, 0.8),
)
#let scene = build-scene(
  face(plane, color: rgb("#a9b7c3"), fill-opacity: 0%, shade: false),
  edge(plane.at(0), plane.at(1), color: luma(90)),
  edge(plane.at(1), plane.at(2), color: luma(90)),
  edge(plane.at(2), plane.at(3), color: luma(90)),
  edge(plane.at(3), plane.at(0), color: luma(90)),
  sphere((1.25, 0.35, 0), 0.42, color: rgb("#b77955")),
  arrow((-2.1, -1.0, 0), (2.1, 1.0, 0), color: rgb("#354f63"), w: 0.055),
  label((-1.55, -0.75, 0.2), [behind]),
  label((1.7, 0.8, 0.2), [in front]),
)

#render-scene(scene, camera(azimuth: 0deg, elevation: 0deg), width: 10cm)
