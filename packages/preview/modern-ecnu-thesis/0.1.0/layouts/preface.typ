#import "@preview/anti-matter:0.1.1": anti-matter, core
#import "../utils/style.typ": 字号

// 前言，重置页面计数器
#let preface(
  doctype: "master",
  // documentclass 传入的参数
  twoside: false,
  // 其他参数
  numbering: ("I", "1", "I"),
  ..args,
  it,
) = {
  set page(footer: context {
    set text(size: 字号.五号)
    let p = core.outer-counter().get().at(0)
    if doctype == "bachelor" {
      align(center)[
        #core.outer-counter().display("I")
      ]
    } else if twoside == true {
      align(right)[
        #core.outer-counter().display("I")
      ]
    } else {
      if calc.rem(p, 2) == 1 {
        h(1fr)
        core.outer-counter().display("I")
      } else {
        core.outer-counter().display("I")
        h(1fr)
      }
    }
  })
  anti-matter(numbering: numbering, ..args, it)
}