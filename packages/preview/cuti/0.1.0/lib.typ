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