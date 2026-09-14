// Converts the zero-indexed nth position of the Karnaugh map to its Gray code
// coordinate.
#let position-to-gray(n, grid-size) = {
  assert(grid-size == 4 or grid-size == 8 or grid-size == 16,
  message: "Please enter a grid size of 4, 8, or 16!")

  let grid-size-4 = (0, 1, 2, 3)
  let grid-size-8 = (0, 1, 2, 3, 6, 7, 4, 5)

  let grid-size-16 = (
    0,  1,  3,  2,
    4,  5,  7,  6,
    12, 13, 15, 14,
    8,  9,  11, 10
  )

  if grid-size == 4 {
    return grid-size-4.at(n)
  } else if grid-size == 8 {
    return grid-size-8.at(n)
  } else {
    return grid-size-16.at(n)
  }
}

// Converts a Gray code position to its coordinate on the K-map.
#let gray-to-coordinate(n, grid-size) = {
  assert(grid-size == 4 or grid-size == 8 or grid-size == 16,
  message: "Please enter a grid size of 4, 8, or 16!")

  let grid-size-4 = ((0, 1), (1,1), (0, 0), (1, 0))

  let grid-size-8 = (
    (0, 3), (1, 3), (0, 2), (1, 2),
    (0, 0), (1, 0), (0, 1), (1, 1)
  )

  let grid-size-16 = (
    (0, 3), (1, 3), (3, 3), (2, 3),
    (0, 2), (1, 2), (3, 2), (2, 2),
    (0, 0), (1, 0), (3, 0), (2, 0),
    (0, 1), (1, 1), (3, 1), (2, 1)
  )

  if grid-size == 4 {
    return grid-size-4.at(n)
  } else if grid-size == 8 {
    return grid-size-8.at(n)
  } else {
    return grid-size-16.at(n)
  }
  // TODO: other grid sizes.
}

// Stacks items in the z-axis.
#let zstack(
  alignment: top + left,
  ..args
) = context {
    let width = 0pt
    let height = 0pt
    for item in args.pos() {
        let size = measure(item.at(0))
        width = calc.max(width, size.width)
        height = calc.max(height, size.height)
    }
    block(width: width, height: height, {
        for item in args.pos() {
            place(
              alignment,
              dx: item.at(1),
              dy: item.at(2),
              item.at(0)
            )
        }
    })
}