#let table-three-line(stroke-color) = {
  (x, y) => (
    top: if y < 2 {
      stroke-color
    } else {
      0pt
    },
    bottom: stroke-color,
  )
}

#let table-no-left-right(stroke-color) = {
  (x, y) => (
    left: if x > 2 {
      stroke-color
    } else {
      0pt
    },
    top: stroke-color,
    bottom: stroke-color,
  )
}

#let tableq(data, k, inset: 0.3em, stroke-color: rgb("000")) = {
  table(
    columns: k,
    inset: inset,
    align: center + horizon,
    stroke: table-three-line(stroke-color),
    ..data.flatten(),
  )
}


#let code(text, lang: "python", breakable: true, width: 100%) = block(
  fill: rgb("#F3F3F3"),
  stroke: rgb("#DBDBDB"),
  inset: (x: 1em, y: 1em),
  outset: -.3em,
  radius: 5pt,
  spacing: 1em,
  breakable: breakable,
  width: width,
  raw(
    text,
    lang: lang,
    align: left,
    block: true,
  ),
)
