#import "/src/theofig.typ": *
#set page(paper: "a6", height: auto, margin: 6mm)

#let thm-numbering(n) = numbering("1.1", counter(heading).get().first(), n)
#let eq-numbering(n) = numbering("(1.1)", counter(heading).get().first(), n)

#show figure-where-kind-in(theofig-kinds): set figure(numbering: thm-numbering)
#set math.equation(numbering: eq-numbering)

#set heading(numbering: "1.")
#show heading: it => {
  theofig-reset-counters(theofig-kinds)
  counter(math.equation).update(0)
  it
}

= Addition

#theorem[$ 1 + 1 = 2. $<eq-add-1>]<th-add-1>
#theorem[$ 2 + 2 = 4. $<eq-add-2>]<th-add-2>
#theorem[$ 4 + 4 = 8. $<eq-add-3>]<th-add-3>

= Multiplication

#theorem[$ 1 times 1 =  1. $<eq-mul-1>]<th-mul-1>
#theorem[$ 2 times 2 =  4. $<eq-mul-2>]<th-mul-2>
#theorem[$ 4 times 4 = 16. $<eq-mul-3>]<th-mul-3>

= References
Note that @th-add-2 about @eq-add-2 and
@th-mul-2 about @eq-mul-2 are similar.
