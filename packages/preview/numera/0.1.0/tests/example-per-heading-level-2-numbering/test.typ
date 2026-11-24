#import "@preview/numera:0.1.0": (
  display-numbering, get-numbering, heading-dependent, my-numbering,
  normal-figure, numera, outer-figure-counter-value,
)

#let level = 2
#show: numera(level: level)
#set heading(numbering: "1.1.1")

#set math.equation(numbering: heading-dependent(level, "1"))

= Chapter 1
$ E = m c^2 $ <eq1.1>

== Section 1.1
$ E = m c^2 $ <eq1.1.1>

== Section 1.2
$ E = m c^2 $ <eq1.2.1>

=== Sub-Section 1.2.1
$ E = m c^2 $ <eq1.2.2>

=== Sub-Section 1.2.2
$ E = m c^2 $ <eq1.2.3>

== Section 1.3
$ E = m c^2 $ <eq1.3.1>

= Chapter 2
$ E = m c^2 $ <eq2.1>
