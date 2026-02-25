// ------ IMPORTS -----
#import "calloution.typ": *  
#import "quotion.typ": *    
#import "checktion.typ": *   
#import "codetion.typ": *     
#import "auto-size-math.typ": * 
#import "linktion.typ": *  

// Main function
#let notionly(
  body,
  notion-look: true,

  // TO-DO: Add subpackage configurations here
) = {
  
  // SHOW RULES (for each subpackage)
  show: quotion
  show: linktion.with(
    // linkDecorations: false,
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
  if notion-look {
    set page(margin: 2.2cm)
    set par(leading: 1.25em)
    set text(
      font: "Inter",
      size: 10.8pt,
      fill: notion.default_text  // rgb("#171717"))
    )
    body // (Set rules are scoped)
  } else {
    body
  }
}

// USAGE:
// #import "notionly.typ": *
// #show: notionly.with(notion-look: true)
