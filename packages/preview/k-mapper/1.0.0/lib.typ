#import "utils.typ": *

#let karnaugh(
  // 4, 8, 16
  grid-size,

  // Label to go on the x-axis of the K-map.
  x-label: $$,

  // Label to go on the y-axis of the K-map.
  y-label: $$,

  // Gray code positions where there is a 0. Otherwise the K-map is filled with 1s.
  minterms: none,

  // Gray code positions where there is a 1. Otherwise the K-map is filled with 0s
  maxterms: none,

  // Terms in order of Gray code positions. 
  manual-terms: none,

  // Rectangular implicants, where each element is an array of two values: two
  // corners of the implicant, in Gray code position.
  implicants: (),

  // Implicants where it wraps around the VERTICAL EDGES of the K-map. Each
  // element is an array of two values: two corners of the implicant, in Gray
  // code position.
  horizontal-implicants: (),

  // Implicants where it wraps around the HORIZONTAL EGES of the K-map. Each
  // element is an array of two values: two corners of the implicant, in Gray
  // code position.
  vertical-implicants: (),

  // A Boolean value indicating whether the K-map has corner implicants (those)
  // where there is an implicant at the four corners (i.e. they wrap around)
  // both horizontal and vertical edges.
  corner-implicants: false,

  // Size of each cell in the K-map.
  cell-size: 20pt,

  // Stroke size of the K-map.
  stroke-size: 0.5pt,

  // Array of colors to be used in the K-map. The first implicant uses the first
  // color, the second the second color, etc. If there are more implicants than
  // there are colors, they wrap around.
  colors: (
    rgb(255, 0, 0, 100),
    rgb(0, 255, 0, 100),
    rgb(0, 0, 255, 100),
    rgb(0, 255, 255, 100),
    rgb(255, 0, 255, 100),
    rgb(255, 255, 0, 100),
  ),

  // Inset of each implicant within its cell.
  implicant-inset: 2pt,

  // How much wrapping implicants (i.e. horizontal, vertical, corner) overflow
  // from the table.
  edge-implicant-overflow: 5pt,

  // Corner radius of the implicants.
  implicant-radius: 5pt
) = {
  assert(
    minterms != none and maxterms == none and manual-terms == none
    or minterms == none and maxterms != none and manual-terms == none
    or minterms == none and maxterms == none and manual-terms != none,
    message: "minterms, maxterms, and manual-terms are mutually exclusive!"
  )

  if manual-terms != none {
    assert(manual-terms.len() == grid-size,
    message: "Please provide exactly the correct number of terms for the" +
    "respective grid size!")
  }

  // Top-to-bottom, left-to-right terms.
  let cell-terms
  let cell-total-size = cell-size
  let implicant-count = 0

  if manual-terms != none {
    cell-terms = manual-terms.enumerate().map(x => manual-terms.at(position-to-gray(x.at(0), grid-size)))
  } else if minterms != none {
    cell-terms = (1, ) * grid-size
    for minterm in minterms {
      cell-terms.at(position-to-gray(minterm, grid-size)) = 0
    }
  } else {
    cell-terms = (0, ) * grid-size
    for maxterm in maxterms {
      cell-terms.at(position-to-gray(maxterm, grid-size)) = 1
    }
  }

  let columns-dict = (
    "4": (cell-size, cell-size),
    "8": (cell-size, cell-size),
    "16": (cell-size, cell-size, cell-size, cell-size),
  )

  let base = table(
    columns: columns-dict.at(str(grid-size)),
    rows: cell-size,
    align: center + horizon,
    stroke: stroke-size,

    ..cell-terms.map(term => [#term])
  )

  let body = zstack(
    alignment: bottom + left,
    (base, 0pt, 0pt), 

    // Implicants.
    ..for (index, implicant) in implicants.enumerate() {
      implicant-count += 1

      let p1 = gray-to-coordinate(implicant.at(0), grid-size) 
      let p2 = gray-to-coordinate(implicant.at(1), grid-size)

      let bottom-left-point
      let top-right-point

      bottom-left-point = (calc.min(p1.at(0), p2.at(0)), calc.min(p1.at(1), p2.at(1)))
      top-right-point = (calc.max(p1.at(0), p2.at(0)), calc.max(p1.at(1), p2.at(1)))

      let dx = bottom-left-point.at(0) * cell-total-size + implicant-inset
      let dy = bottom-left-point.at(1) * cell-total-size + implicant-inset

      let width = (top-right-point.at(0) - bottom-left-point.at(0) + 1) * cell-size - implicant-inset * 2
      let height = (top-right-point.at(1) - bottom-left-point.at(1) + 1) * cell-size - implicant-inset * 2

      // Loop back on the colors array if there are more implicants than there
      // are colors.
      let color = colors.at(calc.rem-euclid(implicant-count - 1, colors.len()))

      (
        (
          rect(
            stroke: color,
            fill: color,
            width: width,
            height: height,
            radius: implicant-radius
          ), dx, -dy 
        ),
      )
    }, // Implicants.

    // Horizontal implicants.
    ..for (index, implicant) in horizontal-implicants.enumerate() {
      implicant-count += 1

      let p1 = gray-to-coordinate(implicant.at(0), grid-size) 
      let p2 = gray-to-coordinate(implicant.at(1), grid-size)

      let bottom-left-point = (calc.min(p1.at(0), p2.at(0)), calc.min(p1.at(1), p2.at(1)))
      let bottom-right-point = (calc.max(p1.at(0), p2.at(0)), calc.min(p1.at(1), p2.at(1)))
      let top-right-point = (calc.max(p1.at(0), p2.at(0)), calc.max(p1.at(1), p2.at(1)))

      let dx1 = bottom-left-point.at(0) * cell-total-size - edge-implicant-overflow + implicant-inset
      let dx2 = bottom-right-point.at(0) * cell-total-size + implicant-inset
      let dy = bottom-left-point.at(1) * cell-total-size + implicant-inset
      // let dy2 = bottom-right-point.at(1) * cell-total-size

      let width = cell-size + edge-implicant-overflow - implicant-inset * 2
      let height = (top-right-point.at(1) - bottom-left-point.at(1) + 1) * cell-size - implicant-inset * 2

      // Loop back on the colors array if there are more implicants than there
      // are colors.
      let color = colors.at(calc.rem-euclid(implicant-count - 1, colors.len()))

      (
        (
          rect(
            stroke: (
              top: color,
              right: color,
              bottom: color
            ),
            fill: color,
            width: width ,
            height: height,
            radius: (right: implicant-radius)
          ), dx1, -dy
        ),
        (
          rect(
            stroke: (
              top: color,
              left: color,
              bottom: color
            ),
            fill: color,
            width: width,
            height: height,
            radius: (left: implicant-radius)
          ), dx2, -dy
        )
      )
    },
    
    // Vertical implicants.
    ..for (index, implicant) in vertical-implicants.enumerate() {
      implicant-count += 1

      let p1 = gray-to-coordinate(implicant.at(0), grid-size) 
      let p2 = gray-to-coordinate(implicant.at(1), grid-size)

      let bottom-left-point = (calc.min(p1.at(0), p2.at(0)), calc.min(p1.at(1), p2.at(1)))
      let top-left-point = (calc.min(p1.at(0), p2.at(0)), calc.max(p1.at(1), p2.at(1)))
      let top-right-point = (calc.max(p1.at(0), p2.at(0)), calc.max(p1.at(1), p2.at(1)))

      let dx = bottom-left-point.at(0) * cell-total-size + implicant-inset
      let dy1 = bottom-left-point.at(1) * cell-total-size - edge-implicant-overflow + implicant-inset
      let dy2 = top-left-point.at(1) * cell-total-size + implicant-inset

      let width = (top-right-point.at(0) - bottom-left-point.at(0) + 1) * cell-size - implicant-inset * 2
      let height = cell-size + edge-implicant-overflow - implicant-inset * 2

      // Loop back on the colors array if there are more implicants than there
      // are colors.
      let color = colors.at(calc.rem-euclid(implicant-count - 1, colors.len()))

      (
        (
          rect(
            stroke: (
              left: color, 
              top: color,
              right: color
            ),
            fill: color,
            width: width,
            height: height,
            radius: (top: implicant-radius)
          ), dx, -dy1
        ),
        (
          rect(
            stroke: (
              left: color,
              bottom: color,
              right: color,
            ),
            fill: color,
            width: width,
            height: height,
            radius: (bottom: implicant-radius)
          ), dx, -dy2
        )
      )
    }, // Vertical implicants.

    // Corner implicants.
    ..if corner-implicants {
      implicant-count += 1

      // Index (below) of array is the Gray code position of that corner.
      //
      //    0    1
      //
      //    2    3
      //
      // For example, at index 3, in a 4x4 K-map, the Gray code at that corner
      // is 10.
      let grid-size-4-corners = (0, 1, 2, 3).map(x => gray-to-coordinate(x, 4))
      let grid-size-8-corners = (0, 1, 4, 5).map(x => gray-to-coordinate(x, 8))
      let grid-size-16-corners = (0, 2, 8, 10).map(x => gray-to-coordinate(x, 16))

      let corners

      if grid-size == 4 {
        corners = grid-size-4-corners
      } else if grid-size == 8 {
        corners = grid-size-8-corners
      } else {
        corners = grid-size-16-corners
      }

      let dx-left = -edge-implicant-overflow + implicant-inset
      let dx-right = corners.at(1).at(0) * cell-total-size + implicant-inset
      let dy-top = corners.at(0).at(1) * cell-total-size + implicant-inset
      let dy-bottom = edge-implicant-overflow - implicant-inset

      let width = cell-size + edge-implicant-overflow - implicant-inset * 2

      // Loop back on the colors array if there are more implicants than there
      // are colors.
      let color = colors.at(calc.rem-euclid(implicant-count - 1, colors.len()))

      (
        (
          rect(
            width: width, 
            height: width, 
            stroke: (right: color, bottom: color), 
            fill: color,
            radius: (bottom-right: implicant-radius)
          ), dx-left, -dy-top
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (left: color, bottom: color), 
            fill: color,
            radius: (bottom-left: implicant-radius)
          ), dx-right, -dy-top
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (top: color, right: color), 
            fill: color,
            radius: (top-right: implicant-radius)
          ), dx-left, dy-bottom
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (top: color, left: color), 
            fill: color,
            radius: (top-left: implicant-radius)
          ), dx-right, dy-bottom
        )
      )
    } // Corner implicants.
  )

  // Labels.
  let x-gray
  if grid-size == 16 {
    x-gray = table(
      columns: (cell-size,) * 4,
      rows: cell-size,
      align: center + bottom,
      stroke: none,
      [00], [01], [11], [10]
    )
  } else {
    x-gray = table(
      columns: (cell-size,) * 2,
      rows: cell-size,
      align: center + bottom,
      stroke: none,
      [0], [1]
    ) 
  }

  let y-gray
  if grid-size == 4 {
    y-gray = table(
      columns: cell-size,
      rows: cell-size,
      align: right + horizon,
      stroke: none,
      [0], [1]
    )
  } else {
    y-gray = table(
      columns: cell-size,
      rows: cell-size,
      align: right + horizon,
      stroke: none,
      [00], [01], [11], [10]
    )
  }

  block(
    breakable: false,
    grid(
      columns: 3,
      align: center + horizon,
      [], [], x-label,
      [], [], x-gray,
      y-label, y-gray, body,
    )
  )
}

#karnaugh(
  8,
  manual-terms: (0, 1, 2, 3, 4, 5, 6, 7),
  implicants: ((0,0), (1,1), (2,2), (3,3), (4,4), (5,5), (6,6))
)

#karnaugh(
  16,
  manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  implicants: ((0, 5), (3, 11), (5, 10), (8, 12))
)

#karnaugh(
  4,
  manual-terms: (0, 1, 2, 3),
  implicants: ((0, 1), (0, 2))
)

#karnaugh(
  16,
  manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  horizontal-implicants: ((12, 10), (0, 2))
)

#karnaugh(
  16,
  x-label: $A$, y-label: "test",
  manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  vertical-implicants: ((0, 8), (2, 11)),
  colors: (rgb(100, 100, 100, 100), )
)

#karnaugh(
  16,
  manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  corner-implicants: true
)