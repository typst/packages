#import "../i-equation.typ"

#set page(width: 15cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.")

// this `level: 2` instructs the equation counters to be reset for every
// level 2 section, so at every level 1 and level 2 heading.
#show heading: i-equation.reset-counters.with(level: 2)
// this `level: 2` instructs the equation numbering to include the first
// two levels of the current heading numbering.
// how this should behave with zeros can be set using `zero-fill`.
// e.g., setting `zero-fill: false` and `leading-zero: false` assures
// there is never a `0` in the numbering.
#show math.equation: i-equation.show-equation.with(level: 2)

This is a @eqt:bef before the first heading.

$ a^2 + b^2 = c^2 $ <bef>

= Introduction

Numbered with label prefix `eqt:` such as @eqt:ratio:

$ phi.alt = (1 + sqrt(5)) / 2 $ <ratio>

== Hello Typst

Numbered with `only-labeled: false`:

$ sum_(k=1)^n k = (n(n+1)) / 2 $

== Hello i-equation

Unnumbered with `<->`:

$ w <- op("update")(w) $ <->


= Performance

@eqt:slow demonstrates what slow
software looks like.

$ O(n) = 2^n $ <slow>