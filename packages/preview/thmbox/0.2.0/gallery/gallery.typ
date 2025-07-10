#import "@preview/thmbox:0.2.0": *

#set text(font: "New Computer Modern")

#let theme = sys.inputs.at("theme", default: "light")
#let dark-mode = theme == "dark"

#set page(
    height: auto,
    width: 40em,
    margin: (
        left: 1em,
        right: 1em,
        top: 1em,
        bottom: 1em
    ),
    background: if dark-mode {box(fill: black, width: 100%, height: 100%)} else {none}
)

#set text(white) if dark-mode

#show: thmbox-init()

#show heading: set text(0pt)
=


#thmbox(color: if dark-mode {rgb("#aeaeae")} else {colors.dark-gray})[
    This is a basic Thmbox
] <basic-box>

It can be referenced (see @basic-box).

#pagebreak()

#thmbox(
    variant: "Important Theorem", 
    title: "Fundamental Theorem of Math", 
    color: red
)[
    A statement can only be believed if it is proven. 
] <important-theorem>

#pagebreak()

#proof[
    Proven by obviousness.
]

=

#pagebreak()

#theorem[
    This is created using #raw("#theorem[...]", lang: "typ").
]

#proposition[
    This is created using #raw("#proposition[...]", lang: "typ").
]

#lemma[
    This is created using #raw("#lemma[...]", lang: "typ").
]

#corollary[
    This is created using #raw("#corollary[...]", lang: "typ").
]

#definition[
    This is created using #raw("#definition[...]", lang: "typ").
]

#example[
    This is created using #raw("#example[...]", lang: "typ").
]

#remark[
    This is created using #raw("#remark[...]", lang: "typ").
]

#note[
    This is created using #raw("#note[...]", lang: "typ").
]

#exercise[
    This is created using #raw("#exercise[...]", lang: "typ").
]

#algorithm[
    This is created using #raw("#algorithm[...]", lang: "typ").
]

#claim[
    This is created using #raw("#claim[...]", lang: "typ").
]

#axiom[
    This is created using #raw("#axiom[...]", lang: "typ").
]

#pagebreak()

#definition[Typst][
    Let Typst be the coolest typesetting system.
]

=

#pagebreak()

#let important = note.with(
    fill: if dark-mode {rgb("#ffdcdc2f")} else {rgb("#ffdcdc")}, variant: "Important", 
    color: red,
) 
// derive from some predefined function

#important[
    This is in fact very important!
]

#pagebreak()

#let exercise-counter = counter("exercise")
#show: sectioned-counter(exercise-counter, level: 1)
#let my-exercise = exercise.with(counter: exercise-counter)

#my-exercise[The first exercise!]

#pagebreak()

// Define your custom thmbox args
#let my-thmbox-rules = (
    fill: if dark-mode {rgb("#fffdd32f")} else {rgb("#fffdd3")}
)

// redefine predefined environments
#let my-definition = definition.with(..my-thmbox-rules)

// use
#my-definition[
    This definition has a yellow background!
]
