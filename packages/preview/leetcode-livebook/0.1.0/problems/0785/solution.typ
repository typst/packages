#import "../../helpers.typ": *

#let solution(graph) = {
  let n = graph.len()
  if n == 0 { return true }

  // Color array: 0 = unvisited, 1 = color A, 2 = color B
  let color = fill(0, n)

  // BFS to check bipartiteness
  let is-bipartite = true

  for start in range(n) {
    if color.at(start) != 0 { continue }

    // BFS from this node
    let queue = (start,)
    color.at(start) = 1
    let qh = 0

    while qh < queue.len() and is-bipartite {
      let u = queue.at(qh)
      qh += 1
      let u-color = color.at(u)
      let neighbor-color = if u-color == 1 { 2 } else { 1 }

      for v in graph.at(u) {
        if color.at(v) == 0 {
          color.at(v) = neighbor-color
          queue.push(v)
        } else if color.at(v) != neighbor-color {
          is-bipartite = false
        }
      }
    }
  }

  is-bipartite
}
