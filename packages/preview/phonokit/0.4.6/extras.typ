
// NOTE: -- A collection of arrows
#let a-r-large = text(font: "New Computer Modern", size: 1.5em)[#h(1em)#sym.arrow.r#h(1em)]
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

// NOTE: -- Greek symbols (upright, for phonological notation)
#let alpha = sym.alpha
#let beta = sym.beta
#let gamma = sym.gamma
#let delta = sym.delta
#let lambda = sym.lambda
#let mu = sym.mu
#let phi = sym.phi
#let pi = sym.pi
#let sigma = sym.sigma
#let tau = sym.tau
#let omega = sym.omega
#let cap-phi = sym.Phi
#let cap-sigma = sym.Sigma
#let cap-omega = sym.Omega

// NOTE: Extrametricality
#let extra(content) = [⟨#content⟩]

