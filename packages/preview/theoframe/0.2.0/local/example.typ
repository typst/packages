#import "../lib.typ":*
#show: reset

#set page(width: 210mm, height: auto, margin: 1cm)
#set heading(numbering: "1.1")
#show heading: set text(fill: rgb("#040404"))

= Preliminaries
#lorem(20)

#definition(name: "Even Integer")[
  An integer $n$ is called *even* if it is divisible by $2$, i.e., there exists an integer $k$ such that $n = 2k$.
]<def:even>

#definition(name: "Odd Integer")[
  An integer $n$ is called *odd* if it is not divisible by $2$, i.e., there exists an integer $k$ such that $n = 2k + 1$.
]<def:odd>

= Main Results
#lorem(20)

#theorem(name: "Sum of Two Even Integers")[
  The sum of any two even integers is even.
]<thm:sum-even>

#proof(name: "Proof of @thm:sum-even")[
  Let $a$ and $b$ be two even integers. By @def:even, there exist integers $k$ and $m$ such that $a = 2k$ and $b = 2m$. Then
  $a + b = 2k + 2m = 2(k + m)$,
  which shows that $a + b$ is divisible by $2$, hence even by @def:even.
]<pf:sum-even>

#corollary(name: "Sum of Multiple Even Integers")[
  The sum of any finite number of even integers is even.
]<cor:sum-multiple>

#proof[
  This follows directly from @thm:sum-even by induction on the number of terms.
]

= Additional Examples
#lorem(20)

#example(name: "Concrete Even Numbers")[
  The integers $4$, $10$, and $16$ are even since $4 = 2 times 2$, $10 = 2 times 5$, and $16 = 2 times 8$.
]<ex:even-numbers>

#problem(name: "Sum of Two Odd Integers")[
  Show that the sum of two odd integers is even.
]<prob:sum-odd>

#solution(name: "Solution to @prob:sum-odd")[
  Let $a$ and $b$ be odd integers. By @def:odd, there exist integers $k$ and $m$ such that $a = 2k + 1$ and $b = 2m + 1$. Then
  $a + b = (2k + 1) + (2m + 1) = 2k + 2m + 2 = 2(k + m + 1)$,
  which is even by @def:even.
]<sol:sum-odd>

#pagebreak()

#show outline: it => {
  show heading: set text(fill: rgb("#000000"))
  it
}

#outline(title:"Definitions", target: figure.where(kind:"Definition"))
#outline(title:"Theorems", target: figure.where(kind:"Theorem"))
#outline(title:"Corollaries", target: figure.where(kind:"Corollary"))