/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón and Showybox Contributors (c) 2023
 *
 * lib/sections.typ -- The package's file containing all the
 * internal functions for drawing sections.
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "func.typ": *

/*
 * Function: showy-title()
 *
 * Description: Returns the title's block
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 * + title-styles: The dictionary with title styles
 * + title: Title of the showybox
 */
#let showy-title( frame, title-style, title ) = {
  /*
   * Porperties independent of `boxed`
   */
  let props = (
    spacing: 0pt,
    fill: frame.at("title-color", default: black),
    inset: showy-section-inset("title", frame)
  )

  /*
   * Porperties dependent of `boxed`
   */
  if title-style.at("boxed", default: false) == true {
    props = props + (
      width: auto,
      radius: frame.at("radius", default: 5pt),
      stroke: showy-stroke(frame),
    )
    
  } else {
    props = props + (
      width: 100%,
      radius: (top: frame.at("radius", default: 5pt)),
      stroke: showy-stroke(frame, bottom: title-style.at("sep-thickness", default: 1pt))
    )
  }

  return block(
    ..props,
    align(
      title-style.at("align", default: left),
      text(
        title-style.at("color", default: white),
        weight: title-style.at("weight", default: "bold"),
        title
      )
    )
  )
}

/*
 * Function: showy-body()
 *
 * Description: Returns the body's block
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 * + body-styles: The dictionary with body styles
 * + sep: The dictionary with sep styles
 * + body: Body content
 */
#let showy-body( frame, body-style, sep, ..body ) = block(
    width: 100%,
    spacing: 0pt,
    inset:  showy-section-inset("body", frame),
    align(
        body-style.at("align", default: left),
        text(
        body-style.at("color", default: black),
        body.pos()
            .map(block.with(spacing:0pt))
            .join(
                block(
                    spacing: sep.at("gutter", default: .65em),
                    align(
                        left, // Avoid alignment errors
                        showy-line(frame)(
                            stroke: (
                                paint: frame.at("border-color", default: black),
                                dash: sep.at("dash", default: "solid"),
                                thickness: sep.at("thickness", default: 1pt)
                            )
                        )
                    )
                )
            )
        )
    )
)

/*
 * Function: showy-footer()
 *
 * Description: Returns the footer's block
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 * + body-styles: The dictionary with body styles
 * + sep: The dictionary with sep styles
 * + body: Body content
 */
#let showy-footer( frame, footer-style, footer ) = block(
    width: 100%,
    spacing: 0pt,
    inset: showy-section-inset("footer", frame),
    fill: frame.at("footer-color", default: luma(220)),
    stroke: showy-stroke(frame, top: footer-style.at("sep-thickness", default: 1pt)),
    radius: (bottom: frame.at("radius", default: 5pt)),
    align(
        footer-style.at("align", default: left),
        text(
            footer-style.at("color", default: luma(85)),
            weight: footer-style.at("weight", default: "regular"),
            footer
        )
    )
)