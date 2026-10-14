// # Section. Seção.

#import "../packages.typ": icons
#import "../state.typ": kept_colors


#let section(
  r1c1: none,
  r1c2: none,
  r2c1: none,
  r2c2: none,
  r3: none,
) = context {
  let colors = kept_colors.get()

  let second_row_cells = ()

  if r2c1 != none {
    second_row_cells.push(
      grid.cell(
        x: 0,
      )[
        #text(
          fill: colors.primary,
          weight: "semibold",
        )[
          #r2c1
        ]
      ],
    )
  }

  if r2c2 != none {
    second_row_cells.push(
      grid.cell(
        x: 1,
      )[
        #text(
          fill: colors.primary,
          weight: "medium",
        )[
          #r2c2
        ]
      ],
    )
  }

  block(
    below: 0.75em,
  )[
    #grid(
      columns: (1fr, auto),
      heading(
        level: 2,
      )[#r1c1],
      text(
        fill: colors.primary,
        weight: "medium",
      )[
        #r1c2
      ],
    )

    #if second_row_cells.len() > 0 {
      grid(
        columns: (1fr, auto),
        ..second_row_cells
      )
    }

    #r3
  ]
}
