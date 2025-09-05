#import "geometry.typ"
#import "tiling.typ"

/// Contouring function that pads the inner image.
/// -> function
#let margin(
  /// Padding.
  /// -> length
  size
) = ((block) => {
  let (x, y, width, height) = block
  ((
    x: x - size,
    y: y - size,
    width: width + 2 * size,
    height: height + 2 * size,
  ),)
},)

/// Drops all boundaries.
/// Using `boundary: phantom` will let other content flow over this object.
/// -> function
#let phantom = (block => (),)

/// Helper function to turn a fractional box into an absolute one.
/// -> (x: length, y: length, width: length, height: length)
#let frac-rect(
  /// Child dimensions as fractions.
  /// -> (x: fraction, y: fraction, width: fraction, height: fraction)
  frac,
  /// Parent dimensions as absolute lengths.
  /// -> (x: length, y: length, width: length, height: length)
  abs,
  /// Currently ignored.
  ..style,
) = {
  ((
    x: abs.x + frac.x * abs.width,
    y: abs.y + frac.y * abs.height,
    width: frac.width * abs.width,
    height: frac.height * abs.height,
  ),)
}

/// Horizontal segmentation as `(left, right)`
/// -> function
#let horiz(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// For each location, returns the left and right bounds.
  /// -> function(fraction) => (fraction, fraction)
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dh = block.height / div
  for i in range(div) {
    let (l, r) = fun((i + 0.5) / div)
    frac-rect(
      (x: l, y: i / div, width: r - l, height: 1 / div),
      block,
    )
  }
  ()
},)

/// Vertical segmentation as `(top, bottom)`
/// -> function
#let vert(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// For each location, returns the top and bottom bounds.
  /// -> function(fraction) => (fraction, fraction)
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dw = block.width / div
  for j in range(div) {
    let (t, b) = fun((j + 0.5) / div)
    frac-rect(
      (x: j / div, y: t, width: 1 / div, height: b - t),
      block,
    )
  }
  ()
},)

/// Horizontal segmentation as `(anchor, width)`.
/// -> function
#let width(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// Relative horizontal alignment of the anchor.
  /// -> alignment
  flush: center,
  /// For each location, returns the position of the anchor and the width.
  /// -> function(fraction) => (fraction, fraction)
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dh = block.height / div
  for i in range(div) {
    let (a, w) = fun((i + 0.5) / div)
    if flush == center {
      frac-rect(
        (x: a - w/2, y: i / div, width: w, height: 1 / div),
        block,
      )
    } else if flush == right {
      frac-rect(
        (x: 1 - a - w, y: i / div, width: w, height: 1 / div),
        block,
      )
    } else if flush == left {
      frac-rect(
        (x: a, y: i / div, width: w, height: 1 / div),
        block,
      )
    } else {
      panic(flush, " is not a proper horizontal alignment")
    }
  }
  ()
},)

/// Vertical segmentation as `(anchor, height)`.
/// -> function
#let height(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// Relative vertical alignment of the anchor.
  /// -> alignment.
  flush: horizon,
  /// For each location, returns the position of the anchor and the height.
  /// -> function(fraction) => (fraction, fraction)
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dw = block.width / div
  for j in range(div) {
    let (a, h) = fun((j + 0.5) / div)
    if flush == horizon {
      frac-rect(
        (x: j / div, y: a - h/2, width: 1 / div, height: h),
        block,
      )
    } else if flush == bottom {
      frac-rect(
        (x: j / div, y: a - h, width: 1 / div, height: h),
        block,
      )
    } else if flush == top {
      frac-rect(
        (x: j / div, y: 1 - a, width: 1 / div, height: h),
        block,
      )
    } else {
      panic(flush, " is not a proper vertical alignment")
    }
  }
  ()
},)

/// Cuts the image into a rectangular grid then checks for each cell if
/// it should be included. The resulting cells are automatically grouped horizontally.
/// -> function
#let grid(
  /// Number of subdivisions.
  /// -> int | (x: int, y: int)
  div: 5,
  /// Returns for each cell whether it satisfies the 2D equations of the image's boundary.
  /// -> function(fraction, fraction) => bool
  fun,
) = (block => {
  let (div-x, div-y) = if type(div) == int {
    (div, div)
  } else if type(div) == dictionary {
    (div.x, div.y)
  } else {
    panic("div should be an integer or an array")
  }
  let dw = block.width / div-x
  let dh = block.height / div-y
  for i in range(div-y) {
    let start = 0
    for j in range(div-x) {
      if fun((j + 0.5) / div-x, (i + 0.5) / div-y) {
        continue
      } else {
        if start < j {
          frac-rect(
            (x: start / div-x, y: i / div-y, width: (j - start) / div-x, height: 1 / div-y),
            block,
          )
        }
        start = j + 1
      }
    }
    if start < div-x {
      frac-rect(
        (x: start / div-x, y: i / div-y, width: (div-x - start) / div-x, height: 1 / div-y),
        block,
      )
    }
  }
  ()
},)

/// Allows drawing the shape of the image as ascii art.
///
/// Blocks
/// - `#`: full
/// - ` `: empty
///
/// Half blocks
/// - `[`: left
/// - `]`: right
/// - `^`: top
/// - `_`: bottom
///
/// Quarter blocks
/// - #raw("`"): top left
/// - `'`: top right
/// - `,`: bottom left
/// - `.`: bottom right
///
/// Anti-quarter blocks
/// - `J`: top left
/// - `L`: top right
/// - `7`: bottom left
/// - `F`: bottom right
///
/// Diagonals
/// - `/`: positive
/// - `\`: negative
#let ascii-art(
  /// Draw the shape of the image in ascii art.
  /// -> code
  ascii
) = (block => {
  let ascii = ascii.text.split("\n")
  let imax = calc.max(ascii.len(), 1)
  let jmax = calc.max(..ascii.map(x => x.len()), 1)
  let interp(chr) = {
    (
      "#": ((0,0,1,1),),
      " ": (),

      "[": ((0,0,0.5,1),),
      "]": ((0.5,0,0.5,1),),
      "_": ((0,0.5,1,0.5),),
      "^": ((0,0,1,0.5),),

      ",": ((0,0.5,0.5,0.5),),
      "'": ((0.5,0,0.5,0.5),),
      ".": ((0.5,0.5,0.5,0.5),),
      "`": ((0,0,0.5,0.5),),

      "L": ((0,0,0.5,1),(0.5,0.5,0.5,0.5)),
      "J": ((0.5,0,0.5,1),(0,0.5,0.5,0.5)),
      "7": ((0.5,0,0.5,1),(0,0,0.5,0.5)),
      "F": ((0,0,0.5,1),(0.5,0,0.5,0.5)),

      "\\": ((0,0,0.5,0.5),(0.5,0.5,0.5,0.5)),
      "/": ((0,0.5,0.5,0.5),(0.5,0,0.5,0.5)),
    ).at(chr)
  }
  for i in range(imax) {
    for j in range(jmax) {
      let chr = ascii.at(i).at(j, default: " ")
      for (x, y, w, h) in interp(chr) {
        frac-rect(
          (x: (j + x) / jmax, y: (i + y) / imax, width: w / jmax, height: h / imax),
          block,
        )
      }
    }
  }
  ()
},)
