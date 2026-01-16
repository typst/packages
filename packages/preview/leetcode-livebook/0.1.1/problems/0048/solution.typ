#import "../../helpers.typ": *

#let solution(matrix) = {
  let n = matrix.len()

  // Rotate 90 degrees clockwise: transpose then reverse each row
  // result[i][j] = matrix[n-1-j][i]

  let result = ()
  for i in range(n) {
    let row = ()
    for j in range(n) {
      row.push(matrix.at(n - 1 - j).at(i))
    }
    result.push(row)
  }

  result
}
