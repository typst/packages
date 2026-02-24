#import "../base.typ" as __
// if you write your own style, `#import "@preview/theoretic:.." as __` here instead.


// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: none,
  options: ("head-font", "link", "color"),
  variants: ("plain", "important"),
)

#let show-theorem(it) = {
  it.options = __.fill-options(it.options, variant: it.variant)
  let color = it.options.at("color", default: oklch(60%, 0.2, 20deg))
  block(
    width: 100%,
    stroke: (left: 3pt + color),
    inset: (left: 1em + 3pt, right: if it.variant == "important" { 3pt } else { 0pt }, y: 0.6em),
    outset: (left: -3pt),
    fill: if it.variant == "important" { oklch(95%, 0.02, oklch(color).components().at(2)) },
    spacing: 1.2em,
    {
      block(
        width: 100%,
        above: 0em,
        below: 0.8em,
        sticky: true,
        {
          text(
            weight: "bold",
            fill: color,
            ..it.options.head-font,
            {
              if it.options.link != none {
                link(
                  it.options.link,
                  {
                    it.supplement
                    if it.number != none [ #it.number]
                  },
                )
              } else {
                it.supplement
                if it.number != none [ #it.number]
              }
              h(1fr)
              if it.title != none {
                it.title
              }
            },
          )
        },
      )
      it.body
    },
  )
}

#let theorem = __.theorem.with(
  show-theorem: show-theorem,
  options: (color: oklch(60%, 0.2, 20deg)),
  supplement: "Theorem",
  kind: "theorem",
)
#let proposition = theorem.with(
  options: (color: oklch(60%, 0.15, 265deg)),
  supplement: "Proposition",
  kind: "proposition",
)
#let lemma = theorem.with(options: (color: oklch(60%, 0.1, 175deg)), supplement: "Lemma", kind: "lemma")
#let corollary = theorem.with(options: (color: oklch(60%, 0.2, 323deg)), supplement: "Corollary", kind: "corollary")
#let definition = theorem.with(options: (color: oklch(65%, 0.15, 52deg)), supplement: "Definition", kind: "definition")
#let exercise = theorem.with(options: (color: oklch(65%, 0.15, 250deg)), supplement: "Exercise", kind: "exercise")
#let algorithm = theorem.with(options: (color: oklch(50%, 0.15, 310deg)), supplement: "Algorithm", kind: "algorithm")
#let axiom = theorem.with(options: (color: oklch(65%, 0.1, 235deg)), supplement: "Axiom", kind: "axiom")

#let example = theorem.with(
  options: (color: oklch(65%, 0.15, 131deg)),
  supplement: "Example",
  kind: "example",
  number: none,
)
#let counter-example = example.with(supplement: "Counter-Example")

#let remark = theorem.with(options: (color: oklch(65%, 0, 0deg)), supplement: "Remark", kind: "remark", number: none)
#let note = theorem.with(options: (color: oklch(60%, 0.1, 195deg)), supplement: "Note", kind: "note", number: none)
#let claim = theorem.with(options: (color: oklch(60%, 0.15, 145deg)), supplement: "Claim", kind: "claim", number: none)

#let qed = __.qed
#let qed-in-equation = __.qed-in-equation

#let proof = __.proof.with(
  variant: "proof",
  options: (
    head-punct: [:],
    head-sep: h(0.5em),
    block-args: (inset: (left: 1em + 3pt, right: 0pt, y: 0pt)),
  ),
  supplement: "Proof",
  kind: "proof",
  number: none,
)
