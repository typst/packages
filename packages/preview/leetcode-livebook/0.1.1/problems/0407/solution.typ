#import "../../helpers.typ": *

#let solution(heightMap) = {
  let m = heightMap.len()
  if m == 0 { return 0 }
  let n = heightMap.at(0).len()
  if n == 0 { return 0 }
  if m < 3 or n < 3 { return 0 }

  // Visited array
  let visited = range(m).map(_ => range(n).map(_ => false))

  // Min-heap: (height, row, col)
  let heap = ()

  // Add all boundary cells to heap
  for i in range(m) {
    for j in range(n) {
      if i == 0 or i == m - 1 or j == 0 or j == n - 1 {
        heap.push((heightMap.at(i).at(j), i, j))
        visited.at(i).at(j) = true
      }
    }
  }

  // Build initial heap (heapify)
  heap = heap.sorted()

  // Directions: up, down, left, right
  let dirs = ((-1, 0), (1, 0), (0, -1), (0, 1))

  let water = 0

  // BFS from boundary inward
  while heap.len() > 0 {
    // --- heap-pop: extract min ---
    let cell = heap.at(0)
    heap.at(0) = heap.at(-1)
    let _ = heap.pop()

    // sift-down
    if heap.len() > 0 {
      let curr = 0
      while true {
        let left = 2 * curr + 1
        let right = 2 * curr + 2
        let smallest = curr
        if left < heap.len() and heap.at(left) < heap.at(smallest) {
          smallest = left
        }
        if right < heap.len() and heap.at(right) < heap.at(smallest) {
          smallest = right
        }
        if smallest != curr {
          let tmp = heap.at(curr)
          heap.at(curr) = heap.at(smallest)
          heap.at(smallest) = tmp
          curr = smallest
        } else {
          break
        }
      }
    }
    // --- end heap-pop ---

    let (h, r, c) = cell

    // Check all neighbors
    for dir in dirs {
      let nr = r + dir.at(0)
      let nc = c + dir.at(1)

      // Skip if out of bounds or visited
      if nr < 0 or nr >= m or nc < 0 or nc >= n {
        continue
      }
      if visited.at(nr).at(nc) {
        continue
      }

      visited.at(nr).at(nc) = true
      let nh = heightMap.at(nr).at(nc)

      // Calculate new height (water level or terrain height)
      let new-h = calc.max(h, nh)

      // If neighbor is lower than current water level, it can trap water
      if nh < h {
        water += h - nh
      }

      // --- heap-push ---
      heap.push((new-h, nr, nc))
      // sift-up
      let curr = heap.len() - 1
      while curr > 0 {
        let parent = calc.floor((curr - 1) / 2)
        if heap.at(parent) > heap.at(curr) {
          let tmp = heap.at(curr)
          heap.at(curr) = heap.at(parent)
          heap.at(parent) = tmp
          curr = parent
        } else {
          break
        }
      }
      // --- end heap-push ---
    }
  }

  water
}
