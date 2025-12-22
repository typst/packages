
// NOTE: -- A collection of arrows
#let a-R = text(font: "New Computer Modern", size: 1.5em)[#h(1em)#sym.arrow.r#h(1em)]
#let a-r = text(font: "New Computer Modern", size: 1em)[#sym.arrow.r]
#let a-l = text(font: "New Computer Modern")[#sym.arrow.l]
#let a-u = text(font: "New Computer Modern")[#sym.arrow.t]
#let a-d = text(font: "New Computer Modern")[#sym.arrow.b]
#let a-ud = text(font: "New Computer Modern")[#sym.arrow.t.b]
#let a-lr = text(font: "New Computer Modern")[#sym.arrow.l.r]
#let a-sr = text(font: "New Computer Modern")[#sym.arrow.r.squiggly]
#let a-sl = text(font: "New Computer Modern")[#sym.arrow.l.squiggly]

// NOTE: -- Function for context underline
#let blank(width: 2em) = box(
  width: width,
  height: 0.8em,
  baseline: 50%,
  stroke: (bottom: 0.5pt + black),
)

// NOTE: Extrametricality
#let extra(content) = [⟨#content⟩]

