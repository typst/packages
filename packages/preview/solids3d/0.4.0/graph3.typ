// graph3.typ — graphing facade inspired by graph3.asy.
#import "src/vec.typ": *
#import "src/path3.typ": *
#import "src/projection.typ": *
#import "src/pens.typ": *
#import "src/picture.typ": *

// Render a 3D curve immediately, with optional coordinate axes.
#let graph3-plot(f, a, b, size: 6cm, projection: orthographic(5, 4, 3),
  n: 100, join: "--", pen: blue, axes: true, xlabel: $x$, ylabel: $y$, zlabel: $z$) = {
  let g = graph3(f, a, b, n: n, join: join)
  let cmds = (draw(g, pen),)
  if axes { cmds += axes3(xlabel, ylabel, zlabel, arrow: Arrow3) }
  picture(size: size, projection: projection, ..cmds)
}

// A parametric curve is the same construction under a name familiar from
// calculus and physics.
#let parametric-plot3 = graph3-plot
