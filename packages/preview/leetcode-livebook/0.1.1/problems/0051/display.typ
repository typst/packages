#import "../../utils.typ": chessboard
#import "../../helpers.typ": display

#let custom-display(input) = {
  // N-Queens: input is just n
  [*n:* #input.n]
}

// Render array of chessboards (N-Queens output)
#let custom-output-display(output) = {
  if type(output) != array or output.len() == 0 {
    return display(output)
  }
  // Check if it's array of boards (each board is array of strings)
  let first = output.at(0)
  if type(first) == array and first.len() > 0 and type(first.at(0)) == str {
    // Array of chessboards
    align(center)[#output.map(chessboard).join(line(length: 80%))]
  } else if type(first) == str {
    // Single chessboard
    chessboard(output)
  } else {
    // Fallback
    repr(output)
  }
}
