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
 * Import functions
 */
#import "lib/func.typ": *
#import "lib/sections.typ": *

/*
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 * Parameters:
 * - title: Title of the showybox
 * - footer: Footer of the showybox
 * - frame:
 *   + title-color: Color used as background color where the title goes
 *   + body-color: Color used as background color where the body goes
 *   + footer-color: Color used as background color where the footer goes
 *   + border-color: Color used for the showybox's border
 *   + inset: Inset for the title, body, and footer, if title-inset, body-inset, footer-inset aren't given
 *   + radius: Showybox's radius
 *   + thickness: Border width of the showybox
 *   + dash: Showybox's border style
 * - title-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 *   + boxed: Whether the title's block should be apart or not
 *   + boxed-align: Alignement of the boxed title
 *   + sep-thickness: Title's separator thickness
 * - body-styles:
 *   + color: Text color
 *   + align: Text align
 * - footer-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 *   + sep-thickness: Footer's separator thickness
 * - sep:
 *   + width: Separator's width
 *   + dash: Separator's style (as a 'line' dash style)
 *   + gutter: Separator's gutter space
 * - shadow:
 *   + color: Shadow color
 *   + offset: How much to offset the shadow in x and y direction either as a length or a dictionary with keys `x` and `y`
 * - width: Showybox's width
 * - align: Alignement of the showybox inside its container
 * - breakable: Whether the showybox can break if it reaches the end of its container
 * - spacing: Space above and below the showybox
 * - above: Space above the showybox
 * - below: Space below the showybox
 * - body: The content of the showybox
 */
 #let showybox(
  frame: (
    title-color: black,
    body-color: white,
    border-color: black,
    footer-color: luma(220),
    inset: (x: 1em, y: .65em),
    radius: 5pt,
    thickness: 1pt,
    dash: "solid"
  ),
  title-style: (
    color: white,
    weight: "bold",
    align: left,
    boxed: false,
    boxed-align: left,
    sep-thickness: 1pt
  ),
  body-style: (
    color: black,
    align: left
  ),
  footer-style: (
    color: luma(85),
    weight: "regular",
    align: left,
    sep-thickness: 1pt,
  ),
  sep: (
    width: 1pt,
    dash: "solid",
    gutter: 0.65em
  ),
  shadow: none,
  width: 100%,
  breakable: false,
  /* align: none, / collides with align-function */
  /* spacing, above, and below are by default what's set for all `block`s */
  title: "",
  footer: "",
  ..body
) = style(styles => {
  /*
   * Useful booleans
   */
  let titled = (title != "")
  let boxed = title-style.at("boxed", default: false)

  /*
   * Useful sizes and alignements
   */
  let title-size = measure(title, styles)
  let title-block-height = title-size.height + showy-inset(top, showy-section-inset("title", frame)) + showy-inset(bottom, showy-section-inset("title", frame))
  let boxed-align = title-style.at("boxed-align", default: left)
  
  /*
   *  Alignment wrapper
   */
  let alignprops = (:)
  for prop in ("spacing", "above", "below") {
    if prop in body.named() {
      alignprops.insert(prop, body.named().at(prop))
    }
  }
  let alignwrap( content ) = block(
    ..alignprops,
    width: 100%,
    if "align" in body.named() and body.named().align != none {
      align(body.named().align, content)
    } else {
      content
    }
  )

  /*
   * Optionally create one or two wrapper
   * functions to add a shadow.
   */
  let shadowwrap = (sbox) => sbox
  let boxedtitleshadowwrap = (tbox) => tbox
  if shadow != none {
    /* Since we cannot modify a exxtern variable from style(), 
       define a local variable for shadow values, called d-shadow */
    let d-shadow = shadow
    
    if type(shadow.at("offset", default: 4pt)) != "dictionary" {
      d-shadow.offset = (
        x: shadow.at("offset", default: 4pt),
        y: shadow.at("offset", default: 4pt)
      )
    }
    shadowwrap = (sbox) => {

      /* If it has a boxed title, leave some space to avoid collisions
         with other elements next to the showybox*/
      if titled and boxed {
        v(title-block-height - 10pt)
      }
      
      block(
        breakable: breakable,
        radius: frame.at("radius", default: 5pt),
        fill:   shadow.at("color", default: luma(128)),
        spacing: 0pt,
        outset: (
          left: -d-shadow.offset.x,
          right: d-shadow.offset.x,
          bottom: d-shadow.offset.y,
          top: -d-shadow.offset.y 
        ),
        /* If it have a boxed title, substract some space to
           avoid the shadow to be body + title height, and only
           body height */
        if titled and boxed {
          v(-(title-block-height - 10pt))
          sbox
        } else {
          sbox
        }
      )
    }

    if titled and boxed {
      /* Due to some uncontrolable spaces between blocks, there's the need
         of adding an offset to `bottom-outset` to avoid an unwanted space
         between the boxed-title shadow and the body. Hopefully in the
         future a more pure-mathematically formula will be found. At the
         moment, this 'trick' solves all cases where a showybox title has
         only one line of heights */
      let bottom-outset = 10pt + frame.at("thickness", default: 1pt)/2 - .15pt
      
      boxedtitleshadowwrap = (tbox) => block(
        breakable: breakable,
        radius: (top: frame.at("radius", default: 5pt)),
        fill:   shadow.at("color", default: luma(128)),
        spacing: 0pt,
        outset: (
          left: -d-shadow.offset.x,
          right: d-shadow.offset.x,
          top: -d-shadow.offset.y,
          bottom: -bottom-outset
        ),
        tbox
      )
    }
  }
  
  let showyblock = {

    if titled and boxed{
      v(title-block-height - 10pt)
    }

    block(
      width: width,
      fill: frame.at("body-color", default: white),
      radius: frame.at("radius", default: 5pt),
      inset: 0pt,
      spacing: 0pt,
      breakable: breakable,
      stroke: showy-stroke(frame)
    )[
      /*
       * Title of the showybox
       */
      #if titled and not boxed {
        showy-title(frame, title-style, title)
      } else if titled and boxed {        
        // Leave some space for putting a boxed title
        v(10pt)
        place(
          top + boxed-align,
          dy: -(title-block-height - 10pt),
          dx: if boxed-align == left {
            1em
          } else if boxed-align == right {
            -1em
          } else {
            0pt
          },
          boxedtitleshadowwrap(showy-title(frame, title-style, title))
        )
      }
      
      /*
       * Body of the showybox
       */
      #showy-body(frame, body-style, sep, ..body)
    
      /*
       * Footer of the showybox
       */
      #if footer != "" {
        showy-footer(frame, footer-style, footer)
      }
    ]
  }

  alignwrap(
    shadowwrap(showyblock)
  )
})