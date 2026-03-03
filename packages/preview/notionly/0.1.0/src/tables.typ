// Style for Tables (Notion style)
#let tabletion(body) = {
  show table.cell: set text(size: 0.9em)
  set table(
    stroke: 0.1pt + gray,
    inset: 0.7em,
  )
  body
}

// EXAMPLE TABLE
/*
#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  fill: (x, y) => {
    if x == 0 or y == 0 {rgb("#f7f6f3")} // Row header + Col header
  },
  [], [Dissabte], [Diumenge],
  [Matí], [Netejar l’habitació], [Programar],
  [Tarda], [Festa d’aniversari], [Estudiar _Relativitat General_]
)
*/