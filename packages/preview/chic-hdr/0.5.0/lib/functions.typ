/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * functions.typ -- The package's file containing all the
 * public functions that the user can access.
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "layout.typ": *

/*
 * chic-header
 *
 * Sets the header content
 *
 * Parameters:
 * - v-center: Whether to vertically align the header content, or not
 * - side-width: Custom width for sides (can be an array or length)
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-header(v-center: false, side-width: none, left-side: none, center-side: none, right-side: none) = {
  return (
    chic-type: "header",
    value:[
      #chic-grid(v-center: v-center, side-width, left-side, center-side, right-side)
    ]
  )
}

/*
 * chic-footer
 *
 * Sets the footer content
 *
 * Parameters:
 * - v-center: Whether to vertically align the header content, or not
 * - side-width: Custom width for sides (can be an array or length)
 * - left-side: Content that goes at the left side
 * - center-side: Content that goes at the center
 * - right-side: Content that goes at the right side
 */
#let chic-footer(v-center: false, side-width: none, left-side: none, center-side: none, right-side: none) = {
  return (
    chic-type: "footer",
    value:[
      #chic-grid(v-center: v-center, side-width, left-side, center-side, right-side)
    ]
  )
}

/*
 * chic-styled-separator
 *
 * Returns a styled separator for chic-separator()
 *
 * Parameters:
 * - color: Separator color
 * - style: Separator to return
 */
#let chic-styled-separator(color: black, style) = {
  if style == "double-line" {
    return block(width: 100%)[
      #block(spacing: 0pt, line(length: 100%, stroke: color))
      #v(2.5pt)
      #block(spacing: 0pt, line(length: 100%, stroke: color))
    ]
  } else if style == "bold-center" {
    return block(width: 100%)[
      #line(length: 100%, stroke: color)
      #place(
        center,
        dy: -1.5pt,
        rect(
          width: 10%,
          height: 3pt,
          radius: 5pt,
          fill: color
        )
      )
    ]
  } else if style == "center-dot" {
    return align(
      center + horizon,
      stack(
        dir: ltr,
        spacing: 3pt,
        path(
          fill: color,
          stroke: color,
          closed: true,
          (0pt, 0pt),
          (50% - 10pt, 1.5pt),
          ((50% - 8pt, 0pt), (0pt, 1.5pt)),
          (50% - 10pt, -1.5pt)
        ),
        circle(radius: 5pt, fill: color),
        path(
          fill: color,
          stroke: color,
          closed: true,
          (50% - 10pt, 0pt),
          (2pt, 1.5pt),
          ((0pt, 0pt), (0pt, 1.5pt)),
          (2pt, -1.5pt)
        ),
      )
    )
  } else if style == "flower-end" {
    let branch = move(
      dy: 3.5pt,
      path(
        closed: false,
        fill: color,
        (50% - 16pt, -1pt),
        ((13pt, -1pt), (5pt, 0pt)),
        ((7pt, -7pt), (0pt, 0pt), (-2pt, 2pt)),
        ((5pt, -2pt), (-1pt, -1pt), (-3pt, 0pt)),
        (0pt, 0pt),
        ((5pt, 2pt), (-3pt, 0pt), (-1pt, 1pt)),
        ((7pt, 7pt), (-2pt, -2pt), (0pt, 0pt)),
        ((13pt, 1pt), (-5pt, 0pt)),
        (50% - 16pt, 1pt),
      )
    )

    return align(
      center + horizon,
      stack(
        dir: ltr,
        spacing: 3pt,
        branch,
        rect(height: 2pt, width: 2pt, fill: color),
        rect(height: 2pt, width: 16pt, fill: color),
        rect(height: 2pt, width: 2pt, fill: color),
        rotate(180deg, branch)
      )
    )
  } else {
    panic("Invalid styled separator was requested. Possible options are `'double-line'`, `'bold-center'`, `'center-dot'` and `'flower-end'`")
  }
}

/*
 * chic-separator
 *
 * Sets the separator for either the header, the footer or both
 *
 * Parameters:
 * - on: Where to apply the separator: "header", "footer" or "both"
 * - outset: Space around the separator beyond the page margins
 * - gutter: Space around the separator
 * - sep: Separator, it can be a stroke or length for creating a line,
 *        or a `line()` element created by the user
 */
#let chic-separator(on: "both", outset: 0pt, gutter: .65em, sep) = {
  assert(on in ("both", "header", "footer"), message: "`on` must receive the strings `'both'`, `'header'` or `'footer'`.")
  if type(sep) == content { // It's a custom separator
    return (
      chic-type: "separator",
      on: on,
      value: block(width: 100% + (2 * outset), spacing: gutter, sep)
    )
  } else if type(sep) == stroke or type(sep) == length { // It's a line stroke
    return (
      chic-type: "separator",
      on: on,
      value: block(width: 100% + (2 * outset), spacing: gutter, line(length: 100%, stroke: sep))
    )
  } else {
    panic("Invalid separator was given in `chic-separator()`")
  }
}

/*
 * chic-height
 *
 * Sets the height of either the header, the footer or both
 *
 * Parameters:
 * - on: Where to change the height: "header", "footer" or "both"
 * - value: New height
 */
#let chic-height(on: "both", value) = {
  if type(value) in (length, ratio, relative) {
    return (
      chic-type: "margin",
      on: on,
      value: value
    )
  }
}

/*
 * chic-offset
 *
 * Sets the offset of either the header, the footer or both (relative
 * to the page content)
 *
 * Parameters:
 * - on: Where to change the offset: "header", "footer" or "both"
 * - value: New offset
 */
#let chic-offset(on: "both", value) = {
  if type(value) in (length, ratio, relative) {
    return (
      chic-type: "offset",
      on: on,
      value: value
    )
  }
}

/*
 * chic-page-number
 *
 * Returns the current page number
 */
#let chic-page-number() = context {
  here().page()
}

/*
 * chic-heading-name
 *
 * Returns the next heading name in the `dir` direction. The
 * heading must has a lower or equal level than `level`. If
 * there're no more headings in that direction, and `fill` is
 * ``true``, then headings are seek in the other direction.
 *
 * Parameters:
 * - dir: Direction for searching the next heading: "next" (get
 *        the next heading from the current page) or "prev" (get
 *        the previous heading from the current page).
 * - fill: If there's no headings in the `dir` direction, try to
 *         get a heading in the opposite direction.
 * - level: Up to what level of headings should this function
 *          search
 */
#let chic-heading-name(dir: "next", fill: false, level: 2) = context {
  let loc = here()
  let headings = array(()) // Array for storing headings

  // Get all the headings in the given direction
  if dir == "next" {
    headings = query(
      selector(heading).after(loc)
    ).rev()
  } else if dir == "prev" {
    headings = query(
      selector(heading).before(loc)
    )
  }

  // If no headings were found, try the other direction if `fill` is true
  if headings.len() == 0 and fill {
    if dir == "next" {
      headings = query(
        selector(heading).before(loc)
      )
    } else if dir == "prev" {
      headings = query(
        selector(heading).after(loc)
      ).rev()
    }
  }

  // Now, get the proper heading (i.e. right ``level`` value)
  // until the headings array is empty
  let found = false
  let return-heading = none
  while not found and headings.len() > 0 {
    return-heading = headings.pop()

    // Check the level of the fetched heading
    if return-heading.level <= level {
      found = true
    }
  }

  if found {
    return return-heading.body
  } else {
    return
  }
}
