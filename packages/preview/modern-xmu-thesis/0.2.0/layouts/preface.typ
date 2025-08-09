#import "../utils/style.typ": 字号, 字体

#let preface(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  // 其他参数
  ..args,
  it,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts

  // 2.  分页
  if twoside {
    pagebreak() + " "
  }

  // 3.  处理页脚
  counter(page).update(0)
  set page(footer: context {
    set text(font: fonts.宋体, size: 字号.小五)
    align(center, counter(page).display("I"))
  })
  it
}
