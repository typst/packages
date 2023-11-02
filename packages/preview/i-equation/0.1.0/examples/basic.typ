#import "../i-equation.typ"

#set page(width: 15cm, height: auto, margin: 1.5cm)

// set up heading numbering
#set heading(numbering: "1.")

// this resets all equation counters at every level 1 heading.
#show heading: i-equation.reset-counters.with(level: 1)
// this show rule is the main logic
#show math.equation: i-equation.show-equation.with(numbering: "(1.1)")


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