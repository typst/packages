// utils.typ - Utility functions for display and comparison
// No external package dependencies

#let fill(value, n) = range(n).map(_ => value)

// Only recognize string-based chessboards (like N-Queens output)
// 0/1 matrix boards should use custom-display instead
#let is-chessboard(value) = {
  if type(value) != array or value.len() == 0 {
    return false
  }
  // Must be array of strings (like [".Q..", "...Q", "Q...", "..Q."])
  let first-row = value.at(0)
  if type(first-row) != str {
    return false
  }
  let row-size = first-row.len()
  for row in value {
    if type(row) != str or row.len() != row-size {
      return false
    }
  }
  true
}

#let chessboard(board) = {
  if board.len() == 0 {
    return []
  }
  let width = board.at(0).len()
  let cells = ()
  for r in range(board.len()) {
    let chars = if type(board.at(r)) == array { board.at(r) } else {
      board.at(r).clusters()
    }
    for c in range(width) {
      let ch = chars.at(c)
      let content = if ch == "Q" {
        text(weight: "bold")[Q]
      } else if ch == "." {
        text(fill: gray)[·]
      } else {
        text(weight: "bold")[#ch]
      }
      cells.push(content)
    }
  }
  table(
    align: center,
    columns: fill(auto, width),
    ..cells,
  )
}

// Comparators for testcases with special requirements
#let unordered-compare(a, b) = {
  if type(a) != array or type(b) != array {
    return a == b
  }
  if a.len() != b.len() {
    return false
  }
  a.sorted() == b.sorted()
}

// Compare float numbers by both absolute and relative error
#let float-compare(a, b) = {
  if a == b {
    return true
  }
  // Handle none values
  if a == none or b == none {
    return a == b
  }
  let abs = calc.abs(a - b)
  let rel = if a == 0 {
    calc.abs(b)
  } else {
    calc.abs(b - a) / calc.abs(a)
  }
  abs < 1e-6 or rel < 1e-6
}
