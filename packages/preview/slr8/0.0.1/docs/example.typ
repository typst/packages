#import "../src/vis.typ": *

// Use "\\epsilon" for empty productions
// The first production's LHS is treated as the start symbol
// The dot character "." is reserved, do not use it as a symbol

#let my-grammar = (("C", ("id", "(", "A", ")"))
                  ,("A", ("A", ",", "E"))
                  ,("A", ("\\epsilon",))
                  ,("A", ("E",))
                  ,("E", ("E", "+", "T"))
                  ,("E", ("T",))
                  ,("T", ("id",))
                  ,("T", ("num",))
                  ,("T", ("C",))) 

#let my-sentence = ("id", "(", "num", "+", "id", "," , "id", "(" , "num", "+" , "id" , ")" , ")")

//  DOCUMENT (comment out any section you don't need)

#set page(margin: 2cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[
  #text()[Your Little Name]
  
  #text(size: 16pt, weight: "bold")[SLR Parser Visualization]
  
  #v(4pt)
  
  #text(weight: "bold",size: 10pt)[
    Input: #raw(my-sentence.join(" "))
  ]
]

#v(16pt)


#grid(
  columns: (1fr, 1fr),
  align: center,
  [
    == Original grammar

    #v(5pt)

    #show-grammar(my-grammar)
  ],
  [
    == Augmented grammar

    #v(5pt)

    #show-aug-grammar(my-grammar)
  ]
)


== First and Follow sets

#v(5pt)

#show-first-follow(my-grammar)

#v(16pt)

== Set of items

#v(5pt)

#show-canonical-items(my-grammar)

#v(16pt)

== DFA

#v(12pt)

#show-automaton(my-grammar)

#v(18pt)

== States table

#v(16pt)

#align(center, show-parse-table(my-grammar))

#pagebreak()

== Stack for #raw(my-sentence.join(" "))

#v(16pt)

#show-parse-trace(my-grammar, my-sentence)

#pagebreak()

== Parse Tree for #raw(my-sentence.join(" "))

#v(16pt)

#show-parse-tree(my-grammar, my-sentence)
