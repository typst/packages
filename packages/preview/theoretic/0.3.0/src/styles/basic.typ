#import "../base.typ" as __
// if you write your own style, import "@preview/theoretic:.." here instead.

// Uses built-in defaults.

// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: [This style uses the built-in #raw(lang: "typ", "#theoretic.show-theorem()"); and accepts all its `options`.],
  options: __._defaults.plain.keys(),
  variants: __._defaults.keys() + ("proof",),
)

#let theorem = __.theorem.with()
#let proposition = theorem.with(supplement: "Proposition", kind: "proposition")
#let lemma = theorem.with(supplement: "Lemma", kind: "lemma")
#let corollary = theorem.with(supplement: "Corollary", kind: "corollary")
#let algorithm = theorem.with(supplement: "Algorithm", kind: "algorithm")
#let axiom = theorem.with(supplement: "Axiom", kind: "axiom")

#let definition = theorem.with(variant: "definition", supplement: "Definition", kind: "definition")
#let exercise = theorem.with(variant: "definition", supplement: "Exercise", kind: "exercise")

#let example = theorem.with(variant: "definition", supplement: "Example", kind: "example", number: none)
#let counter-example = example.with(supplement: "Counter-Example")

#let remark = theorem.with(variant: "remark", supplement: "Remark", kind: "remark", number: none)
#let note = theorem.with(variant: "remark", supplement: "Note", kind: "note", number: none)
#let claim = theorem.with(variant: "remark", supplement: "Claim", kind: "claim", number: none)

#let qed = __.qed
#let qed-in-equation = __.qed-in-equation

#let proof = __.proof
