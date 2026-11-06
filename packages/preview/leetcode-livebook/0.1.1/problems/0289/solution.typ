#import "../../helpers.typ": *

#let solution(board) = {
  let m = board.len()
  let n = board.at(0).len()
  let next-board = fill(fill(0, n), m)

  let count-live-neighbors(board, i, j) = {
    let count = 0
    for di in range(-1, 2) {
      for dj in range(-1, 2) {
        if di == 0 and dj == 0 {
          continue
        }
        if i + di < 0 or i + di >= m or j + dj < 0 or j + dj >= n {
          continue
        }
        if board.at(i + di).at(j + dj) == 1 {
          count += 1
        }
      }
    }
    count
  }

  for i in range(m) {
    for j in range(n) {
      let live-neighbors = count-live-neighbors(board, i, j)
      if board.at(i).at(j) == 1 {
        if live-neighbors == 2 or live-neighbors == 3 {
          next-board.at(i).at(j) = 1
        }
      } else {
        if live-neighbors == 3 {
          next-board.at(i).at(j) = 1
        }
      }
    }
  }
  next-board
}
