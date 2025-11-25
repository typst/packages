#import "@preview/polylux:0.4.0": toolbox
#import "@preview/unofficial-cambridge-polylux-theme:0.0.1": logo, slide
#import "@preview/mannot:0.3.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(
  paper: "presentation-16-9",
  footer: align(right, text(size: .8em, toolbox.slide-number)),
  margin: (bottom: 2em, rest: 1em),
)


#logo.update(image("example-logo.svg"))



#slide(type: "title", [
  #set align(horizon)


  = An example presentation

  Matthew Ord
])

#slide[
  = Outline

  There are five types of slides in this presentation:
  - Standard slides with a dark blue background
  - Light slides with a light blue background
  - Title slides
  - Two alternate slide styles
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

#slide(type: "alt1", [
  == Alternate Slide Example

  This is an alternate slide style.

])


#slide(type: "alt2", [
  == Another Alternate Slide Example

  This is another alternate slide style.

])
