// 中文缩进
#let indent = h(2em)

// 假段落，附着于 heading 之后可以实现首行缩进
// #let empty-par = par[#box()]
#let fake-par = context {
  let b = par(box())
  b
  v(-measure(b + b).height)
}