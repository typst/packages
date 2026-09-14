#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly

// 后记，重置 heading 计数器
#let appendix(
  numbering: numbly(none, "{1:A}.{2}", "{1:A}.{2}.{3}", "{1:A}.{2}.{3}.{4}"),
  figure-equation-numbering: auto,
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "1.1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(1.1)"),
  // 重置计数
  reset-counter: false,
  it,
) = {
  if figure-equation-numbering == auto {
    figure-equation-numbering = numbering
  }

  counter(heading).update(0)
  set heading(numbering: numbering)
  if reset-counter {
    counter(heading).update(0)
  }
  // 设置 figure 的编号
  show figure: show-figure.with(numbering: figure-equation-numbering)
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation.with(
    numbering: (..args) => "(" + figure-equation-numbering(..args) + ")",
  )
  it
}
