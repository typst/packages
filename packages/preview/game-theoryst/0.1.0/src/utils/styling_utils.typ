#import table: cell
#import "table_utils.typ": blank-cells
#import "programming_utils.typ": if-else


// Helper function to format player 1's name
  // Default color is red
  // Default rspn (`row-span`) is for a 3x3 game
#let p1(name, color: red, rspn: 3) = {
  cell(
    inset: (right: 1em),
    rowspan: rspn, 
    text(
      fill: color, 
      weight: "semibold",
      name
    )
  )
}

// Helper function to format player 1's name
  // Default color is blue
  // Default cspn (`column-span`) is for a 3x3 game
#let p2(name, color: blue, cspn: 3) = {
  table.header(
    blank-cells(), 
    cell(
      inset: (bottom: 0.66em),
      colspan: cspn, 
      text(
        fill: color, 
        weight: "semibold", 
        name
      )
    )
  )
}

// Utility for styling mixed parameters
#let mixd(color: "e64173", delims: ([\[], [\]]), spaces: false, body) = {
  let spc = if-else(spaces, [ ], [])
  set text(fill: rgb(color))
  if body != [] [#delims.at(0)#spc#body#spc#delims.at(1)]
}