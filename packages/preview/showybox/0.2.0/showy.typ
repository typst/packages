/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón (c) 2023
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
    width: 2pt, 
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
  title: "",
  breakable: false,
  ..body
) = {
  block(
    fill: frame.at("border-color", default: black),
    radius: frame.at("radius", default: 5pt),
    inset: 0pt,
    breakable: // Auto break if there's no title
      if title != "" {
        false
      } else {
        breakable
      },
    stroke: (
      paint: frame.at("border-color", default: black),
      dash: frame.at("dash", default: "solid"),
      thickness: frame.at("width", default: 2pt)
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
        fill: frame.at("upper-color", default: black),
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
      v(-1.1em) // Avoid an inelegant space
    }
    
    /*
     * Body of the showybox
     */
    #block(
      fill: frame.at("lower-color", default: white),
      width: 100%, 
      inset:(x: 1em, y: 0.75em),
      radius: 
        if title != "" {
          (bottom: frame.at("radius", default: 5pt))
        } else {
          frame.at("radius", default: 5pt)
        },
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
  ]
}