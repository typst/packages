#import "@preview/cetz:0.5.3"
#import cetz : draw
#import "utils.typ": recolor-stroke

// (row-step, column-step) when the input is (east, south, west, north)
#let directions = ((0, 1), (1, 0), (0, -1), (-1, 0))

// Indices to the neighbours array,
// (north, east, south, west, north-east, north-west, south-east, south-west)
// looked up by direction (east, south, west, north):
#let ahead-index      = (1, 2, 3, 0)
#let ahead-left-index = (4, 6, 7, 5)

// Corner of a cell (top-left, top-right, bottom-right, bottom-left)
#let cell-corner(row, column, index, inset) = (
  (column - 0.5 + inset, row - 0.5 + inset),
  (column + 0.5 - inset, row - 0.5 + inset),
  (column + 0.5 - inset, row + 0.5 - inset),
  (column - 0.5 + inset, row + 0.5 - inset),
).at(index)

// Find the position of the outline vertex based on row, column, direction
#let position-of-outline-vertex(row, column, d, inset, concave: false) = {
  let (forward-row, forward-column) = directions.at(d)
  let (right-row, right-column)     = directions.at(calc.rem(d + 1, 4))

  // The exact grid corner at the end of the edge (no inset)
  let grid-corner = cell-corner(row, column, calc.rem(d + 1, 4), 0)

  // Always inset to the right; along the direction of travel it depends on the turn
  let along = if concave { inset } else { -inset }

  (
    grid-corner.at(0) + inset * right-column + along * forward-column,
    grid-corner.at(1) + inset * right-row    + along * forward-row,
  )
}

// Stringifies coordinates so they can be used as keys in a dictionary
#let cell-key(row, column) = str(row) + "," + str(column)

// Calculates which of the surrounding cells are also in the term
// Returns boolean array: (north, east, south, west, north-east, north-west, south-east, south-west)
#let cell-neighbours(row, column, has-cell) = {
  let up    = row - 1
  let down  = row + 1
  let left  = column - 1
  let right = column + 1

  (
    has-cell(up,   column), // north
    has-cell(row,  right),  // east
    has-cell(down, column), // south
    has-cell(row,  left),   // west

    has-cell(up,   right),  // north-east
    has-cell(up,   left),   // north-west
    has-cell(down, right),  // south-east
    has-cell(down, left),   // south-west
  )
}

// Turns a closed list of corner points (cell units, axis-aligned polygon) into curve
// components. Every corner is replaced by a quadratic curve whose control point is the
// original corner. `radius` is in cell units and is shrunk where an edge is too short.
#let rounded-loop(vertices, radius, unit-length) = {
  let count = vertices.len()
  let scale = (point) => (point.at(0) * unit-length, point.at(1) * unit-length)

  // For each corner: (where the curve starts, the corner itself, where the curve ends)
  let corners = ()
  for (i, vertex) in vertices.enumerate() {
    let previous = vertices.at(calc.rem(i - 1, count))
    let next = vertices.at(calc.rem(i + 1, count))

    let to-previous = (previous.at(0) - vertex.at(0), previous.at(1) - vertex.at(1))
    let to-next     = (next.at(0) - vertex.at(0),     next.at(1) - vertex.at(1))

    let length-previous = calc.abs(to-previous.at(0)) + calc.abs(to-previous.at(1))
    let length-next     = calc.abs(to-next.at(0)) + calc.abs(to-next.at(1))
    let r = calc.min(radius, length-previous / 2, length-next / 2)

    let entry = (
      vertex.at(0) + to-previous.at(0) / length-previous * r,
      vertex.at(1) + to-previous.at(1) / length-previous * r,
    )
    let exit = (
      vertex.at(0) + to-next.at(0) / length-next * r,
      vertex.at(1) + to-next.at(1) / length-next * r,
    )
    corners.push((entry, vertex, exit))
  }

  let (first-entry, first-vertex, first-exit) = corners.first()

  let path = (curve.move(scale(first-exit)),)
  for (entry, vertex, exit) in corners.slice(1) {
    path.push(curve.line(scale(entry)))
    path.push(curve.quad(scale(vertex), scale(exit)))
  }
  path.push(curve.line(scale(first-entry)))
  path.push(curve.quad(scale(first-vertex), scale(first-exit)))
  path.push(curve.close(mode: "straight"))
  path
}

#let fast-outline(term-coordinates, rows, columns, color, stroke, radius, inset, step) = ((ctx) => {
  // Inset is inset + step
  let inset = inset + step * (stroke.thickness / ctx.length)

  // For terms that wrap around the edges of the k-map,
  // add additional coordinates to the sides
  let tiled = ()
  for (row, column) in term-coordinates {
    for row-shift in (-rows, 0, rows) {
      for column-shift in (-columns, 0, columns) {
        let (r, c) = (row + row-shift, column + column-shift)
        if r >= -1 and r <= rows and c >= -1 and c <= columns {
          tiled.push((r, c))
        }
      }
    }
  }

  // Create a dictionary of all coordinates
  // This way, checking wether (x, y) is in the term-coordinates
  // runs in constant time
  let cell-set = (:)
  for (row, column) in tiled {
    cell-set.insert(cell-key(row, column), true)
  }

  // Helper function to test if (x, y) re in the term-coordinates
  let has-cell(row, column) = {cell-key(row, column) in cell-set}

  // key: row, column, direction, value represents wether this exact
  // combination has already been visited
  let visited = (:)

  // Holds all the final curves
  let segments = ()

  // We need to make sure that all coordinates have been visited
  for (row, column) in tiled {
    // (north, east, south, west, north-east, north-west, south-east, south-west)
    let neighbours = cell-neighbours(row, column, has-cell)

    // If all four sides have a neighbour, then it is an interior cell
    // and does not require an outline
    if neighbours.slice(0, 4).all(has-neighbour => has-neighbour) { continue }

    // Start direction is a number that represents an index of neighbours.
    // (east, south, west, north)
    //
    // Find the start direction
    for start-direction in range(4) {
      // Skips, if there is no boundary on this side
      if neighbours.at(start-direction) { continue }
      if visited.at(cell-key(row, column) + "," + str(start-direction), default: false) { continue }

      // Stores the working-copy of the current row, column and direction
      let (r, c, d) = (row, column, start-direction)

      // Stores all of the corners, so all places where the direction changes
      let vertices = ()

      // Do-while, break condition is at the bottom
      // Traces clockwise, until we are back at the same coordinate we started
      // and facing the same direction as when we started
      while true {

        // Remember that we have been here before
        visited.insert(cell-key(r, c) + "," + str(d), true)

        // Current neighbours
        let n = cell-neighbours(r, c, has-cell)

        // Is there something ahead?
        let ahead = n.at(ahead-index.at(d))

        // Is there something to the left ahead?
        let ahead-left = n.at(ahead-left-index.at(d))

        // What the direction is in actual row and column difference
        let (step-row, step-column) = directions.at(d)

        // Nothing ahead
        if not ahead {
          // Push edge vertice
          vertices.push(position-of-outline-vertex(r, c, d, inset))

          // Turn right, but stay on the same cell
          d = calc.rem(d + 1, 4)
        }

        // Something to the left ahead
        else if ahead-left {
          // Insert vertices
          vertices.push(position-of-outline-vertex(r, c, d, inset, concave: true))

          // Continue on the diagonal cell
          let (left-row, left-column) = directions.at(calc.rem(d + 3, 4))
          r += step-row + left-row
          c += step-column + left-column
          d = calc.rem(d + 3, 4)
        }
        // Only ahead
        else {
          // Go ahead
          r += step-row
          c += step-column
        }

        if (r, c, d) == (row, column, start-direction) { break }
      }
      segments += rounded-loop(vertices, radius, ctx.length)
    }
  }

  let body = box(
    width: columns * ctx.length, height: rows * ctx.length, clip: true,
    place(top + left, dx: 0.5 * ctx.length, dy: 0.5 * ctx.length,
      curve(fill: color, stroke: stroke, ..segments)))

  let (width: w, height: h) = measure(body)
  let (w, h) = (w / ctx.length, h / ctx.length)
  let pos = (-0.5, rows - 0.5)
  let p = cetz.util.apply-transform(ctx.transform, pos)

  p = (p.at(0) + w/2, p.at(1) - h/2, 0)

  (
    ctx: ctx,
    drawables: ((
      type: "content", pos: p,
      width: w, height: h,
      segments: (), body: body, tags: (),
    ),),
  )
},)

// Draws all the term bundles provided in the term-coordinate-list
#let draw-multiple-bundle-cells(term-coordinates-list, highlight-colors, highlight-inset, highlight-steps, highlight-stroke, columns, rows, highlight-radius, highlight-transparency) = {
  for (term-number, term-coordinates) in term-coordinates-list.enumerate() {
    // Iterate through the coloros. Wrap around
    let color = highlight-colors.at(calc.rem(term-number, highlight-colors.len()))

    // Calculate the inset of a given term, so the distance
    // from the grid line to the bundle outline
    let step = calc.rem-euclid(term-number, highlight-steps)

    fast-outline(term-coordinates, rows, columns, color.transparentize(highlight-transparency), recolor-stroke(highlight-stroke, color), highlight-radius, highlight-inset, step)
  }
}
