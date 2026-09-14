// 前言，重置页面计数器
#let preface(
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
