
// NOTE: -- A collection of arrows
#let aR = text(font: "New Computer Modern", size: 1.5em)[#h(1em)#sym.arrow.r#h(1em)]
#let ar = text(font: "New Computer Modern", size: 1em)[#sym.arrow.r]
#let al = text(font: "New Computer Modern")[#sym.arrow.l]
#let au = text(font: "New Computer Modern")[#sym.arrow.t]
#let ad = text(font: "New Computer Modern")[#sym.arrow.b]
#let aud = text(font: "New Computer Modern")[#sym.arrow.t.b]
#let alr = text(font: "New Computer Modern")[#sym.arrow.l.r]
#let asr = text(font: "New Computer Modern")[#sym.arrow.r.squiggly]
#let asl = text(font: "New Computer Modern")[#sym.arrow.l.squiggly]

// NOTE: -- Function for context underline
#let blank(width: 2em) = box(
  width: width,
  height: 0.8em,
  baseline: 50%,
  stroke: (bottom: 0.5pt + black),
)

// NOTE: Extrametricality
#let extra(content) = [⟨#content⟩]

