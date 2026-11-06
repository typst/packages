/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * layout.typ -- The package's file for handling header and
 * footer layouts properly
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

/*
 * chic-distribute-layout
 *
 * Generates the proper layout for the header and
 * footer sides.
 *
 * Parameters:
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-distribute-layout(left-side, center-side, right-side) = {
  let sides = (left-side, center-side, right-side)
  let not-none-sides = sides.filter(side => {
    if side != none {
      return true
    } else {
      return false
    }
  })

  // If only is one side, allow it to use all space
  if not-none-sides.len() == 1 {
    return sides.map(side => {
      if side == none { 0fr } else { 1fr }
    })
  // If only center is none, divide the width into two
  } else if sides.at(1) == none {
    return (1fr, 0fr, 1fr)
  // Otherwise, give the same width to all sides
  } else {
    return (1fr, 1fr, 1fr)
  }
}

/*
 * chic-grid
 *
 * Creates a grid element with the corresponding
 * format needed to be used as a header or a footer
 *
 * Parameters:
 * - v-center: Whether to vertically align the header content, or not
 * - side-width: Custom width for sides (can be an array or length)
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-grid(v-center: false, side-width, left-side, center-side, right-side) = block(
  spacing: 0pt,
  grid(
    columns: if side-width == none {

      // If the user didn't give a custom side-width, then distribute the layout
      // using fraction values
      chic-distribute-layout(left-side, center-side, right-side)
    } else {

      // If an unidimensional value is given, use it to all columns
      if type(side-width) in (fraction, relative, length) {
        (side-width, side-width, side-width)

      // If a 3-item-length array is given, use it as the columns dimensions
      } else if type(side-width) == array and side-width.len() == 3 {
        side-width

      // Otherwise, just distribute the layout using default fraction values
      } else {
        chic-distribute-layout(left-side, center-side, right-side)
      }
    },
    column-gutter: 11pt,
    align(if v-center {horizon + left} else {left}, left-side),
    align(if v-center {horizon + center} else {center}, center-side),
    align(if v-center {horizon + right} else {right}, right-side)
  )
)
