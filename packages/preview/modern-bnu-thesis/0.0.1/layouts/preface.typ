#import "@preview/anti-matter:0.0.2": anti-matter

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
    pagebreak(weak: true) + " "
    counter(page).update(0)
  }else{
    counter(page).update(1)
  }
  
  anti-matter(spec: spec, ..args, it)
}