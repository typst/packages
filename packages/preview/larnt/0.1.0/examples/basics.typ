#set page(margin: 0pt, height: auto)
#import "../lib.typ": *

#render(
  eye: (2., 7., 5.),
  center: (1.5, 2., 0.),
  step: 0.01,
  cube((0., 0., 0.), (1., 1., 1.)),
  cube((1.5, 0., 0.), (2.5, 1., 1.), texture: "Stripes", stripes: 8),
  sphere((0.5, 2., .5), 0.5),
  sphere((2., 2., .5), 0.5, texture: "RandomCircles"),
  sphere((0.5, 3.5, .5), 0.5, texture: "RandomEquators"),
  outline(sphere((2., 3.5, .5), 0.5)),
  cone(0.5, (-1., 0.5, 0.), (-1., 0.5, 1.)),
  translate(outline(cone(0.5, (0., 0., 0.), (0., 0., 1.))), (-1., 2.0, 0.)),
  cylinder(0.5, (3.5, 0.5, 0.), (3.5, 0.5, 1.)),
  translate(outline(cylinder(0.5, (0., 0., 0.), (0., 0., 1.))), (3.5, 2.0, 0.)),
)
