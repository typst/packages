#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly

// 后记，重置 heading 计数器
#let appendix(
  numbering: numbly(
    "附录{1:A}. ",
    "{1:A}.{2} ",
    "{1:A}.{2}.{3} ",
    "{1:A}.{2}.{3}.{4} ",
    "{1:A}.{2}.{3}.{4}.{5} ",
    "{1:A}.{2}.{3}.{4}.{5}.{6} ",
  ),
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "A-1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(A-1)"),
  // 重置计数
  reset-counter: true,
  it,
) = {
  set heading(numbering: numbering)
  if reset-counter {
    counter(heading).update(0)
  }
  // 设置 figure 的编号
  show figure: show-figure
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  it
}