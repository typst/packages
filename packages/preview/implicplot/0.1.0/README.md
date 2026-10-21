# Implicplot

![Five arms of the discrete logarithmic spiral: floor(15/(2pi) ln r) = floor(15/(2pi) theta) + k (mod 15), for k = 0, 3, 6, 9, 12 — drawn by this package's plotter](thumbnail.png)

Plot implicit relations in Typst, rigorously. A relation is one string, written
the way it is written on paper — `"sin(x^2 + y^2) = cos(x*y)"` — and the
comparison lives inside it. The cover above is five relations of the form
`(floor(15/(2*pi) * log(x^2 + y^2) / 2) - floor(15/pi * atan(y / (sqrt(x^2 + y^2) + x))) - k) % 15 = 0`,
one colour per residue `k` — a plot only interval arithmetic gets right: the
relation is a step function whose solution set has area, poles, and no
continuity to lean on.

Two entry points answer two different questions:

* `plot` — *which pixels may the relation touch?* Returns one byte per pixel,
  computed by adaptive subdivision with interval arithmetic (Tupper's reliable
  graphing): coverage errs outward, never inward, and inequalities fill
  regions. Not an image — the document decides what to draw.
* `contour` — *where is the curve?* Returns polylines whose topology is
  guaranteed (Plantinga & Vegter's subdivision with Lin & Yap's stopping
  rule), plus a count of cells around singularities where no subdivision
  could decide. Stroke them, fill them, or hand them to your plotting package.

```typst
#import "@preview/implicplot:0.1.0": plot, contour, rows

// 64 bytes, row-major from the top: an 8x8 raster of x < 0.
#let pixels = plot("x < 0", size: (8, 8), x: (-1, 1), y: (-1, 1))

// One closed chain of (x, y) points on the unit circle, stroked as a path.
#let c = contour("x^2 + y^2 = 1", n: 60, x: (-1.5, 1.5), y: (-1.5, 1.5))
#box(width: 5cm, height: 5cm, {
  let s = 5cm / 3
  let pts = c.chains.at(0).map(p => ((p.at(0) + 1.5) * s, (1.5 - p.at(1)) * s))
  place(curve(curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p))))
})
```

The expression language is `x`, `y`, `pi`, `tau`, `e`, decimal literals,
`+ - * / %` (floored modulo), `^` with an integer exponent, and the functions
`abs neg sin cos tan exp sqrt log asin acos atan floor ceil min max`.
Multiplication is never implicit. A relation that does not parse fails at the
call site with a caret under the offending character.

The computation runs in a WebAssembly plugin written in Zig; nothing but the
relation text and the view crosses the boundary. The full manual, with
rendered examples, poles-and-asymptotes behaviour and the API reference, lives
in the [repository](https://github.com/uwni/implicplot).
