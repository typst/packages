#import "../base.typ" as __
// if you write your own style, `#import "@preview/theoretic:.." as __` here instead.

#let _badge(title, color: oklch(70%, 0, 0deg)) = {
  let (l, c, h, _) = oklch(color).components()
  box(
    fill: std.color.mix(
      (oklch(70%, calc.clamp(c, 0, 0.2), h), 20%),
      (white, 80%),
      // space: oklch,
    ),
    outset: (y: 4.25pt),
    inset: (x: 2pt),
    radius: 2pt,
    text(
      fill: oklch(calc.clamp(float(l), 0.3, 0.5) * 100%, calc.clamp(c, 0, 0.25), h),
      weight: "semibold",
      title,
    ),
  )
}

#let _defaults = (
  plain: (
    color: oklch(70%, 0, 0deg),
    head-font: (style: "normal", stretch: 85%, weight: "semibold"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, spacing: 1.4em),
    link: none,
  ),
  important: (
    color: oklch(70%, 0, 0deg),
    head-font: (style: "normal", stretch: 85%, weight: "semibold"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, spacing: 1.4em),
    link: none,
  ),
  muted: (
    color: oklch(70%, 0, 0deg),
    head-font: (style: "normal", stretch: 85%, weight: "regular", fill: luma(40%)),
    body-font: (style: "normal", weight: "regular", fill: luma(40%)),
    block-args: (width: 100%, breakable: true, spacing: 1.4em),
    link: none,
  ),
  remark: (
    color: oklch(70%, 0, 0deg),
    head-font: (style: "normal", stretch: 85%, weight: "regular"),
    body-font: (style: "italic", weight: "regular"),
    block-args: (width: 100%, breakable: true, spacing: 1.4em),
    link: none,
  ),
)

#let show-theorem(it) = {
  it.options = __.fill-options(it.options, variant: it.variant, _defaults: _defaults)

  let color = if it.variant == "muted" or it.variant == "remark" {
    oklch(44.67%, 0, 0deg)
  } else {
    it.options.color
  }

  let stroke = {
    let (l, c, h, _) = oklch(color).components()
    0.5pt + oklch(calc.clamp(float(l), 0.3, 0.5) * 100%, calc.clamp(c, 0, 0.2), h)
  }
  block(
    ..it.options.block-args,
    stroke: (left: stroke),
    outset: (left: 4pt, right: 0pt, y: 4pt),
    {
      box(
        stroke: (top: if it.variant == "important" { stroke }),
        outset: (left: 4pt, right: if it.title != none { 1pt } else { 4pt }, y: 3.9pt),
        {
          set text(..it.options.head-font)
          it.supplement
          if it.number != none [ #it.number]
        },
      )
      if it.title != none {
        h(2pt)
        _badge(it.title, color: color)
        h(-2pt)
      }
      h(1em)
      set text(..it.options.body-font)
      it.body
    },
  )
}

#let theorem = __.theorem.with(
  show-theorem: show-theorem,
  variant: "important",
  options: (color: oklch(70%, 0.15, 307.4deg)),
)
#let proposition = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 255.8deg)),
  supplement: "Proposition",
  kind: "proposition",
)
#let lemma = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 255.8deg)),
  supplement: "Lemma",
  kind: "lemma",
)
#let corollary = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 255.8deg)),
  supplement: "Corollary",
  kind: "corollary",
)
#let algorithm = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 142.5deg)),
  supplement: "Algorithm",
  kind: "algorithm",
)
#let axiom = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 142.5deg)),
  supplement: "Axiom",
  kind: "axiom",
)

#let definition = theorem.with(
  variant: "important",
  options: (color: oklch(70%, 0.15, 142.5deg)),
  supplement: "Definition",
  kind: "definition",
)
#let exercise = theorem.with(
  variant: "plain",
  options: (color: oklch(70%, 0.15, 1deg)),
  supplement: "Exercise",
  kind: "exercise",
)

#let example = theorem.with(
  variant: "muted",
  supplement: "Example",
  kind: "example",
)
#let counter-example = example.with(supplement: "Counter-Example")

#let remark = theorem.with(variant: "remark", supplement: "Remark", kind: "remark", number: none)
#let note = theorem.with(variant: "remark", supplement: "Note", kind: "note", number: none)
#let claim = theorem.with(
  variant: "plain",
  options: (color: oklch(70%, 0.15, 50deg)),
  supplement: "Claim",
  kind: "claim",
  number: none,
)

#let proof = __.proof

#let QED = {
  h(1em)
  $square$
}
#let QED-BOLT = {
  h(1em)
  [$limits(square)^arrow.zigzag$]
}

#let qed = __.qed
#let qed-in-equation = __.qed-in-equation

#let proof = __.proof.with(
  options: (
    variant: "proof",
    head-punct: [.],
    head-sep: h(1em),
    block-args: (inset: (left: 1em, right: 0pt, y: 0pt)),
  ),
  suffix: QED,
  supplement: "Proof",
  kind: "proof",
  number: none,
)


// `_meta` is only used for the documentation, and can be omitted for custom styles.
#let _meta = (
  description: [
    This style is intended#footnote[It still looks okay in other fonts, but it does not reach full potential. Compare: #h(8pt) #box(width: 6cm, lemma(toctitle: none)[Lorem][ipsum.])] for use with a font that supports `stretch: 85%` and `weight: "semibold"`. It is here shown using the _Besley\*_ font, #link("https://github.com/indestructible-type/Besley/tree/master/fonts/ttf")[which you can download on GitHub].
    //
    // This style ignores most `options`, except for a new `hue` option to set the `oklch` hue.
    // The `variant` can be "muted", "remark", "plain", or "important".
  ],
  options: _defaults.plain.keys(),
  variants: _defaults.keys(),
)
