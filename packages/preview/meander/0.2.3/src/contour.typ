#import "geometry.typ"
#import "tiling.typ"

/// Contouring function that pads the inner image.
/// -> contour
#let margin(
  /// May contain the following parameters, ordered here by decreasing generality
  /// and increasing precedence
  /// - #arg[length]: #typ.t.length for all sides, the only possible positional argument
  /// - #arg[x], #arg[y]: #typ.t.length for horizontal and vertical margins respectively
  /// - #arg[top], #arg[bottom], #arg[left], #arg[right]: #typ.t.length for single-sided margins
  ..args
) = ((block) => {
  let pos = args.pos()
  let named = args.named()
  if pos.len() > 1 { panic("contour.margin expects at most 1 positional argument") }
  for (name,_) in named {
    if name not in ("x", "y", "top", "bottom", "left", "right") {
      panic("contour.margin cannot interpret the argument '" + name + "'")
    }
  }
  let size = pos.at(0, default: 0pt)
  let x = named.at("x", default: size)
  let y = named.at("y", default: size)
  let left = named.at("left", default: x)
  let right = named.at("right", default: x)
  let top = named.at("top", default: y)
  let bottom = named.at("bottom", default: y)
  ((
    x: block.x - left,
    y: block.y - top,
    width: block.width + left + right,
    height: block.height + top + bottom,
  ),)
},)

/// Drops all boundaries.
/// Having as #arg[boundary] a @cmd:contour:phantom will let other content flow over this object.
/// -> contour
#let phantom() = (block => (),)

/// Horizontal segmentation as `(left, right)`
/// -> contour
#let horiz(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// For each location, returns the left and right bounds.
  ///
  /// #lambda(ratio, ret:(ratio,ratio))
  /// -> function
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dh = block.height / div
  for i in range(div) {
    let (l, r) = fun((i + 0.5) / div)
    geometry.frac-rect(
      (x: l, y: i / div, width: r - l, height: 1 / div),
      block,
    )
  }
  ()
},)

/// Vertical segmentation as `(top, bottom)`
/// -> contour
#let vert(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// For each location, returns the top and bottom bounds.
  ///
  /// #lambda(fraction, ret:(fraction,fraction))
  /// -> function
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dw = block.width / div
  for j in range(div) {
    let (t, b) = fun((j + 0.5) / div)
    geometry.frac-rect(
      (x: j / div, y: t, width: 1 / div, height: b - t),
      block,
    )
  }
  ()
},)

/// Horizontal segmentation as `(anchor, width)`.
/// -> contour
#let width(
  /// Number of subdivisions.
  /// -> int
  div: 5,
  /// Relative horizontal alignment of the anchor.
  /// -> align
  flush: center,
  /// For each location, returns the position of the anchor and the width.
  ///
  /// #lambda(fraction, ret:(fraction,fraction))
  /// -> function
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dh = block.height / div
  for i in range(div) {
    let (a, w) = fun((i + 0.5) / div)
    if flush == center {
      geometry.frac-rect(
        (x: a - w/2, y: i / div, width: w, height: 1 / div),
        block,
      )
    } else if flush == right {
      geometry.frac-rect(
        (x: 1 - a - w, y: i / div, width: w, height: 1 / div),
        block,
      )
    } else if flush == left {
      geometry.frac-rect(
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
  /// -> align
  flush: horizon,
  /// For each location, returns the position of the anchor and the height.
  ///
  /// #lambda(fraction, ret:(fraction,fraction))
  /// -> function
  fun,
) = (block => {
  assert(type(div) == int, message: "div should be an integer")
  let dw = block.width / div
  for j in range(div) {
    let (a, h) = fun((j + 0.5) / div)
    if flush == horizon {
      geometry.frac-rect(
        (x: j / div, y: a - h/2, width: 1 / div, height: h),
        block,
      )
    } else if flush == bottom {
      geometry.frac-rect(
        (x: j / div, y: a - h, width: 1 / div, height: h),
        block,
      )
    } else if flush == top {
      geometry.frac-rect(
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
/// -> contour
#let grid(
  /// Number of subdivisions.
  /// -> int | (x: int, y: int)
  div: 5,
  /// Returns for each cell whether it satisfies the 2D equations of the image's boundary.
  ///
  /// #lambda(fraction, fraction, ret:bool)
  /// -> function
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
          geometry.frac-rect(
            (x: start / div-x, y: i / div-y, width: (j - start) / div-x, height: 1 / div-y),
            block,
          )
        }
        start = j + 1
      }
    }
    if start < div-x {
      geometry.frac-rect(
        (x: start / div-x, y: i / div-y, width: (div-x - start) / div-x, height: 1 / div-y),
        block,
      )
    }
  }
  ()
},)

/// #property(since: version(0, 2, 1))
/// Allows drawing the shape of the image as ascii art.
///
/// Blocks
/// - ```typc "#"```: full
/// - ```typc " "```: empty
///
/// Half blocks
/// - ```typc "["```: left
/// - ```typc "]"```: right
/// - ```typc "^"```: top
/// - ```typc "_"```: bottom
///
/// Quarter blocks
/// - ```typc "`"```: top left
/// - ```typc "'"```: top right
/// - ```typc ","```: bottom left
/// - ```typc "."```: bottom right
///
/// Anti-quarter blocks
/// - ```typc "J"```: top left
/// - ```typc "L"```: top right
/// - ```typc "7"```: bottom left
/// - ```typc "F"```: bottom right
///
/// Diagonals
/// - ```typc "/"```: positive
/// - #text(fill: rgb("226600"))[#raw("\"\\\"")]: negative
/// -> contour
#let ascii-art(
  /// Draw the shape of the image in ascii art.
  /// -> code | str
  ascii
) = (block => {
  let ascii = if type(ascii) == type(``) {
    ascii.text
  } else {
    ascii
  }
  let ascii = ascii.split("\n")
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
        geometry.frac-rect(
          (x: (j + x) / jmax, y: (i + y) / imax, width: w / jmax, height: h / imax),
          block,
        )
      }
    }
  }
  ()
},)
