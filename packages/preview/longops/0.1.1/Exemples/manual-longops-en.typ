#import "@preview/tidy:0.4.3"
#import "@preview/codly:1.3.0": *
#set text(lang:"en")
#set raw(lang: "typ")
#let primary = teal.mix(eastern)
#show link: set text(primary)
#show: codly-init.with()
#codly(display-name: false, number-format: none, zebra-fill: none)

// #set page(
//   header: [
//     #h(1fr) #datetime.today().display()
//   ],
//   numbering: "1.",
// )

#[
  #set align(center)
  #let prop = toml("../typst.toml").package
  #text(2em, weight: "bold", primary)[longops]\
  #let subtitle = text(1.5em, prop.description)
  #subtitle

  #{//context 
    box(width: 1fr)[//measure(subtitle).width
      v#prop.version 
      #h(1fr)
      #prop.authors.join(
        ", ",
        last: " & ",
      )#h(1fr)#prop.license]
  }]

= About

As a mathematics teacher, I sometimes need to show how to carry out arithmetic "by hand". I am now making available the functions that I originally created for my own use.

I previously used the LaTeX package *xlop*, and since Typst is much more convenient to use, I decided to create my own equivalent. This package is *not* a direct translation of *xlop*: it includes some features that *xlop* does not, while omitting others, according to my own needs.

I occasionally used AI tools (mainly Gemini for the *Order of Operations* module, and also to add features to the other functions that I had initially implemented for just one of them).

*Acknowledgments* : I wanted to thank #link("https://github.com/ObaulG")[ObaulG], the part "durations" is mostly is work.

#import "Ops-en.typ"
#import "/Operations.typ"

#show heading.where(level:2): it => {pagebreak(); it}
== Functions for handwritten arithmetic layouts ...
#let docs = tidy.parse-module(
  read("Ops-en.typ") + read("/Operations.typ"),
  scope: (Operations: Operations), 
  preamble: "#import Operations: *\n",
)

#show: tidy.render-examples.with(
layout: (code, preview) => grid(code, preview)
)
// #set block(
//   breakable:false,
// )

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

// #tidy.show-module(
//   module,
//   style: dictionary(tidy.styles.default) + (show-example: show-example),
// )

#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example),omit-private-definitions: true,)

#import "/durées.typ" 
#import "durees-en.typ" 

== Additions and substractions of durations
#let docs = tidy.parse-module(
  read("durees-en.typ") + read("/durées.typ"),
  scope: (durées: durées), 
  preamble: "#import durées: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example))

#import "Prio-en.typ"
#import "/Priorités.typ" 

== Step-by-step calculations and highlighting
#let docs = tidy.parse-module(
  read("Prio-en.typ")  + read("/Priorités.typ"),
  scope: (Priorités: Priorités), 
  preamble: "#import Priorités: *\n",
)
#tidy.show-module(docs, style: dictionary(tidy.styles.default) + (show-example: show-example))
