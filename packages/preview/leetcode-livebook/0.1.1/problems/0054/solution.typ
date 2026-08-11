#import "../../helpers.typ": *

#let solution(matrix) = {
  if matrix.len() == 0 {
    return ()
  }

  let m = matrix.len()
  let n = matrix.at(0).len()
  let result = ()

  let top = 0
  let bottom = m - 1
  let left = 0
  let right = n - 1

  while top <= bottom and left <= right {
    // Right
    for j in range(left, right + 1) {
      result.push(matrix.at(top).at(j))
    }
    top += 1

    // Down
    for i in range(top, bottom + 1) {
      result.push(matrix.at(i).at(right))
    }
    right -= 1

    // Left
    if top <= bottom {
      for j in range(right, left - 1, step: -1) {
        result.push(matrix.at(bottom).at(j))
      }
      bottom -= 1
    }

    // Up
    if left <= right {
      for i in range(bottom, top - 1, step: -1) {
        result.push(matrix.at(i).at(left))
      }
      left += 1
    }
  }

  result
}
