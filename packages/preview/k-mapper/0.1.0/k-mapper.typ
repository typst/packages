// Copyright 2024 Derek Chai.
// Use of this code is governed by a MIT license in the LICENSE.txt file.

// Calculates the resultant color when multiple RGB colors with alpha are
// overlayed atop each other.
#let overlay-color(colors, alpha: 120) = {
  let r_sum = 0
  let g_sum = 0
  let b_sum = 0
  
  for color in colors {
    r_sum += color.at(0)
    g_sum += color.at(1)
    b_sum += color.at(2)
  }

  if colors.len() == 0 {
    return rgb(255, 255, 255, 0)
  }

  return rgb(
    calc.div-euclid(r_sum, colors.len()),
    calc.div-euclid(g_sum, colors.len()),
    calc.div-euclid(b_sum, colors.len()),
    alpha
  )
}

#let guard(expression, otherwise: "") = {
  if not expression {
    panic(otherwise)
  }
}

#let karnaugh(
  variables: (), 
  manual-terms: (), 
  implicants: (), 
  cell-size: 20pt,
  stroke: 0.5pt,
  colors: (
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (255, 255, 0),
    (0, 255, 255),
    (255, 0, 255),
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (255, 255, 0),
    (0, 255, 255),
    (255, 0, 255)
  ),
  alpha: 120
) = {
  guard(variables.len() >= 2, otherwise: "Too few variables provided! There " +
  "should be at least 2 variables provided.")

  if variables.len() == 2 {
    assert(manual-terms.len() == 4, 
    message: "Invalid number of terms provided! There should be exactly 4 "+
    "terms provided.")
  } else if variables.len() == 3 {
    assert(manual-terms.len() == 8,
    message: "Invalid number of terms provided! There should be exactly 8 "+
    "terms provided.")
  } else if variables.len() == 4 {
    assert(manual-terms.len() == 16,
    message: "Invalid number of terms provided! There should be exactly 16 "+
    "terms provided.")
  }

  let cell_colors = (
    (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()
  )

  let x-label
  let y-label

  if variables.len() == 2 {
    x-label = variables.at(1)
    y-label = variables.at(0)
  } else if variables.len() == 3 {
    x-label = variables.at(2)
    y-label = variables.at(0) + variables.at(1)
  } else if variables.len() == 4 {
    x-label = variables.at(2) + variables.at(3)
    y-label = variables.at(0) + variables.at(1)
  }

  for (index, implicant) in implicants.enumerate() {
    for cell in implicant {
      cell_colors.at(cell).push(colors.at(index))
    }
  }

  let y-label-row-span

  if variables.len() == 2 {
    y-label-row-span = 2
  } else {
    y-label-row-span = 4
  }

  let term-cells = ()

  for (index, term) in manual-terms.enumerate() {
    term-cells.push(
      table.cell(
        fill: overlay-color(cell_colors.at(index), alpha: alpha)
      )[#manual-terms.at(index)]
    )
  }

  // 2 variable (2x2) Karnaugh map
  if variables.len() == 2 {
    return block(
      breakable: false, 
      table(
        columns: (auto, auto, cell-size, cell-size),
        rows: (cell-size),
        align: center + horizon, 
        stroke: none,
        
        [], [], table.cell(colspan: 2, x-label), 
        [], [], [0], [1], 
        table.hline(start: 2, stroke: stroke),
        table.cell(rowspan: y-label-row-span, y-label), 
        [0],
        table.vline(start: 2, stroke: stroke),
        term-cells.at(0),
        term-cells.at(1),
        table.vline(start: 2, stroke: stroke),
        [1],
        term-cells.at(2),
        term-cells.at(3),
        table.hline(start: 2, stroke: stroke),
      ) 
    )

  // 3 variable (2x4) Karnaugh map
  } else if variables.len() == 3 {
    return block(
      breakable: false,
      table(
        columns: (auto, auto, cell-size, cell-size),
        rows: (cell-size),
        align: center + horizon, 
        stroke: none,

        [], [], table.cell(colspan: 2, x-label), 
        [], [], [0], [1], 
        table.hline(start: 2, stroke: stroke),
        table.cell(rowspan: y-label-row-span, y-label), 
        [00],
        table.vline(start: 2, stroke: stroke),
        term-cells.at(0), term-cells.at(1),
        table.vline(start: 2, stroke: stroke),
        [01], term-cells.at(2), term-cells.at(3),
        [11], term-cells.at(4), term-cells.at(5),
        [10], term-cells.at(6), term-cells.at(7),
        table.hline(start: 2, stroke: stroke)
      )
    )

  // 4 variable (4x4) Karnaugh map
  } else if variables.len() == 4 {
    return block(
      breakable: false,
      table(
        columns: (auto, auto, cell-size, cell-size, cell-size, cell-size),
        rows: (cell-size),
        align: center + horizon, 
        stroke: none,

        [], [], table.cell(colspan: 4, x-label), 
        [], [], [00], [01], [11], [10], 
        table.hline(start: 2, stroke: stroke),
        table.cell(rowspan: y-label-row-span, y-label), 
        [00],
        table.vline(start: 2, stroke: stroke),
        term-cells.at(0), term-cells.at(1), term-cells.at(2), term-cells.at(3),
        [01], term-cells.at(4), term-cells.at(5), term-cells.at(6), term-cells.at(7),
        [11], term-cells.at(8), term-cells.at(9), term-cells.at(10), term-cells.at(11),
        [10], term-cells.at(12), term-cells.at(13), term-cells.at(14), term-cells.at(15),
        table.vline(start: 2, stroke: stroke),
        table.hline(start: 2, stroke: stroke)
      )
    )
  }
}

#karnaugh(
  variables: ($A$, $B$, $C$) , 
  manual-terms: ("1", "1", "1", "1", "1", "0", "0", "0"), 
  implicants: ((0,1,2,3), (2,4))
)

#karnaugh(
  variables: ($A$, $B$) , 
  manual-terms: ("1", "1", "1", "1"), 
  implicants: ((0,1), (0,2))
)

#karnaugh(
  variables: ($A$, $B$, $C$, $D$) , 
  manual-terms: ("1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", ), 
  implicants: ((0,1,2,3), (0,1,4,5,8,9,12,13), (15,), (14,13))
)