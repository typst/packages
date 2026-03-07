#import "@preview/beautiframe:0.1.0": *

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[Elegant Style]]

#beautiframe-setup(style: "elegant")
#beautiframe-reset()

#theorem(name: "Pythagorean")[
  In a right triangle with legs $a$ and $b$ and hypotenuse $c$:
  $ a^2 + b^2 = c^2 $
]

#definition[
  A *continuous function* is one where small changes in input produce small changes in output.
]

#lemma[
  If $f$ is continuous at $a$, then $f$ is bounded in some neighborhood of $a$.
]

#remark[
  This result generalizes to higher dimensions.
]

#example[
  Consider $f(x) = x^2$. Then $f(2) = 4$.
]

#proof[
  By direct calculation and the definition of continuity.
]
