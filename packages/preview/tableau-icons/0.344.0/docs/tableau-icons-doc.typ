#import "@preview/tableau-icons:0.344.0" as tableau-icons
#import "thumbnail_list.typ": *

#import "@preview/tidy:0.4.3"
#import "@preview/shadowed:0.3.0": shadow

/* -------------------------------------------------------------------------- */
/*                            General Configuration                           */
/* -------------------------------------------------------------------------- */
#set text(font: "Atkinson Hyperlegible Next", 10pt)
#set page(margin: 1cm)

// Display block code in a larger block
// with more padding.
#show raw.where(block: true): block.with(
  fill: luma(240),
  width: 100%,
  breakable: true,
  inset: 5pt,
  radius: 4pt,
)


#show raw.where(block: false): it => text(1.1em, it)

#set enum(numbering: (
  it => align(text(weight: "bold", color.darken(blue, 10%), number-width: "tabular")[#it.], horizon)
))


#show enum: set align(top)
#show enum: set par(leading: 0.8em)

#show heading.where(level: 1): it => {
  it
  block(
    v(-1mm) + line(length: 100%, stroke: (thickness: 0.5pt, cap: "round", paint: blue)),
    above: 0.4em,
    below: 0.8em,
  )
}

#show heading.where(level: 3): it => {
  grid(
    columns: (auto, 1fr),
    align: horizon,
    column-gutter: 3pt,
    box(
      align(horizon + center, tableau-icons.ti-icon("code", fill: blue, size: 1em)),
      width: 1.1em,
      height: 1.1em,
      stroke: blue + 0.5pt,
      radius: 2pt,
    ),
    grid.cell(
      it.body,
      inset: (left: 0.1em, y: 3pt),
      stroke: (bottom: (dash: "dashed", thickness: 0.5pt, cap: "round", paint: blue)),
    ),
  )
}

/* -------------------------------------------------------------------------- */
/*                                Header Image                                */
/* -------------------------------------------------------------------------- */
#[
  #image("banner.svg", width: 100%)
]
/* -------------------------------------------------------------------------- */
/*                             Module Description                             */
/* -------------------------------------------------------------------------- */
#linebreak()
#align(center)[

  #block(radius: 0.6em, stroke: orange + 1pt, inset: 0.5em, width: 60%)[
    #set align(left)
    == #tableau-icons.ti-icon("alert-triangle", fill: orange) This package has no association with Tabler

    This package contains the symbols from Tabler Icons v#tableau-icons.ti-icons-version, but has no association with the Tabler.io team themselves.
  ]
]
#linebreak()

Despite the bad naming (the name is translated _Table icons_, which is only one character away from _Tabler_ icons), this package implements a simple function to allow the use of Tabler.io Icons (#text(blue, underline(offset: 0.2em, link("https://tabler.io/icons")))) in your documents.



= #place(dy: -0.1em)[#tableau-icons.ti-icon("hand-click", fill: blue)] #h(1.2em) Usage

Include the package as any other package:

#raw(block: true, "#import \"@preview/tableau-icons:" + tableau-icons.ti-pkg-version + "\": *", lang: "typst")


#box(stroke: color.mix(red, orange), radius: 5pt, inset: 5pt)[
  #grid(
    align: horizon,
    columns: 3,
    column-gutter: 3pt,
    tableau-icons.ti-icon("alert-triangle-filled", size: 1.2em, baseline: 0pt, fill: color.mix(red, orange)),
    [and don't forget to install the Tabler.io Icons font],
    tableau-icons.ti-icon("alert-triangle-filled", size: 1.2em, baseline: 0pt, fill: color.mix(red, orange)),
  )
]

Since some time ago, the Tabler.io team has decided to exclude the webfonts from the free tier and moved them into the \$5 tier. While it is sad, I do understand, that they want to earn a bit more cash from it.


/* -------------------------------------------------------------------------- */
/*                                 Tidy Magic                                 */
/* -------------------------------------------------------------------------- */


= #tableau-icons.ti-icon("license", fill: blue, baseline: 0.15em) Documentation
#import "../tableau-icons.typ"
#show "->": it => { raw("->") }
#let docs = tidy.parse-module(
  read("../tableau-icons.typ"),
  name: "tableau-icons",
  scope: (tableau-icons: tableau-icons),
  preamble: "#import tableau-icons: *;",
)

#show "->": $->$

#let my-show-example = tidy.show-example.show-example.with(
  layout: (code, preview) => {
    grid(columns: (1fr, 1fr))[
      #shadow(radius: 4pt, blur: 4pt, fill: gray)[
        #set text(0.9em)
        #block(code)
      ]
    ][
      #set align(center + horizon)
      #shadow(radius: 4pt, blur: 4pt, fill: gray, block(fill: white, radius: 4pt, inset: 4pt,[
        #set align(left)
        #set text(font: "Atkinson Hyperlegible Next", 1.3em)
        #block(preview)
      ]))
    ]
  },
)


#set heading(numbering: none)
#block(
  width: 100%,
  fill: white,
  inset: (x: 5pt),
  tidy.show-module(docs, show-outline: false, style: dictionary(tidy.styles.default) + (show-example: my-show-example)),
)



= #tableau-icons.ti-icon("versions", fill: blue, baseline: 0.15em) Known Issues

- Some symbols are missing, but I think this is an operating system issue!


/* -------------------------------------------------------------------------- */
/*                                  Changelog                                 */
/* -------------------------------------------------------------------------- */

= #tableau-icons.ti-icon("versions", fill: blue, baseline: 0.15em) Changelog

#include "changelog.typ"

#v(1cm)
#line(length: 30%)
*Used Fonts*: #text(blue, underline(offset: 0.2em, link("https://www.brailleinstitute.org/freefont/", [Atkinson Hyperlegible]))), #text(blue, underline(offset: 0.2em, link("https://github.com/microsoft/cascadia-code", [Cascadia Code])))\
*Created By* Joel von Rotz #text([\(], 2em, weight: "extralight", gray, baseline: 0.13em)\@joelvonrotz on#box(baseline: 1em)[#image("codeberg-logo_horizontal_blue.svg", width: 3cm)
]#text([\)], 2em, weight: "extralight", gray, baseline: 0.13em)

