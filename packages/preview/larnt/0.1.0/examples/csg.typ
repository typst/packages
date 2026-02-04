#set page(margin: 0pt, height: auto)
#import "../lib.typ": *

#render(
  eye: (3., 2.5, 2.0),
  center: (1., 0.0, 0.0),
  step: 0.05,
  difference(
    cube((0., 0., 0.), (1., 1., 1.), texture: "Stripes", stripes: 15),
    sphere((1., 1., 0.5), 0.5),
    sphere((0., 1., 0.5), 0.5),
    sphere((0., 0., 0.5), 0.5),
    sphere((1., 0., 0.5), 0.5),
  ),
  cube((0.3, 0.3, 1.), (.7, .7, 1.2), texture: "Stripes", stripes: 10),
  intersection(
    sphere((2.0, 0.25, 0.5), 0.6),
    cube((1.5, -0.25, 0.), (2.5, 0.75, 1.0), texture: "Stripes", stripes: 25),
  ),
)
