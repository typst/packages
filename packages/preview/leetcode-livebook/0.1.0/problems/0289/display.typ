#import "../../utils.typ": chessboard
#import "../../helpers.typ": display

#let custom-display(input) = {
  // Game of Life: display board as chessboard
  [*Board:* #input.board.len() x #input.board.at(0).len()]
  linebreak()
  chessboard(input.board)
}

#let custom-output-display(output) = {
  // Game of Life output: display as chessboard
  if type(output) != array or output.len() == 0 {
    return display(output)
  }
  chessboard(output)
}
