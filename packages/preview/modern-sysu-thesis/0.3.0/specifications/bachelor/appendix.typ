// 利用 state 捕获摘要参数，并通过 context 传递给渲染函数
#import "/utils/style.typ": 字号, 字体
#import "/utils/indent.typ": fake-par

#import "@preview/numblex:0.1.1": numblex
#import "@preview/i-figured:0.2.4"

#let appendix-content = state("appendix", [
= 附录要求
对于一些不宜放在正文中的重要支撑材料，可编入毕业论文的附录中，包括某些重要的原始数据、详细数学推导、程序全文及其说明、复杂的图表、设计图纸等一系列需要补充提供的说明材料。如果毕业论文中引用的实例、数据资料，实验结果等符号较多时，为了节约篇幅，便于读者查阅，可以编写一个符号说明，注明符号代表的意义。附录的篇幅不宜太多，一般不超过正文。此项不是必需项，空缺时可以省略。
])

#let appendix(
  body
) = {
  context appendix-content.update(body)
}

#let appendix-part() = {
  // 致谢、附录内容	宋体小四号
  set text(font: 字体.宋体, size: 字号.小四)

  // 附录标题中不需要分隔中英文
  show heading: set text(cjk-latin-spacing: none)

  // 致谢、附录标题 黑体三号居中
  show heading.where(level: 1): set text(font: 字体.黑体, size: 字号.三号)

  // 目录仅展示附录章标题
  // 论文附录依次用大写字母“附录A、附录B、附录C……”表示，附录内的分级序号可采用“附A1、
  // 附A1.1、附A1.1.1”等表示，图、表、公式均依此类推为“图A1、表A1、式A1”等。
  show heading.where(level: 1): set heading(numbering: "附录A", outlined: true)
  show heading.where(level: 2): set heading(numbering: "附A1", outlined: false)
  show heading.where(level: 3): set heading(numbering: "附A1.1", outlined: false)
  show heading.where(level: 4): set heading(numbering: "附A1.1.1", outlined: false)

  show figure: i-figured.show-figure.with(numbering: "A.1")
  show math.equation: i-figured.show-equation.with(numbering: "(A.1)")

  // 重置 heading 计数
  counter(heading).update(0)

  // 通过插入假段落修复[章节第一段不缩进问题](https://github.com/typst/typst/issues/311)
  show heading.where(level: 1): it => {
    it
    fake-par
  }

  context appendix-content.final()
}
