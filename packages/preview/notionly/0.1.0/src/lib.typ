// ------ IMPORTS -----
#import "callouts.typ": *  
#import "quotes.typ": *    
#import "checklists.typ": *   
#import "code.typ": *     
#import "math.typ": * 
#import "links.typ": *  
#import "toggles.typ": *
#import "media.typ": *
#import "tables.typ": *

// Main function
#let notionly(
  body,
  style: "notion",
  font: "",

  // TO-DO: Add subpackage configurations here
) = {
  
  // SHOW RULES (for each subpackage)
  show: quotion
  show: tabletion
  show: linktion.with(
    // link-decorations: false,
  )
  show: checktion.with(
    // unchecked-stroke-color: blue,
    // checked-fill-color: red,
    // checkmark-stroke-color: black,
    // checked-stroke-color: purple,
    // checked-stroke-thickness: 2pt,
  )
  show: codetion.with(
    // mono-font: "IBM Plex Mono",
    // bg-color: rgb("#d0a0d0"),
    // text-color: black,
  )
  show: auto-size-math.with(
    // scale-equations: false,
  )

  // --------- NOTION LOOK ---------
  if (style == "notion") {
    set page(margin: 2.2cm)
    set par(leading: 1.25em)
    set par(spacing: 1em)
    let notion-font = "Inter" // It actually is San Francisco Pro on MacOS, but it is not free nor included on the Typst.app so Inter is the best fallback.
    if (font != "") {
      notion-font = font
    }
    set text(font: notion-font)
    set text(
      size: 10.8pt,
      fill: notion.default_text  // rgb("#171717"))
    )
    show math.equation.where(block: true): set block(spacing: 2.2em)
    
    body
  } else if (style == "elegant") {
    // PENDING
    body
  } else if (style == "modern") {
    // PENDING
    body
  } else if (style == "classic") {
    // PENDING
    body
  } else if (style == "handwritten") {
    // PENDING
    body
  } else if (style == "brutalist") {
    // PENDING
    body
  } else {
    body
  }
}
