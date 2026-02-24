/* Flyer in Typst
Author: Mariano Mollo <marianomollo@protonmail.ch>
*/

#import "@preview/impaginato:0.1.0": *

// Leave a null margin here. It will be handled later in the grid.
// Horizontal A4 format, to be cut in half by hand.
#set page(paper: "a4", margin: 0pt, flipped: true)
// Set your language here.
#set text(lang: "it")

#let single_flyer = [
  // Place your logo if you wish.
  #place(
    bottom + right,
    dx: 0mm, dy: 0mm,
    image("fantasma.svg", height: 3.5cm))
  
  // Main heading
  #set text(font: "Bebas Neue", size: 48pt)
  #set par(leading: 10pt, spacing: 10pt)

  A simple flyer for activists using Typst
  
  // Body
  #set text(font: "Myriad Pro", size: 14pt)
  #set par(leading: 9pt, justify: true, spacing: 13pt)
  
  This document features two identical A5 flyers, ready to print at home or at local copy shops on A4 paper, with a dashed line guide to cut in half precisely.
  Write once, and the content will appear on both sides with the same formatting.

  This was possible thanks to the usage of Typst variables in the source code.
  The variable `single_flyer` is assigned with the content of one A5 flyer.
  This is then repeated twice inside a grid with two columns.
  Each column of the grid has a inset, and the two columns are separated by a dashed `vline`.

  This flyer features a big uppercase and catchy left-aligned heading on the top, and a medium-large, center-aligned footer for a call to action.
  The footer is flushed to the bottom, using a `#v(1fr)` at the end of the body text.

  You can place a logo or an image of your choice in this flyer.
  This is done using the `#place` function.
  By default, the logo is placed at the bottom right.
  You can move the logo changing its placement keywords, or tweaking the `dx` and `dy` parameters for a finer tuning.

  Using Typst for graphics design guarantees reproducibility, do-what-i-mean behaviour, reduces technical debt (goodbye expensive tools), and allows more people to collaborate freely.

  #strong[
    Ditch proprietary software and closed file formats.

    Embrace declarative design and open source tools.
  ]

  // Flush the rest to bottom.
  #v(1fr)
  
  // Footer
  #set text(font: "Bebas Neue", size: 24pt)
  #align(center)[
    I design in Typst \
    #text(size: 32pt)[You can do it too]
  ]
]

#impagina(single_flyer)
