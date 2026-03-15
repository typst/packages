// 前言，重置页面计数器
#let preface(
  // documentclass 传入的参数
  twoside: false,
  ..args,
  it,
) = {
  // 分页
  if twoside {
    pagebreak() + " "
  }
  counter(page).update(0)
  set page(numbering: "I")
  it
}