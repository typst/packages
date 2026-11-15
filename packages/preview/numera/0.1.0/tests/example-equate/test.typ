#import "@preview/equate:0.3.3": equate
#import "@preview/numera:0.1.0": (
  concat, display-numbering, get-numbering, heading-dependent, my-numbering,
  non-ref, normal-figure, numera, outer-figure-counter-value,
  subfigure-counter-dependent,
)

#let level = 2
#show: equate
#show: numera(level: level)

#set heading(numbering: "A.A.A.A")
#set math.equation(numbering: concat(
  non-ref("("),
  heading-dependent(level, "1.1"),
  non-ref(")"),
))

= Test 1

$ 1 + 1 $ <eq1-1>

== Subtitle
$ 1 + 1 #<eq1-2a> \ 2 + 2 #<eq1-2b> $ <eq1-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

= Appendix

$ 1 + 1 $ <eq2-1>
$ 1 + 1 $ <eq2-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

= Test 1

$ 1 + 1 \ 2 + 2 $ <eq3-1>
$ 1 + 1 $ <eq3-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

#set heading(numbering: "I.I.I.I")

= Appendix

$ 1 + 1 $ <eq4-1>

== Subtitle
$ 1 + 1 #<eq4-2a> \ 2 + 2 #<eq4-2b> $ <eq4-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b
