#import "../utils/anti-matter.typ": anti-matter

// 前言，重置页面计数器
#let preface(
  // documentclass 传入的参数
  twoside: false,
  // 其他参数
  spec: (front: "I", inner: "1", back: "I"),
  ..args,
  it,
) = {
  // 分页
  if (twoside) {
    pagebreak() + " "
  }
  counter(page).update(0)
  anti-matter(spec: spec, ..args, it)
}