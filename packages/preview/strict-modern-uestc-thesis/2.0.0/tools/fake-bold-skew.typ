// https://csimide.github.io/cuti-docs/zh-CN/
#import "@preview/cuti:0.3.0": show-cn-fakebold

#let regex-fakeitalic(reg-exp: ".+?", ang: -18.4deg, s) = {
  show regex(reg-exp): it => {
    box(skew(ax: ang, reflow: false, text(bottom-edge: 0pt)[#it]))
  }
  s
}

#let fakeitalic(
  ang: -18.4deg,
  s,
) = regex-fakeitalic(
  reg-exp: "[\p{script=Han}！-･〇-〰—]+",
  ang: ang,
  s,
)

#let set-font(info, body) = {
  show: show-cn-fakebold.with()
  show emph: it => fakeitalic(it)
  body
}
