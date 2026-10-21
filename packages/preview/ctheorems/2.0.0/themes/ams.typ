#import "../src/thm.typ": thm, thm-fmt-block, proof-body-fmt

/// Set of theorem environments, styled in the manner of `amsthm`.

#let thm = thm.with(
  fmt: thm-fmt-block.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: emph,
    separator: [*.* ]
  )
)

#let thm-def = thm.with(
  fmt: thm-fmt-block.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: x => x,
    separator: [*.* ]
  )
)

#let thm-rem = thm.with(
  numbering: none,
  fmt: thm-fmt-block.with(
    name-fmt: name => emph([(#name)]),
    title-fmt: emph,
    body-fmt: x => x,
    separator: [. ]
  )
)


#let theorem = thm.with(
  supplement: "Theorem",
  counter: "Theorem"
)
#let proposition = thm.with(
  supplement: "Proposition",
  counter: "Theorem"
)
#let lemma = thm.with(
  supplement: "Lemma",
  counter: "Theorem"
)
#let conjecture = thm.with(
  supplement: "Conjecture",
  counter: "Theorem"
)

#let corollary = thm.with(
  supplement: "Corollary",
  counter: "Sub-Theorem",
  base: "Theorem"
)

#let definition = thm-def.with(
  supplement: "Definition",
  counter: "Theorem"
)
#let example = thm-def.with(
  supplement: "Example",
  counter: "Sub-Theorem",
  base: "Theorem"
)

#let problem = thm-def.with(
  supplement: "Problem",
  counter: "Problem"
)

#let remark = thm-rem.with(
  supplement: "Remark",
)
#let claim = thm-rem.with(
  supplement: "Claim"
)

#let proof = thm.with(
  supplement: "Proof",
  numbering: none,
  fmt: thm-fmt-block.with(
    name-fmt: emph,
    title-fmt: emph,
    body-fmt: proof-body-fmt,
    separator: [. ]
  )
)
