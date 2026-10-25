#import "@preview/numera:0.1.0": (
  display-numbering, get-numbering, heading-dependent, my-numbering,
  normal-figure, numera, outer-figure-counter-value,
)

#let level = 0
#show: numera(level: level)
#set heading(numbering: "1.1.1")

#set math.equation(numbering: heading-dependent(level, "1"))

= Chapter 1
$ E = m c^2 $ <eq1>

== Section 1.1
$ E = m c^2 $ <eq2>

== Section 1.2
$ E = m c^2 $ <eq3>

=== Sub-Section 1.2.1
$ E = m c^2 $ <eq4>

=== Sub-Section 1.2.2
$ E = m c^2 $ <eq5>

== Section 1.3
$ E = m c^2 $ <eq6>

= Chapter 2
$ E = m c^2 $ <eq7>
