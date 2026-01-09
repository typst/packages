#import "../../helpers.typ": *

#let solution(grid) = {
  let m = grid.len()
  let n = grid.at(0).len()
  let visited = fill(fill(false, n), m)
  let count = 0
  let stack = ()
  for i in range(m) {
    for j in range(n) {
      if grid.at(i).at(j) == 1 and not visited.at(i).at(j) {
        stack.push((i, j))
        while stack.len() > 0 {
          let (x, y) = stack.pop()
          if (
            x < 0
              or x >= m
              or y < 0
              or y >= n
              or visited.at(x).at(y)
              or grid.at(x).at(y) == 0
          ) {
            continue
          }
          visited.at(x).at(y) = true
          stack.push((x + 1, y))
          stack.push((x - 1, y))
          stack.push((x, y + 1))
          stack.push((x, y - 1))
        }
        count += 1
      }
    }
  }
  count
}
