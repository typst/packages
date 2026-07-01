#import "@preview/tableau-icons:0.334.0": *
#import "thumbnail_list.typ": *

#import "@preview/tidy:0.4.2"
#import "@preview/shadowed:0.2.0": shadowed

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

#set enum(
  numbering: (it => align(text(weight: "bold", color.darken(blue, 10%), number-width: "tabular")[#it.], horizon)),
)


#show enum: set align(top)
#show enum: set par(leading: 0.8em)

#show heading.where(level: 1): it => {
  it
  block(
    v(-1mm) + line(length: 100%, stroke: (dash: (2pt, 4pt), cap: "round", thickness: 2pt, paint: blue)),
    above: 0.4em,
    below: 0.8em,
  )
}

#show heading.where(level: 3): it => {
  tableau-icons.draw-icon("function", fill: blue, height: 1.5em, baseline: 0.4em) + h(0.3em) + it.body + linebreak()
}

/* -------------------------------------------------------------------------- */
/*                                Header Image                                */
/* -------------------------------------------------------------------------- */
#[
  #set align(center)


  #box(clip: true, width: 100%, height: 10cm)[
    #box(
      inset: (left: -2em, top: -5em),
      width: 100%,
      height: 10cm,
      clip: true,
      rotate(
        -10deg,
        [
          #for icon in thumbnail_list {
            (
              tableau-icons.draw-icon(icon, fill: color.lighten(blue, 10%), height: 2.9em, width: 2.9em)
            )
          }
        ],
      ),
    )

    #place(
      center + horizon,
      block(
        width: 100%,
        align(center + horizon)[
          #box(
            stroke: white + 2pt,
            fill: white,
            inset: 0em,
            radius: (top: 2em, bottom: 1em),
          )[
            #box(
              stroke: black + 2pt,
              fill: white,
              inset: 2em,
              radius: 1em,
              align(center + horizon)[#text(weight: "bold", 4em, font: "Atkinson Hyperlegible Next")[tableau-icons.typ]],
            )
            #block(height: 2em, above: 0.3em)[
              #set align(center + horizon)
              #set text(1.25em)
              #grid(columns: (30%, 30%), align: (left, right))[
                *Tabler Icons Version* #tableau-icons.tabler-icons-version
              ][*Package* #tableau-icons.package-version]
            ]
          ]
        ],
      ),
    )
  ]


]
/* -------------------------------------------------------------------------- */
/*                             Module Description                             */
/* -------------------------------------------------------------------------- */
#linebreak()
#align(center)[

  #block(radius: 0.6em, stroke: orange + 1pt, inset: 0.5em, width: 60%)[
    #set align(left)
    == #tableau-icons.draw-icon("alert-triangle", fill: orange, baseline: 15%) This package has no association with Tabler

    This package contains the symbols from Tabler Icons v#tableau-icons.tabler-icons-version, but has no association with the Tabler.io team themselves.
  ]
]
#linebreak()

Despite the bad naming (the name is translated _Table icons_, which is only one character away from _Tabler_ icons), this package implements a couple of functions to allow the use of Tabler.io Icons (#text(blue,underline(offset: 0.2em,link("https://tabler.io/icons")))) in your documents.



= #tableau-icons.draw-icon("hammer", fill: blue, baseline: 0.15em) Usage

Include the package as any other package:

#raw(block: true, "#import \"@preview/tableau-icons:" + tableau-icons.package-version + "\": *", lang: "typst")

#tableau-icons.draw-icon("alert-triangle-filled", height: 1.2em, baseline: 25%, fill: red) and install the Tabler.io Icons font #tableau-icons.draw-icon("alert-triangle-filled", height: 1.2em, baseline: 25%, fill: red) 

Since some time ago, the Tabler.io team has decided to exclude the webfonts from the free tier and moved them into the \$5 tier. While it is sad, I do understand, that they want to earn a bit more cash from it.

/* -------------------------------------------------------------------------- */
/*                                 Tidy Magic                                 */
/* -------------------------------------------------------------------------- */
= #tableau-icons.draw-icon("books", fill: blue, baseline: 0.15em) Documentation
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
      #shadowed(radius: 4pt, color: color.lighten(black, 50%))[
        #block(code)
      ]
    ][
      #set align(center+horizon)
      #shadowed(radius: 4pt, inset: 6pt, color: color.lighten(black, 50%))[
      #set align(left)
        #set text(font: "Atkinson Hyperlegible Next")
        #block(preview)
      ]
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



= #tableau-icons.draw-icon("versions", fill: blue, height: 1em, width: 1em, baseline: 0.15em) Known Issues

- Some symbols are missing, but I think this is an operating system issue!


/* -------------------------------------------------------------------------- */
/*                                  Changelog                                 */
/* -------------------------------------------------------------------------- */

= #tableau-icons.draw-icon("versions", fill: blue, height: 1em, width: 1em, baseline: 0.15em) Changelog

#include "changelog.typ"

#v(1cm)
#line(length: 30%)
*Used Fonts*: #text(blue,underline(offset: 0.2em,link("https://www.brailleinstitute.org/freefont/",[Atkinson Hyperlegible]))), #text(blue,underline(offset: 0.2em,link("https://github.com/microsoft/cascadia-code",[Cascadia Code])))\
*Created By* Joel von Rotz (\@joelvonrotz on #tableau-icons.draw-icon("brand-github", baseline: 20%))

