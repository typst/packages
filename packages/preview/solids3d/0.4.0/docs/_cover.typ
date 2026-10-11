// Cover mosaic: the simple API in six figures.
#import "_h.typ": *

#let cover-mosaic() = {
  let L = s3.light((-1, 0.9, 1.1))
  let sz = 5.3cm
  set align(center)
  let cell(body, cap) = block(breakable: false, { body; v(-3pt); text(size: 8.5pt, style: "italic", cap) })
  grid(columns: 3, column-gutter: 3pt, row-gutter: 16pt,
    cell(s3.fig(s3.sphere(1), size: sz, style: "banknote", s3.brace3((0, 0, -1), (0, 0, 1), $2r$)), [fig(sphere(1), style: "banknote")]),
    cell(s3.fig(s3.torus(1, 0.38), size: sz, style: "engraving"), [fig(torus(1, 0.38), style: "engraving")]),
    cell(s3.fig(s3.cone(1, 1.8), size: sz, s3.brace3((0, 0, 0), (0, 0, 1.8), $h$)), [fig(cone(1, 1.8), brace3(…))]),
    cell(s3.fig(s3.trefoil(), size: sz, tube: 10pt, style: "engraving"), [fig(trefoil(), style: "engraving")]),
    cell(s3.fig(..s3.borromean(a: 2, b: 1.25), size: sz, tube: 7pt), [fig(..borromean())]),
    cell(s3.fig(s3.torus-knot(2, 5, R: 2, r: 0.8), size: sz, tube: 8pt, view: (0, 85)), [fig(torus-knot(2, 5), view: "top")]),
  )
}
