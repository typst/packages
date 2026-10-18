#import "../base.typ" as __
// if you write your own style, import "@preview/theoretic:.." here instead.

#let _defaults = (
  plain: (
    head-font: (style: "normal", weight: "bold"),
    number-font: (style: "normal", weight: "regular"),
    title-font: (style: "italic", weight: "regular"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true),
    grid-args: (columns: (1fr, 3fr), gutter: 1em),
    head-punct: [],
    link: none,
  ),
  important: (
    head-font: (style: "normal", weight: "bold"),
    number-font: (style: "normal", weight: "regular"),
    title-font: (style: "italic", weight: "regular"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, outset: 4pt, stroke: 0.5pt),
    grid-args: (columns: (1fr, 3fr), gutter: 1em),
    head-punct: [],
    link: none,
  ),
  remark: (
    head-font: (style: "normal", weight: "bold"),
    number-font: (style: "normal", weight: "regular"),
    title-font: (style: "italic", weight: "regular"),
    body-font: (style: "italic", weight: "regular"),
    block-args: (width: 100%, breakable: true),
    grid-args: (columns: (1fr, 3fr), gutter: 1em),
    head-punct: [],
    link: none,
  ),
)


// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: none,
  options: _defaults.plain.keys(),
  variants: _defaults.keys() + ("proof",),
)

#let show-theorem(it) = {
  it.options = __.fill-options(it.options, variant: it.variant, _defaults: _defaults)
  block(
    ..it.options.block-args,
    grid(
      ..it.options.grid-args,
      block(
        breakable: false,
        stack(
          spacing: 0.4em,
          text(
            ..it.options.head-font,
            {
              if it.options.link != none {
                link(
                  it.options.link,
                  it.supplement,
                )
              } else {
                it.supplement
              }
              it.options.head-punct
            },
          ),
          if it.number != none { text(..it.options.number-font, it.number) } else { v(0.5em) },
          if it.title != none { text(..it.options.title-font, style: "italic", it.title) } else { v(0em) },
        ),
      ),
      {
        text(..it.options.body-font, it.body)
      },
    ),
  )
}

#let theorem = __.theorem.with(show-theorem: show-theorem)
#let proposition = theorem.with(supplement: "Proposition", kind: "proposition")
#let lemma = theorem.with(supplement: "Lemma", kind: "lemma")
#let corollary = theorem.with(supplement: "Corollary", kind: "corollary")
#let algorithm = theorem.with(supplement: "Algorithm", kind: "algorithm")
#let axiom = theorem.with(supplement: "Axiom", kind: "axiom")

#let definition = theorem.with(supplement: "Definition", kind: "definition")
#let exercise = theorem.with(supplement: "Exercise", kind: "exercise")

#let example = theorem.with(supplement: "Example", kind: "example", number: none)
#let counter-example = example.with(supplement: "Counter-Example")

#let remark = theorem.with(variant: "remark", supplement: "Remark", kind: "remark", number: none)
#let note = theorem.with(variant: "remark", supplement: "Note", kind: "note", number: none)
#let claim = theorem.with(variant: "remark", supplement: "Claim", kind: "claim", number: none)

#let qed = __.qed
#let qed-in-equation = __.qed-in-equation

#let proof = __.proof
