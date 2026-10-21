#import "../base.typ" as __
// if you write your own style, import "@preview/theoretic:.." here instead.

#let _defaults = (
  plain: (
    head-font: (style: "normal", weight: "bold"),
    title-font: (style: "normal", weight: "bold"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, inset: 1em, above: 2em, below: 1em, radius: 0.5em),
    head-punct: [],
    color: orange,
    icon: sym.suit.heart.stroked,
    link: none,
  ),
  remark: (
    head-font: (style: "normal", weight: "regular"),
    title-font: (style: "normal", weight: "regular"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, inset: 1em, above: 2em, below: 1em, radius: 0.5em),
    head-punct: [],
    color: orange,
    icon: sym.suit.heart.stroked,
    link: none,
  ),
)


// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: [
    This is a more flashy style. You may want to combine it with another preset to avoid emphasizing too many things, e.g. by using ```typ #example[]``` from the `basic` preset.
  ],
  options: _defaults.plain.keys(),
  variants: _defaults.keys() + ("proof",),
)

#let show-theorem(it) = {
  it.options = __.fill-options(it.options, variant: it.variant, _defaults: _defaults)
  let (l, c, h, _) = oklch(it.options.color).components()
  let color = oklch(calc.clamp(float(l), 0.2, 0.8) * 100%, calc.clamp(c, 0, 0.2), h)
  block(
    ..it.options.block-args,
    fill: std.color.mix((oklch(70%, calc.clamp(c, 0, 0.15), h), 8%), (white, 92%)),
    stroke: 1pt + color,
    {
      set text(..it.options.body-font)
      block(
        fill: if it.variant == "remark" { white } else { color },
        stroke: if it.variant == "remark" { 1pt + color },
        inset: (x: 0.75em, bottom: -0.1em, top: -1.3em),
        outset: (x: 0.25em, top: 1.8em, bottom: 0.6em),
        sticky: true,
        text(
          ..it.options.head-font,
          {
            set text(fill: white) if it.variant != "remark"
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
            if it.title != none {
              if it.variant == "proof" {
                text(..it.options.title-font)[ of #it.title]
              } else {
                text(..it.options.title-font)[ (#it.title)]
              }
            }
            it.options.head-punct
          },
        ),
      )
      it.body
      place(
        bottom + end,
        dx: 0.7em,
        dy: 0.6em,
        text(size: 0.6em, fill: color, it.options.icon),
      )
    },
  )
}

#let theorem = __.theorem.with(show-theorem: show-theorem)
#let proposition = theorem.with(
  supplement: "Proposition",
  kind: "proposition",
  options: (color: navy, icon: sym.suit.spade),
)
#let lemma = theorem.with(supplement: "Lemma", kind: "lemma")
#let corollary = theorem.with(supplement: "Corollary", kind: "corollary")
#let algorithm = theorem.with(supplement: "Algorithm", kind: "algorithm")

#let definition = theorem.with(
  supplement: "Definition",
  kind: "definition",
  options: (color: green.darken(20%), icon: sym.suit.club),
)
#let axiom = theorem.with(supplement: "Axiom", kind: "axiom", options: (color: green.darken(20%), icon: sym.suit.club))

#let exercise = theorem.with(
  variant: "remark",
  supplement: "Exercise",
  kind: "exercise",
)

#let example = theorem.with(
  variant: "remark",
  supplement: "Example",
  kind: "example",
  number: none,
  options: (color: gray, icon: sym.suit.diamond),
)
#let counter-example = example.with(supplement: "Counter-Example")

#let remark = theorem.with(
  variant: "remark",
  supplement: "Remark",
  kind: "remark",
  number: none,
  options: (color: yellow, icon: sym.suit.diamond.stroked),
)
#let note = remark.with(
  supplement: "Note",
  kind: "note",
)
#let claim = remark.with(
  supplement: "Claim",
  kind: "claim",
)

#let qed = __.qed
#let qed-in-equation = __.qed-in-equation

#let proof = __.proof
