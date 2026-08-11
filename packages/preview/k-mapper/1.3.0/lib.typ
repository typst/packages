#import "utils.typ": *

#let karnaugh(
  // 4, 8, 16
  grid-size,

  // Label to go on the x-axis of the K-map. (For style 0)
  x-label: $$,

  // Label to go on the y-axis of the K-map. (For style 0)
  y-label: $$,

  // The labels (usually variable names) to be placed for their respective values. (For styles 1, 2) 
  labels: (),

  // The labeling style, that should be used. May be 0, 1 or 2.
  style: 0,

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
  stroke-width: 0.5pt,

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
  implicant-radius: 5pt,

  // How much to transparentize the implicant strokes by.
  implicant-stroke-transparentize: -100%,

  // How much to darken the implicant strokes by.
  implicant-stroke-darken: 60%,

  // Stroke width of implicants.
  implicant-stroke-width: 0.5pt
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

  assert(style >= 0 and style <= 2,
    message: "Unsupported Style, must be one of 0, 1, 2")
  if style != 0 {
    assert(
      labels.len() == 2 and grid-size == 4
      or labels.len() == 3 and grid-size == 8
      or labels.len() == 4 and grid-size == 16,
      message: "In alt-style you need to provide the matching amount of labels"
    )
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
    stroke: stroke-width,

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
            stroke: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
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
              top: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              right: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              bottom: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width
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
              top: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              left: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              bottom: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width
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
              left: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width, 
              top: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              right: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width
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
              left: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              bottom: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
              right: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width,
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
            stroke: (right: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width, bottom: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width), 
            fill: color,
            radius: (bottom-right: implicant-radius)
          ), dx-left, -dy-top
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (left: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width, bottom: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width), 
            fill: color,
            radius: (bottom-left: implicant-radius)
          ), dx-right, -dy-top
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (top: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width, right: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width), 
            fill: color,
            radius: (top-right: implicant-radius)
          ), dx-left, dy-bottom
        ),
        (
          rect(
            width: width, 
            height: width, 
            stroke: (top: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width, left: color.darken(implicant-stroke-darken).transparentize(implicant-stroke-transparentize) + implicant-stroke-width), 
            fill: color,
            radius: (top-left: implicant-radius)
          ), dx-right, dy-bottom
        )
      )
    } // Corner implicants.
  )

  // Labels.
  if style == 0 {
    let x-label1
    let y-label1

    x-label1 = if labels == () { 
      x-label 
    } else if grid-size == 4 or grid-size == 8 {
      labels.last()
    } else {
      [#labels.at(2)#labels.at(3)]
    }

    y-label1 = if labels == () {
      y-label
    } else if grid-size == 4 {
      labels.first()
    } else {
      [#labels.at(0)#labels.at(1)]
    }

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
        [], [], x-label1,
        [], [], x-gray,
        y-label1, y-gray, body,
      )
    )
  } else {
    let top-label
    if grid-size == 16 {
      top-label = table(
        columns: (cell-size,) * 4,
        rows: cell-size,
        align: center + bottom,
        stroke: none,
        table.cell(colspan: 2, if style == 2 {[]} else {$overline(#labels.at(2))$}),
        table.cell(colspan: 2, stroke: if style == 2 {(bottom: black + 2pt)} else {none}, $#labels.at(2)$),
      )
    } else {
      let i = if grid-size == 4 {1} else {2}
      top-label = table(
        columns: (cell-size,) * 2,
        rows: cell-size,
        align: center + bottom,
        stroke: none,
        if style == 2 {[]} else {$overline(#labels.at(i))$},
        table.cell(stroke: if style == 2 {(bottom: black + 2pt)} else {none}, $#labels.at(i)$),
      )
    }
    let bottom-label
    if grid-size == 16 {
      bottom-label = table(
        columns: (cell-size,) * 4,
        rows: cell-size,
        align: center + top,
        stroke: none,
        if style == 2 {[]} else {$overline(#labels.at(3))$},
        table.cell(colspan: 2, stroke: if style == 2 {(top: black + 2pt)} else {none}, $#labels.at(3)$),
        if style == 2 {[]} else {$overline(#labels.at(3))$}
      )
    } else {
      bottom-label = []
    }
    let left-label
    if grid-size == 4 {
      left-label = table(
        columns: cell-size,
        rows: cell-size,
        align: right + horizon,
        stroke: none,
        table.cell(stroke: if style == 2 {(right: black + 2pt)} else {none}, $#labels.at(0)$),
        if style == 2 {[]} else {$overline(#labels.at(0))$}
      )
    } else {
      left-label = table(
        columns: cell-size,
        rows: cell-size,
        align: right + horizon,
        stroke: none,
        table.cell(rowspan: 2, if style == 2 {[]} else {$overline(#labels.at(0))$}),
        table.cell(rowspan: 2, stroke: if style == 2 {(right: black + 2pt)} else {none}, $#labels.at(0)$),
      )
    }
    let right-label
    if grid-size == 4 {
      right-label = []
    } else {
      right-label = table(
        columns: cell-size,
        rows: cell-size,
        align: left + horizon,
        stroke: none,
        if style == 2 {[]} else {$overline(#labels.at(1))$},
        table.cell(rowspan: 2, stroke: if style == 2 {(left: black + 2pt)} else {none}, $#labels.at(1)$),
        if style == 2 {[]} else {$overline(#labels.at(1))$}
      )
    }
  
    block(
      breakable: false,
      grid(
        columns: 3,
        align: center + horizon,
        [], top-label, [],
        left-label, body, right-label,
        [], bottom-label, [],
      )
    )
  }
}
