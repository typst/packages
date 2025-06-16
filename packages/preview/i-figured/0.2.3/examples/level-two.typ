#import "../i-figured.typ"

#set page(width: 15cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.")

// this `level: 2` instructs the figure counters to be reset for every
// level 2 section, so at every level 1 and level 2 heading.
#show heading: i-figured.reset-counters.with(level: 2)
// this `level: 2` instructs the figure numbering to include the first
// two levels of the current heading numbering.
// how this should behave with zeros can be set using `zero-fill`.
// e.g., setting `zero-fill: false` and `leading-zero: false` assures
// there is never a `0` in the numbering.
#show figure: i-figured.show-figure.with(level: 2)

// show the outline
#i-figured.outline()

#figure([x], caption: [This is a figure before the first heading.])

= Introduction

#figure([a], caption: [This is a figure.])

= Background

#figure([b], caption: [This is another figure.])

== Some History

#figure([c], caption: [This is the third figure.])

== Hello World

#figure([d], caption: [Guess what? This is also a figure.])
#figure([e], caption: [This is the final figure.])
