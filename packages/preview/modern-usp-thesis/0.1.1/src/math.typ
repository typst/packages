#import "@preview/ctheorems:2.0.0"
#import ctheorems: qedhere

// Subscripts go underneath in display math, as for lim and max.
#let argmax = math.op("argmax", limits: true)
#let argmin = math.op("argmin", limits: true)
#let bm(x) = math.bold(x)
#let tr = math.op("tr")
#let diag = math.op("diag")
#let Cov = math.op("Cov")
#let Var = math.op("Var")
#let EE = math.bb("E")
#let RR = math.bb("R")

// Theorem environments setup
#let thm-rules(body) = {
  show: ctheorems.thm-rules
  body
}

// Boxed environments (theorem, lemma, definition) and plain ones
// (corollary, proof), with vertical padding around the boxed ones.
#let _thm-fmt(padding: (top: 0em, bottom: 0em), ..args) = thm => pad(
  ..padding,
  ctheorems.thm-fmt-block(thm, ..args),
)
#let _boxed = _thm-fmt(
  padding: (top: 0.5em, bottom: 0.5em),
  block-args: (inset: 1.2em, radius: 0.3em, breakable: false),
  body-fmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
)
#let _plain(..args) = _thm-fmt(
  block-args: (inset: (top: 0em, left: 1.2em, right: 1.2em), breakable: true),
  name-fmt: name => emph[(#name)],
  body-fmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  ..args,
)

#let _theorem = ctheorems.thm.with(counter: "theorem", fmt: _boxed, fill: rgb("#eeeeeef0"))
#let _lemma = ctheorems.thm.with(counter: "lemma", fmt: _boxed, fill: rgb("#eeeeeef0"))
#let _corollary = ctheorems.thm.with(counter: "corollary", base: "theorem", fmt: _plain(title-fmt: strong))
#let _definition = ctheorems.thm.with(counter: "definition", fmt: _boxed, inset: (x: 1.2em, y: 1em))
#let _proof = ctheorems.thm.with(
  counter: "proof",
  numbering: none,
  fmt: _plain(title-fmt: emph, name-fmt: emph, body-fmt: ctheorems.proof-body-fmt),
)

#let theorem = _theorem.with(supplement: "Teorema")
#let lemma = _lemma.with(supplement: "Lema")
#let corollary = _corollary.with(supplement: "Corolário")
#let definition = _definition.with(supplement: "Definição")
#let proof = _proof.with(supplement: "Prova")

// English aliases
#let en-theorem = _theorem.with(supplement: "Theorem")
#let en-lemma = _lemma.with(supplement: "Lemma")
#let en-corollary = _corollary.with(supplement: "Corollary")
#let en-definition = _definition.with(supplement: "Definition")
#let en-proof = _proof.with(supplement: "Proof")
