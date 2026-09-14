#import "../../helpers.typ": *

#let solution(isConnected) = {
  let n = isConnected.len()
  if n == 0 { return 0 }

  let parent = range(n)
  let rank = (0,) * n

  // Find with path compression (modifies parent in place)
  // Returns root, caller must update parent afterwards
  let find-and-compress(p, x) = {
    // First pass: find root
    let curr = x
    while p.at(curr) != curr {
      curr = p.at(curr)
    }
    let root = curr

    // Second pass: collect nodes to compress
    let path = ()
    curr = x
    while curr != root {
      path.push(curr)
      curr = p.at(curr)
    }

    (root, path)
  }

  let provinces = n

  for i in range(n) {
    for j in range(i + 1, n) {
      if isConnected.at(i).at(j) == 1 {
        // Find roots with path compression
        let (rx, path-i) = find-and-compress(parent, i)
        for node in path-i {
          parent.at(node) = rx
        }

        let (ry, path-j) = find-and-compress(parent, j)
        for node in path-j {
          parent.at(node) = ry
        }

        if rx != ry {
          // Union by rank
          if rank.at(rx) < rank.at(ry) {
            parent.at(rx) = ry
          } else if rank.at(rx) > rank.at(ry) {
            parent.at(ry) = rx
          } else {
            parent.at(ry) = rx
            rank.at(rx) = rank.at(rx) + 1
          }
          provinces -= 1
        }
      }
    }
  }

  provinces
}
