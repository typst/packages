#import table: cell
#let ytableausp(
  shape: ((1,2,3), (4,5), (6,)),
  cellsize: 1.1em,
  fontsize: 0.7em,
) = {
  let tableaucells = calc.max(shape.len(), shape.at(0).len())
  let cells = ()
  let columnsize = ()
  let rowsize = ()
  let i = 0

  while i < shape.at(0).len() {
    columnsize.push(cellsize)
    i += 1
  }
  i = 0
  while i < shape.len() {
    rowsize.push(cellsize)
    i += 1
  }

  for (y, row-length) in shape.enumerate() {
    let x = 0
    while x < shape.at(0).len() {
      if x < shape.at(y).len() {
        if type(shape.at(y).at(x)) == int {
          cells.push(
            cell(x: x,
                y: y
            )[#text(size: fontsize)[#shape.at(y).at(x)]],
          )
        } else {
          cells.push(
            cell(x: x,
                y: y,
                stroke: shape.at(y).at(x).at(1),
                fill: shape.at(y).at(x).at(2)
            )[#shape.at(y).at(x).at(0)],
          )
        }
      } else {
        cells.push(
          cell(x: x,
              y: y,
              stroke: none
          )[],
        )
      }
      x += 1
    }
  }
  box(
    baseline: 50% - 0.5em,
    table(
      columns: columnsize,
      rows: rowsize,
      align: center + horizon,
      ..cells
    )
  )
}