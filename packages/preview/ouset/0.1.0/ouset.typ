/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}, 
#let overset(s, t, c: 0) = style(sty => {
  let sw = measure(s, sty).width
  let tw = measure(math.script(t), sty).width
  let dw = calc.max(tw - sw, 0pt)
  if calc.odd(c) { h(-dw/2) } // left clip for e.g. &=
  pad($attach(#s, t: #t, tr: "")$, right: dw)
  if c > 1 { h(-dw/2) } // right clip for e.g. =&
})

/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}, 
#let underset(s, b, c: 0) = style(sty => {
  let sw = measure(s, sty).width
  let bw = measure(math.script(b), sty).width
  let dw = calc.max(bw - sw, 0pt)
  if calc.odd(c) { h(-dw/2) } // left clip for e.g. &=
  pad($attach(#s, b: #b, br: "")$, right: dw)
  if c > 1 { h(-dw/2) } // right clip for e.g. =&
})

/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}, 
#let overunderset(s, t, b, c: 0) = style(sty => {
  let sw = measure(s, sty).width
  let tw = measure(math.script(t), sty).width
  let bw = measure(math.script(b), sty).width
  let dw = calc.max(calc.max(tw, bw) - sw, 0pt)
  if calc.odd(c) { h(-dw/2) } // left clip for e.g. &=
  pad($attach(#s, t: #t, tr: "", b: #b, br: "")$, right: dw)
  if c > 1 { h(-dw/2) } // right clip for e.g. =&
})