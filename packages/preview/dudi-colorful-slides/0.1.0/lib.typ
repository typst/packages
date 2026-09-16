#let color1 = rgb("#282bce")
#let color2 = rgb("#f02d2d")
#let text-color = black

#let styles = (doc) => {
  set page(
    paper: "presentation-16-9",
    margin: 0cm
  )
  set text(
    font: "Helvetica",
    size: 24pt
  )
  doc
}

#let regular-pattern(color1: rgb("#142d95"), color2: rgb("#60c9f3"), n: 4, small-part, big-part, h) = {
  let small-step = small-part * 100% / (n)
  let big-step = big-part * 100% / (n)
  let h = h
  let shapes = ()
  let x = 0%
  for i in range(n) {
    shapes.push(polygon(fill:color1, (x, 0pt), (x, h), (x + small-step, h)))

    shapes.push(polygon(fill: color2, (x - small-step, 0pt), (x, 0pt), (x, h)))

    shapes.push(polygon(fill: color2, (x, 0pt), (x, h), (x + big-step, h)))

    shapes.push(polygon(fill: color1, (x - big-step, 0pt), (x, 0pt), (x, h)))

  }
  stack(dir: ltr, spacing: 0pt, ..shapes)
}


#let triangle-grid(color1: rgb("#142d95"), color2: rgb("#60c9f3"), n: 6) = {
  let row = 0
  let w = 100% / n
  let h = 100% / n
  let shapes = ()
  while row < n {
      let col = 0
      while col < n {
        let x = 0%
        let y = 0%
        let cx = x + w / 2
        let cy = y + h / 2
        let swap = calc.rem(row + col, 2) == 1
        let c-top = if swap { color2 } else { color1 }
        let c-right = if swap { color1 } else { color2 }

        shapes.push(polygon(fill: c-top, (x, y), (x + w, y), (cx, cy)))
        shapes.push(polygon(fill: c-right, (x - w, y), (x - w, y + h), (cx - w, cy)))
        shapes.push(polygon(fill: c-top, (x - w, y + h), (x, y + h), (cx - w, cy)))
        shapes.push(polygon(fill: c-right, (x, y + h), (x, y), (cx - w, cy)))
        col += 1
  }
  stack(dir: ltr, spacing: 0pt, ..shapes)
  shapes = ()
  row += 1
  }
}


#let slide(title, column1, column2, color1: color1, color2: color2, text-color: text-color, ratio1: 0.5, ratio2: 0.5, title-size: 42pt, text-size: 24pt, is-last: false) = {
  place(regular-pattern(color1:color1, color2: color2, n: 4, ratio1, ratio2, 8%))
  set align(center)
  set text(fill: text-color, size: title-size)
  v(8%+3%)
  [#underline([#title])]
  set text(fill: text-color, size: text-size)
  grid(align: left, columns: 2, rows: (56%), [#column1], [#column2], inset: 1em)
  place(regular-pattern(color2: color1, color1: color2, n: 4, ratio1, ratio2, 8%), dy: 9%)
  if not is-last [
  #pagebreak()
  ]
}


#let title-slide(title, title-size, author1, author2, color1: color1, color2: color2, n: 6) = {
  set par(spacing: 0em)
  set text(size: title-size)
  place(triangle-grid(color1: color1, color2: color2, n: n))
  place(horizon+center, rect(fill:white, stroke: 3pt, width: 80%, height: 80%)[#title])
  place(horizon+center, [#v(6em)#line(length: 60%, stroke: 2pt)
  #text(size: 26pt)[#v(1em) #align(center)[#grid(columns: (10cm, 10cm), [#align(left)[#author1]], [#align(right)[#author2]])]]])
  pagebreak()
}
