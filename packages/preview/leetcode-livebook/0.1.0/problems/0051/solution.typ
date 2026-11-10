#import "../../helpers.typ": *

#let solution(n) = {
  if n == 0 {
    return ((),)
  }

  let build-board(positions) = {
    range(n).map(r => range(n)
      .map(c => if c == positions.at(r) { "Q" } else { "." })
      .join())
  }

  let is-safe(positions, row, col) = {
    for r in range(row) {
      let c = positions.at(r)
      if c == col or calc.abs(r - row) == calc.abs(c - col) {
        return false
      }
    }
    true
  }

  let solve(positions, row) = {
    if row == n {
      return (build-board(positions),)
    }

    let ret = ()
    for col in range(n) {
      if not is-safe(positions, row, col) {
        continue
      }
      let new-pos = positions.map(x => x)
      new-pos.push(col)
      for board in solve(new-pos, row + 1) {
        ret.push(board)
      }
    }
    ret
  }

  solve((), 0)
}
