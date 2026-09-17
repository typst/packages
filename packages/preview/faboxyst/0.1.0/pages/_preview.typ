// shared bits for the combo-style preview pages
#let titre(t) = block(above: 0.95em, below: 0.4em,
  text(size: 8pt, style: "italic", fill: rgb("#666"), t))

#let badge(n, fill: rgb("#1A3580")) = box(
  width: 0.52cm, height: 0.52cm,
  fill: fill, radius: 50%,
  align(center + horizon,
    text(fill: white, weight: "bold", size: 0.85em, dir: ltr, n)))

#let chip(fill, body) = grid(
  columns: (auto, 1fr), column-gutter: 0.22cm, align: (horizon, horizon),
  box(width: 0.36cm, height: 0.36cm, fill: fill, radius: 0.05cm,
    stroke: 0.6pt + fill.darken(25%)),
  body,
)

#let sample(kind, ar: false) = {
  let title-line = if ar {
    grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{" + kind + "}"))
      ])
  } else {
    grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        Example #h(0.25em) #raw("begin{" + kind + "}")
      ])
  }
  title-line
  v(0.28em)
  if ar {
    chip(rgb("#E91E63"), [الحالة الأولى])
    v(0.14em)
    chip(rgb("#7CB342"), [الحالة الثانية])
  } else {
    chip(rgb("#E91E63"), [First case])
    v(0.14em)
    chip(rgb("#7CB342"), [Second case])
  }
}
