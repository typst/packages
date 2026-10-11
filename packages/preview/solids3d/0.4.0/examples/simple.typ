// L'API simple : une seule fonction, fig().   typst compile --root . examples/simple.typ
#import "@preview/solids3d:0.4.0": *
#set page(width: auto, height: auto, margin: 1cm)

#grid(columns: 4, gutter: 8pt, align: center,
  fig(sphere(1), size: 3.4cm),
  fig(paint(cone(1, 1.8), orange), size: 3.4cm, view: "low"),
  fig(torus(1, 0.38), size: 3.4cm, style: "banknote", view: "high"),
  fig(trefoil(), size: 3.4cm, style: "engraving"),
  fig(cone(1, 1.8), brace3((0, 0, 0), (0, 0, 1.8), $h$), size: 3.4cm),
  fig(brick(3, 2, 1.4), brace3((-1.5, 1, -0.7), (1.5, 1, -0.7), $3$), size: 3.4cm),
  fig(cylinder(0.8, 1.6), size: 3.4cm, style: "etching", view: "front"),
  fig(..borromean(), size: 3.4cm, tube: 7pt))
