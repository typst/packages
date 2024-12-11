/**
 * logo.typ
 */

#let letter(baseline: 0pt, size, body) = text(
  size: size,
  baseline: baseline,
  top-edge: "cap-height",
  bottom-edge: "baseline",
  body)

#let kern(length) = h(length, weak: true)
#let TeX =  context {
  let e = measure(letter(10pt, "E"))
  let T = "T"
  let E = text(baseline: 2 * e.height / 6, "E")
  let X = "X"
  box(T + kern(-0.1667em) + E + kern(-0.125em) + X)
}
#let LaTeX = context {
  let l = measure(letter(10pt, "L"))
  let a = measure(letter(7pt, "A"))
  let L = "L"
  let A = text(7pt, baseline: a.height - l.height, "A")
  box(L + kern(-0.36em) + A + kern(-0.15em) + TeX)
}
#let LaTeX2e = context {
  let e = text(baseline: 0.0em, $epsilon$)
  box(LaTeX + sym.space.sixth + [2] + e)
}
