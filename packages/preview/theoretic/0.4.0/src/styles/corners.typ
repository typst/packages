#import "../base.typ" as __
// if you write your own style, import "@preview/theoretic:.." here instead.

// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: [This style is almost identical to the `basic` one, it just wraps the environments in a block with corners. Note the added `color` option.],
  options: __._defaults.plain.keys() + ("color",),
  variants: __._defaults.keys() + ("proof",),
)

#let show-theorem(it) = {
  it.options = __.fill-options(it.options, variant: it.variant)
  let color = it.options.at("color", default: black)
  if it.variant == "important" {
    it.options.block-args = (..it.options.block-args, stroke: 0.5pt + color)
    // don’t bother adding corners if it is framed
    __.show-theorem(it)
  } else {
    block(
      width: 100%,
      breakable: true,
      {
        place(
          top + left,
          dx: -4pt,
          dy: -4pt,
          curve(
            stroke: 0.5pt + color,
            curve.move((1em, 0pt)),
            curve.line((0pt, 0pt)),
            curve.line((0pt, 1em)),
          ),
        )
        __.show-theorem(it)
        place(
          bottom + right,
          dx: 4pt,
          dy: 4pt,
          curve(
            stroke: 0.5pt + color,
            curve.move((-1em, 0pt)),
            curve.line((0pt, 0pt)),
            curve.line((0pt, -1em)),
          ),
        )
      },
    )
  }
}

#let theorem = __.theorem.with(show-theorem: show-theorem)
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
