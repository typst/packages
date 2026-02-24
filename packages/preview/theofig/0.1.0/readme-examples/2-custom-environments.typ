#import "/theofig.typ": theofig, problem, solution
#set page(paper: "a6", height: auto, margin: 6mm)

#let hard-problem = theofig.with(
  supplement: "Problem", 
  numbering: n => $#n^*$
)

#let hint = theofig.with(
  supplement: "Hint", 
  numbering: none, 
  format-caption: none,
  separator: ":"
)

= Default

#problem[ What $1 + 1$ equals to in $ZZ_2$? ]

#solution[
  Observe that $1 + 1$ is $2$, and $2 mod 2$ is $0$. 
  Hense, the answer is $0$.
]

= Custom

#hard-problem[ Prove that $ZZ_2$ is a field. ]

#hint[ Verify all axioms of a field exaustively. ]
