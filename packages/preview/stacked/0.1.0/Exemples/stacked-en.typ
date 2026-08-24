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
  #text(2em, weight: "bold", primary)[stacked]\
  #let subtitle = text(1.5em, prop.description)
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

Cube stacks were introduced into the French middle-school curriculum in 2025,
which is what motivated the creation of this package.

I was inspired by `tikz3d-fr` (author: Cédric Pierquet) and by part of
`ProfCollege` for LaTeX (author: Christophe Poulain), but this implementation
is not a copy of either. I used AI (Gemini and Claude) for the dice and the
random part of the `pile` function; the rest is my own work, except for the
`dice-face` function, which was created by eric1102 (on Discord) and is
included here with his permission.

= Functions: cube stacks and dice

#import "premanual-en.typ"
#import "../PileCubes.typ"
#import "../Dés3D.typ"

// #show heading.where(level:2): it => {pagebreak(); it}

#let docs = tidy.parse-module(
  read("premanual-en.typ") + read("/PileCubes.typ") + read("/Dés3D.typ"),
  // name:"OpsM",
  scope: (PileCubes: PileCubes, Dés3D:Dés3D), 
  preamble: "#import PileCubes: *\n #import Dés3D: *\n ",
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