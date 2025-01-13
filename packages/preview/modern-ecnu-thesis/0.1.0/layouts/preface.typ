#import "../utils/style.typ": 字号

// 前言，重置页面计数器
#let preface(
  doctype: "master",
  // documentclass 传入的参数
  twoside: false,
  ..args,
  it,
) = {
  counter(page).update(0)
  set page(footer: context {
    set text(size: 字号.五号)
    let p = counter(page).get().at(0)
    let pagealign = center
    if doctype == "bachelor" {
      pagealign = center
    } else if twoside == true {
      let preal = here().position().page
      if calc.rem(preal, 2) == 1 {
        pagealign = right
      } else {
        pagealign = left
      }
    } else {
      if calc.rem(p, 2) == 1 {
        pagealign = right
      } else {
        pagealign = left
      }
    }
    align(pagealign, counter(page).display("I"))
  })
  set par(linebreaks: "optimized")
  it
}