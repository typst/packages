#import "@preview/numera:0.1.0": (
  display-numbering, get-numbering, heading-dependent, my-numbering,
  normal-figure, numera, outer-figure-counter-value,
  subfigure-counter-dependent,
)

// The default heading prefix uses reference formatting, so appendix brackets
// remain on headings but are omitted from figure and equation prefixes.
#let level = 1
#show: numera(level: level)

// Custom figure kinds require an explicit supplement.
#show figure.where(kind: "subfigure"): set figure(supplement: [Figure])

#set math.equation(numbering: heading-dependent(1, "(1)"))
#show normal-figure: set figure(numbering: heading-dependent(1, "(1)"))

= Test 1

$ 1 + 1 $ <eq1-1>

#show figure.where(kind: "subfigure"): set figure(numbering: heading-dependent(
  level,
  subfigure-counter-dependent("(S1a)"),
))

#figure(
  [
    F1.1
    #figure("S1.1.a", caption: "S1.1.a", kind: "subfigure") <s1-1-a>
    #figure("S1.1.b", caption: "S1.1.b", kind: "subfigure") <s1-1-b>
  ],
  caption: "F1.1",
) <fig1-1>


== Subtitle
$ 1 + 1 $ <eq1-2>
#figure("F1.2", caption: "F1.2") <fig1-2>

See @eq1-1, @eq1-2, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2

#set heading(numbering: "[A.A]")

= Appendix

$ 1 + 1 $ <eq2-1>
#figure("F2.1", caption: "F2.1") <fig2-1>
$ 1 + 1 $ <eq2-2>
#figure("F2.2", caption: "F2.2") <fig2-2>

See @eq1-1, @eq1-2, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2

#set math.equation(numbering: heading-dependent(level, "(1)", separator: "-"))
#show normal-figure: set figure(numbering: heading-dependent(
  level,
  "(1)",
  separator: "-",
))
#show figure.where(kind: "subfigure"): set figure(numbering: heading-dependent(
  level,
  subfigure-counter-dependent("(X1a)"),
))

#set math.equation(supplement: "Eq")
#set figure(supplement: "Fig")
#show figure.where(kind: "subfigure"): set figure(supplement: [Fig])

= Test 1

$ 1 + 1 $ <eq3-1>
#figure("F3.1", caption: "F3.1") <fig3-1>
$ 1 + 1 $ <eq3-2>
#figure("F3.2", caption: "F3.2") <fig3-2>

See @eq1-1, @eq1-2, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2

#set heading(numbering: "[I.I]")

= Appendix

$ 1 + 1 $ <eq4-1>
#figure(
  [
    F4.1
    #figure("S4.1.a", caption: "S4.1.a", kind: "subfigure") <s4-1-a>
    #figure("S4.1.b", caption: "S4.1.b", kind: "subfigure") <s4-1-b>
  ],
  caption: "F4.1",
) <fig4-1>
== Subtitle
$ 1 + 1 $ <eq4-2>
#figure("F4.2", caption: "F4.2") <fig4-2>

See @eq1-1, @eq1-2, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2
