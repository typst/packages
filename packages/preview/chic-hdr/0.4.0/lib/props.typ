/*
 * Chic-header - A package for Typst
 * Pablo González Calderón (c) 2023
 *
 * props.typ -- The package's file for handling properties
 * given to the main function.
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "types.typ": *

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

  // Set page props to default
  let props = (
    header: none,
    footer: none,
    margin: (:),
    header-ascent: 30%,
    footer-descent: 30%
  )

  // Set page additions. These are exclusive values used by chic package,
  // and not required by the ``#set page()`` instruction
  let additions = (
    header-sep: none,
    footer-sep: none
  )

  // Process each option and modify the page properties according to them
  for option in options {
    if chic-valid-type(option) {

      /*
       * Footer and Header
       */
      if option.chic-type in ("header", "footer") {
        props.at(option.chic-type) = option.value

      /*
       * Separator
       */
      } else if option.chic-type == "separator" {
        if option.on == "both" {
          additions.header-sep = option.value
          additions.footer-sep = option.value
        } else if option.on == "header" {
          additions.header-sep = option.value
        } else if option.on == "footer" {
          additions.footer-sep = option.value
        }

      /*
       * Height of footer and header
       */
      } else if option.chic-type == "margin" {
        if option.on == "both" {
          props.margin.insert("top", option.value)
          props.margin.insert("bottom", option.value)
        } else if option.on == "header" {
          props.margin.insert("top", option.value)
        } else if option.on == "footer" {
          props.margin.insert("bottom", option.value)
        }

      /*
       * Offset of text inside footer and header
       */
      } else if option.chic-type == "offset" {
        if option.on == "both" {
          props.header-ascent = option.value
          props.footer-descent = option.value
        } else if option.on == "header" {
          props.header-ascent = option.value
        } else if option.on == "footer" {
          props.footer-descent = option.value
        }
      }
    }
  }

  // Since we only have set the text of the footer and/or header,
  // if we have a separator to add, we must put it after that
  // text --ideally in a proper block element. And also we must
  // align and set all elements properly in the header and footer

  // If there's header text, apply the styles and separator
  if props.header != none {
    props.header = align(
      center,
      block(
        width: width
      )[
        #props.header
        #if additions.header-sep != none {
          additions.header-sep
        }
      ]
    )
  }

  // If there's footer text, apply the style and separator
  if props.footer != none {
    props.footer = align(
      center,
      block(
        width: width
      )[
        #if additions.footer-sep != none {
          additions.footer-sep
        }
        #props.footer
      ]
    )
  }

  return props
}