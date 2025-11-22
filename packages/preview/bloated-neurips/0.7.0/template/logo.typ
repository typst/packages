#let kern(length) = h(length, weak: true)
#let TeX = context {
  let e = measure(text("E"))
  let T = "T"
  let E = text(baseline: e.height / 2, "E")
  let X = "X"
  box(T + kern(-0.1667em) + E + kern(-0.125em) + X)
}
#let LaTeX = context {
  let l = measure(text(10pt, "L"))
  let a = measure(text(7pt, "A"))
  let L = "L"
  let A = text(7pt, baseline: a.height - l.height, "A")
  box(L + kern(-0.36em) + A + kern(-0.15em) + TeX)
}
#let LaTeXe = context {
  box(LaTeX + sym.space.sixth + [2#text(baseline: 0.3em, $epsilon$)])
}
