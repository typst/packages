/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón and Showybox Contributors (c) 2023
 *
 * Main Contributors:
 * - Jonas Neugebauer (<https://github.com/jneug>)
 *
 * showy.typ -- The package's main file containing the
 * public and (more) useful functions
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

/*
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 * Parameters:
 * - frame:
 *   + upper-color: Color used as background color where the title goes
 *   + lower-color: Color used as background color where the body goes
 *   + border-color: Color used for the showybox's border
 *   + radius: Showybox's radius
 *   + width: Border width of the showybox
 *   + dash: Showybox's border style
 * - title-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 * - body-styles:
 *   + color: Text color
 *   + align: Text align
 * - sep:
 *   + width: Separator's width
 *   + dash: Separator's style (as a 'line' dash style)
 */
#let showybox(
  frame: (
    upper-color: black,
    lower-color: white,
    border-color: black,
    radius: 5pt,
    width: 1pt,
    dash: "solid"
  ),
  title-style: (
    color: white,
    weight: "bold",
    align: left
  ),
  body-style: (
    color: black,
    align: left
  ),
  sep: (
    width: 1pt,
    dash: "solid"
  ),
  shadow: none,
  title: "",
  breakable: false,
  ..body
) = {
  /*
   * Optionally create a wrapper
   * function to add a shadow.
   */
  let wrap = (sbox) => sbox
  if shadow != none {
    if type(shadow.at("offset", default: 4pt)) != "dictionary" {
      shadow.offset = (
        x: shadow.at("offset", default: 4pt),
        y: shadow.at("offset", default: 4pt)
      )
    }
    wrap = (sbox) => block(
      breakable: breakable,
      radius: frame.at("radius", default: 5pt),
      fill:   shadow.at("color", default: luma(128)),
      inset: (
        top: -shadow.offset.y,
        left: -shadow.offset.x,
        right: shadow.offset.x,
        bottom: shadow.offset.y
      ),
      sbox
    )
  }
  wrap(block(
    fill: frame.at("lower-color", default: white),
    radius: frame.at("radius", default: 5pt),
    inset: 0pt,
    breakable: breakable,
    stroke: (
      paint: frame.at("border-color", default: black),
      dash: frame.at("dash", default: "solid"),
      thickness: frame.at("width", default: 1pt)
    )
  )[
    /*
     * Title of the showybox. We'll check if it is
     * empty. If so, skip its drawing and only put
     * the body
     */
    #if title != "" {
      block(
        inset:(x: 1em, y: 0.5em),
        width: 100%,
        spacing: 0pt,
        fill: frame.at("upper-color", default: black),
        stroke: (
          paint: frame.at("border-color", default: black),
          dash: frame.at("dash", default: "solid"),
          thickness: frame.at("width", default: 1pt)
        ),
        radius: (top: frame.at("radius", default: 5pt)))[
          #align(
            title-style.at("align", default: left),
            text(
              title-style.at("color", default: white),
              weight: title-style.at("weight", default: "bold"),
              title
            )
          )
      ]
    }

    /*
     * Body of the showybox
     */
    #block(
      width: 100%,
      spacing: 0pt,
      inset:(x: 1em, y: 0.75em),
      align(
        body-style.at("align", default: left),
        text(
          body-style.at("color", default: black),
          body.pos().join(
            align(left, // Avoid alignement errors
              line(
                start:(-1em, 0pt),
                end: (100% + 1em, 0pt),
                stroke: (
                  paint: frame.at("border-color", default: black),
                  dash: sep.at("dash", default: "solid"),
                  thickness: sep.at("width", default: 1pt)
                )
              )
            )
          )
        )
      )
    )
  ])
}
