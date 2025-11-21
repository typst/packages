#import "@preview/polylux:0.4.0": toolbox
#import "../lib.typ": camDarkBlue, camLightBlue, slide
#import "@preview/mannot:0.3.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(
  paper: "presentation-16-9",
  footer: align(right, text(size: .8em, toolbox.slide-number)),
  margin: (bottom: 2em, rest: 1em),
)


#let bra(expr) = [$#math.chevron.l expr|$]
#let ket(expr) = [$|expr#math.chevron.r$]



#slide(type: "title", [
  #set align(horizon)


  = An example presentation

  Matthew Ord
])

#slide[
  = Outline

  There are three types of slides in this presentation:
  - Standard slides with a dark blue background
  - Light slides with a light blue background
  - Title slides
  These can be created using the `#slide` command with the appropriate type parameter.

]

#slide(type: "light", [
  == Light Slide Example

  This is an example of a light slide with a light blue header.
  #set text(size: 12pt)
  ```typst
  // Create a title slide
  #slide(type: "title", [
    = Welcome to the Presentation
  ])
  // Create a standard slide
  #slide(type: "standard", [
    == Standard Slide Example
    This is an example of a standard slide with a dark blue header.
  ])
  // Create a light slide
  #slide(type: "light", [
    == Light Slide Example
    This is an example of a light slide with a light blue header.
  ])
  ```

])
