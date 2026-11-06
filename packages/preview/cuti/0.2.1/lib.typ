#let fakebold(base-weight: none, s, ..params) = {
  set text(weight: base-weight) if base-weight != none
  set text(..params) if params != ()
  context {
    set text(stroke: 0.02857em + text.fill)
    s
  }
}

#let regex-fakebold(reg-exp: ".", base-weight: none, s, ..params) = {
  show regex(reg-exp): it => {
    fakebold(base-weight: base-weight, it, ..params)
  }
  s
}

#let show-fakebold(reg-exp: ".", base-weight: none, s, ..params) = {
  show text.where(weight: "bold").or(strong): it => {
    regex-fakebold(reg-exp: reg-exp, base-weight: base-weight, it, ..params)
  }
  s
}

#let cn-fakebold(s, ..params) = {
  regex-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]", base-weight: "regular", s, ..params)
}

#let show-cn-fakebold(s, ..params) = {
  show-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]", base-weight: "regular", s, ..params)
}


// https://github.com/typst/typst/issues/2749
#let _skew(angle, vscale: 1, body) = {
  let (a, b, c, d)= (1, vscale*calc.tan(angle), 0, vscale)
  let E = (a + d)/2
  let F = (a - d)/2
  let G = (b + c)/2
  let H = (c - b)/2
  let Q = calc.sqrt(E*E + H*H)
  let R = calc.sqrt(F*F + G*G)
  let sx = Q + R
  let sy = Q - R
  let a1 = calc.atan2(F,G)
  let a2 = calc.atan2(E,H)
  let theta = (a2 - a1) /2
  let phi = (a2 + a1)/2
  
  set rotate(origin: bottom+center)
  set scale(origin: bottom+center)
  
  rotate(phi, scale(x: sx * 100%, y: sy * 100%, rotate(theta, body)))
}

#let regex-fakeitalic(reg-exp: ".", ang: -0.32175, spacing: none, s) = {
  show regex(reg-exp): it => {
    box(place(_skew(ang, it)), baseline: -0.7em) + hide(it)
  }
  s
  if spacing != none {h(spacing)}
}

#let fakeitalic(ang: -0.32175, s) = regex-fakeitalic(reg-exp: "[^ ]", ang: ang, s)
