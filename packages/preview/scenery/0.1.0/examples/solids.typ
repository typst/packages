// Solids gallery: the four parametric mesh generators — UV-sphere, cylinder,
// cone and prism — lined up beside a convex-hull polyhedron built from bare
// vertices. Meshes are flat-shaded with hidden facet seams; the icosahedron is
// drawn from `hull-faces`, one filled `face` per hull plane, so its edges read
// as visible strokes.
#import "@preview/scenery:0.1.0": face, build-scene
#import "@preview/scenery:0.1.0": uv-sphere, cylinder, cone, prism, hull-faces
#import "@preview/scenery:0.1.0": camera, render-scene

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "New Computer Modern", size: 10pt)

#let solid-color = rgb("#6485a6")
#let hull-color = rgb("#7b8490")

// Icosahedron vertices: cyclic permutations of (0, +/-1, +/-phi).
#let phi = (1 + calc.sqrt(5)) / 2
#let ico-verts = (
  (0, 1, phi), (0, 1, -phi), (0, -1, phi), (0, -1, -phi),
  (1, phi, 0), (1, -phi, 0), (-1, phi, 0), (-1, -phi, 0),
  (phi, 0, 1), (phi, 0, -1), (-phi, 0, 1), (-phi, 0, -1),
)
// Every hull plane becomes one opaque, stroked triangle centred at (10, 0, 0).
#let ico = hull-faces(ico-verts).map(f => face(
  f.vertices.map(v => (v.at(0) + 11.5, v.at(1), v.at(2))),
  color: hull-color, fill-opacity: 0%,
))

// Solids are drawn opaque (fill-opacity: 0%) so the flat lighting reads as a
// solid surface rather than glass.
#let scene = build-scene(
  uv-sphere((0, 0, 0), 1.2, segments: 24, rings: 12, color: solid-color, fill-opacity: 0%),
  cylinder((2.7, 0, -1.2), (2.7, 0, 1.2), 0.9, segments: 28, color: solid-color, fill-opacity: 0%),
  cone((5.4, 0, -1.2), (5.4, 0, 1.4), 1.0, segments: 28, color: solid-color, fill-opacity: 0%),
  prism(
    ((7.2, -0.9, -1.2), (8.6, -0.9, -1.2), (7.9, 0.6, -1.2)),
    (0, 0, 2.4), color: solid-color, fill-opacity: 0%,
  ),
  ico, // an array of faces; build-scene flattens nested groups
)

#render-scene(scene, camera(azimuth: 30deg, elevation: 28deg), width: 15cm)
