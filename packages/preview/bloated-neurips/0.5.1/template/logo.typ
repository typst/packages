#let kern(length) = h(length, weak: true)
#let TeX = style(styles => {
  let e = measure(text("E"), styles)
  let T = "T"
  let E = text(baseline: e.height / 2, "E")
  let X = "X"
  box(T + kern(-0.1667em) + E + kern(-0.125em) + X)
})
#let LaTeX = style(styles => {
  let l = measure(text(10pt, "L"), styles)
  let a = measure(text(7pt, "A"), styles)
  let L = "L"
  let A = text(7pt, baseline: a.height - l.height, "A")
  box(L + kern(-0.36em) + A + kern(-0.15em) + TeX)
})
#let LaTeXe = style(styles => {
  box(LaTeX + sym.space.sixth + [2#text(baseline: 0.3em, $epsilon$)])
})
