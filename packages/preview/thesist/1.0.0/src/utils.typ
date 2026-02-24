// Import subfigure package and make it work with the chapter-relative numbering

#import "@preview/subpar:0.2.0"

#let subfigure-grid(..args) = context {

  let numbering-format = if state("after-refs").get() { "A.1" } else { "1.1" }

  subpar.grid(

    numbering: super => numbering(numbering-format, counter(heading).get().first(), super),

    numbering-sub-ref: (super, sub) => numbering(numbering-format+"a", counter(heading).get().first(), super, sub),

    gap: 1.5em,

    ..args

  )

}


// Add ability to show shorter captions in the indices

#let flex-caption(long, short) = context if state("in-outline").get() { short } else { long }
