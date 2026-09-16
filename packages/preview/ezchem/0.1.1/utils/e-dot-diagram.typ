#import "@preview/cetz:0.4.2"

#let deault-elements = (
  top: "",
  bottom: "",
  left: "",
  right: "",
  center: "",
)
#let default-dots = (
  tl: ".",
  tr: ".",
  tc: ".",
  bl: ".",
  br: ".",
  bc: ".",
  lt: ".",
  lb: ".",
  lc: ".",
  rt: ".",
  rb: ".",
  rc: ".",
)
// 电子式
#let e-dot-diagram(
  elements: deault-elements,
  dots: default-dots,
  charge: 0,
) = {
  let (center, left, right, bottom, top) = deault-elements + elements
  let (tl, tr, bl, br, lt, lb, rt, rb) = default-dots + dots
  // 电荷的处理
  // let _charge = if charge > 0 { super[#if charge == 1 [+] else [#charge+]] } else if charge < 0 {
  //   super[#if charge == -1 { sym.minus } else [#calc.abs(charge)#sym.minus]]
  // }

  // 生成电子结构
  let res = box(baseline: 40.5%)[
    #cetz.canvas({
      import cetz.draw: *

      rect((0, 0), (.45, .45), name: "rect", stroke: none)
      content("rect")[#center]

      set-style(fill: black, radius: 0.02)
      // 上方的点
      circle((.15, 0.45))
      circle((.15 * 2, 0.45))
      content((.225, 0.68))[#top]

      // 下方的点
      circle((.15, 0))
      circle((.15 * 2, 0))
      content((.225, -.22))[#bottom]

      // 左侧的点
      circle((0, .15))
      circle((0, .15 * 2))
      content((-.2, 0.225))[#left]

      // 右侧的点
      circle((0.45, .15))
      circle((0.45, .15 * 2))
      content((.65, 0.225))[#right]
    })]

  res
  // if with-paren {
  //   "[" + left + res + right + "]" + _charge
  // } else [#left#res#right#_charge]
  // left + h(1pt) + res + h(1pt) + right
}


// [#e-dot-diagram(
//   elements: (
//     center: "H",
//     left: "H",
//     right: "H",
//     bottom: "H",
//     top: "H",
//   ),
//   charge: 1,
// )]#super[+]


