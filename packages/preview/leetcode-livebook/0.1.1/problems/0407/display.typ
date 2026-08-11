// Trapping Rain Water II - 3D isometric visualization
#import "../../helpers.typ": display

// Calculate water levels using the same algorithm as solution
#let calculate-water-levels(heightMap) = {
  let m = heightMap.len()
  if m == 0 { return heightMap }
  let n = heightMap.at(0).len()
  if n == 0 { return heightMap }
  if m < 3 or n < 3 { return heightMap }

  // Water level at each cell (starts as terrain height)
  let water-level = heightMap.map(row => row.map(h => h))

  // Visited array
  let visited = range(m).map(_ => range(n).map(_ => false))

  // Min-heap: (height, row, col)
  let heap = ()

  // Add all boundary cells
  for i in range(m) {
    for j in range(n) {
      if i == 0 or i == m - 1 or j == 0 or j == n - 1 {
        heap.push((heightMap.at(i).at(j), i, j))
        visited.at(i).at(j) = true
      }
    }
  }
  heap = heap.sorted()

  let dirs = ((-1, 0), (1, 0), (0, -1), (0, 1))

  while heap.len() > 0 {
    let cell = heap.at(0)
    heap.at(0) = heap.at(-1)
    let _ = heap.pop()

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

    let (h, r, c) = cell

    for dir in dirs {
      let nr = r + dir.at(0)
      let nc = c + dir.at(1)

      if nr < 0 or nr >= m or nc < 0 or nc >= n { continue }
      if visited.at(nr).at(nc) { continue }

      visited.at(nr).at(nc) = true
      let nh = heightMap.at(nr).at(nc)
      let new-h = calc.max(h, nh)

      // Update water level
      water-level.at(nr).at(nc) = new-h

      heap.push((new-h, nr, nc))
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
    }
  }

  water-level
}

// Isometric block rendering
#let isometric-block(x, y, z, size: 20, fill-color: gray) = {
  let cos30 = calc.cos(30deg)
  let sin30 = calc.sin(30deg)

  let to2d(dx, dy, dz) = {
    let sx = (dx - dy) * cos30 * size
    let sy = (dx + dy) * sin30 * size + dz * size
    (sx, -sy)
  }

  let v = (
    "000": to2d(x, y, z),
    "100": to2d(x + 1, y, z),
    "110": to2d(x + 1, y + 1, z),
    "010": to2d(x, y + 1, z),
    "001": to2d(x, y, z + 1),
    "101": to2d(x + 1, y, z + 1),
    "111": to2d(x + 1, y + 1, z + 1),
    "011": to2d(x, y + 1, z + 1),
  )

  (
    (
      vertices: (v.at("001"), v.at("101"), v.at("111"), v.at("011")),
      fill: fill-color.lighten(40%),
    ),
    (
      vertices: (v.at("010"), v.at("011"), v.at("001"), v.at("000")),
      fill: fill-color.lighten(10%),
    ),
    (
      vertices: (v.at("000"), v.at("001"), v.at("101"), v.at("100")),
      fill: fill-color.darken(10%),
    ),
  )
}

// Render isometric grid with water
#let render-isometric(height-map, water-map, block-size: 12) = {
  let rows = height-map.len()
  let cols = height-map.at(0).len()

  let all-faces = ()

  // Painter's algorithm: back to front, bottom to top
  for y in range(rows).rev() {
    for x in range(cols).rev() {
      let h = height-map.at(y).at(x)
      let wl = water-map.at(y).at(x)

      // Terrain blocks
      for z in range(h) {
        let faces = isometric-block(
          x,
          y,
          z,
          size: block-size,
          fill-color: rgb("#C0C0C0"),
        )
        for face in faces { all-faces.push(face) }
      }

      // Water blocks
      for z in range(h, wl) {
        let faces = isometric-block(
          x,
          y,
          z,
          size: block-size,
          fill-color: rgb("#4A90E2"),
        )
        for face in faces { all-faces.push(face) }
      }
    }
  }

  // Calculate bounding box
  let all-x = ()
  let all-y = ()
  for face in all-faces {
    for v in face.vertices {
      all-x.push(v.at(0))
      all-y.push(v.at(1))
    }
  }

  let min-x = calc.min(..all-x)
  let max-x = calc.max(..all-x)
  let min-y = calc.min(..all-y)
  let max-y = calc.max(..all-y)

  let width = (max-x - min-x) * 1pt + 20pt
  let height = (max-y - min-y) * 1pt + 20pt

  let offset-x = -min-x + 10
  let offset-y = -min-y + 10

  box(
    width: width,
    height: height,
    {
      for face in all-faces {
        let pts = face.vertices.map(v => (
          (v.at(0) + offset-x) * 1pt,
          (v.at(1) + offset-y) * 1pt,
        ))
        place(
          curve(
            fill: face.fill,
            stroke: 0.3pt + black,
            curve.move(pts.at(0)),
            curve.line(pts.at(1)),
            curve.line(pts.at(2)),
            curve.line(pts.at(3)),
            curve.close(mode: "straight"),
          ),
        )
      }
    },
  )
}

#let custom-display(input) = {
  let height-map = input.heightMap

  // Show raw data
  [*heightMap:* #display(height-map)]
  linebreak()

  if height-map.len() == 0 { return }

  // Calculate water levels
  let water-map = calculate-water-levels(height-map)

  // Determine block size based on grid size
  let max-dim = calc.max(height-map.len(), height-map.at(0).len())
  let block-size = if max-dim <= 5 { 15 } else if max-dim <= 8 { 12 } else {
    10
  }

  // Render 3D visualization
  v(0.5em)
  render-isometric(height-map, water-map, block-size: block-size)
}
