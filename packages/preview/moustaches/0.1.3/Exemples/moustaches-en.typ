#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#set text(lang:"en")
#set raw(lang: "typ")
#let primary = teal.mix(eastern)
#show link: set text(primary)
#show: codly-init.with()
#codly(display-name: false, number-format: none, zebra-fill: none)

#[
  #set align(center)
  #let prop = toml("../typst.toml").package
  #text(2em, weight: "bold", primary)[moustaches]\
  #let subtitle = text(1.5em, "Fench statistics (tables and diagrams)")
  #subtitle

  #{//context 
    box(width: 1fr)[
      v#prop.version 
      #h(1fr)
      #prop.authors.join(
        ", ",
        last: " & ",
      )
      #h(1fr)#prop.license]
  }]


= About
While preparing my lessons, I realized that none of the existing packages for creating statistical diagrams support counts, the French definitions of quartiles, or the construction of histograms and box plots as I teach them... This package was created to fill that gap.

I took inspiration from parts of the LaTeX package ProfCollege (by Christophe Poulain), but the implementation is not a copy, and I did not use AI at all in the development of this package.

In the updates, I added proportionality tables, equation solving and matrix operations (with arrows for explanations and mblock for blocks spanning multiple columns/rows) and a few helper functions (with fletcher 0.5.8) and help-en (made by tidy 0.4.3).

== Main module: "stat" and "gridmath" module

All the functions in this part from `math-grid` onward are part of the `gridmath` module which can be imported on its own.

#import "premanual-en.typ"
#import "/moustaches.typ"

// #show heading.where(level:2): it => {pagebreak(); it}

#let docs = tidy.parse-module(
  read("premanual-en.typ") + read("/moustaches.typ"),
  // name:"OpsM",
  scope: (moustaches: moustaches), 
  preamble: "#import moustaches: *\n  #import gridmath: *\n",
)

#let show-example(
  ..args
) = {
  
  tidy.show-example.show-example(
    ..args,
    layout: (code, preview, ..args) => block(breakable: false, 
      tidy.show-example.default-layout-example(
        code, preview, 
        code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
        preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
        col-spacing: 5pt,
        ..args
      )
    ),
  )
}

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,sort-functions: none)

== Sub-module for tilings and colormaps: "hachures"

#import "../Hachures.typ"
#let docs = tidy.parse-module(
  read("/Hachures.typ"),
  // name:"OpsM",
  scope: (Hachures: Hachures), 
  preamble: "#import Hachures: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,sort-functions: none)
