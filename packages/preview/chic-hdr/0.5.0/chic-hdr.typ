/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * chic-hdr.typ -- The package's main file containing
 * the chic() function
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "lib/props.typ": *
#import "lib/functions.typ": * // Import public functions

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
  // both-options is used in case `even` is specified or `odd` is specified, but not both, or when none of them are specified
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

  // Sometimes users give an integer value inside parenthesis
  // instead of an array. So, handle this cases to avoid unwanted
  // user reports of bugs/errors in the package
  if type(skip) == int {
    skip = array((skip,))
  }

  // Load header and footer
  for option in ("header", "footer") {
    page-options.at(option) = context {
      // Convert 'skip' negative indexes to positive indexes
      let positive-skip = skip.map((index) => {
        if index >= 0{
          index
        } else {
          let last-page = counter(page).final().last() + 1
          last-page + index
        }
      })

      let loc = here()
      if loc.page() not in positive-skip { // Skip given pages
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
    }
  }

  set page(
    ..page-options
  )

  // Rest of the document
  options.pos().last()
}
