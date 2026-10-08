#import "../src/thm.typ": thm, thm-fmt-block, proof-body-fmt

/// Set of theorem environments, with stripes


/// Theorem formatting function, producing a colorful stripe on the left side.
/// Wrapper around @thm-fmt-block.
/// -> content
#let thm-fmt-stripe(
  /// -> dictionary
  thm,
  /// Arguments, passed on to @thm-fmt-block
  /// -> arguments
  ..args,
  /// Stroke of the stripe.
  /// -> stroke | none
  stripe: 2pt + black,
  /// Inset for the block.
  /// -> relative | dictionary
  inset: (x: 1.0em, y: 0.2em),
) = {
  stripe = thm.args.remove("stripe", default: stripe)
  inset  = thm.args.remove("inset",  default: inset)
  thm-fmt-block(
    thm,
    ..args,
    block-args: (
      stroke: (left: stripe),
      inset: inset
    ),
  )
}

#let thm = thm.with(
  fmt: thm-fmt-stripe.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: emph,
    separator: [*.* ]
  )
)

#let thm-def = thm.with(
  fmt: thm-fmt-stripe.with(
    name-fmt: x => [(#x)],
    title-fmt: strong,
    body-fmt: x => x,
    separator: [*.* ]
  )
)

#let thm-rem = thm.with(
  numbering: none,
  fmt: thm-fmt-stripe.with(
    name-fmt: name => emph([(#name)]),
    title-fmt: emph,
    body-fmt: x => x,
    separator: [. ]
  )
)


#let theorem = thm.with(
  supplement: "Theorem",
  counter: "Theorem",
  stripe: 2pt + olive
)
#let proposition = thm.with(
  supplement: "Proposition",
  counter: "Theorem",
  stripe: 2pt + green
)
#let lemma = thm.with(
  supplement: "Lemma",
  counter: "Theorem",
  stripe: 2pt + blue
)
#let conjecture = thm.with(
  supplement: "Conjecture",
  counter: "Theorem",
  stripe: 2pt + red
)

#let corollary = thm.with(
  supplement: "Corollary",
  counter: "Sub-Theorem",
  base: "Theorem",
  stripe: 2pt + orange
)

#let definition = thm-def.with(
  supplement: "Definition",
  counter: "Theorem",
  stripe: 2pt + eastern
)
#let example = thm-def.with(
  supplement: "Example",
  counter: "Sub-Theorem",
  base: "Theorem",
  stripe: 2pt + maroon
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
  fmt: thm-fmt-stripe.with(
    name-fmt: emph,
    title-fmt: emph,
    body-fmt: proof-body-fmt,
    separator: [. ]
  ),
  stripe: 2pt + gray
)
