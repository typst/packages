#import "../../utils.typ": chessboard

#let custom-display(input) = {
  // Number of Provinces: display adjacency matrix as chessboard
  let n = input.isConnected.len()
  [*Adjacency Matrix:* $#n times #n$]
  linebreak()
  chessboard(input.isConnected)
}
