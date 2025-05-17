#import "../utils/custom-numbering.typ": custom-numbering

#import "../imports.typ": i-figured

#let back-matter(
  // options
  heading-numbering: custom-numbering.with(first-level: "", depth: 4, "1.1 "),
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "1.1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(1.1)"),
  // 重置计数
  reset-counter: false,
  // self
  it,
) = {
  set heading(numbering: heading-numbering)
  if reset-counter { counter(heading).update(0) }
  // 设置 figure 的编号
  show figure: show-figure
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation

  it
}
