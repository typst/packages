#import "@preview/i-figured:0.2.4"
#import "../utils/custom-numbering.typ": custom-numbering

// 后记，重置 heading 计数器
#let appendix(
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "1-1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(1-1)"),
  // 重置计数
  reset-counter: true,
  title: "附录",
  it,
) = {
  set heading(
    numbering: (..ns) => {
      let ns = ns.pos()
      if ns.len() == 1 {
        return [] 
      } else if ns.len() == 2 {
        return numbering("附录1", ns.at(1)) 
      } else {
        return numbering("1.1", ..ns.slice(1))
      }
    },
  )
  set outline(depth: 1)

  if reset-counter {
    counter(heading).update(0)
  }
  [
    = #title
  ]
  // 设置标题的样式
  set heading(offset: 1)
  // 设置 figure 的编号
  show figure: show-figure
  // 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  it
}
