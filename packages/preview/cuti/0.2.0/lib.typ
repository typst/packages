#let fakebold(base-weight: none, s) = {
  set text(stroke: 0.02857em)
  set text(weight: base-weight) if base-weight != none
  s
}

#let regex-fakebold(reg-exp: ".", base-weight: none, s) = {
  show regex(reg-exp): it => {
    fakebold(base-weight: base-weight, it)
  }
  s
}

#let show-fakebold(reg-exp: ".", base-weight: none, s) = {
  show text.where(weight: "bold").or(strong): it => {
    regex-fakebold(reg-exp: reg-exp, base-weight: base-weight, it)
  }
  s
}

#let cn-fakebold(s) = {
  regex-fakebold(reg-exp: "[\p{script=Han} ！-･〇-〰—]", base-weight: "regular", s)
}

#let show-cn-fakebold(s) = {
  show-fakebold(reg-exp: "[\p{script=Han} ！-･〇-〰—]", base-weight: "regular", s)
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
  
  box(rotate(phi, scale(x: sx*100%, y: sy*100%, rotate(theta, body))))
}

#let regex-fakeitalic(reg-exp: "[^ ]", ang: -0.32175, spacing: none, s) = {
  show regex(reg-exp): _skew.with(ang)
  s
  if spacing != none {h(spacing)}
}

#let fakeitalic(ang: -0.32175, s) = regex-fakeitalic(reg-exp: "[^ ]", ang: ang, s)
