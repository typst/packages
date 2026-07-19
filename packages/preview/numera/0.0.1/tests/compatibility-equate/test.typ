#import "@preview/equate:0.3.3": equate
#import "@preview/numera:0.0.1": (
  display-numbering, get-numbering, my-numbering, normal-figure, numera,
  outer-figure-counter-value,
)

#show: equate.with(sub-numbering: true, number-mode: "line")
#show: numera(level: 1)

#set math.equation(numbering: (ref: false, ..nums) => {
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "."
  }
  heading + my-numbering("(1.1)", ref: ref, ..nums)
})

#show normal-figure: set figure(numbering: (ref: false, ..nums) => {
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "."
  }
  heading + my-numbering("(1)", ref: ref, ..nums)
})

= Test 1

$ 1 + 1 $ <eq1-1>

#show figure.where(kind: "subfigure"): set figure(numbering: (
  ref: false,
  ..nums,
) => {
  let outer-count = outer-figure-counter-value()
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "."
  }
  heading + my-numbering("(S1a)", ref: ref, ..outer-count, ..nums)
})

#figure(
  [
    F1.1
    #figure("S1.1.a", caption: "S1.1.a", kind: "subfigure") <s1-1-a>
    #figure("S1.1.b", caption: "S1.1.b", kind: "subfigure") <s1-1-b>
  ],
  caption: "F1.1",
) <fig1-1>


== Subtitle
$ 1 + 1 #<eq1-2a> \ 2 + 2 #<eq1-2b> $ <eq1-2>
#figure("F1.2", caption: "F1.2") <fig1-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2

#set heading(numbering: "[A.A]")

= Appendix

$ 1 + 1 $ <eq2-1>
#figure("F2.1", caption: "F2.1") <fig2-1>
$ 1 + 1 $ <eq2-2>
#figure("F2.2", caption: "F2.2") <fig2-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2


#set math.equation(numbering: (ref: false, ..nums) => {
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "-"
  }
  heading + my-numbering("(1.1)", ref: ref, ..nums)
})

#show normal-figure: set figure(numbering: (ref: false, ..nums) => {
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "-"
  }
  heading + my-numbering("(1)", ref: ref, ..nums)
})

#show figure.where(kind: "subfigure"): set figure(numbering: (
  ref: false,
  ..nums,
) => {
  let outer-count = outer-figure-counter-value()
  let heading = display-numbering(heading, ref: ref)
  if heading != none {
    heading += "."
  }
  heading + my-numbering("(X1a)", ref: ref, ..outer-count, ..nums)
})

#set math.equation(supplement: "Eq")
#set figure(supplement: "Fig")

= Test 1

$ 1 + 1 \ 2 + 2 $ <eq3-1>
#figure("F3.1", caption: "F3.1") <fig3-1>
$ 1 + 1 $ <eq3-2>
#figure("F3.2", caption: "F3.2") <fig3-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

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
$ 1 + 1 #<eq4-2a> \ 2 + 2 #<eq4-2b> $ <eq4-2>
#figure("F4.2", caption: "F4.2") <fig4-2>

See @eq1-1, @eq1-2, @eq1-2a, @eq1-2b, @eq2-1, @eq2-2, @eq3-1, @eq3-2, @eq4-1, @eq4-2, @eq4-2a, @eq4-2b

See @fig1-1, @s1-1-a, @s1-1-b, @fig1-2, @fig2-1, @fig2-2, @fig3-1, @fig3-2, @fig4-1, @s4-1-a, @s4-1-b, @fig4-2
