/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * chic-hdr.typ -- The package's main file containing
 * the public functions
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "internal.typ": *

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
 * - gutter: Space arround the separator
 * - sep: Separator, it can be a stroke or length for creating a line,
 *        or a `line()` element created by the user
 */
#let chic-separator(on: "both", outset: 0pt, gutter: .65em, sep) = {
  if on in ("both", "header", "footer") {
    if type(sep) == "content" { // It's a custom separator
      return (
        chic-type: "separator",
        on: on,
        value: block(width: 100% + (2 * outset), spacing: gutter, sep)
      )
    } else if type(sep) == "stroke" or type(sep) == "length" { // It's a line stroke
      return (
        chic-type: "separator",
        on: on,
        value: block(width: 100% + (2 * outset), spacing: gutter, line(length: 100%, stroke: sep))
      )
    }
  }
  // Return nothing if happens a type mismatch
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
  if type(value) in ("length", "ratio", "relative length") {
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
  if type(value) in ("length", "ratio", "relative length") {
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
#let chic-page-number() = {
  return locate(loc => {
    loc.page()
  })
}

/*
 * chic-heading-name
 *
 * Returns the previous heading name. If there’s no previous
 * headings, it returns the next heading name. Finally, if
 * there’s no headings ahead, it returns nothing.
 */
#let chic-heading-name() = {
  return locate(loc => {
    // Search for previous headings
    let headings = query(selector(heading).before(loc), loc)

    if headings != () {
      return headings.last().body
    } else {
      // Search for next headings
      let headings = query(selector(heading).after(loc), loc)

      if headings != () {
        return headings.first().body
      } else {
        // There's no headings
        return
      }
    }
  })
}

/*
 * chic
 *
 * Chic-header package main function. It receives all the
 * parameters to modify the header and the footer of the document
 *
 * Parameters:
 * - width: Width of headers and footers
 * - skip: Which pages must not have a header and footer
 * - even: Header and footer for even pages
 * - odd: Header and footer for odd pages
 * - options: Header and footer for all non-specified pages, and
 *            general header and footer options for all pages.
 */
#let chic(width: 100%, skip: (), even: none, odd: none, ..options) = {
  // both-options is used in case `even` is sepcified or `odd` is specified, but not both, or when none of them are specified
  let both-options = chic-generate-props(width, options.pos())
  let even-options = none
  let odd-options = none

  // Final properties
  let page-options = (
    header: none,
    footer: none,
    margin: both-options.margin,
    header-ascent: both-options.header-ascent,
    footer-descent: both-options.footer-descent
  )

  // Load even and odd properties
  if even != none {
    even-options = chic-generate-props(width, even)
  }
  if odd != none {
    odd-options = chic-generate-props(width, odd)
  }

  // Load header and footer
  for option in ("header", "footer") {
    page-options.at(option) = locate(loc => {
      if loc.page() not in skip { // Skip given pages
        if calc.odd(loc.page()) { // Odd pages
          if odd != none {
            odd-options.at(option)
          } else {
            both-options.at(option)
          }
        } else { // Even pages
          if even != none {
            even-options.at(option)
          } else {
            both-options.at(option)
          }
        }
      }
    })
  }

  set page(
    ..page-options
  )

  // Rest of the document
  options.pos().last()
}