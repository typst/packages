// 多行对齐公式：编号对齐到最后一行右侧
// 编号底部对齐由 mainmatter/appendix 的 set math.equation(number-align: bottom + end) 全局提供
// 使用方式：
// #aligned-equation[$
//   f(x) & = a x^2 + b x + c \\
//        & = a(x + b/(2a))^2 + c - b^2/(4a)
// $] <quadratic>
// 引用：@eqt:quadratic；不编号用 <->
#let aligned-equation(body) = body
