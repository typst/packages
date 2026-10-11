// Public module facades inspired by Asymptote's 3D modules.
#import "@preview/solids3d:0.4.0": three, three_surface, three_light, graph3mod, college
#set page(width: auto, height: auto, margin: 8pt)

#let P = three.orthographic(5, 4, 3)
#let tetra = college.regular-tetrahedron(radius: 1)
#let octa = college.regular-octahedron(radius: 1)
#let frustum = college.frustum3(bottom-radius: 1, top-radius: 0.55, height: 1.6, n: 16)

#grid(columns: 3, gutter: 8pt,
  three.picture(width: 5cm, projection: P,
    three.draw(tetra, three.withopacity(three.paleblue, 0.75)),
  ),
  three.picture(width: 5cm, projection: P,
    three.draw(octa, three.withopacity(three.palegreen, 0.75)),
  ),
  three.picture(width: 5cm, projection: P,
    three.draw(frustum, three.withopacity(three.paleyellow, 0.8)),
  ),
)

#graph3mod.graph3-plot(
  t => (t, t * t, t * t * t),
  -1, 1,
  size: 7cm,
  n: 64,
  pen: three.royalblue,
  axes: true,
)

#repr(three_light.material(diffuse: three.red, specular: three.white))
#repr(three_surface.unitsphere.patches.len())
