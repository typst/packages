#import "@preview/i-figured:0.2.4"
#import "../utils/custom-numbering.typ": custom-numbering

// 后记，重置 heading 计数器
#let appendix(
  numbering: custom-numbering.with(first-level: "附录A", depth: 4,),
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "A-1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(A-1)"),
  // 重置计数
  reset-counter: true,
  it,
) = {
  set heading(numbering: numbering)
  //仅显示一级标题在目录中
  set heading(outlined: false)
  show heading.where(level: 1): set heading(outlined: true)
  if reset-counter {
    counter(heading).update(0)
  }
  set par(spacing: 1.25em, leading:1.25em, first-line-indent: (amount: 2em, all:true))
  // 设置 figure 的编号
  show figure: show-figure
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  it
}