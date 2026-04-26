#import "@preview/great-theorems:0.1.0": *
#import "@preview/headcount:0.1.0": *

#set heading(numbering: "1.1")
#show: great-theorems-init

#show link: text.with(fill: blue)

#let mathcounter = counter("mathblocks")
#show heading: reset-counter(mathcounter)

#let theorem = mathblock(
  blocktitle: "Theorem",
  counter: mathcounter,
  numbering: dependent-numbering("1.1"),
)

#let lemma = mathblock(
  blocktitle: "Lemma",
  counter: mathcounter,
  numbering: dependent-numbering("1.1")
)

#let remark = mathblock(
  blocktitle: "Remark",
  prefix: [_Remark._],
  inset: 5pt,
  fill: lime,
  radius: 5pt,
)

#let proof = proofblock()

= Some Heading

#theorem[
  This is some theorem.
] <mythm>

#lemma[
  This is a lemma. Maybe it's used to prove @mythm.
]

#proof[
  This is a proof.
]

= Another Heading

#theorem(title: "some title")[
  This is a theorem with a title.
] <thm2>

#proof(of: <thm2>)[
  This is a proof of the theorem which has a title.
]

#remark[
  This is a remark.
  The remark box has some custom styling applied.
]
