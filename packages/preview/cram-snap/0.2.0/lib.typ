#let cram-snap(
  title: none,
  icon: none,
  column-number: 2,
  subtitle: none,
  doc,
) = {
  let table_stroke(color) = (
    (x, y) => (
      left: none,
      right: none,
      top: none,
      bottom: if y == 0 {
        color
      } else {
        0pt
      },
    )
  )

  let table_fill(color) = (
    (x, y) => {
      if calc.odd(y) {
        rgb(color)
      } else {
        none
      }
    }
  )

  set table(
    align: left + horizon,
    columns: (2fr, 3fr),
    fill: table_fill(rgb("F2F2F2")),
    stroke: table_stroke(rgb("21222C")),
  )

  set table.header(repeat: false)

  show table.cell.where(y: 0): set text(weight: "bold", size: 12pt)

  columns(column-number)[
    #align(center)[
      #box(height: 20pt)[
        #if icon != none {
          set image(height: 100%)
          box(icon, baseline: 25%)
        }
        #text(17pt, title)
      ]

      #text(10pt, subtitle)
    ]

    #doc
  ]
}

#let theader(..cells, colspan: 2) = table.header(
  ..cells.pos().map(x => if type(x) == content and x.func() == table.cell {
    x
  } else {
    table.cell(colspan: colspan, x)
  }),
  ..cells.named(),
)
