/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * internal.typ -- The package's file containing
 * the internal functions
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

/*
 * chic-valid-type
 *
 * Checks if a given argument is a valid element of
 * the chic-hdr package
 *
 * Parameters:
 * - arg: Argument to check
 */
#let chic-valid-type(arg) = {
  return type(arg) == "dictionary" and "chic-type" in arg
}

/*
 * chic-layout
 *
 * Generates the proper layout for the header and
 * footer sides.
 *
 * Parameters:
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-layout(left-side, center-side, right-side) = {
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
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-grid(v-center: false, left-side, center-side, right-side) = block(
  spacing: 0pt,
  grid(
    columns: chic-layout(left-side, center-side, right-side),
    column-gutter: 11pt,
    align(if v-center {horizon + left} else {left}, left-side),
    align(if v-center {horizon + center} else {center}, center-side),
    align(if v-center {horizon + right} else {right}, right-side)
  )
)

/*
 * chic-generate-props
 *
 * Obtains the correct properties to apply for a 
 * particular type of pages (or all pages).
 *
 * Parameters:
 * - width: Width of the header and the footer
 * - options: Options given to apply into the header and footer
 */
#let chic-generate-props(width, options) = {
  let page-options = (
    // Set default options
    header: none,
    footer: none,
    margin: (:),
    header-ascent: 30%,
    footer-descent: 30%
  )

  let additions = (
    header-sep: none,
    footer-sep: none
  )

  // Process each option and modify the properties according to them
  for option in options {
    if chic-valid-type(option) {
      
      // Footer and Header
      if option.chic-type in ("header", "footer") {
        page-options.at(option.chic-type) = option.value

      // Separator
      } else if option.chic-type == "separator" {
        if option.on == "both" {
          additions.header-sep = option.value
          additions.footer-sep = option.value
        } else if option.on == "header" {
          additions.header-sep = option.value
        } else if option.on == "footer" {
          additions.footer-sep = option.value
        }

      // Height of footer and header
      } else if option.chic-type == "margin" {
        if option.on == "both" {
          page-options.margin.insert("top", option.value)
          page-options.margin.insert("bottom", option.value)
        } else if option.on == "header" {
          page-options.margin.insert("top", option.value)
        } else if option.on == "footer" {
          page-options.margin.insert("bottom", option.value)
        }

      // Offset of footer and header
      } else if option.chic-type == "offset" {
        if option.on == "both" {
          page-options.header-ascent = option.value
          page-options.footer-descent = option.value
        } else if option.on == "header" {
          page-options.header-ascent = option.value
        } else if option.on == "footer" {
          page-options.footer-descent = option.value
        }
      }
    }
  }

  // Add separator and set width of the header and footer
  if page-options.header != none {
    page-options.header = align(
      center,
      block(
        width: width
      )[
        #page-options.header
        #if additions.header-sep != none {
          additions.header-sep
        }
      ]
    )
  }
  if page-options.footer != none {
    page-options.footer = align(
      center,
      block(
        width: width
      )[
        #if additions.footer-sep != none {
          additions.footer-sep
        }
        #page-options.footer
      ]
    )
  }

  return page-options
}