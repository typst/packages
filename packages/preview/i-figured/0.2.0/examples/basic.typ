#import "../i-figured.typ"

#set page(width: 15cm, height: auto, margin: 1.5cm)

// set up heading numbering
#set heading(numbering: "1.")

// this resets all figure counters at every level 1 heading.
// custom figure kinds must be added here.
#show heading: i-figured.reset-counters.with(extra-kinds: ("atom",))
// this show rule is the main logic, custom prefixes for custom figure kinds
// can optionally be added here.
#show figure: i-figured.show-figure.with(extra-prefixes: (atom: "atom:"))
// a similar function exists for math equations
#show math.equation: i-figured.show-equation

// show outlines for all kinds of figures
#i-figured.outline()
#i-figured.outline(target-kind: table, title: [List of Tables])
#i-figured.outline(target-kind: raw, title: [List of Listings])
#i-figured.outline(target-kind: "atom", title: [List of Atoms])
// and equations
#outline(target: math.equation, title: [List of Equations])

#figure([x], caption: [This is a figure before the first heading.])

= Introduction

// references to figures must be prefixed with the respective prefix
Below are @fig:my-figure, @tbl:my-table, @lst:my-listing, @atom:my-atom, and also @eqt:my-equation.
Also see @fig:my-second-figure and @fig:my-third-figure.

#figure([a], caption: [This is a figure.]) <my-figure>
#figure(table([a]), caption: [This is a table.]) <my-table>
#figure(```rust fn main() {}```, caption: [This is a code listing.]) <my-listing>
#figure(circle(radius: 10pt), caption: [A curious atom.], kind: "atom", supplement: "Atom") <my-atom>
$ phi.alt := (1 + sqrt(5)) / 2 $ <my-equation>

= Background

#figure([b], caption: [This is another figure.]) <my-second-figure>

== Some History

#figure([c], caption: [This is the third figure.]) <my-third-figure>

== Hello World

#figure([d], caption: [Guess what? This is also a figure.])
#figure([e], caption: [This is the final figure.])
