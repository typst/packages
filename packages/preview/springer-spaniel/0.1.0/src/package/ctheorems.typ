#import "@preview/ctheorems:1.1.2": *

#let thmrules = thmrules.with(qed-symbol: $square.stroked$)

#let thmbox = thmbox.with(
  padding: (y: 0.25em),
  inset: 0pt, 
  radius: 0pt, 
  breakable: true,
  base_level: 0,
)

#let thmplain = thmbox.with(
  padding: (y: 0em), breakable: true,
  namefmt: name => emph([(#name)]),
  titlefmt: emph
)

#let thmproof = thmplain.with(
  namefmt: emph,
  bodyfmt: proof-bodyfmt
)

#let theorem = thmbox("theorem", "Theorem")
#let lemma = thmbox("theorem", "Lemma")

#let corollary = thmbox(
  "corollary", 
  "Corollary",
  base: "theorem",
  base_level: 1
).with(numbering: "1.1")

#let proof = thmproof("proof", "Proof").with(numbering: none)