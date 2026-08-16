#import "../utils/style.typ": 字号

// 前言，重置页面计数器
#let preface(
  doctype: "master",
  // documentclass 传入的参数
  twoside: false,
  centered-page-number: true,
  ..args,
  it,
) = {
  set page(numbering: "I", footer: context {
    set text(size: 字号.五号)
    let p = counter(page).get().at(0)
    let pagealign = center
    if doctype == "bachelor" {
      pagealign = center
    } else if twoside == true {
      let preal = here().position().page
      if calc.rem(preal, 2) == 1 {
        pagealign = if (centered-page-number) { center } else { right }
      } else {
        pagealign = if (centered-page-number) { center } else { right }
      }
    } else {
      if calc.rem(p, 2) == 1 {
        pagealign = if (centered-page-number) { center } else { right }
      } else {
        pagealign = if (centered-page-number) { center } else { left }
      }
    }
    align(pagealign, counter(page).display("I"))
  })
  set par(linebreaks: "optimized")
  counter(page).update(1)
  it
}