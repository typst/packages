// Minimal inline marks. (The woven tile/emblem of the original were dropped in
// favour of a cleaner STEM look.)
#import "colors.typ": *
#import "fonts.typ": default-fonts

// a small solid square — used as the proof end-mark (qed), and anywhere a tiny
// coloured accent is wanted. Takes an explicit colour.
#let mark(c, size: 6pt) = box(
  baseline: 1pt,
  rect(width: size, height: size, fill: c, stroke: none, radius: 0.5pt),
)

// a small inline label / badge — bold sans in the theme's tag colour. The default
// style for theorem tags (source, claim-ID), and usable anywhere: `label-it[GSM 211]`.
#let label-it(t) = context text(
  font: default-fonts.sans, size: 8pt, weight: "bold", fill: active.get().tag,
)[#t]
