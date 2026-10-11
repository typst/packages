// Exemple minimal — compiler avec :  typst compile quickstart.typ
#import "@preview/solids3d:0.4.0": *
#set page(width: auto, height: auto, margin: 1cm)

#let P = orthographic(5, 4, 3)
#let b = sphere(O, 1)

#picture(size: 6cm, projection: P,
  draw(surface(b), withopacity(paleblue, 0.5)),
  draw(b, m: 5, frontpen: blue, backpen: pen(blue, linetype("8 8")), longitudinalpen: nullpen),
  dot(Label($O$, align: NW), O),
  xaxis3($x$, Arrow3), yaxis3($y$, Arrow3), zaxis3($z$, Arrow3),
)
#h(1cm)
#picture(size: 6cm, projection: perspective(6, 3, 3),
  draw(apply(shift(-0.5, -0.5, 0), unitcube), withopacity(palered, 0.8), orange),
  draw(surface(cone((0, 0, 1), 0.7, 1.2, Z, 1)), withopacity(palegreen, 0.7)),
  draw(cone((0, 0, 1), 0.7, 1.2, Z, 1), black),
  draw(silhouette(sphere((1.5, 0, 0.5), 0.5), m: 32), heavyblue),
  draw(surface(sphere((1.5, 0, 0.5), 0.5)), withopacity(paleblue, 0.6)),
)
